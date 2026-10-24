#!/usr/bin/env bash
# Deterministically minimize low-signal PR comments/reviews.
# Usage: minimise.sh [owner] [repo] [pr-number] [--apply]
#   Any of owner/repo/pr-number can be omitted to use the current repo/PR (via gh).
#   Without --apply: prints the classification table only (dry run).
#   With --apply: also minimizes everything classified "minimize".
#   MINIMISE_KEEP_IDS: comma-separated subject IDs that are never minimized (always kept).
set -euo pipefail

apply=false
keepids=${MINIMISE_KEEP_IDS:-}
args=()
for a in "$@"; do [ "$a" = --apply ] && apply=true || args+=("$a"); done

owner=${args[0]:-} repo=${args[1]:-} pr=${args[2]:-}
if [ -z "$owner" ] || [ -z "$repo" ]; then
  read -r owner repo < <(gh repo view --json owner,name -q '.owner.login+" "+.name')
fi
[ -z "$pr" ] && pr=$(gh pr view --json number -q .number)

data=$(gh api graphql -f query='
query($owner:String!,$repo:String!,$pr:Int!){
  repository(owner:$owner,name:$repo){ pullRequest(number:$pr){
    author{login}
    comments(first:100){nodes{id author{__typename login} body isMinimized}}
    reviews(first:100){nodes{id author{__typename login} body isMinimized submittedAt
      comments(first:50){nodes{id author{__typename login} body isMinimized}}}}
    reviewThreads(first:100){nodes{comments(first:50){nodes{id author{__typename login} body isMinimized}}}}
  }}}' -f owner="$owner" -f repo="$repo" -F pr="$pr")

author=$(jq -r '.data.repository.pullRequest.author.login' <<<"$data")

# Bots whose comments are deploy/preview notifications — always keep.
# GraphQL Bot.login omits the "[bot]" suffix (REST includes it) — match both forms.
keepbots='^(github-actions|vercel|netlify|cloudflare-workers-and-pages)(\[bot\])?$'
# PR-author bodies that count as verification / explainer, not self-chatter.
# `manual verification` stays for older and hand-written comments.
# `!\[` covers comments that embed evidence images even when they never say
# "screenshot" (e.g. a grid of before/after captures with prose captions).
keepauthor='(live verification|manual verification|verified in (nonprod|prod)|tested in (nonprod|prod)|screenshot|!\[|autofix report|review guide|for reviewers|call graph|feedback points|handover|^#+ ?Plan|^#+ ?Impact analysis|^#+ .*(autofix|implementation notes|handover))'

rows=$(jq -r --arg author "$author" --arg keepbots "$keepbots" --arg keepauthor "$keepauthor" --arg keepids "$keepids" '
  .data.repository.pullRequest as $pr

  # Only the most recently *submitted* Copilot review survives; id of that review.
  | ($pr.reviews.nodes | map(select(.author.login=="copilot-pull-request-reviewer")) | (max_by(.submittedAt) // {}).id) as $latest

  # IDs that must never be minimized (MINIMISE_KEEP_IDS, comma-separated).
  | ($keepids | split(",") | map(select(length>0))) as $keepids_list

  # All inline comments already covered by the reviews connection (dedupe against these).
  | ([ $pr.reviews.nodes[].comments.nodes[].id ]) as $revids

  # Classify a single comment or review node (not its inline children).
  | def vd(n):
      if n.isMinimized then {v:"skip",r:"already minimized"}
      elif ($keepids_list | index(n.id)) != null then {v:"keep",r:"kept by keep-ids"}
      elif n.author.login=="copilot-pull-request-reviewer" then
        (if n.id==$latest then {v:"keep",r:"latest Copilot review"} else {v:"minimize",r:"superseded Copilot review"} end)
      elif n.author.__typename=="Bot" and (n.author.login|test($keepbots)) then {v:"keep",r:"deploy/preview bot"}
      elif n.author.__typename=="Bot" then {v:"minimize",r:"admin bot noise"}
      elif n.author.login==$author then
        # only fuzzy branch: keyword allowlist stands in for judgement on the authors own words
        (if (n.body // ""|test($keepauthor;"i")) then {v:"keep",r:"author explainer/verification"} else {v:"minimize",r:"author self-comment"} end)
      else {v:"keep",r:"real reviewer feedback"}
      end;

  [ $pr.comments.nodes[] | . as $n | vd($n) as $x | [$n.id,"comment",$x.v,$x.r] ]
  + [ $pr.reviews.nodes[] | . as $rev | vd($rev) as $x |
        ( [$rev.id,"review",$x.v,$x.r],
          # inline PullRequestReviewComments have their own isMinimized flag and are NOT
          # cascaded when the parent review is minimized — so each
          # one must inherit the review verdict and get its own mutation call.
          # Keep-ids protect the exact listed nodes, inline or top-level. Other inline
          # comments are classified on their own merits (Copilot inlines follow their
          # parent review recency).
          ($rev.comments.nodes[] | . as $c |
            (if $c.isMinimized then {v:"skip",r:"already minimized"}
             elif ($keepids_list | index($c.id)) != null then {v:"keep",r:"kept by keep-ids"}
             elif $rev.author.login=="copilot-pull-request-reviewer" then
               (if $rev.id==$latest then {v:"keep",r:"latest Copilot review inline"} else {v:"minimize",r:"superseded Copilot review inline"} end)
             else vd($c) end) as $cv
            | [$c.id,"review-comment",$cv.v,("inherits: "+$cv.r)]) ) ]
  # Thread replies can exist outside any review (e.g. direct thread replies) — classify
  # those too, deduped against the reviews-connection comments above.
  + [ $pr.reviewThreads.nodes[].comments.nodes[] | . as $c | select(($revids | index($c.id)) | not) | vd($c) as $cx | [$c.id,"thread-comment",$cx.v,$cx.r] ]
  | .[] | @tsv' <<<"$data")

echo "$rows" | column -t -s$'\t'

if ! $apply; then
  echo
  echo "Dry run — pass --apply to minimize the rows above marked 'minimize'."
  exit 0
fi

while IFS=$'\t' read -r id kind verdict reason; do
  [ "$verdict" = minimize ] || continue
  gh api graphql -f query='mutation($id:ID!){minimizeComment(input:{subjectId:$id,classifier:OUTDATED}){minimizedComment{isMinimized}}}' -f id="$id" >/dev/null
done <<<"$rows"

#!/usr/bin/env bash

print_status() {
  local icon="$1" title="$2" desc="${3:-}"
  echo
  if [[ -n "$desc" ]]; then
    printf -- "· %s ${BOLD}%s${RESET} · ${GRAY}%s${RESET}\n" "$icon" "$title" "$desc"
  else
    printf -- "· %s ${BOLD}%s ${RESET}\n" "$icon" "$title"
  fi
}

print_threads() {
  echo "$gql_data" | jq -r '
    .data.repository.pullRequest.reviewThreads.nodes[]
    | select(.isResolved == false)
    | .comments.nodes[0]
    | "  \(.author.login // "unknown") · \(.path):\(.line // .originalLine // "?")\n  > \(.body | gsub("\n"; "\n  > "))"
  ' 2>/dev/null || true
}

header() {
  echo "${BOLD}$1${RESET}"
  printf -- '=%.0s' $(seq 1 ${#1})
  echo
}

print_body() {
  echo "${GREEN}~~~~~~~~~~${RESET}${GRAY}"
  echo "$1"
  echo "${GREEN}~~~~~~~~~~${RESET}"
}

print_comments() {
  echo "$PR_DATA" | jq -c '.comments[]' 2>/dev/null | while IFS= read -r c; do
    author=$(echo "$c" | jq -r '.author.login // "unknown"')
    created=$(echo "$c" | jq -r '.createdAt')
    echo "${GRAY}### ${author} · ${created}${RESET}"
    echo
    print_body "$(echo "$c" | jq -r '.body')"
    echo
  done || true
}

print_conflicts() {
  git fetch origin "$base_branch" "$branch" -q 2>/dev/null || return
  local out; out=$(git merge-tree --write-tree --name-only --no-messages "origin/$branch" "origin/$base_branch" 2>/dev/null)
  [[ $? -eq 1 ]] || return
  print_status "$FAIL" "Conflicts" "this branch has conflicts to resolve"
  echo "$out" | tail -n +2 | sed 's/^/  - /'
}

parse_args() {
  PR_NUMBER=""
  REPO_ARG=""
  VERBOSE=false
  COMMENTS=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --verbose|-v) VERBOSE=true ;;
      --comments) COMMENTS=true ;;
      --repo) [[ $# -ge 2 ]] || { echo "Error: --repo requires a value" >&2; exit 1; }
        case "$2" in
          -*|*/*/*|*/|/*) echo "Error: --repo must be owner/repo (exactly one slash), got '$2'" >&2; exit 1 ;;
          */*) ;;  # valid: owner/repo
          *) echo "Error: --repo must be in owner/repo format, got '$2'" >&2; exit 1 ;;
        esac
        REPO_ARG="$2"; shift ;;
      --pr)   [[ $# -ge 2 ]] || { echo "Error: --pr requires a value" >&2; exit 1; }
        [[ "$2" != -* ]] || { echo "Error: --pr requires a PR number, got '$2'" >&2; exit 1; }
        PR_NUMBER="$2"; shift ;;
      -*) echo "Error: unknown option '$1'" >&2; exit 1 ;;
      *) PR_NUMBER="$1" ;;
    esac
    shift
  done
  if [[ -n "$REPO_ARG" && -z "$PR_NUMBER" ]]; then
    echo "Error: a PR number is required when --repo is set" >&2
    exit 1
  fi
}

setup_colors() {
  if [[ -z "${NO_COLOR:-}" && -z "${CLAUDECODE:-}" ]]; then
    GREEN=$'\033[32m'
    GRAY=$'\033[37m'
    YELLOW=$'\033[33m'
    RED=$'\033[31m'
    ORANGE=$'\033[38;5;214m'
    BLUE=$'\033[34m'
    BOLD=$'\033[1m'
    RESET=$'\033[0m'
    LINK_START=$'\033]8;;'
    LINK_MID=$'\033\\'
    LINK_END=$'\033]8;;\033\\'
  else
    GREEN='' GRAY='' YELLOW='' RED='' ORANGE='' BLUE='' BOLD='' RESET=''
    LINK_START='<' LINK_MID='> ' LINK_END=''
  fi
  OK="${GREEN}󰄬${RESET}"
  WARN="${YELLOW}󰀦${RESET}"
  FAIL="${RED}󰜺${RESET}"
  PENDING="${ORANGE}󰏤${RESET}"
  INFO="${BLUE}󰋼${RESET}"
}

fetch_pr_data() {
  local -a repo_flag=()
  local -a pr_arg=()
  [[ -n "$REPO_ARG" ]] && repo_flag=(--repo "$REPO_ARG")
  [[ -n "$PR_NUMBER" ]] && pr_arg=("$PR_NUMBER")

  PR_DATA=$(gh pr view ${repo_flag[@]+"${repo_flag[@]}"} ${pr_arg[@]+"${pr_arg[@]}"} \
    --json number,title,state,url,comments,mergeable,mergeStateStatus,isDraft,\
headRefName,baseRefName,reviewDecision,body,additions,deletions,\
author,createdAt,latestReviews,reviewRequests \
    2>/dev/null) || {
    if [[ -n "$REPO_ARG" ]]; then
      echo "PR #${PR_NUMBER} not found in ${REPO_ARG}." >&2
    elif [[ -n "$PR_NUMBER" ]]; then
      echo "PR #${PR_NUMBER} not found." >&2
    else
      echo "No PR found for current branch." >&2
    fi
    return 1
  }

  number=$(echo "$PR_DATA"          | jq -r '.number')
  title=$(echo "$PR_DATA"           | jq -r '.title')
  state=$(echo "$PR_DATA"           | jq -r '.state')
  url=$(echo "$PR_DATA"             | jq -r '.url')
  branch=$(echo "$PR_DATA"          | jq -r '.headRefName')
  base_branch=$(echo "$PR_DATA"     | jq -r '.baseRefName')
  mergeable=$(echo "$PR_DATA"       | jq -r '.mergeable')
  merge_state=$(echo "$PR_DATA"     | jq -r '.mergeStateStatus')
  review_decision=$(echo "$PR_DATA" | jq -r '.reviewDecision')
  body=$(echo "$PR_DATA"            | jq -r '.body')
  additions=$(echo "$PR_DATA"       | jq -r '.additions')
  deletions=$(echo "$PR_DATA"       | jq -r '.deletions')
  is_draft=$(echo "$PR_DATA"        | jq -r '.isDraft')
  author_login=$(echo "$PR_DATA"    | jq -r '.author.login // "unknown"')
  created_at=$(echo "$PR_DATA"      | jq -r '.createdAt // ""')
  [[ "$is_draft" == "true" ]] && state="DRAFT"
  return 0
}

fetch_repo_nwo() {
  if [[ -n "$REPO_ARG" ]]; then
    REPO_NWO="$REPO_ARG"
  else
    REPO_NWO="$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null)" || true
  fi
  if [[ -z "$REPO_NWO" ]]; then
    echo "Error: could not determine repository owner/name." >&2
    return 1
  fi
  OWNER="${REPO_NWO%/*}"
  REPO="${REPO_NWO#*/}"
}

fetch_graphql() {
  gql_data=$(gh api graphql \
    -f query='query($owner: String!, $repo: String!, $number: Int!) {
      repository(owner: $owner, name: $repo) {
        pullRequest(number: $number) {
          headRefOid
          reviewThreads(first: 100) {
            nodes {
              id
              isResolved
              comments(first: 50) {
                nodes {
                  databaseId
                  body
                  path
                  line
                  originalLine
                  author { login }
                }
              }
            }
          }
          mergeQueueEntry {
            position
            state
          }
          reviewRequests(first: 20) {
            nodes {
              requestedReviewer {
                __typename
                ... on Bot { login }
              }
            }
          }
          reviews(first: 100, states: [APPROVED, CHANGES_REQUESTED, COMMENTED, DISMISSED]) {
            nodes {
              author { login }
              state
              submittedAt
              commit { oid }
              isMinimized
            }
            pageInfo { hasNextPage endCursor }
          }
        }
      }
    }' \
    -F owner="$OWNER" -F repo="$REPO" -F number="$number" \
    2>/dev/null || echo '{}')

  unresolved=$(echo "$gql_data" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length' 2>/dev/null || echo 0)
  mq_state=$(echo "$gql_data"  | jq -r '.data.repository.pullRequest.mergeQueueEntry.state // empty' 2>/dev/null || true)
  mq_pos=$(echo "$gql_data"    | jq -r '.data.repository.pullRequest.mergeQueueEntry.position // empty' 2>/dev/null || true)

  # Copilot review status
  copilot_pending=$(echo "$gql_data" | jq -r '
    [.data.repository.pullRequest.reviewRequests.nodes[]?.requestedReviewer
     | select(.login == "copilot-pull-request-reviewer")] | length > 0
  ' 2>/dev/null || echo false)

  head_oid=$(echo "$gql_data" | jq -r '.data.repository.pullRequest.headRefOid // ""' 2>/dev/null)

  copilot_review=$(echo "$gql_data" | jq -c '
    .data.repository.pullRequest.reviews.nodes
    | map(select(.author.login == "copilot-pull-request-reviewer" and .isMinimized == false and .state != "DISMISSED"))
    | sort_by(.submittedAt) | last // empty
    # ponytail: reviews() returns ascending by submittedAt; sort explicitly so we do not depend on that default
  ' 2>/dev/null)

  if [[ -n "$copilot_review" && "$copilot_review" != "null" ]]; then
    copilot_state=$(echo "$copilot_review" | jq -r '.state // ""')
    review_oid=$(echo "$copilot_review" | jq -r '.commit.oid // ""')
    if [[ "$review_oid" != "$head_oid" ]]; then
      copilot_stale=true
    else
      copilot_stale=false
    fi
  else
    copilot_state=""
    copilot_stale=false
  fi
}

print_copilot_status() {
  if [[ "$copilot_pending" == "true" ]]; then
    print_status "$PENDING" "Copilot pending" "Copilot is reviewing this pull request"
  elif [[ "$copilot_stale" == "true" ]]; then
    print_status "$INFO" "Copilot outdated" "reviewed an older commit"
  elif [[ -n "$copilot_state" ]]; then
    case "$copilot_state" in
      APPROVED)          print_status "$OK"   "Copilot approved" ;;
      CHANGES_REQUESTED) print_status "$FAIL" "Copilot changes requested" ;;
      COMMENTED)         print_status "$OK"   "Copilot reviewed" ;;
    esac
  else
    print_status "$INFO" "No Copilot review requested"
  fi
}

relative_time() {
  [[ -z "$1" ]] && { echo "unknown"; return; }
  local input="${1%Z}"      # strip trailing Z
  input="${input%%.*}Z"     # strip fractional seconds, re-add Z
  local then
  if date --version &>/dev/null; then
    then=$(date -d "$input" +%s 2>/dev/null)
  else
    then=$(TZ=UTC0 date -j -f "%Y-%m-%dT%H:%M:%SZ" "$input" +%s 2>/dev/null)
  fi
  [[ -z "$then" ]] && { echo "unknown"; return; }
  local now; now=$(date +%s)
  local diff=$(( now - then ))
  local n="" s=""
  [[ $diff -le 0 ]] && { echo "just now"; return; }  # clock skew or future timestamp
  if   [[ $diff -lt 60 ]]; then          echo "just now"
  elif [[ $diff -lt 3600 ]]; then        n=$(( diff / 60 )); s="min";
  elif [[ $diff -lt 86400 ]]; then       n=$(( diff / 3600 )); s="hr";
  elif [[ $diff -lt 604800 ]]; then      n=$(( diff / 86400 )); s="day";
  elif [[ $diff -lt 2592000 ]]; then     n=$(( diff / 604800 )); s="wk";
  else                                   n=$(( diff / 2592000 )); s="mo"
  fi
  [[ -n "$n" ]] && { [[ $n -eq 1 ]] && echo "$n $s ago" || echo "${n} ${s}s ago"; }
}

print_author_info() {
  local when; when=$(relative_time "$created_at")
  printf -- "█  %s ${GRAY}opened %s${RESET}\n" "$author_login" "$when"
}

print_reviewers() {
  local approved changes pending summary_icon summary_text

  # Fields joined on ASCII unit separator (0x1F), not tab -- bash `read`
  # strips/collapses leading and repeated IFS *whitespace* runs (tab
  # counts), which silently shifts empty fields into the wrong variable
  # whenever one is empty (the common case, e.g. no approvals yet).
  IFS=$'\x1f' read -r approved changes pending < <(echo "$PR_DATA" | jq -r --arg sep $'\x1f' '
    [.latestReviews[]? | select(.state == "APPROVED" or .state == "CHANGES_REQUESTED") | .author.login] as $reviewed
    | ([.latestReviews[]? | select(.state == "APPROVED") | .author.login // "unknown"] | join(", ")) as $a
    | ([.latestReviews[]? | select(.state == "CHANGES_REQUESTED") | .author.login // "unknown"] | join(", ")) as $c
    | ([.reviewRequests[]? | (.login // .slug // .name) // empty] - $reviewed | join(", ")) as $p
    | [$a, $c, $p] | join($sep)
  ' 2>/dev/null)

  # Summary line (worst-first)
  if [[ -n "$changes" ]]; then
    print_status "$FAIL" "Changes requested" "changes have been requested by reviewers"
  elif [[ "$review_decision" == "REVIEW_REQUIRED" ]]; then
    print_status "$FAIL" "Review required" "approvals required to merge"
  elif [[ -n "$approved" ]]; then
    print_status "$OK" "Approved" "reviewers have approved this PR"
  elif [[ -n "$pending" ]]; then
    print_status "$PENDING" "Awaiting reviews"
  else
    return  # no review requirement at all — omit section
  fi

  # Always show indented groups for each non-empty status
  [[ -n "$approved" ]] && printf -- "  %s %s\n" "$OK" "approved: $approved"
  [[ -n "$changes" ]] && printf -- "  %s %s\n" "$FAIL" "requested changes: $changes"
  [[ -n "$pending" ]] && printf -- "  %s %s\n" "$PENDING" "waiting for: $pending"
}

print_ci_status() {
  local -a repo_flag=()
  [[ -n "$REPO_ARG" ]] && repo_flag=(--repo "$REPO_ARG")
  ci_checks=$({ gh pr checks ${repo_flag[@]+"${repo_flag[@]}"} "$number" 2>/dev/null || true; })

  if echo "$ci_checks" | grep -q $'^[^\t]*\tfail\t'; then
    print_status "$FAIL" "CI failing"
    echo "$ci_checks" | tr $'\t' $'\x1f' | while IFS=$'\x1f' read -r name status duration url_check; do
      [[ "$(echo "$status" | xargs)" == "fail" ]] && echo "  - $(echo "$name" | xargs)"
    done
  elif echo "$ci_checks" | grep -q $'^[^\t]*\tpending\t'; then
    pending_count=$(echo "$ci_checks" | grep -c $'^[^\t]*\tpending\t' || true)
    print_status "$PENDING" "CI pending" "${pending_count} checks in progress"
  else
    print_status "$OK" "CI passing"
  fi
}

print_merge_status() {
  if [[ "$state" == "MERGED" ]]; then
    print_status "$OK" "Merged"

  elif [[ -n "$mq_state" ]]; then
    case "$mq_state" in
      QUEUED)          mq_desc="queued" ;;
      AWAITING_CHECKS) mq_desc="running checks" ;;
      MERGEABLE)       mq_desc="ready to merge" ;;
      UNMERGEABLE)     mq_desc="blocked, won't merge" ;;
      LOCKED)          mq_desc="locked" ;;
      *)               mq_desc="$mq_state" ;;
    esac
    print_status "$PENDING" "Queued to merge" "${mq_desc}${mq_pos:+, position ${mq_pos}}"

  else
    # reviewDecision is covered by print_reviewers above;
    # merge_status only assesses mergeability.
    case "$merge_state" in
      BEHIND)   print_status "$FAIL" "Out of date"     "branch is behind the base branch and needs to be updated" ;;
      BLOCKED)  print_status "$FAIL" "Blocked"         "required reviews or checks are not satisfied" ;;
      DIRTY)    print_status "$FAIL" "Dirty"           "branch has conflicts that must be resolved" ;;
      UNKNOWN)  print_status "$FAIL" "Unknown"         "merge state not available" ;;
      UNSTABLE) print_status "$OK"   "Mergeable"       "with non-passing checks" ;;
      *) # CLEAN DRAFT HAS_HOOKS
        case "$mergeable" in
          CONFLICTING) print_status "$FAIL" "Merge conflicts" "branch has conflicts with the base branch" ;;
          MERGEABLE)   print_status "$OK"   "Mergeable"       "ready to merge" ;;
          UNKNOWN)     print_status "$WARN" "Unknown"         "status not available" ;;
        esac
        ;;
    esac

    # Check if branch is behind base independently of merge_state (which may be BLOCKED)
    if [[ -z "$REPO_ARG" ]]; then
      behind=$(git fetch origin "$base_branch" "$branch" -q 2>/dev/null && \
        git rev-list --count "origin/$branch"..origin/"$base_branch" 2>/dev/null || echo 0)
      if [[ "$behind" -gt 0 ]]; then
        print_status "$WARN" "Out of date" "branch is ${behind} commit(s) behind ${base_branch}"
      fi
      print_conflicts
    fi

    print_copilot_status

    if [[ "$unresolved" -gt 0 ]]; then
      print_status "$WARN" "${unresolved} unresolved threads"
      print_threads
    fi

    print_ci_status
  fi
}

main() {
  parse_args "$@"
  setup_colors
  fetch_pr_data || exit 1
  fetch_repo_nwo || exit 1
  fetch_graphql
  # Title header (three echo lines, inline — too small to abstract)
  echo
  echo "█  ${BOLD}$title${RESET}"
  echo "█  ${GRAY}${LINK_START}${url}${LINK_MID}#${number}${LINK_END}${GRAY} · ${RESET}${GREEN} ${state}${RESET}${GRAY} · ${GREEN}+${additions}${GRAY} ${RED}-${deletions}${RESET}${GRAY} · 󰘬  ${branch}${RESET}"
  print_author_info
  print_reviewers
  print_merge_status
  # verbose + comments
  if [[ "$VERBOSE" == true ]]; then
    header "PR description"
    echo
    print_body "$body"
    echo
  fi
  if [[ "$COMMENTS" == true ]]; then
    comments_count=$(echo "$PR_DATA" | jq '.comments | length' 2>/dev/null || echo 0)
    if [[ "$comments_count" -gt 0 ]]; then
      header "Comments (${comments_count})"
      echo
      print_comments
    fi
  fi
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi

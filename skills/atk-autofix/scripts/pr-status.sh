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
    -f query='query($owner: String!, $repo: String!, $number: Int!, $configYaml: String!, $configYml: String!) {
      repository(owner: $owner, name: $repo) {
        codeRabbitYaml: object(expression: $configYaml) { __typename }
        codeRabbitYml: object(expression: $configYml) { __typename }
        pullRequest(number: $number) {
          headRefOid
          reviewThreads(first: 100) {
            pageInfo { hasNextPage }
            nodes {
              id
              isResolved
              comments(first: 50) {
                pageInfo { hasNextPage }
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
          reviewRequests(first: 100) {
            pageInfo { hasNextPage }
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
              body
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
    -f configYaml="${base_branch}:.coderabbit.yaml" -f configYml="${base_branch}:.coderabbit.yml" \
    2>/dev/null) || gql_data=''

  gql_complete=true
  gql_problem=""
  if ! echo "$gql_data" | jq -e '
    (.errors // [] | length == 0) and
    (.data.repository.pullRequest as $pr |
      ($pr.headRefOid | type == "string" and length > 0) and
      ($pr.reviewThreads.nodes | type == "array") and
      ($pr.reviews.nodes | type == "array") and
      ($pr.reviewRequests.nodes | type == "array") and
      ($pr.reviewThreads.pageInfo.hasNextPage | type == "boolean") and
      ($pr.reviews.pageInfo.hasNextPage | type == "boolean") and
      ($pr.reviewRequests.pageInfo.hasNextPage | type == "boolean") and
      ([$pr.reviewThreads.nodes[] | .comments.pageInfo.hasNextPage | type == "boolean"] | all))
  ' >/dev/null 2>&1; then
    gql_complete=false
    gql_problem="GitHub GraphQL data unavailable or incomplete"
  elif echo "$gql_data" | jq -e '
    .data.repository.pullRequest |
    .reviewThreads.pageInfo.hasNextPage or .reviews.pageInfo.hasNextPage or
    .reviewRequests.pageInfo.hasNextPage or
    any(.reviewThreads.nodes[]; .comments.pageInfo.hasNextPage)
  ' >/dev/null; then
    gql_complete=false
    gql_problem="GitHub GraphQL results truncated by pagination"
  fi

  unresolved=$(echo "$gql_data" | jq '[.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved == false)] | length' 2>/dev/null || echo 0)
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

  # atk-code-review verdict — read from review bodies, not a Copilot state
  atk_review=$(echo "$gql_data" | jq -c '
    .data.repository.pullRequest.reviews.nodes
    | map(select(.isMinimized == false
        and .state != "DISMISSED"
        and .author.login != "copilot-pull-request-reviewer"
        and (.body // "" | contains("_🤖 automated agent (atk-code-review)_"))))
    | sort_by(.submittedAt) | last // empty
  ' 2>/dev/null)

  if [[ -n "$atk_review" && "$atk_review" != "null" ]]; then
    atk_review_oid=$(echo "$atk_review" | jq -r '.commit.oid // ""')
    if [[ "$atk_review_oid" != "$head_oid" ]]; then
      atk_stale=true
    else
      atk_stale=false
    fi
    atk_verdict=$(echo "$atk_review" | jq -r '
      (.body // "") | split("\n") | map(select(startswith("### "))) | first // ""
      | if . == "### 🟢 Approval recommended" then "🟢 Approval recommended"
        elif . == "### 🔵 Needs a closer look" then "🔵 Needs a closer look"
        elif . == "### 🟡 Changes recommended" then "🟡 Changes recommended"
        else "reviewed" end
    ')
  else
    atk_stale=false
    atk_verdict=""
  fi

  coderabbit_review=$(echo "$gql_data" | jq -c '
    [.data.repository.pullRequest.reviews.nodes[]?
     | select((.author.login // "" | ascii_downcase) | IN("coderabbitai", "coderabbitai[bot]", "coderabbit[bot]"))
     | select(.isMinimized == false and .state != "DISMISSED")]
    | sort_by(.submittedAt) | last // empty
  ' 2>/dev/null)
  coderabbit_pending=$(echo "$gql_data" | jq -r '
    [.data.repository.pullRequest.reviewRequests.nodes[]?.requestedReviewer
     | select((.login // "" | ascii_downcase) | IN("coderabbitai", "coderabbitai[bot]", "coderabbit[bot]"))] | length > 0
  ' 2>/dev/null)
  coderabbit_config=$(echo "$gql_data" | jq -r '
    .data.repository | (.codeRabbitYaml != null or .codeRabbitYml != null)
  ' 2>/dev/null)
}

print_copilot_status() {
  if [[ "$gql_complete" != "true" ]]; then
    print_status "$WARN" "Copilot unknown" "$gql_problem"
  elif [[ "$copilot_pending" == "true" ]]; then
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

print_atk_review_status() {
  if [[ "$gql_complete" != "true" ]]; then
    print_status "$WARN" "atk-code-review unknown" "$gql_problem"
  elif [[ "$atk_stale" == "true" ]]; then
    print_status "$INFO" "atk-code-review outdated" "verdict is for an older commit"
  elif [[ -n "$atk_verdict" ]]; then
    case "$atk_verdict" in
      "🟢 Approval recommended") print_status "$OK"   "atk-code-review: 🟢 Approval recommended" ;;
      "🟡 Changes recommended")  print_status "$FAIL" "atk-code-review: 🟡 Changes recommended" ;;
      "🔵 Needs a closer look")  print_status "$WARN" "atk-code-review: 🔵 Needs a closer look" ;;
      *)                         print_status "$INFO" "atk-code-review: reviewed" ;;
    esac
  else
    print_status "$INFO" "No atk-code-review review"
  fi
}

print_coderabbit_status() {
  local review_oid review_state review_time rate_limited processing check_pending check_failed
  review_oid=$(echo "$coderabbit_review" | jq -r '.commit.oid // ""' 2>/dev/null)
  review_state=$(echo "$coderabbit_review" | jq -r '.state // ""' 2>/dev/null)
  review_time=$(echo "$coderabbit_review" | jq -r '.submittedAt // ""' 2>/dev/null)
  check_failed=false
  rate_limited=$(echo "$PR_DATA" | jq -r --arg after "$review_time" '
    [.comments[]? | select((.author.login // "" | ascii_downcase) | IN("coderabbitai", "coderabbitai[bot]", "coderabbit[bot]"))
     | select((.createdAt // "") >= $after)
     | select((.body // "" | ascii_downcase) | test("rate.limit|too many requests"))]
    | length > 0
  ' 2>/dev/null)
  processing=$(echo "$PR_DATA" | jq -r --arg after "$review_time" '
    [.comments[]? | select((.author.login // "" | ascii_downcase) | IN("coderabbitai", "coderabbitai[bot]", "coderabbit[bot]"))
     | select((.updatedAt // .createdAt // "") >= $after)]
    | sort_by(.updatedAt // .createdAt) | last // {}
    | (.body // "" | ascii_downcase | test("currently processing new changes|come back again in a few minutes"))
  ' 2>/dev/null)
  if echo "$coderabbit_review" | jq -e '(.body // "" | ascii_downcase) | test("rate.limit|too many requests")' >/dev/null 2>&1; then
    rate_limited=true
  fi
  check_pending=false
  if echo "$ci_checks" | grep -i -q $'^coderabbit[^\t]*\tpending\t'; then
    check_pending=true
  fi
  if echo "$ci_checks" | grep -i -q $'^coderabbit[^\t]*\tfail\t'; then
    check_failed=true
  fi

  if [[ "$gql_complete" != "true" ]]; then
    print_status "$WARN" "CodeRabbit unknown" "$gql_problem"
  elif [[ "$rate_limited" == "true" ]]; then
    print_status "$WARN" "CodeRabbit rate-limited" "review may not be complete"
  elif [[ "$coderabbit_pending" == "true" || "$check_pending" == "true" || "$processing" == "true" ]]; then
    print_status "$PENDING" "CodeRabbit pending" "review requested or check in progress"
  elif [[ "$checks_available" != "true" || "$check_failed" == "true" ]]; then
    print_status "$WARN" "CodeRabbit unknown" "checks unavailable or CodeRabbit check failed"
  elif [[ -n "$coderabbit_review" && -z "$review_oid" ]]; then
    print_status "$WARN" "CodeRabbit unknown" "review commit unavailable"
  elif [[ -n "$coderabbit_review" && "$review_oid" != "$head_oid" ]]; then
    print_status "$WARN" "CodeRabbit stale" "reviewed an older commit"
  elif [[ "$review_state" == "CHANGES_REQUESTED" ]]; then
    print_status "$FAIL" "CodeRabbit changes requested"
  elif [[ -n "$coderabbit_review" ]]; then
    print_status "$INFO" "CodeRabbit reviewed" "inspect review body and threads for findings"
  elif [[ "$coderabbit_config" == "true" ]]; then
    print_status "$WARN" "CodeRabbit unknown" "repository config exists; no active review found"
  else
    print_status "$WARN" "CodeRabbit unknown" "no current review found; enablement not established"
  fi
  echo "$gql_data" | jq -r '
    .data.repository.pullRequest.reviews.nodes[]?
    | select((.author.login // "" | ascii_downcase) | IN("coderabbitai", "coderabbitai[bot]", "coderabbit[bot]"))
    | select(.isMinimized == false and (.body // "" | length > 0))
    | "\n  CodeRabbit review body (\(.submittedAt // "unknown date"), \(.state)):\n\(.body)"
  ' 2>/dev/null || true
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

fetch_checks() {
  local -a repo_flag=()
  local checks_exit=0
  [[ -n "$REPO_ARG" ]] && repo_flag=(--repo "$REPO_ARG")
  ci_checks=$(gh pr checks ${repo_flag[@]+"${repo_flag[@]}"} "$number" 2>/dev/null) || checks_exit=$?
  checks_available=true
  if [[ -z "$ci_checks" || ( "$checks_exit" -ne 0 && "$checks_exit" -ne 1 && "$checks_exit" -ne 8 ) ]]; then
    checks_available=false
  fi
}

print_ci_status() {

  if echo "$ci_checks" | grep -q $'^[^\t]*\tfail\t'; then
    print_status "$FAIL" "CI failing"
    echo "$ci_checks" | tr $'\t' $'\x1f' | while IFS=$'\x1f' read -r name status duration url_check; do
      [[ "$(echo "$status" | xargs)" == "fail" ]] && echo "  - $(echo "$name" | xargs)"
    done
  elif echo "$ci_checks" | grep -q $'^[^\t]*\tpending\t'; then
    pending_count=$(echo "$ci_checks" | grep -c $'^[^\t]*\tpending\t' || true)
    print_status "$PENDING" "CI pending" "${pending_count} checks in progress"
  elif [[ "$checks_available" != "true" ]]; then
    print_status "$WARN" "CI unknown" "checks unavailable or no checks reported"
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
    print_coderabbit_status
    print_atk_review_status

    if [[ "$gql_complete" != "true" ]]; then
      print_status "$WARN" "Review threads unknown" "$gql_problem"
      if [[ "$unresolved" -gt 0 ]]; then
        print_status "$WARN" "At least ${unresolved} unresolved threads"
        print_threads
      fi
    elif [[ "$unresolved" -gt 0 ]]; then
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
  fetch_checks
  # Title header (three echo lines, inline — too small to abstract)
  echo
  echo "█  ${BOLD}$title${RESET}"
  echo "█  ${GRAY}${LINK_START}${url}${LINK_MID}#${number}${LINK_END}${GRAY} · ${RESET}${GREEN} ${state}${RESET}${GRAY} · ${GREEN}+${additions}${GRAY} ${RED}-${deletions}${RESET}${GRAY} · 󰘬  ${branch}${RESET}"
  print_author_info
  print_reviewers
  print_merge_status
  if [[ "$state" == "MERGED" || -n "$mq_state" ]]; then
    print_coderabbit_status
    if [[ "$gql_complete" != "true" ]]; then
      print_status "$WARN" "Review threads unknown" "$gql_problem"
    fi
  fi
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

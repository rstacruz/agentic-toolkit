#!/usr/bin/env bash
set -euo pipefail

PR_NUMBER=""
VERBOSE=false

for arg in "$@"; do
  case "$arg" in
    --verbose|-v) VERBOSE=true ;;
    *) PR_NUMBER="$arg" ;;
  esac
done

if [[ -z "${NO_COLOR:-}" && -z "${CLAUDECODE:-}" ]]; then
  GREEN=$'\033[32m'
  GRAY=$'\033[37m'
  YELLOW=$'\033[33m'
  RED=$'\033[31m'
  ORANGE=$'\033[38;5;214m'
  BOLD=$'\033[1m'
  RESET=$'\033[0m'
else
  GREEN='' GRAY='' YELLOW='' RED='' ORANGE='' BOLD='' RESET=''
fi
OK="${GREEN}󰄬${RESET}"
WARN="${YELLOW}󰀦${RESET}"
FAIL="${RED}󰀦${RESET}"
PENDING="${ORANGE}󰏤${RESET}"

# Resolve PR number from current branch if not given
if [[ -z "$PR_NUMBER" ]]; then
  PR_DATA=$(gh pr view --json number,title,state,url,comments,mergeable,mergeStateStatus,isDraft,headRefName,baseRefName,reviewDecision,body,additions,deletions 2>/dev/null) || {
    echo "No PR found for current branch." >&2
    exit 1
  }
else
  PR_DATA=$(gh pr view "$PR_NUMBER" --json number,title,state,url,comments,mergeable,mergeStateStatus,isDraft,headRefName,baseRefName,reviewDecision,body,additions,deletions 2>/dev/null) || {
    echo "PR #$PR_NUMBER not found." >&2
    exit 1
  }
fi

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
[[ "$is_draft" == "true" ]] && state="DRAFT"

print_status() {
  local icon="$1" title="$2" desc="${3:-}"
  if [[ -n "$desc" ]]; then
    printf -- "- %s ${BOLD}%s${RESET} · ${GRAY}%s${RESET}\n" "$icon" "$title" "$desc"
  else
    printf -- "- %s ${BOLD}%s${RESET}\n" "$icon" "$title"
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

print_conflict_files() {
  git fetch origin "$base_branch" "$branch" -q 2>/dev/null || return
  local base; base=$(git merge-base "origin/$base_branch" "origin/$branch" 2>/dev/null) || return
  git merge-tree "$base" "origin/$base_branch" "origin/$branch" 2>/dev/null \
    | awk '/^changed in both/{getline; print "  - " $NF}'
}

REPO_NWO="$(gh repo view --json nameWithOwner -q .nameWithOwner)"
OWNER="${REPO_NWO%/*}"
REPO="${REPO_NWO#*/}"

# Unresolved review threads + merge queue via GraphQL
gql_data=$(gh api graphql \
  -f query='query($owner: String!, $repo: String!, $number: Int!) {
    repository(owner: $owner, name: $repo) {
      pullRequest(number: $number) {
        reviewThreads(first: 100) {
          nodes {
            isResolved
            comments(first: 50) {
              nodes {
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
      }
    }
  }' \
  -F owner="$OWNER" -F repo="$REPO" -F number="$number" \
  2>/dev/null || echo '{}')

unresolved=$(echo "$gql_data" | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length' 2>/dev/null || echo 0)
mq_state=$(echo "$gql_data"  | jq -r '.data.repository.pullRequest.mergeQueueEntry.state // empty' 2>/dev/null || true)
mq_pos=$(echo "$gql_data"    | jq -r '.data.repository.pullRequest.mergeQueueEntry.position // empty' 2>/dev/null || true)

echo
echo "${BOLD}$title${RESET}"
printf "${GRAY}%0.s=${RESET}" $(seq 1 ${#title})
echo
echo

if [[ "$state" == "MERGED" ]]; then
  print_status "$OK" "Merged"

elif [[ -n "$mq_state" ]]; then
  print_status "$PENDING" "Merge queue" "${mq_state}${mq_pos:+ (position ${mq_pos})}"

else
  case "$review_decision" in
    REVIEW_REQUIRED)    print_status "$FAIL" "Review required"      "approving reviews are required" ;;
    CHANGES_REQUESTED)  print_status "$FAIL" "Changes requested"    "a reviewer has requested changes" ;;
    *) # APPROVED
      # https://docs.github.com/en/graphql/reference/pulls#enum-mergestatestatus
      case "$merge_state" in
        BEHIND)   print_status "$FAIL" "Out of date"     "branch is behind the base branch and needs to be updated" ;;
        BLOCKED)  print_status "$FAIL" "Blocked"         "required reviews or checks are not satisfied" ;;
        DIRTY)    print_status "$FAIL" "Dirty"           "branch has conflicts that must be resolved"; print_conflict_files ;;
        UNKNOWN)  print_status "$FAIL" "Unknown"         "merge state not available" ;;
        UNSTABLE) print_status "$OK"   "Mergeable"       "with non-passing checks" ;;
        *) # CLEAN DRAFT HAS_HOOKS
          case "$mergeable" in
            CONFLICTING) print_status "$FAIL" "Merge conflicts" "branch has conflicts with the base branch"; print_conflict_files ;;
            MERGEABLE)   print_status "$OK"   "Mergeable"       "ready to merge" ;;
            UNKNOWN)     print_status "$WARN" "Unknown"         "status not available" ;;
          esac
          ;;
      esac
  esac

  # Check if branch is behind base independently of merge_state (which may be BLOCKED)
  behind=$(git fetch origin "$base_branch" "$branch" -q 2>/dev/null && \
    git rev-list --count "origin/$branch"..origin/"$base_branch" 2>/dev/null || echo 0)
  if [[ "$behind" -gt 0 ]]; then
    print_status "$WARN" "Out of date" "branch is ${behind} commit(s) behind ${base_branch}"
  fi

  if [[ "$unresolved" -gt 0 ]]; then
    print_status "$WARN" "${unresolved} unresolved threads"
    print_threads
  fi

  ci_checks=$({ gh pr checks "$number" 2>/dev/null || true; })

  if echo "$ci_checks" | grep -q $'^[^\t]*\tfail\t'; then
    print_status "$FAIL" "CI failing"
    echo "$ci_checks" | while IFS=$'\t' read -r name status duration url_check; do
      [[ "$(echo "$status" | xargs)" == "fail" ]] && echo "  $(echo "$name" | xargs)"
    done
  elif echo "$ci_checks" | grep -q $'^[^\t]*\tpending\t'; then
    pending_count=$(echo "$ci_checks" | grep -c $'^[^\t]*\tpending\t' || true)
    print_status "$PENDING" "CI pending" "${pending_count} checks in progress"
  else
    print_status "$OK" "CI passing"
  fi
fi

echo
echo "${GRAY}> #${number} · ${state} · ${GREEN}+${additions}${GRAY} ${RED}-${deletions}${RESET}"
echo "${GRAY}> 󰘬  ${branch}${RESET}"
echo "${GRAY}> 󰊤  $url${RESET}"
echo

if [[ "$VERBOSE" == true ]]; then
  echo "${BOLD}PR description${RESET}"
  printf '%0.s=' $(seq 1 14)
  echo
  echo
  echo "${GRAY}~~~~~~~~~~"
  echo "$body"
  echo "~~~~~~~~~~${RESET}"
  echo
fi

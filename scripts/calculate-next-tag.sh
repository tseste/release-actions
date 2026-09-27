#!/usr/bin/env bash
set -euo pipefail

LATEST_TAG="${1:-$(git tag --list 'v*' --sort=-version:refname | head -n 1)}"
PR_TITLE="${2:-${PR_TITLE:-${GITHUB_EVENT_NAME:-}}}"

if [[ -z "$LATEST_TAG" ]]; then
  BASE_VERSION="0.1.0"
else
  BASE_VERSION="${LATEST_TAG#v}"
fi

IFS='.' read -r MAJOR MINOR PATCH <<< "$BASE_VERSION"
MAJOR=${MAJOR:-0}
MINOR=${MINOR:-0}
PATCH=${PATCH:-0}

if [[ "$PR_TITLE" =~ (^|[[:space:]])(feat|feature)(\(|:|!|$) ]]; then
  TYPE="minor"
elif [[ "$PR_TITLE" =~ (^|[[:space:]])fix(\(|:|!|$) ]]; then
  TYPE="patch"
elif [[ "$PR_TITLE" =~ (BREAKING[[:space:]]CHANGE|!:) ]]; then
  TYPE="major"
else
  TYPE="patch"
fi

case "$TYPE" in
  major)
    NEXT_MAJOR=$((MAJOR + 1))
    NEXT_MINOR=0
    NEXT_PATCH=0
    ;;
  minor)
    NEXT_MAJOR=$MAJOR
    NEXT_MINOR=$((MINOR + 1))
    NEXT_PATCH=0
    ;;
  patch)
    NEXT_MAJOR=$MAJOR
    NEXT_MINOR=$MINOR
    NEXT_PATCH=$((PATCH + 1))
    ;;
  *)
    echo "Unsupported bump type: $TYPE" >&2
    exit 1
    ;;
esac

NEXT_VERSION="v${NEXT_MAJOR}.${NEXT_MINOR}.${NEXT_PATCH}"
DEV_TAG="${NEXT_VERSION}-dev"
RC_TAG="${NEXT_VERSION}-rc"
FINAL_TAG="${NEXT_VERSION}"

printf '%s\n' "$DEV_TAG"
printf '%s\n' "$RC_TAG"
printf '%s\n' "$FINAL_TAG"

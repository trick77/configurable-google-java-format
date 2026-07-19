#!/usr/bin/env bash
#
# Sync this fork with upstream google/google-java-format.
#
# Strategy: MERGE (never rebase). The fork shares history with upstream, so a
# merge records the base and each future sync only reconciles genuinely new
# upstream changes. git rerere (enabled below) replays your recurring
# content-conflict resolutions automatically.
#
# Usage:
#   util/sync-upstream.sh                # merge the latest upstream release tag
#   util/sync-upstream.sh v1.36.0        # merge a specific tag/ref
#
# After running, resolve any remaining conflicts, then:
#   mvn test && git commit
#
set -euo pipefail

REMOTE="google"
REMOTE_URL="https://github.com/google/google-java-format.git"

# Make sure the upstream remote exists (read-only fetch URL).
if ! git remote get-url "$REMOTE" >/dev/null 2>&1; then
  echo "Adding '$REMOTE' remote -> $REMOTE_URL"
  git remote add "$REMOTE" "$REMOTE_URL"
fi

# rerere: record + auto-apply conflict resolutions across syncs.
git config rerere.enabled true
git config rerere.autoUpdate true

echo "Fetching $REMOTE (with tags)..."
git fetch "$REMOTE" --tags --quiet

# Target: explicit arg, else the highest v* release tag.
TARGET="${1:-$(git tag -l 'v*' --sort=-v:refname | head -1)}"
if [ -z "$TARGET" ]; then
  echo "ERROR: no target ref given and no v* tags found." >&2
  exit 1
fi

BRANCH="sync/upstream-${TARGET}"
echo "Target upstream ref: $TARGET"
echo "Working branch:      $BRANCH"

git checkout -B "$BRANCH"

echo
echo "Merging $TARGET ..."
if git merge --no-edit "$TARGET"; then
  echo
  echo "Clean merge. Now run:  mvn test"
  exit 0
fi

# Merge stopped on conflicts. Auto-resolve the mechanical modify/delete cases:
# files WE intentionally deleted that upstream changed -> keep them deleted.
echo
echo "Conflicts detected. Auto-resolving modify/delete (keeping our deletions)..."
git status --porcelain \
  | awk '/^(DU|UD) / {print $2}' \
  | while read -r f; do
      echo "  git rm $f"
      git rm --quiet "$f"
    done

echo
echo "Remaining conflicts to resolve by hand (content merges):"
git status --porcelain | awk '/^(UU|AA|DD|AU|UA) / {print "  "$0}'
echo
echo "Next steps:"
echo "  1. Resolve the files above (rerere may have pre-filled known ones)."
echo "  2. Bump the fork version in pom.xml to <upstream>-fork.N"
echo "  3. mvn test"
echo "  4. git commit    # finalizes the merge"
exit 1

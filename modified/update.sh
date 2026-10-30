#!/usr/bin/env bash
# Pull the latest official T3 Code, replay your modifications on top, then build and install.
#
#   modified/update.sh             sync + build + install
#   modified/update.sh --no-build  sync only
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

BUILD=1
[[ "${1:-}" == "--no-build" ]] && BUILD=0

[[ "$(git branch --show-current)" == "$MOD_BRANCH" ]] || die "Switch to '${MOD_BRANCH}' first: git checkout ${MOD_BRANCH}"
require_clean_tree

say "Fetching official T3 Code (pingdotgg/t3code)..."
git fetch upstream main --tags --quiet

say "Mirroring official main to your fork's main..."
git branch -f main upstream/main
git push --quiet origin upstream/main:refs/heads/main || warn "Could not push main to your fork (continuing)."

if git merge-base --is-ancestor upstream/main HEAD; then
  say "Your build already contains the latest official code."
else
  before="$(git rev-parse --short HEAD)"
  say "Replaying your modifications on top of the latest official code..."
  if ! git rebase upstream/main; then
    git rebase --abort || true
    warn "One of your modifications conflicts with the new official code. Nothing was changed."
    warn "Open the 'T3 Code Modified' project and ask Claude:"
    warn "  \"Update from upstream and resolve the rebase conflicts in my modifications.\""
    exit 2
  fi
  say "Rebased ${before} -> $(git rev-parse --short HEAD)"
  git push --quiet --force-with-lease origin "$MOD_BRANCH" || warn "Could not back up '${MOD_BRANCH}' to your fork (continuing)."
  say "Installing dependencies..."
  vp i
fi

say "Your modifications on top of official T3 Code:"
git log --oneline upstream/main..HEAD | sed 's/^/    /'

if [[ "$BUILD" == 1 ]]; then
  exec "$REPO_ROOT/modified/build.sh"
fi

#!/usr/bin/env bash
# Shared helpers for the T3 Code Modified scripts. Sourced, not run.

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MOD_BRANCH="my-build"
APP_NAME="T3 Code Modified"
APP_PATH="/Applications/${APP_NAME}.app"
OFFICIAL_APP_PATH="/Applications/T3 Code (Nightly).app"
STAGE_DIR="${REPO_ROOT}/release/modified"
T3_USERDATA="${HOME}/.t3/userdata"
BACKUP_DIR="${HOME}/.t3/modified-backups"
KEEP_BACKUPS=2

# vp's own env file breaks under some zsh completion setups, and we don't want
# its node shim in the user's global PATH, so add it only for these scripts.
export PATH="${HOME}/.local/share/vite-plus/bin:${HOME}/.local/share/vite-plus/fallback-bin:${PATH}"

# Upstream builds with current stable Rust. Use a side-by-side toolchain so the user's default
# rustc stays untouched. If a build says "requires rustc X", install a newer one and bump this.
export RUSTUP_TOOLCHAIN="1.99.1"

say() { printf '\033[1;36m==>\033[0m %s\n' "$*"; }
warn() { printf '\033[1;33m!!\033[0m %s\n' "$*" >&2; }
die() { printf '\033[1;31mxx\033[0m %s\n' "$*" >&2; exit 1; }

# True if any process is running from inside the given .app bundle (detection only, never used to kill).
app_running() {
  # comm= is the executable path only, so this can't match grep's own arguments.
  # No grep -q: it exits early, SIGPIPEs ps, and under pipefail that reads as "not running".
  ps -axo comm= | grep -F "$1/Contents/MacOS/" >/dev/null
}

require_clean_tree() {
  if ! git -C "$REPO_ROOT" diff --quiet || ! git -C "$REPO_ROOT" diff --cached --quiet; then
    die "You have uncommitted changes. Commit them on '${MOD_BRANCH}' (or stash them) first."
  fi
}

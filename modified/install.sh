#!/usr/bin/env bash
# Back up your T3 database, then copy the freshly built app into /Applications.
# Requires both T3 Code apps to be quit, so nothing is writing to your data.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"

staged="$STAGE_DIR/${APP_NAME}.app"
[[ -d "$staged" ]] || die "Nothing to install. Run modified/build.sh first."

for app in "$APP_PATH" "$OFFICIAL_APP_PATH"; do
  if app_running "$app"; then
    warn "$(basename "$app" .app) is running. The new build is ready but NOT installed yet."
    warn "Quit it (Cmd+Q), then double-click:  $REPO_ROOT/modified/Install T3 Code Modified.command"
    exit 3
  fi
done

if [[ -f "$T3_USERDATA/statev2.sqlite" ]]; then
  mkdir -p "$BACKUP_DIR"
  backup="$BACKUP_DIR/$(date +%Y%m%d-%H%M%S)"
  say "Backing up your T3 database to $backup ..."
  # Both apps are quit, so nothing is writing: copying the db with its WAL/SHM files is consistent.
  mkdir -p "$backup"
  cp -p "$T3_USERDATA"/statev2.sqlite* "$backup"/
  ls -1dt "$BACKUP_DIR"/*/ | tail -n +$((KEEP_BACKUPS + 1)) | while read -r old; do rm -rf "$old"; done
fi

say "Installing to $APP_PATH ..."
rm -rf "$APP_PATH"
ditto "$staged" "$APP_PATH"
say "Done. Open '${APP_NAME}' from Applications or Spotlight."

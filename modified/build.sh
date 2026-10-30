#!/usr/bin/env bash
# Build "T3 Code Modified.app" from the current checkout, then install it if the app isn't running.
set -euo pipefail
source "$(dirname "${BASH_SOURCE[0]}")/lib.sh"
cd "$REPO_ROOT"

# Version: <official base>-preview.<date>.<commit count>.
# The "-preview" suffix is what upstream uses for builds with no update feed, so this app
# never auto-updates itself to the stock nightly and never downloads anything on its own.
base="$(git describe --tags --match 'v*-nightly.*' --abbrev=0 upstream/main 2>/dev/null \
  | sed -E 's/^v([0-9]+\.[0-9]+\.[0-9]+).*/\1/' || true)"
[[ -n "$base" ]] || base="$(node -p 'require("./apps/server/package.json").version')"
version="${base}-preview.$(date +%Y%m%d).$(git rev-list --count HEAD)"

arch="$(uname -m)"; [[ "$arch" == "x86_64" ]] && arch="x64"

# Never point a release build at a publish repo, or electron-builder would embed an update feed.
unset GITHUB_REPOSITORY T3CODE_DESKTOP_UPDATE_REPOSITORY T3CODE_DESKTOP_MOCK_UPDATES

say "Building ${APP_NAME} ${version} (${arch}). This takes several minutes..."
rm -rf "$STAGE_DIR"
node scripts/build-desktop-artifact.ts \
  --platform mac --target zip --arch "$arch" \
  --build-version "$version" --output-dir "$STAGE_DIR"

# The build script only keeps top-level files, so a zip is how the .app gets out of its temp stage.
archive="$(find "$STAGE_DIR" -maxdepth 1 -name '*.zip' | head -1)"
[[ -n "$archive" ]] || die "Build finished but no .zip was found in $STAGE_DIR"
ditto -x -k "$archive" "$STAGE_DIR"
rm -f "$archive" "$archive.blockmap"

built_app="$(find "$STAGE_DIR" -maxdepth 1 -name '*.app' -type d | head -1)"
[[ -n "$built_app" ]] || die "Build finished but no .app was found in $STAGE_DIR"

# Rename the bundle and its visible name so it's distinct from the official app in Finder and the Dock.
staged="$STAGE_DIR/${APP_NAME}.app"
[[ "$built_app" == "$staged" ]] || { rm -rf "$staged"; mv "$built_app" "$staged"; }
/usr/libexec/PlistBuddy -c "Set :CFBundleName ${APP_NAME}" "$staged/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleName string ${APP_NAME}" "$staged/Contents/Info.plist"
/usr/libexec/PlistBuddy -c "Set :CFBundleDisplayName ${APP_NAME}" "$staged/Contents/Info.plist" 2>/dev/null \
  || /usr/libexec/PlistBuddy -c "Add :CFBundleDisplayName string ${APP_NAME}" "$staged/Contents/Info.plist"
# Local builds are unsigned; re-seal with an ad-hoc signature after editing Info.plist.
codesign --force --deep --sign - "$staged" >/dev/null 2>&1 || warn "Ad-hoc signing failed; the app may not launch."

say "Built: $staged"
exec "$REPO_ROOT/modified/install.sh"

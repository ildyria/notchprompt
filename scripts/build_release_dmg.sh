#!/usr/bin/env bash
# build_release_dmg.sh — Build a distributable macOS DMG for Notchprompt Flutter
#
# Usage:
#   ./scripts/build_release_dmg.sh [VERSION] [--sign DEVELOPER_ID]
#
# Arguments:
#   VERSION       Optional version string, e.g. v1.2.0  (default: v1.0.0)
#   --sign ID     Optional Developer ID Application identity for code-signing.
#                 Omitting this flag produces an ad-hoc signed build suitable
#                 for direct distribution but not Mac App Store submission.
#
# Requirements:
#   - Flutter SDK on PATH (or FLUTTER_BIN env var pointing to flutter binary)
#   - Xcode Command Line Tools
#   - hdiutil (built-in on macOS)
#
# Output:
#   dist/notchprompt-flutter-<VERSION>-macos.dmg
set -euo pipefail

# ─── Configuration ────────────────────────────────────────────────────────────
ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
FLUTTER_PROJECT="$ROOT_DIR/notchprompt_flutter"
FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
VERSION="${1:-v1.0.0}"
SIGN_IDENTITY=""

# Parse flags
shift || true
while [[ $# -gt 0 ]]; do
  case "$1" in
    --sign)
      SIGN_IDENTITY="${2:-}"
      shift 2
      ;;
    *)
      echo "Unknown argument: $1" >&2
      exit 1
      ;;
  esac
done

APP_PATH="$FLUTTER_PROJECT/build/macos/Build/Products/Release/notchprompt.app"
STAGING_DIR="$ROOT_DIR/build/dmg-staging-flutter"
OUTPUT_DIR="$ROOT_DIR/dist"
OUTPUT_DMG="$OUTPUT_DIR/notchprompt-flutter-${VERSION}-macos.dmg"
VOLUME_NAME="Notchprompt"

echo "==> Building Flutter macOS Release (${VERSION})"
(
  cd "$FLUTTER_PROJECT"
  "$FLUTTER_BIN" build macos --release
)

if [[ ! -d "$APP_PATH" ]]; then
  echo "ERROR: Expected app bundle not found at: $APP_PATH" >&2
  exit 1
fi

# ─── Code signing ─────────────────────────────────────────────────────────────
if [[ -n "$SIGN_IDENTITY" ]]; then
  echo "==> Signing with Developer ID: $SIGN_IDENTITY"
  codesign \
    --force \
    --deep \
    --options runtime \
    --entitlements "$FLUTTER_PROJECT/macos/Runner/Release.entitlements" \
    --sign "$SIGN_IDENTITY" \
    "$APP_PATH"
else
  echo "==> Ad-hoc signing (no Developer ID provided)"
  echo "    To notarize, re-run with: --sign 'Developer ID Application: Your Name (TEAMID)'"
  codesign --force --deep --sign - "$APP_PATH"
fi

# ─── DMG packaging ────────────────────────────────────────────────────────────
mkdir -p "$OUTPUT_DIR"
rm -rf "$STAGING_DIR"
mkdir -p "$STAGING_DIR"
rm -f "$OUTPUT_DMG"

cp -R "$APP_PATH" "$STAGING_DIR/"
ln -s /Applications "$STAGING_DIR/Applications"

echo "==> Packaging $OUTPUT_DMG"
hdiutil create \
  -volname "$VOLUME_NAME" \
  -srcfolder "$STAGING_DIR" \
  -ov \
  -format UDZO \
  "$OUTPUT_DMG"

rm -rf "$STAGING_DIR"

echo ""
echo "✓ DMG created: $OUTPUT_DMG"

# ─── Notarize (optional, requires APPLE_ID and APP_SPECIFIC_PASSWORD env vars) ─
if [[ -n "$SIGN_IDENTITY" && -n "${APPLE_ID:-}" && -n "${APP_SPECIFIC_PASSWORD:-}" ]]; then
  TEAM_ID="${APPLE_TEAM_ID:-}"
  echo "==> Submitting to Apple notary service…"
  xcrun notarytool submit "$OUTPUT_DMG" \
    --apple-id "$APPLE_ID" \
    --password "$APP_SPECIFIC_PASSWORD" \
    ${TEAM_ID:+--team-id "$TEAM_ID"} \
    --wait

  echo "==> Stapling notarization ticket"
  xcrun stapler staple "$OUTPUT_DMG"
  echo "✓ Notarized and stapled."
else
  if [[ -n "$SIGN_IDENTITY" ]]; then
    echo ""
    echo "Tip: To notarize, set APPLE_ID, APP_SPECIFIC_PASSWORD (and optionally"
    echo "     APPLE_TEAM_ID) environment variables and re-run."
  fi
fi

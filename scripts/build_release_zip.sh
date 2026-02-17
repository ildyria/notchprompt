#!/usr/bin/env bash
set -euo pipefail

ROOT_DIR="$(cd "$(dirname "$0")/.." && pwd)"
VERSION="${1:-v1.0.0}"
DERIVED_DATA_PATH="$ROOT_DIR/build/release"
OUTPUT_DIR="$ROOT_DIR/dist"
APP_PATH="$DERIVED_DATA_PATH/Build/Products/Release/notchprompt.app"
OUTPUT_ZIP="$OUTPUT_DIR/notchprompt-${VERSION}-macos.zip"

echo "==> Building Release app for ${VERSION}"
xcodebuild \
  -project "$ROOT_DIR/notchprompt.xcodeproj" \
  -scheme notchprompt \
  -configuration Release \
  -derivedDataPath "$DERIVED_DATA_PATH" \
  CODE_SIGNING_ALLOWED=NO \
  CODE_SIGN_IDENTITY="" \
  build

if [[ ! -d "$APP_PATH" ]]; then
  echo "Expected app bundle not found at: $APP_PATH" >&2
  exit 1
fi

mkdir -p "$OUTPUT_DIR"
rm -f "$OUTPUT_ZIP"

echo "==> Packaging $OUTPUT_ZIP"
ditto -c -k --sequesterRsrc --keepParent "$APP_PATH" "$OUTPUT_ZIP"

echo "==> Done"
echo "$OUTPUT_ZIP"

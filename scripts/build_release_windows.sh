#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────────
# build_release_windows.sh  —  Build and package Notchprompt for Windows.
#
# Run this script from a Windows machine or GitHub Actions Windows runner
# (Git Bash / MSYS2 shell).
#
# Usage:
#   ./scripts/build_release_windows.sh [VERSION] [--msix] [--zip]
#
# If no package flag is given, a plain .zip archive is produced (always works
# without additional tools).  --msix requires the Microsoft MSIX Packaging
# Tool or makeappx.exe (part of Windows SDK).
#
# Environment variables:
#   FLUTTER_BIN         path to flutter binary  (default: flutter)
#   PUBLISHER_DISPLAY   Publisher display name for MSIX manifest
#   PUBLISHER_ID        Publisher ID (CN=…)  required for --msix
# ────────────────────────────────────────────────────────────────────────────
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
PUBLISHER_DISPLAY="${PUBLISHER_DISPLAY:-Notchprompt Contributors}"
PUBLISHER_ID="${PUBLISHER_ID:-CN=NotchpromptContributors}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FLUTTER_ROOT="$REPO_ROOT/notchprompt_flutter"
DIST_DIR="$REPO_ROOT/dist"

VERSION="${1:-0.1.0}"
VERSION="${VERSION#v}"

DO_ZIP=false
DO_MSIX=false
shift || true
for arg in "$@"; do
  case "$arg" in
    --zip)  DO_ZIP=true ;;
    --msix) DO_MSIX=true ;;
  esac
done
# Default: produce zip only
if [[ "$DO_ZIP" == false && "$DO_MSIX" == false ]]; then
  DO_ZIP=true
fi

mkdir -p "$DIST_DIR"

echo "==> Building Flutter release (windows)…"
cd "$FLUTTER_ROOT"
"$FLUTTER_BIN" build windows --release

BUILD_DIR="$FLUTTER_ROOT/build/windows/x64/runner/Release"

# ─── .zip (portable, no-install) ─────────────────────────────────────────────
if [[ "$DO_ZIP" == true ]]; then
  echo "==> Packaging .zip…"
  ZIP_STAGE="$DIST_DIR/notchprompt-${VERSION}-windows-x64"
  rm -rf "$ZIP_STAGE"
  mkdir -p "$ZIP_STAGE"
  cp -r "$BUILD_DIR/." "$ZIP_STAGE/"

  ZIP_PATH="$DIST_DIR/notchprompt-${VERSION}-windows-x64.zip"
  # Use PowerShell if available, else python zipfile
  if command -v powershell &>/dev/null; then
    powershell -Command \
      "Compress-Archive -Path '$(cygpath -w "$ZIP_STAGE")\\*' \
       -DestinationPath '$(cygpath -w "$ZIP_PATH")' -Force"
  else
    python3 -c "
import zipfile, os, sys
src = sys.argv[1]; dst = sys.argv[2]
with zipfile.ZipFile(dst, 'w', zipfile.ZIP_DEFLATED) as z:
    for root, _, files in os.walk(src):
        for f in files:
            fp = os.path.join(root, f)
            z.write(fp, os.path.relpath(fp, src))
print('Created:', dst)
" "$ZIP_STAGE" "$ZIP_PATH"
  fi
  rm -rf "$ZIP_STAGE"
  echo "    Created: $ZIP_PATH"
fi

# ─── MSIX package ────────────────────────────────────────────────────────────
# MSIX requires a certificate to be installed for side-loading, or submission
# to the Microsoft Store.  The manifest below targets Windows 10 1809+.
if [[ "$DO_MSIX" == true ]]; then
  echo "==> Packaging MSIX…"

  MSIX_STAGE="$DIST_DIR/notchprompt_msix"
  rm -rf "$MSIX_STAGE"
  mkdir -p "$MSIX_STAGE"
  cp -r "$BUILD_DIR/." "$MSIX_STAGE/"

  # Write AppxManifest.xml
  cat > "$MSIX_STAGE/AppxManifest.xml" <<EOF
<?xml version="1.0" encoding="utf-8"?>
<Package
  xmlns="http://schemas.microsoft.com/appx/manifest/foundation/windows10"
  xmlns:uap="http://schemas.microsoft.com/appx/manifest/uap/windows10"
  xmlns:rescap="http://schemas.microsoft.com/appx/manifest/foundation/windows10/restrictedcapabilities">
  <Identity
    Name="Notchprompt"
    Publisher="${PUBLISHER_ID}"
    Version="${VERSION}.0" />
  <Properties>
    <DisplayName>Notchprompt</DisplayName>
    <PublisherDisplayName>${PUBLISHER_DISPLAY}</PublisherDisplayName>
    <Logo>Assets\\StoreLogo.png</Logo>
  </Properties>
  <Dependencies>
    <TargetDeviceFamily
      Name="Windows.Desktop"
      MinVersion="10.0.17763.0"
      MaxVersionTested="10.0.22621.0" />
  </Dependencies>
  <Resources>
    <Resource Language="en-us" />
  </Resources>
  <Applications>
    <Application Id="Notchprompt" Executable="notchprompt.exe"
                 EntryPoint="Windows.FullTrustApplication">
      <uap:VisualElements
        DisplayName="Notchprompt"
        Description="Desktop teleprompter"
        BackgroundColor="transparent"
        Square150x150Logo="Assets\\Square150x150Logo.png"
        Square44x44Logo="Assets\\Square44x44Logo.png" />
    </Application>
  </Applications>
  <Capabilities>
    <rescap:Capability Name="runFullTrust" />
  </Capabilities>
</Package>
EOF

  mkdir -p "$MSIX_STAGE/Assets"
  # Use the existing tray icon as a placeholder for all MSIX assets.
  # Replace with properly-sized PNGs before Store submission.
  if [[ -f "$FLUTTER_ROOT/assets/tray_icon.png" ]]; then
    for asset in StoreLogo Square150x150Logo Square44x44Logo; do
      cp "$FLUTTER_ROOT/assets/tray_icon.png" "$MSIX_STAGE/Assets/${asset}.png"
    done
  fi

  MSIX_PATH="$DIST_DIR/notchprompt-${VERSION}-windows-x64.msix"
  makeappx pack /d "$(cygpath -w "$MSIX_STAGE")" /p "$(cygpath -w "$MSIX_PATH")" /nv
  rm -rf "$MSIX_STAGE"
  echo "    Created: $MSIX_PATH"
  echo "    Note: sign the MSIX with signtool.exe before distribution."
  echo "    Example: signtool sign /fd SHA256 /a \"$MSIX_PATH\""
fi

echo "==> Done. Artifacts in $DIST_DIR/"

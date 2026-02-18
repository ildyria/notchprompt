#!/usr/bin/env bash
# ────────────────────────────────────────────────────────────────────────────
# build_release_linux.sh  —  Build and package Notchprompt for Linux.
#
# Usage:
#   ./scripts/build_release_linux.sh [VERSION] [--appimage] [--deb]
#
# If no package flag is given, both formats are produced.
#
# Requirements:
#   .deb   : dpkg-deb (part of dpkg, available on all Debian/Ubuntu systems)
#   AppImage: linuxdeploy + linuxdeploy-plugin-gtk (auto-downloaded to /tmp)
#
# Environment variables:
#   FLUTTER_BIN   path to flutter binary  (default: flutter)
#   MAINTAINER    "Name <email>" for .deb control file
# ────────────────────────────────────────────────────────────────────────────
set -euo pipefail

FLUTTER_BIN="${FLUTTER_BIN:-flutter}"
MAINTAINER="${MAINTAINER:-Notchprompt Contributors <notchprompt@example.com>}"

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
FLUTTER_ROOT="$REPO_ROOT/notchprompt_flutter"
DIST_DIR="$REPO_ROOT/dist"

VERSION="${1:-0.1.0}"
# Strip leading 'v' if present
VERSION="${VERSION#v}"

DO_DEB=false
DO_APPIMAGE=false
shift || true
for arg in "$@"; do
  case "$arg" in
    --deb)      DO_DEB=true ;;
    --appimage) DO_APPIMAGE=true ;;
  esac
done
# Default: produce both
if [[ "$DO_DEB" == false && "$DO_APPIMAGE" == false ]]; then
  DO_DEB=true
  DO_APPIMAGE=true
fi

mkdir -p "$DIST_DIR"

echo "==> Building Flutter release (linux)…"
cd "$FLUTTER_ROOT"
"$FLUTTER_BIN" build linux --release

BUILD_DIR="$FLUTTER_ROOT/build/linux/x64/release/bundle"

# ─── .deb package ────────────────────────────────────────────────────────────
if [[ "$DO_DEB" == true ]]; then
  echo "==> Packaging .deb…"

  PKG_DIR="$DIST_DIR/notchprompt_${VERSION}_amd64"
  rm -rf "$PKG_DIR"
  install -d "$PKG_DIR/DEBIAN"
  install -d "$PKG_DIR/usr/bin"
  install -d "$PKG_DIR/usr/lib/notchprompt"
  install -d "$PKG_DIR/usr/share/applications"
  install -d "$PKG_DIR/usr/share/icons/hicolor/256x256/apps"

  # Control file
  cat > "$PKG_DIR/DEBIAN/control" <<EOF
Package: notchprompt
Version: ${VERSION}
Architecture: amd64
Maintainer: ${MAINTAINER}
Depends: libgtk-3-0, libblkid1, liblzma5
Description: Desktop teleprompter
 Notchprompt is a cross-platform desktop teleprompter that lives in the
 system tray and displays a floating transparent overlay for scripts.
EOF

  # Copy bundle
  cp -a "$BUILD_DIR/." "$PKG_DIR/usr/lib/notchprompt/"

  # Thin launcher wrapper
  cat > "$PKG_DIR/usr/bin/notchprompt" <<'EOF'
#!/bin/sh
exec /usr/lib/notchprompt/notchprompt "$@"
EOF
  chmod 755 "$PKG_DIR/usr/bin/notchprompt"

  # Desktop integration
  cp "$FLUTTER_ROOT/linux/notchprompt.desktop" \
     "$PKG_DIR/usr/share/applications/notchprompt.desktop"

  # Icon — use the tray icon PNG if available
  if [[ -f "$FLUTTER_ROOT/assets/tray_icon.png" ]]; then
    cp "$FLUTTER_ROOT/assets/tray_icon.png" \
       "$PKG_DIR/usr/share/icons/hicolor/256x256/apps/notchprompt.png"
  fi

  DEB_PATH="$DIST_DIR/notchprompt-${VERSION}-linux-amd64.deb"
  dpkg-deb --build --root-owner-group "$PKG_DIR" "$DEB_PATH"
  rm -rf "$PKG_DIR"
  echo "    Created: $DEB_PATH"
fi

# ─── AppImage ─────────────────────────────────────────────────────────────────
if [[ "$DO_APPIMAGE" == true ]]; then
  echo "==> Packaging AppImage…"

  # Download linuxdeploy if not present
  LINUXDEPLOY_BIN="/tmp/linuxdeploy-x86_64.AppImage"
  LINUXDEPLOY_GTK="/tmp/linuxdeploy-plugin-gtk.sh"

  if [[ ! -x "$LINUXDEPLOY_BIN" ]]; then
    echo "    Downloading linuxdeploy…"
    curl -fsSL -o "$LINUXDEPLOY_BIN" \
      "https://github.com/linuxdeploy/linuxdeploy/releases/download/continuous/linuxdeploy-x86_64.AppImage"
    chmod +x "$LINUXDEPLOY_BIN"
  fi

  if [[ ! -x "$LINUXDEPLOY_GTK" ]]; then
    echo "    Downloading linuxdeploy-plugin-gtk…"
    curl -fsSL -o "$LINUXDEPLOY_GTK" \
      "https://raw.githubusercontent.com/linuxdeploy/linuxdeploy-plugin-gtk/master/linuxdeploy-plugin-gtk.sh"
    chmod +x "$LINUXDEPLOY_GTK"
  fi

  APPDIR="$DIST_DIR/notchprompt.AppDir"
  rm -rf "$APPDIR"
  mkdir -p "$APPDIR/usr/bin" "$APPDIR/usr/lib/notchprompt"

  cp -a "$BUILD_DIR/." "$APPDIR/usr/lib/notchprompt/"

  cat > "$APPDIR/usr/bin/notchprompt" <<'EOF'
#!/bin/sh
HERE="$(dirname "$(readlink -f "$0")")"
exec "$HERE/../lib/notchprompt/notchprompt" "$@"
EOF
  chmod 755 "$APPDIR/usr/bin/notchprompt"

  ICON_SRC="$FLUTTER_ROOT/assets/tray_icon.png"
  if [[ ! -f "$ICON_SRC" ]]; then
    echo "    Warning: no icon at assets/tray_icon.png — AppImage will have no icon"
  fi

  OUTPUT_DIR="$DIST_DIR" \
  LINUXDEPLOY_PLUGIN_GTK="$LINUXDEPLOY_GTK" \
  VERSION="$VERSION" \
    "$LINUXDEPLOY_BIN" \
      --appdir "$APPDIR" \
      --executable "$APPDIR/usr/bin/notchprompt" \
      --desktop-file "$FLUTTER_ROOT/linux/notchprompt.desktop" \
      ${ICON_SRC:+--icon-file "$ICON_SRC"} \
      --plugin gtk \
      --output appimage 2>&1

  # linuxdeploy writes Notchprompt-VERSION-x86_64.AppImage to cwd
  APPIMAGE_OUT=$(find "$DIST_DIR" -maxdepth 1 -name "Notchprompt*x86_64.AppImage" | head -1)
  if [[ -n "$APPIMAGE_OUT" ]]; then
    FINAL="$DIST_DIR/notchprompt-${VERSION}-linux-x86_64.AppImage"
    mv "$APPIMAGE_OUT" "$FINAL"
    echo "    Created: $FINAL"
  fi

  rm -rf "$APPDIR"
fi

echo "==> Done. Artifacts in $DIST_DIR/"

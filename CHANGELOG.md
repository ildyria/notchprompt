# Changelog

All notable changes to this project will be documented in this file.

The format follows [Keep a Changelog](https://keepachangelog.com/en/1.1.0/).
Versioning follows [Semantic Versioning](https://semver.org/).

---

## [Unreleased]

---

## [1.0.0] — 2026-02-18

### Added

#### Core
- `PrompterState` + `PrompterNotifier` — full transport state machine
  (`idle → countingDown → running`) with Riverpod state management
- Countdown async loop (configurable 0–10 s)
- Jump-back mechanism via `jumpBackToken` UUID trigger (default 5 s)
- Reset-scroll mechanism via `resetToken` UUID trigger
- `SettingsState` + `SettingsNotifier` — all settings with load/save/clamp
- Settings persist via `shared_preferences` with 250 ms debounce
- Estimated read duration formula (§13 of SPEC)

#### Overlay Window
- Transparent, borderless, always-on-top floating overlay
- `NotchClipper` — macOS notch-blend shape (`CustomClipper<Path>`)
- `RoundedBottomClipper` — generic rounded bar for Linux/Windows
- `ScrollingTextView` — `Ticker`-driven seamless scroll with configurable
  speed and edge-fade gradient; reacts to `resetToken`/`jumpBackToken`
- `CountdownView` — full-frame numeral countdown with `AnimatedSwitcher`
  scale/fade between numbers
- `ControlsHud` — floating play/pause, jump-back, speed +/− capsule clusters;
  repeat-while-pressed speed buttons

#### System Integration
- System tray icon and reactive menu (Start/Pause, Reset, Privacy, Settings,
  Quit) on macOS, Linux, and Windows via `tray_manager`
- 6 global hotkeys (`⌥⌘P/R/J/H/=/−`) via `hotkey_manager`
- `LSUIElement = true` on macOS — no Dock icon

#### Settings Window
- Script editor (`TextField`) with placeholder text
- Script import (`.txt`, UTF-8, file picker) with error dialog
- Script export (`file_picker` save panel) with error dialog
- Sliders: speed, font size, overlay width/height, countdown duration
- Speed preset buttons: Slow (55 pts/s) / Normal (85 pts/s) / Fast (125 pts/s)
- Privacy mode toggle (macOS only)
- Estimated read duration live display
- Launch / Hide Overlay button

#### macOS Platform
- `NSWindow.sharingType = .none` privacy mode via `MethodChannel('notchprompt/window')`
- `NSWindowLevel.screenSaver` — overlay survives fullscreen apps and
  Spaces transitions
- `collectionBehavior = [.canJoinAllSpaces, .fullScreenAuxiliary, .stationary, .ignoresCycle]`
- Ad-hoc + code-signed DMG packaging (`scripts/build_release_dmg.sh`)

#### Linux Platform
- GTK runner configured for tray-only operation (no GNOME header bar)
- Application ID `io.github.saif0200.notchprompt`
- `.desktop` file for DE integration
- `.deb` package + AppImage via `linuxdeploy` (`scripts/build_release_linux.sh`)

#### Windows Platform
- Win32 runner configured for tray-only operation (`SetQuitOnClose(false)`)
- Portable `.zip` + MSIX packaging (`scripts/build_release_windows.sh`)
- `PerMonitorV2` DPI-awareness manifest

#### CI/CD
- GitHub Actions CI: analyze, test, build matrix (macOS/Linux/Windows)
- GitHub Actions Release: tag-triggered, three-platform builds, single
  GitHub Release with all artifacts

### Architecture
- Feature-first folder structure (`lib/features/<feature>/`)
- Unidirectional Riverpod data flow — zero `setState` for shared state
- Platform abstraction via `lib/core/platform.dart` — no `dart:io` in feature code
- `lib/core/macos_window_channel.dart` — typed Dart client for macOS method channel
- All settings constants centralised in `lib/core/constants.dart`
- 35 unit tests covering all transport transitions and settings validation

---

[Unreleased]: https://github.com/saif0200/notchprompt/compare/v1.0.0...HEAD
[1.0.0]: https://github.com/saif0200/notchprompt/releases/tag/v1.0.0

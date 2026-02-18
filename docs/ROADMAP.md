# Notchprompt Flutter — Roadmap

All work is tracked here at the milestone level. Individual tasks live in GitHub
Issues. This file is the authoritative sequence — do not implement Phase N+1
before Phase N is complete and tested.

---

## Phase 0 — Project Bootstrap ✅

Goal: empty Flutter desktop app builds and runs on all three platforms.

- [x] `flutter create notchprompt_flutter --platforms=macos,linux,windows`
- [x] Configure `pubspec.yaml` with pinned dependencies
- [x] `analysis_options.yaml` — strict lints, no implicit dynamic
- [x] CI: GitHub Actions matrix build (macOS, Ubuntu, Windows)
- [x] Folder structure per ARCHITECTURE.md
- [x] `AGENTS.md`, `CONSTITUTION.md`, `SPEC.md`, `ARCHITECTURE.md` checked in

**Exit criteria:** `flutter build macos` / `linux` / `windows` produce artifacts with zero warnings.

---

## Phase 1 — Core State & Logic (no UI) ✅

Goal: all business logic exists and is tested, zero UI.

- [x] `SettingsState` + `SettingsNotifier` with load/save/clamp
- [x] `PrompterState` + `PrompterNotifier`: transport state machine
- [x] Countdown async loop
- [x] Jump back / reset token mechanism
- [x] Estimated read duration utility
- [x] `shared_preferences` integration
- [x] Unit tests: all transport transitions, all settings validation

**Exit criteria:** `flutter test` passes 100 %; coverage ≥ 80 % on notifier files. ✅

---

## Phase 2 — Overlay Window ✅

Goal: a visible always-on-top overlay window with scrolling text, no tray.

- [x] `OverlayWindow` bootstrapped via `window_manager`
- [x] Transparent, borderless, always-on-top, non-focusable
- [x] Top-center positioning on primary display
- [x] `NotchClipper` (macOS) and `RoundedBottomClipper` (Linux/Windows)
- [x] Black fill, subtle border stroke
- [x] `ScrollingTextView` — Ticker-driven, edge fade
- [x] `CountdownView` — numeral countdown
- [x] `ControlsHud` — play/pause, jump back, speed +/−
- [x] Reposition on display config change

**Exit criteria:** overlay scrolls a test script smoothly; controls work via on-screen buttons. ✅

---

## Phase 3 — System Tray & Hotkeys ✅

Goal: full tray menu and global shortcuts; app has no Dock icon.

- [x] `TrayService` — icon, tooltip, dynamic menu
- [x] Tray menu wired to `PrompterNotifier` and `SettingsNotifier`
- [x] `Start / Pause` title reflects state reactively
- [x] `hotkey_manager` global shortcuts (all 6 from SPEC §7)
- [x] `LSUIElement = true` (macOS `Info.plist`)
- [x] Privacy mode toggle visible on macOS only

**Exit criteria:** app runs with no Dock icon; all hotkeys fire when app is not focused. ✅

---

## Phase 4 — Settings Window & Script Editor ✅

Goal: full settings UI; script can be edited, imported, exported.

- [x] Settings window opens from tray menu (via `settingsWindowRequestProvider` signal)
- [x] Sliders for all numeric settings
- [x] Speed preset buttons (Slow / Normal / Fast)
- [x] Countdown toggle (0 = Off)
- [x] Privacy mode toggle (macOS only; hidden on other platforms)
- [x] Estimated read duration live display
- [x] Plain-text script editor
- [x] Import script (`file_picker`, `.txt`, UTF-8) with error dialog
- [x] Export script (`file_picker`, default `script.txt`) with error dialog
- [x] Launch / Hide Overlay button in settings window
- [x] Settings window brought to front when requested from tray

**Exit criteria:** full workflow — edit script → import → adjust settings → start scroll — works end-to-end. ✅

---

## Phase 5 — macOS Polish ✅

Goal: macOS-specific finishing touches.

- [x] Privacy mode native channel (`NSWindow.sharingType = .none`)
- [ ] Verify notch blend on MacBook (black fill vs. physical notch)
- [x] `NSWindowLevel` lock ensuring overlay survives fullscreen apps
- [x] App-signed DMG build (`scripts/build_release_dmg.sh`)
- [x] Code-sign and notarize (documented in `notchprompt_flutter/README.md`)

**Exit criteria:** app passes manual testing on macBook with a real notch. DMG distributable. ✅

---

## Phase 6 — Linux & Windows ✅

Goal: verified, distributable builds for both platforms.

- [x] Linux `.deb` / `.AppImage` packaging (`scripts/build_release_linux.sh`)
- [x] Linux tray: `libayatana-appindicator3` noted; DE compatibility table in README
- [x] Windows `.zip` / MSIX packaging (`scripts/build_release_windows.sh`)
- [x] Windows tray icon (PNG via `tray_manager`; ICO in runner resources)
- [x] HiDPI / scaling verified and documented (GDK_SCALE / PerMonitorV2 manifest)
- [x] Overlay positioning on multi-monitor documented

**Exit criteria:** app installs and runs without errors on Ubuntu 22.04+ and Windows 11. ✅

---

## Phase 7 — 1.0 Release ✅

- [x] README updated with install instructions for all platforms
- [x] GitHub Releases workflow (tag → verify → build → publish release)
- [x] CHANGELOG.md written covering all phases
- [x] All SPEC items covered (audited against SPEC.md — all §2–§13 implemented)
- [x] All CONSTITUTION principles upheld (audited — no violations)

**Exit criteria:** tag `v1.0.0`, GitHub Actions produces release with macOS DMG,
Linux .deb, and Windows .zip. ✅

---

## Backlog (Post-1.0)

- Word / character count in script editor
- Multiple script slots (named presets)
- Font family selector
- Mirror/flip mode (reading from reflection)
- Linux Wayland explicit overlay layer protocol support

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

## Phase 1 — Core State & Logic (no UI) *(current)*

Goal: all business logic exists and is tested, zero UI.

- [ ] `SettingsState` + `SettingsNotifier` with load/save/clamp
- [ ] `PrompterState` + `PrompterNotifier`: transport state machine
- [ ] Countdown async loop
- [ ] Jump back / reset token mechanism
- [ ] Estimated read duration utility
- [ ] `shared_preferences` integration
- [ ] Unit tests: all transport transitions, all settings validation

**Exit criteria:** `flutter test` passes 100 %; coverage ≥ 80 % on notifier files.

---

## Phase 2 — Overlay Window

Goal: a visible always-on-top overlay window with scrolling text, no tray.

- [ ] `OverlayWindow` bootstrapped via `window_manager`
- [ ] Transparent, borderless, always-on-top, non-focusable
- [ ] Top-center positioning on primary display
- [ ] `NotchClipper` (macOS) and `RoundedBottomClipper` (Linux/Windows)
- [ ] Black fill, subtle border stroke
- [ ] `ScrollingTextView` — Ticker-driven, edge fade
- [ ] `CountdownView` — numeral countdown
- [ ] `ControlsHud` — play/pause, jump back, speed +/−
- [ ] Reposition on display config change

**Exit criteria:** overlay scrolls a test script smoothly; controls work via on-screen buttons.

---

## Phase 3 — System Tray & Hotkeys

Goal: full tray menu and global shortcuts; app has no Dock icon.

- [ ] `TrayManagerService` — icon, tooltip, dynamic menu
- [ ] Tray menu wired to `PrompterNotifier` and `SettingsNotifier`
- [ ] `Start / Pause` title reflects state reactively
- [ ] `hotkey_manager` global shortcuts (all 6 from SPEC §7)
- [ ] `LSUIElement = true` (macOS) / equivalent on Linux/Windows
- [ ] Privacy mode toggle visible on macOS only

**Exit criteria:** app runs with no Dock icon; all hotkeys fire when app is not focused.

---

## Phase 4 — Settings Window & Script Editor

Goal: full settings UI; script can be edited, imported, exported.

- [ ] Settings window opens from tray menu
- [ ] Sliders for all numeric settings
- [ ] Speed preset buttons (Slow / Normal / Fast)
- [ ] Countdown toggle (0 = Off)
- [ ] Privacy mode toggle (macOS only; hidden elsewhere)
- [ ] Estimated read duration live display
- [ ] Plain-text script editor
- [ ] Import script (file_picker, `.txt`, UTF-8)
- [ ] Export script (file_picker, default `script.txt`)
- [ ] Error dialogs on file IO failure

**Exit criteria:** full workflow — edit script → import → adjust settings → start scroll — works end-to-end.

---

## Phase 5 — macOS Polish

Goal: macOS-specific finishing touches.

- [ ] Privacy mode native channel (`NSWindow.sharingType = .none`)
- [ ] Verify notch blend on MacBook (black fill vs. physical notch)
- [ ] `NSWindowLevel` lock ensuring overlay survives fullscreen apps
- [ ] App-signed DMG build via `scripts/build_release_zip.sh` equivalent
- [ ] Code-sign and notarize (or document unsigned workaround as README)

**Exit criteria:** app passes manual testing on macBook with a real notch. DMG distributable.

---

## Phase 6 — Linux & Windows

Goal: verified, distributable builds for both platforms.

- [ ] Linux `.deb` / `.AppImage` packaging
- [ ] Linux tray: verify `tray_manager` on common DEs (GNOME, KDE)
- [ ] Windows `.exe` / MSIX packaging
- [ ] Windows tray icon
- [ ] HiDPI / scaling verification on both platforms
- [ ] Overlay positioning on multi-monitor setups

**Exit criteria:** app installs and runs without errors on Ubuntu 22.04+ and Windows 11.

---

## Phase 7 — 1.0 Release

- [ ] README updated with install instructions for all platforms
- [ ] GitHub Releases workflow (tag → build → upload artifacts)
- [ ] Changelog
- [ ] All SPEC items covered
- [ ] All CONSTITUTION principles upheld

---

## Backlog (Post-1.0)

- Word / character count in script editor
- Multiple script slots (named presets)
- Font family selector
- Mirror/flip mode (reading from reflection)
- Linux Wayland explicit overlay layer protocol support

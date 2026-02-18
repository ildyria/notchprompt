# Notchprompt Flutter — Feature Specification

**Version:** 0.1.0-draft  
**Status:** Active  
**Source of truth for:** All feature behavior, edge cases, and acceptance criteria.

---

## Table of Contents

1. [Overview](#1-overview)
2. [Transport Controls](#2-transport-controls)
3. [Countdown](#3-countdown)
4. [Scroll Engine](#4-scroll-engine)
5. [Overlay Window](#5-overlay-window)
6. [System Tray](#6-system-tray)
7. [Global Keyboard Shortcuts](#7-global-keyboard-shortcuts)
8. [Settings](#8-settings)
9. [Script Editor](#9-script-editor)
10. [Script File IO](#10-script-file-io)
11. [Persistence](#11-persistence)
12. [Privacy Mode (macOS only)](#12-privacy-mode-macos-only)
13. [Estimated Read Duration](#13-estimated-read-duration)

---

## 1. Overview

Notchprompt is a macOS-first, cross-platform desktop teleprompter. It displays a
floating, always-on-top overlay near the top of the primary display. The overlay
scrolls user-provided script text upward at a configurable speed. The app lives
entirely in the system tray — no Dock icon, no main window on launch.

---

## 2. Transport Controls

### 2.1 States

```
idle → [start] → countdown (if countdownSeconds > 0) → running
running → [pause] → idle
(idle | running | countdown) → [reset] → idle (scroll position = 0)
running → [jump back] → running (scroll position -= jumpBackDistance)
```

`TransportState` enum: `idle`, `countingDown`, `running`

### 2.2 Start / Pause

- **Start**: If `countdownSeconds > 0`, enter countdown state first. Otherwise
  transition directly to `running`.
- **Pause**: Transition from `running` → `idle`. Scroll position is preserved.
- Re-starting from `idle` (after a pause, without reset) resumes from the
  preserved position.
- `hasStartedSession` becomes `true` on first transition to `running`; resets
  to `false` on `reset`.

### 2.3 Reset

- Immediately halts scrolling and any active countdown.
- Scroll position returns to the top (offset = 0).
- `transportState` → `idle`.
- `hasStartedSession` → `false`.

### 2.4 Jump Back

- Only meaningful when `transportState == running`.
- `jumpBackDistancePoints = speedPointsPerSecond × 5.0` (always 5 seconds worth).
- If the resulting offset would be < 0, clamp to 0; do **not** error.

---

## 3. Countdown

- Duration: `countdownSeconds` (range 0–10, default 3).
- When 0: countdown phase is skipped entirely; transport goes directly to
  `running`.
- Display: large centered numeral in the overlay, counting down from N to 1.
  On reaching 0 the overlay transitions to the running scroll view without flash.
- Cancellation: any stop/reset action during countdown immediately cancels it.
- Countdown ticks at 1-second intervals driven by an async loop (not a `Timer`).

---

## 4. Scroll Engine

### 4.1 Driving Mechanism

- The scroll is driven by a `Ticker` (linked to `TickerProvider` / `AnimationController`)
  so it runs at the native display refresh rate.
- Each tick: `offset += speedPointsPerSecond × (elapsed / 1000)` (elapsed in ms).

### 4.2 Speed

| Property | Value |
|---|---|
| Range | 10 – 300 pts/sec |
| Step | 5 pts/sec |
| Default | 80 pts/sec |
| Presets | Slow: 55 / Normal: 85 / Fast: 125 |

Speed changes take effect on the next tick (no animation smoothing required, but
smoothing is allowed).

### 4.3 End-of-Script Behavior

- When the last line of text scrolls fully out of view, the scroll **stops**
  (transport → `idle`). It does not loop.
- An empty script shows a placeholder prompt; scrolling a blank script is a no-op.

### 4.4 Edge Fade

- Top and bottom `edgeFadeFraction` (20 % of viewport height) are masked with a
  gradient fade to transparent/black, so text appears to "emerge" and "exit"
  rather than hard-clip.

---

## 5. Overlay Window

### 5.1 Positioning

- Anchored to the **top-center of the primary display**.
- Width and height are user-configurable.

| Property | Default | Min | Max |
|---|---|---|---|
| `overlayWidth` | 600 px | 400 px | 1200 px |
| `overlayHeight` | 150 px | 120 px | 300 px |

- The window repositions automatically when display configuration changes
  (resolution, arrangement, connection/disconnection).

### 5.2 Window Properties

- `always_on_top`: true  
- `skip_taskbar`: true (no Dock / taskbar entry)  
- `decorations`: false (no title bar, no frame)  
- `transparent`: true (background drawn by Flutter, not OS chrome)  
- `focus_on_show`: false (overlay must never steal keyboard focus)  

### 5.3 Shape (macOS)

An `AppleNotchShape`-equivalent custom `CustomClipper`:
- Square top corners / flat top edge (flush with menu bar).
- Straight side walls for `~82 %` of height.
- Rounded lower corners with radius `≈ 18 %` of height.
- Fill: pure black (`#000000`) for notch blending.
- Subtle white border stroke (`opacity 5 %`) masked off at the top 2 px.

### 5.4 Shape (Linux / Windows)

Rounded-bottom rectangle (radius 8 px). Same black fill.

### 5.5 Controls HUD

Shown when `transportState != countingDown`. Two capsule-shaped control clusters
float at the top of the overlay:

**Left cluster:**
- Play / Pause button (SF Symbol equivalent: `play_arrow` / `pause`)
- Jump Back 5s button

**Right cluster:**
- Speed − (repeat-while-pressed)
- Speed + (repeat-while-pressed)

Buttons: 22×22 px, circular, semi-transparent white fill, white icon.

---

## 6. System Tray

- Tray icon label: `NP`
- Tooltip: `Notchprompt`

### Tray Menu

```
Start / Pause          ⌥⌘P   (title toggles dynamically)
Reset Scroll           ⌥⌘R
Jump Back 5s           ⌥⌘J
Privacy Mode ✓         ⌥⌘H   (checkmark when enabled; macOS only)
─────────────────────────────
Import Script…
Export Script…
─────────────────────────────
Settings…              ⌘,
─────────────────────────────
Quit Notchprompt       ⌘Q
```

- `Start / Pause` title must reflect current state reactively.
- `Privacy Mode` item is hidden on Linux/Windows.

---

## 7. Global Keyboard Shortcuts

| Shortcut | Action |
|---|---|
| `⌥⌘P` | Toggle start / pause |
| `⌥⌘R` | Reset scroll |
| `⌥⌘J` | Jump back 5 s |
| `⌥⌘H` | Toggle privacy mode (macOS only) |
| `⌥⌘=` | Increase speed by one step |
| `⌥⌘−` | Decrease speed by one step |

- Shortcuts fire even when the app is not focused (global monitor).
- Implemented via `hotkey_manager`.

---

## 8. Settings

All settings persist across launches (see §11).

| Setting | Type | Default | Range / Options |
|---|---|---|---|
| `speedPointsPerSecond` | double | 80 | 10–300, step 5 |
| `fontSize` | double | 20 | 12–40, step 1 |
| `overlayWidth` | double | 600 | 400–1200 |
| `overlayHeight` | double | 150 | 120–300 |
| `countdownSeconds` | int | 3 | 0–10 |
| `privacyModeEnabled` | bool | true | — |

Settings UI provides:
- Sliders for all numeric values.
- Three speed preset buttons: Slow / Normal / Fast.
- Countdown toggle (0 = disabled, label changes to "Off").
- Privacy mode toggle (macOS only; hidden on other platforms).
- Estimated read duration display (updates live as script changes).

---

## 9. Script Editor

- A plain-text `TextField` / `TextEditingController`.
- Default placeholder text:
  ```
  Paste your script here.

  Tip: Use the menu bar icon to start/pause or reset the scroll.
  ```
- No rich text, no markdown rendering — plain text only.
- Live character/word count shown below the editor (optional, P2).
- The editor lives in the **Settings window**, not the overlay.

---

## 10. Script File IO

### Import

- Opens a native file picker filtered to `.txt` files.
- On success: replaces current `script` content entirely.
- On failure: shows an error dialog with the OS error message.
- Encoding: UTF-8.

### Export

- Opens a native save panel defaulting to `script.txt`.
- Writes current `script` as UTF-8.
- On failure: shows an error dialog.

---

## 11. Persistence

Backed by `shared_preferences`.

| Key | Type | Notes |
|---|---|---|
| `hasSavedSession` | bool | Guard to skip loading on first-ever launch |
| `script` | String | Full script text |
| `speedPointsPerSecond` | double | |
| `fontSize` | double | |
| `overlayWidth` | double | |
| `overlayHeight` | double | |
| `countdownSeconds` | int | |
| `privacyModeEnabled` | bool | |

- `isRunning` is **never** persisted — always starts as `idle`.
- Persistence is debounced: save fires 250 ms after the last change.
- Values are clamped to valid ranges on load (never trust raw stored values).

---

## 12. Privacy Mode (macOS only)

- Implemented via `window_manager` platform channel calling
  `NSWindow.sharingType = .none`.
- When enabled: the overlay window does not appear in screenshots, screen
  recordings, or AirPlay mirrors (best-effort; app-dependent).
- When disabled: standard sharing behavior.
- State persisted (default: `true`).
- Silently no-ops on Linux/Windows.

---

## 13. Estimated Read Duration

```
words = script.trim().split(whitespace).count
speedFactor = speedPointsPerSecond / 85.0   // 85 = Normal preset
adjustedWPM = clamp(160 * speedFactor, 60, ∞)
durationSeconds = (words / adjustedWPM) * 60
```

Display format:
- `< 60s` → `~Xs`
- `≥ 60s` → `~Xm Ys`
- Empty script → `~0s`

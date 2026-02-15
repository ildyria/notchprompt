# Notchprompt

A native macOS notch-adjacent teleprompter for presentations and recordings, with keyboard and overlay controls designed for low-friction live use.

## Quick Demo

> Demo assets below are placeholders. Replace with real captures before public launch.

![Notchprompt hero screenshot](docs/media/hero.png)
*Hero view of the overlay panel and settings workflow.*

![Notchprompt scrolling demo GIF](docs/media/notchprompt-demo.gif)
*In-use scrolling demo with start/pause and speed adjustments.*

## Why This Project

Notchprompt focuses on a few practical engineering problems that show up in real recording workflows:

- Keeping a non-activating overlay panel pinned to the main display notch/menu bar area.
- Maintaining smooth real-time scrolling with pause, reset, and jump-back semantics.
- Providing privacy-mode capture controls through `NSWindow.SharingType` (best-effort, app-dependent).
- Supporting reliable keyboard control through both local and global key monitors.
- Persisting script and tuning settings through `UserDefaults` for quick session recovery.

## Feature Highlights

- Menu bar utility workflow (`NP` status item).
- Start/pause, reset, and jump back 5 seconds.
- Optional countdown before scrolling starts.
- Adjustable speed, font size, overlay width, and overlay height.
- Import/export plain text scripts.
- Inline estimated read-time calculation.
- On-overlay transport and speed controls.
- Privacy mode toggle with explicit best-effort behavior.

## Architecture Overview

Notchprompt is a single-process native macOS app built with SwiftUI + AppKit interop.

Core components:

- `PrompterModel`: Source of truth for script content, session state, countdown, speed, sizing, and persistence.
- `OverlayWindowController`: Manages overlay panel lifecycle, z-level, main-display positioning, and privacy sharing mode.
- `OverlayView` + `ScrollingTextView`: Renders notch-style chrome and the scrolling script surface.
- `ContentView` + `SettingsWindowController`: Main controls and settings window orchestration.
- `AppDelegate`: Status bar menu, command routing, keyboard shortcut wiring, and app lifecycle glue.
- `ScriptFileIO` / `FilePanelCoordinator`: Import/export file panels and text file operations.

Data flow (high level): script/settings input in settings window or menu actions updates `PrompterModel` state, and the model drives overlay rendering plus transport control behavior in real time.

## Tech Stack

- Swift 5
- SwiftUI
- AppKit
- Combine
- Xcode project (no SPM/CocoaPods dependencies)

## Requirements

- macOS compatible with the current Xcode project deployment target.
- Xcode 16+ (or equivalent toolchain compatibility for the project settings).
- Apple Silicon or Intel Mac that supports the target macOS version.

## Run Locally

```bash
cd /Users/saif/Documents/notchprompt/notchprompt
open notchprompt.xcodeproj
```

Or build from CLI:

```bash
cd /Users/saif/Documents/notchprompt/notchprompt
xcodebuild -project notchprompt.xcodeproj -scheme notchprompt -configuration Debug build
```

Notes:

- The app runs as a menu bar utility and opens settings via the status item menu.
- On first run, macOS behavior for display/capture interaction can vary by app and system settings.
- Privacy mode behavior is best-effort and depends on the screen-recording app in use.

## Usage

Happy path:

1. Paste or import a script.
2. Set speed, font, overlay size, and countdown.
3. Start scrolling.
4. Control playback from the menu bar or overlay controls.

Keyboard shortcuts:

| Shortcut | Action |
|---|---|
| `⌥⌘P` | Start / Pause |
| `⌥⌘R` | Reset scroll |
| `⌥⌘J` | Jump back 5s |
| `⌥⌘H` | Toggle Privacy Mode (menu command) |
| `⌥⌘=` | Increase speed |
| `⌥⌘-` | Decrease speed |

## Project Status

Active early-stage project.

### Roadmap

- Add automated unit/UI tests for model timing, scrolling state, and shortcut handling.
- Improve packaging/release flow for easier external testing.
- Add richer script formatting options while preserving readability.
- Improve multi-display behavior and explicit display selection controls.
- Add diagnostics/logging toggles for capture and overlay troubleshooting.

## Known Limitations

- Privacy mode is best-effort and capture behavior is app-dependent.
- Overlay behavior can vary with multi-display setups and menu bar auto-hide configuration.
- No automated test suite is currently committed in this repository.

## Contributing

Contributions are welcome.

- Open an issue before major architectural or UX changes.
- Keep pull requests small and focused.
- Include clear reproduction steps and validation notes in PR descriptions.

## License

License: TBD

If a `LICENSE` file is added, this section should link to it.

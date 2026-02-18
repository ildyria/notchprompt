# Notchprompt Flutter — Architecture

**Version:** 0.1.0-draft

---

## Folder Structure

```
notchprompt_flutter/
├── lib/
│   ├── main.dart                        # Entry point; initialises window, tray, providers
│   ├── app.dart                         # Root widget; MaterialApp shell (settings window)
│   ├── core/
│   │   ├── constants.dart               # kDefault* values, speed range, presets
│   │   ├── platform.dart                # Platform detection helpers
│   │   └── extensions.dart              # Dart extension methods
│   ├── features/
│   │   ├── overlay/
│   │   │   ├── overlay_window.dart      # window_manager bootstrap & reposition logic
│   │   │   ├── overlay_view.dart        # Root overlay widget (transparent window content)
│   │   │   ├── notch_clipper.dart       # CustomClipper — AppleNotchShape equivalent
│   │   │   ├── controls_hud.dart        # Play/pause, jump-back, speed +/- HUD
│   │   │   ├── countdown_view.dart      # Large numeral countdown overlay
│   │   │   └── scrolling_text_view.dart # Ticker-driven text scroller
│   │   ├── prompter/
│   │   │   ├── prompter_state.dart      # PrompterState value object (freezed)
│   │   │   ├── prompter_notifier.dart   # StateNotifier — all transport logic
│   │   │   └── prompter_provider.dart   # Riverpod provider exports
│   │   ├── settings/
│   │   │   ├── settings_state.dart      # SettingsState value object (freezed)
│   │   │   ├── settings_notifier.dart   # StateNotifier — load/save/validate
│   │   │   ├── settings_provider.dart   # Riverpod provider exports
│   │   │   └── settings_view.dart       # Settings window UI
│   │   ├── script/
│   │   │   ├── script_editor_view.dart  # Plain-text editor widget
│   │   │   └── script_file_io.dart      # Import / export via file_picker
│   │   └── tray/
│   │       └── tray_manager_service.dart # tray_manager setup & menu wiring
│   └── shared/
│       ├── widgets/
│       │   └── control_button.dart      # Reusable circular icon button
│       └── theme/
│           └── app_theme.dart           # Colors, text styles, dimensions
├── test/
│   ├── features/
│   │   ├── prompter/
│   │   │   └── prompter_notifier_test.dart
│   │   └── settings/
│   │       └── settings_notifier_test.dart
│   └── shared/
│       └── extensions_test.dart
├── pubspec.yaml
├── analysis_options.yaml
└── README.md
```

---

## State Architecture

### Two Independent State Slices

```
SettingsState (persisted)          PrompterState (session-only)
─────────────────────────          ──────────────────────────────
speedPointsPerSecond               transportState (idle|countingDown|running)
fontSize                           hasStartedSession
overlayWidth                       countdownRemaining
overlayHeight                      scrollOffset          ← owned by ScrollController
countdownSeconds                   jumpBackToken         ← UUID trigger
privacyModeEnabled                 resetToken            ← UUID trigger
script
```

`PrompterState` intentionally does NOT own `scrollOffset` directly — the
`ScrollingTextView` widget owns a `ScrollController` and reacts to
`resetToken`/`jumpBackToken` UUID changes, keeping animation inside the widget
layer.

### Provider Graph

```
settingsProvider  (StateNotifierProvider<SettingsNotifier, SettingsState>)
      │
      ├──► overlayWidthProvider    (select)
      ├──► overlayHeightProvider   (select)
      └──► scriptProvider          (select)

prompterProvider  (StateNotifierProvider<PrompterNotifier, PrompterState>)
      │
      └──► depends on settingsProvider for speedPointsPerSecond, countdownSeconds
```

---

## Data Flow

```
User input (button / hotkey / tray menu)
        │
        ▼
  PrompterNotifier.toggleRunning()
   / resetScroll() / jumpBack()
        │
        ▼
  PrompterState updated
        │
        ▼
  Widgets rebuild via ref.watch(prompterProvider)
        │
        ├──► CountdownView (if countingDown)
        ├──► ScrollingTextView (ticker starts/stops, jump applied)
        └──► ControlsHud (play/pause icon)
```

Settings changes flow independently:

```
SettingsView widget
        │
        ▼
  SettingsNotifier.updateSpeed() / updateFontSize() / ...
        │
        ▼
  SettingsState updated → debounced save to shared_preferences
        │
        ▼
  Overlay rebuilds via ref.watch(settingsProvider.select(...))
```

---

## Window Architecture

Two separate OS windows:

| Window | Role | always_on_top | decorations | transparent |
|---|---|---|---|---|
| Overlay | Scrolling teleprompter | true | false | true |
| Settings | Script editor + settings | false | true | false |

`window_manager` manages the overlay window.  
The settings window is a standard Flutter `Window` (managed by `runApp`).

On macOS, `window_manager` is used to call the notch-shape window mask via a
method channel. On Linux/Windows, a `CustomClipper` alone handles the shape.

---

## Platform Abstraction

`lib/core/platform.dart` exposes:

```dart
abstract class PlatformServices {
  static bool get isMacOS => Platform.isMacOS;
  static bool get supportsPrivacyMode => Platform.isMacOS;
  static bool get hasNotch => Platform.isMacOS; // conservative default
}
```

Platform-specific implementations (e.g., privacy mode native channel) are
gated behind `if (PlatformServices.isMacOS)` at the call site; no conditional
imports required at this scale.

---

## Scroll Engine Detail

```
ScrollingTextView
  └── SingleTickerProviderStateMixin
        └── AnimationController (vsync: this, duration: ∞)
              └── Ticker callback:
                    elapsed = ticker.elapsed since last frame
                    offset += (speed pts/sec) × (elapsed.inMicroseconds / 1e6)
                    scrollController.jumpTo(offset)
```

- `speed` is read from `ref.read(settingsProvider).speedPointsPerSecond` each
  tick (no rebuild cost; `read` not `watch` inside the ticker).
- `resetToken` change → `scrollController.jumpTo(0)`.
- `jumpBackToken` change → `scrollController.jumpTo(max(0, offset - jumpBackDistance))`.

---

## Persistence Strategy

`SettingsNotifier` owns read/write:

1. `loadSettings()` called once at app start; guards with `hasSavedSession`.
2. Every mutating method calls `_scheduleSave()`.
3. `_scheduleSave()` debounces with a 250 ms `Timer`; cancels previous timer.
4. `_save()` writes all fields to `SharedPreferences`; clamps before writing.

---

## Testing Strategy

| Layer | Tool | Coverage target |
|---|---|---|
| `PrompterNotifier` | `flutter_test` unit tests | All transport transitions |
| `SettingsNotifier` | `flutter_test` unit tests | Load/save/clamp/validate |
| `ScrollingTextView` | Widget test (pump + verify offset) | Basic start/stop/reset |
| File IO | Unit test with mock `FilePicker` | Happy path + error paths |
| Tray wiring | Manual / integration test | Not automated at MVP |

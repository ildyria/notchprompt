# AGENTS.md — AI Agent Guidelines for Notchprompt Flutter

This file provides authoritative guidance for any AI coding agent (GitHub Copilot,
Cursor, Aider, Claude, GPT, etc.) working on this repository.

**Read this file before making any change. Follow it strictly.**

---

## 1. First, Read These Files

Before writing a single line of code, read:

1. [`docs/CONSTITUTION.md`](docs/CONSTITUTION.md) — Non-negotiable principles.
2. [`docs/SPEC.md`](docs/SPEC.md) — Exact feature behavior and acceptance criteria.
3. [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) — Folder structure and state design.
4. [`docs/ROADMAP.md`](docs/ROADMAP.md) — Current phase and what is in/out of scope.

If any instruction in a user prompt conflicts with the CONSTITUTION, **the
CONSTITUTION wins**. Surface the conflict; do not silently ignore it.

---

## 2. Repository Layout

```
notchprompt/              ← original macOS Swift source (read-only reference)
notchprompt_flutter/      ← Flutter port (active development target)
docs/                     ← spec, architecture, constitution, roadmap
AGENTS.md                 ← this file
```

All new Flutter code lives under `notchprompt_flutter/`. Do not modify the Swift
source unless explicitly asked.

---

## 3. What You Are Allowed to Do

- Implement features described in `SPEC.md` that fall within the current
  roadmap phase.
- Write, edit, or delete files under `notchprompt_flutter/`.
- Write tests under `notchprompt_flutter/test/`.
- Update `docs/` files when a spec detail is clarified (mark changes clearly).
- Update `pubspec.yaml` to add dependencies approved in `CONSTITUTION.md §5`.

---

## 4. What You Must NOT Do

- Do not add state management libraries other than Riverpod.
- Do not add `setState` for shared/cross-widget state.
- Do not place business logic inside widget `build()` methods.
- Do not use `Timer` for the scroll animation — use `Ticker` / `AnimationController`.
- Do not import platform packages (`dart:io`, `window_manager`, etc.) directly
  in feature business-logic files — route through service/abstraction classes.
- Do not create files outside the structure defined in `ARCHITECTURE.md` without
  first proposing the change.
- Do not modify `CONSTITUTION.md` — it requires human review.
- Do not commit secrets, API keys, or credentials of any kind.
- Do not add mobile (`android`/`ios`) platform folders to the Flutter project.

---

## 5. Code Style Defaults

Follow these unless the existing code in the file does otherwise:

```dart
// ✅ Good
final class PrompterNotifier extends StateNotifier<PrompterState> { ... }

// ❌ Bad — mutable class, no encapsulation
class PrompterNotifier extends StateNotifier<PrompterState> {
  var _somePublicField = 0;
}
```

- **Dart version:** use the version in `pubspec.yaml`; do not use features not
  supported by that version.
- **Null safety:** always sound null safety — no `!` force-unwrap without a
  comment explaining why it is safe.
- **Prefer `const`** constructors and widgets wherever possible.
- **No `dynamic`** — explicit types everywhere. `analysis_options.yaml` enforces
  this; the build will fail on violations.
- **Trailing commas** on all multi-line argument lists and collection literals.
- **max line length:** 100 characters.
- **Imports order:** dart: → package: → relative, separated by blank lines.
- **No commented-out code** in committed files. Delete dead code.

---

## 6. Naming Quick Reference

| Thing | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `prompter_notifier.dart` |
| Classes | `PascalCase` | `PrompterNotifier` |
| Providers | `camelCase` + `Provider` | `prompterProvider` |
| Constants | `kCamelCase` | `kDefaultSpeed` |
| Private fields | `_camelCase` | `_scrollOffset` |
| Test files | mirror source under `test/` | `test/features/prompter/prompter_notifier_test.dart` |

---

## 7. Testing Requirements

- Every new `StateNotifier` subclass must ship with a corresponding
  `*_notifier_test.dart` file in the same PR/commit.
- Tests must cover: happy path, edge cases (empty input, boundary values),
  and at least one error/exception path per public method.
- Use `ProviderContainer` for unit testing notifiers — do not use
  `WidgetTester` for pure logic tests.
- Test file template:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:notchprompt/features/prompter/prompter_provider.dart';

void main() {
  group('PrompterNotifier', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is idle', () {
      final state = container.read(prompterProvider);
      expect(state.transportState, TransportState.idle);
    });
  });
}
```

---

## 8. Dependency Approval Checklist

Before adding a new package to `pubspec.yaml`:

1. Does it exist in the approved list in `CONSTITUTION.md §5`? ✅ Add it.
2. If not: does it have pub.dev score ≥ 120 AND active maintenance? Document
   your justification in a code comment above the dependency line in `pubspec.yaml`.
3. Never add a package that shells out to an external binary silently.
4. Never add a package that requires internet access at runtime.

---

## 9. Platform Guard Pattern

When writing platform-specific code:

```dart
// ✅ Correct
import 'package:notchprompt/core/platform.dart';

if (PlatformServices.isMacOS) {
  await _applyPrivacyMode();
}

// ❌ Wrong — leaks dart:io into business logic
import 'dart:io';
if (Platform.isMacOS) { ... }
```

---

## 10. Commit Message Format

```
<type>(<scope>): <short imperative description>

[optional body]

[optional footer: Closes #issue]
```

Types: `feat` | `fix` | `refactor` | `test` | `docs` | `chore` | `perf`

Examples:
```
feat(overlay): add Ticker-driven scroll animation
fix(prompter): clamp jump-back offset to zero at start of script
test(settings): add clamp validation cases for overlayWidth
docs(spec): clarify end-of-script idle transition
```

---

## 11. Pull Request Checklist

Before marking a PR ready for review:

- [ ] `flutter analyze` — zero errors, zero warnings
- [ ] `flutter test` — all tests pass
- [ ] New `StateNotifier` has tests
- [ ] No `TODO` comments left unresolved
- [ ] No new dependency added without justification comment
- [ ] SPEC.md consulted and behavior matches exactly
- [ ] CONSTITUTION.md not violated

---

## 12. When You Are Unsure

1. **Check SPEC.md first** — most behavioral questions are answered there.
2. **Check ARCHITECTURE.md** — most structural questions are answered there.
3. **Do not guess at business rules** — surface the ambiguity as a comment or
   question rather than inventing behavior.
4. **Do not auto-fix lints by disabling them** — fix the actual code.

---

## 13. Reference: Swift → Flutter Mapping

Use this when porting logic from the macOS Swift source.

| Swift (notchprompt/) | Flutter equivalent |
|---|---|
| `PrompterModel` (`ObservableObject`) | `PrompterNotifier` + `SettingsNotifier` |
| `@Published var isRunning` | `PrompterState.transportState` |
| `@Published var script` | `SettingsState.script` |
| `model.toggleRunning()` | `ref.read(prompterProvider.notifier).toggleRunning()` |
| `model.resetScroll()` | `ref.read(prompterProvider.notifier).resetScroll()` |
| `model.jumpBack(seconds:)` | `ref.read(prompterProvider.notifier).jumpBack()` |
| `resetToken: UUID` | `PrompterState.resetToken: String (UUID)` |
| `jumpBackToken: UUID` | `PrompterState.jumpBackToken: String (UUID)` |
| `UserDefaults` | `SharedPreferences` via `SettingsNotifier` |
| `NSStatusItem` | `tray_manager` |
| `NSEvent.addGlobalMonitor` | `hotkey_manager` |
| `OverlayWindowController` | `window_manager` + `OverlayWindow` |
| `ScrollingTextView (NSView)` | `ScrollingTextView` with `AnimationController` |
| `AppleNotchShape` | `NotchClipper` (`CustomClipper<Path>`) |
| `ScriptFileIO` | `ScriptFileIO` (Dart, `file_picker`) |

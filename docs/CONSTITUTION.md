# Notchprompt Flutter — Constitution

This document defines the non-negotiable principles and constraints that govern
all development on this project. Every contributor and every AI agent MUST treat
this file as the highest-authority document in the repository.

---

## 1. Product Identity

Notchprompt is a **desktop teleprompter utility**, not a general-purpose app.
Every decision — feature, UI, dependency — must serve a presenter in front of a
camera or audience. If a change does not serve that person, it does not belong.

---

## 2. Platform Targets

| Priority | Platform |
|---|---|
| P0 | macOS (primary, must ship first) |
| P1 | Linux |
| P2 | Windows |

Platform-specific code is acceptable when necessary, but must be isolated behind
abstractions. Shared business logic must never import platform packages directly.

---

## 3. Architecture Law

1. **Feature-first folder structure** — code lives under `lib/features/<feature>/`,
   never in a flat `lib/` root dump.
2. **Unidirectional data flow** — UI reads state, UI dispatches events, state
   changes flow downward. No widget mutates shared state directly.
3. **One state solution** — [Riverpod](https://riverpod.dev/) is the sole state
   management library. Do not introduce `Provider`, `Bloc`, `GetX`, or `setState`
   for shared state.
4. **No business logic in widgets** — all logic lives in `Notifier` / `StateNotifier`
   classes or service objects. Widgets are dumb renderers.
5. **Test at the boundary** — every `Notifier` and every service must have unit
   tests. Widget tests are welcome but not blocking.

---

## 4. UI / Visual Constraints

1. The overlay window must be **always-on-top**, **borderless**, and
   **transparent-background** on all platforms.
2. The overlay shape on macOS must visually reference the notch aesthetic:
   black fill, subtle rounded-bottom corners, no title bar.
3. On Linux/Windows the overlay is a **top-anchored floating bar** — no notch
   shape is required but the same sizing/positioning logic applies.
4. **No Material widgets inside the overlay** — the overlay uses only custom
   painted/composed widgets. `AppBar`, `Scaffold`, `Card` are forbidden in the
   overlay subtree.
5. Font rendering must be **crisp at small sizes** — prefer `TextStyle` with
   explicit `fontFeatures` and `letterSpacing` over defaults.
6. The settings/editor window MAY use standard Material or Cupertino widgets.

---

## 5. Dependency Policy

- Prefer packages from the [leanflutter](https://github.com/leanflutter) ecosystem
  for window management, tray, and hotkeys.
- Every new dependency requires a one-line justification comment in `pubspec.yaml`.
- Dependencies must have a pub.dev score ≥ 120 OR be actively maintained by a
  known author reviewed and approved in a PR comment.
- Zero tolerance for packages that pull in platform-specific SDKs without a clear
  containment strategy.

### Pinned Packages (do not change major version without a SPEC update)

| Package | Role |
|---|---|
| `flutter_riverpod` | State management |
| `window_manager` | Overlay window control |
| `tray_manager` | System tray |
| `hotkey_manager` | Global keyboard shortcuts |
| `file_picker` | Script import/export |
| `shared_preferences` | Settings persistence |

---

## 6. Performance Constraints

- The scrolling animation must run at the **native display refresh rate**
  (`Ticker`-driven, not `Timer`-driven).
- The overlay window must consume < 2 % CPU at idle (no animation running).
- Settings must load synchronously from cache on first frame; async refresh is
  acceptable afterward.

---

## 7. Naming Conventions

| Thing | Convention | Example |
|---|---|---|
| Files | `snake_case.dart` | `prompter_state.dart` |
| Classes | `PascalCase` | `PrompterNotifier` |
| Providers | `camelCase` + `Provider` suffix | `prompterProvider` |
| Enums | `PascalCase` values | `TransportState.running` |
| Constants | `kCamelCase` | `kDefaultSpeed` |
| Test files | mirror source path under `test/` | `test/features/overlay/prompter_notifier_test.dart` |

---

## 8. What Is Out of Scope (Forever)

- Cloud sync or account system
- Mobile (iOS / Android) targets
- Video recording or capture
- Voice / speech recognition
- Collaborative editing
- In-app purchases or licensing checks
- Privacy mode (screen-capture blocking) on Linux/Windows — no reliable API exists

---

## 9. Versioning

[Semantic Versioning 2.0](https://semver.org/). `MAJOR.MINOR.PATCH`.

- `PATCH` — bug fixes, no API changes
- `MINOR` — new features, backward-compatible
- `MAJOR` — breaking changes or complete rewrites

Initial public release target: `1.0.0`.

---

## 10. Amendments

Changes to this document require a PR with the title prefix `[CONSTITUTION]` and
must be reviewed by at least one human maintainer. AI agents must not auto-merge
constitution changes.

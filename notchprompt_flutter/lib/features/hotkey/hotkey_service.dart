import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';

import '../../core/constants.dart';
import '../../core/platform.dart';
import '../prompter/prompter_provider.dart';
import '../settings/settings_provider.dart';

/// Registers and manages all six global keyboard shortcuts defined in SPEC §7.
///
/// | Shortcut | Action                          |
/// |----------|---------------------------------|
/// | ⌥⌘P     | Toggle start / pause            |
/// | ⌥⌘R     | Reset scroll                    |
/// | ⌥⌘J     | Jump back 5 s                   |
/// | ⌥⌘H     | Toggle privacy mode (macOS only)|
/// | ⌥⌘=     | Increase speed by one step      |
/// | ⌥⌘−     | Decrease speed by one step      |
///
/// Shortcuts fire even when the app is not focused (global monitor).
class HotkeyService {
  HotkeyService(this._ref);

  final Ref _ref;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> init() async {
    await hotKeyManager.unregisterAll();
    await _register(
      _hotkey(LogicalKeyboardKey.keyP),
      () => _ref.read(prompterProvider.notifier).toggleRunning(),
    );
    await _register(
      _hotkey(LogicalKeyboardKey.keyR),
      () => _ref.read(prompterProvider.notifier).resetScroll(),
    );
    await _register(
      _hotkey(LogicalKeyboardKey.keyJ),
      () => _ref.read(prompterProvider.notifier).jumpBack(),
    );
    if (isMacOS) {
      await _register(
        _hotkey(LogicalKeyboardKey.keyH),
        () => _ref.read(settingsProvider.notifier).togglePrivacyMode(),
      );
    }
    await _register(
      _hotkey(LogicalKeyboardKey.equal),
      () => _ref.read(settingsProvider.notifier).adjustSpeed(kSpeedStep),
    );
    await _register(
      _hotkey(LogicalKeyboardKey.minus),
      () => _ref.read(settingsProvider.notifier).adjustSpeed(-kSpeedStep),
    );
  }

  Future<void> dispose() async {
    await hotKeyManager.unregisterAll();
  }

  // ─── Helpers ─────────────────────────────────────────────────────────────

  /// Builds a HotKey with Alt+Meta (⌥⌘) modifiers.
  HotKey _hotkey(LogicalKeyboardKey key) => HotKey(
        key: key,
        modifiers: [HotKeyModifier.alt, HotKeyModifier.meta],
      );

  Future<void> _register(HotKey hotKey, VoidCallback handler) async {
    try {
      await hotKeyManager.register(
        hotKey,
        keyDownHandler: (_) => handler(),
      );
    } on Exception catch (e) {
      debugPrint('[HotkeyService] failed to register ${hotKey.key}: $e');
    }
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notchprompt/core/constants.dart';
import 'package:notchprompt/core/extensions.dart';
import 'package:notchprompt/features/settings/settings_state.dart';

// ─── SharedPreferences key names ─────────────────────────────────────────────

abstract final class _Key {
  static const String hasSavedSession = 'hasSavedSession';
  static const String script = 'script';
  static const String speed = 'speedPointsPerSecond';
  static const String fontSize = 'fontSize';
  static const String overlayWidth = 'overlayWidth';
  static const String overlayHeight = 'overlayHeight';
  static const String countdownSeconds = 'countdownSeconds';
  static const String privacyModeEnabled = 'privacyModeEnabled';
}

// ─── Notifier ─────────────────────────────────────────────────────────────────

/// Manages all user-configurable settings with load/save/clamp behaviour.
///
/// Persistence is debounced: the last change within [kSaveDebounceMs] ms wins.
class SettingsNotifier extends StateNotifier<SettingsState> {
  SettingsNotifier(this._prefs) : super(const SettingsState());

  final SharedPreferences _prefs;
  Timer? _saveTimer;

  // ─── Public mutators ───────────────────────────────────────────────────────

  void updateScript(String value) {
    state = state.copyWith(script: value);
    _scheduleSave();
  }

  void updateSpeed(double value) {
    state = state.copyWith(speedPointsPerSecond: clampSpeed(value));
    _scheduleSave();
  }

  void applySpeedPreset(double preset) => updateSpeed(preset);

  void adjustSpeed(double delta) =>
      updateSpeed(state.speedPointsPerSecond + delta);

  void updateFontSize(double value) {
    state = state.copyWith(
      fontSize: clampDouble(value, kMinFontSize, kMaxFontSize),
    );
    _scheduleSave();
  }

  void updateOverlayWidth(double value) {
    state = state.copyWith(
      overlayWidth: clampDouble(value, kMinOverlayWidth, kMaxOverlayWidth),
    );
    _scheduleSave();
  }

  void updateOverlayHeight(double value) {
    state = state.copyWith(
      overlayHeight: clampDouble(value, kMinOverlayHeight, kMaxOverlayHeight),
    );
    _scheduleSave();
  }

  void updateCountdownSeconds(int value) {
    state = state.copyWith(
      countdownSeconds:
          clampInt(value, kMinCountdownSeconds, kMaxCountdownSeconds),
    );
    _scheduleSave();
  }

  void togglePrivacyMode() {
    state = state.copyWith(privacyModeEnabled: !state.privacyModeEnabled);
    _scheduleSave();
  }

  void setPrivacyMode({required bool enabled}) {
    state = state.copyWith(privacyModeEnabled: enabled);
    _scheduleSave();
  }

  // ─── Persistence ──────────────────────────────────────────────────────────

  /// Loads persisted settings. If no session has been saved, defaults are kept.
  void loadSettings() {
    if (!_prefs.containsKey(_Key.hasSavedSession)) return;

    final savedScript = _prefs.getString(_Key.script);
    final savedSpeed = _prefs.getDouble(_Key.speed);
    final savedFontSize = _prefs.getDouble(_Key.fontSize);
    final savedWidth = _prefs.getDouble(_Key.overlayWidth);
    final savedHeight = _prefs.getDouble(_Key.overlayHeight);
    final savedCountdown = _prefs.getInt(_Key.countdownSeconds);
    final savedPrivacy = _prefs.getBool(_Key.privacyModeEnabled);

    state = SettingsState(
      script: savedScript ?? state.script,
      speedPointsPerSecond:
          savedSpeed != null ? clampSpeed(savedSpeed) : state.speedPointsPerSecond,
      fontSize: savedFontSize != null
          ? clampDouble(savedFontSize, kMinFontSize, kMaxFontSize)
          : state.fontSize,
      overlayWidth: savedWidth != null
          ? clampDouble(savedWidth, kMinOverlayWidth, kMaxOverlayWidth)
          : state.overlayWidth,
      overlayHeight: savedHeight != null
          ? clampDouble(savedHeight, kMinOverlayHeight, kMaxOverlayHeight)
          : state.overlayHeight,
      countdownSeconds: savedCountdown != null
          ? clampInt(savedCountdown, kMinCountdownSeconds, kMaxCountdownSeconds)
          : state.countdownSeconds,
      privacyModeEnabled: savedPrivacy ?? state.privacyModeEnabled,
    );
  }

  void _scheduleSave() {
    _saveTimer?.cancel();
    _saveTimer = Timer(
      const Duration(milliseconds: kSaveDebounceMs),
      _save,
    );
  }

  void _save() {
    _prefs.setBool(_Key.hasSavedSession, true);
    _prefs.setString(_Key.script, state.script);
    _prefs.setDouble(_Key.speed, state.speedPointsPerSecond);
    _prefs.setDouble(_Key.fontSize, state.fontSize);
    _prefs.setDouble(_Key.overlayWidth, state.overlayWidth);
    _prefs.setDouble(_Key.overlayHeight, state.overlayHeight);
    _prefs.setInt(_Key.countdownSeconds, state.countdownSeconds);
    _prefs.setBool(_Key.privacyModeEnabled, state.privacyModeEnabled);
  }

  @override
  void dispose() {
    _saveTimer?.cancel();
    super.dispose();
  }
}

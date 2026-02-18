import 'package:freezed_annotation/freezed_annotation.dart';

part 'settings_state.freezed.dart';

/// All user-configurable settings. This is the persisted slice of app state.
@freezed
class SettingsState with _$SettingsState {
  const factory SettingsState({
    @Default(80.0) double speedPointsPerSecond,
    @Default(20.0) double fontSize,
    @Default(600.0) double overlayWidth,
    @Default(150.0) double overlayHeight,
    @Default(3) int countdownSeconds,
    @Default(true) bool privacyModeEnabled,
    @Default('Paste your script here.\n\nTip: Use the menu bar icon to start/pause or reset the scroll.')
    String script,
  }) = _SettingsState;
}

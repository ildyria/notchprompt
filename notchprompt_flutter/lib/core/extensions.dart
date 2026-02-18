import 'package:notchprompt/core/constants.dart';

/// Clamps [value] to [min]..[max] and snaps to nearest [step].
double clampAndStep(double value, double min, double max, double step) {
  final clamped = value.clamp(min, max);
  return (clamped / step).roundToDouble() * step;
}

/// Clamps [value] to [min]..[max].
double clampDouble(double value, double min, double max) =>
    value.clamp(min, max);

/// Clamps [value] to [min]..[max].
int clampInt(int value, int min, int max) => value.clamp(min, max);

/// Validates and clamps a speed value to the legal range and step.
double clampSpeed(double value) =>
    clampAndStep(value, kMinSpeed, kMaxSpeed, kSpeedStep);

/// Formats a duration in seconds as a human-readable string.
/// - < 60 s → `~Xs`
/// - ≥ 60 s → `~Xm Ys`
/// - 0     → `~0s`
String formatDuration(int seconds) {
  if (seconds <= 0) return '~0s';
  if (seconds < 60) return '~${seconds}s';
  final minutes = seconds ~/ 60;
  final secs = seconds % 60;
  return '~${minutes}m ${secs.toString().padLeft(2, '0')}s';
}

/// Estimates read duration from script text at the given speed (pts/sec).
int estimateReadSeconds(String script, double speedPointsPerSecond) {
  final trimmed = script.trim();
  if (trimmed.isEmpty) return 0;
  final words = trimmed.split(RegExp(r'\s+')).length;
  final speedFactor = speedPointsPerSecond / kSpeedPresetNormal;
  final adjustedWpm = (160.0 * speedFactor).clamp(60.0, double.infinity);
  return ((words / adjustedWpm) * 60).round();
}

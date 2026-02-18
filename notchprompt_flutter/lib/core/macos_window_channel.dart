import 'package:flutter/services.dart';

import '../../core/platform.dart';

/// Dart-side client for the `notchprompt/window` method channel.
///
/// All calls silently no-op on non-macOS platforms so callers do not need to
/// guard on the platform themselves. The channel is only registered in
/// `macos/Runner/AppDelegate.swift`.
///
/// Per CONSTITUTION §3: platform-specific APIs must not be called directly in
/// feature code. Route through this service class instead.
class MacOSWindowChannel {
  MacOSWindowChannel._();

  static const MethodChannel _channel =
      MethodChannel('notchprompt/window');

  /// Sets `NSWindow.sharingType` to `.none` (enabled) or `.readOnly` (disabled).
  ///
  /// When enabled the overlay window will not appear in screen captures,
  /// screen recordings, or AirPlay mirrors.
  ///
  /// No-ops on Linux and Windows.
  static Future<void> setPrivacyMode({required bool enabled}) async {
    if (!isMacOS) return;
    try {
      await _channel.invokeMethod<void>(
        'setPrivacyMode',
        <String, dynamic>{'enabled': enabled},
      );
    } on PlatformException catch (e) {
      // Silently degrade — privacy mode is best-effort.
      assert(false, '[MacOSWindowChannel.setPrivacyMode] $e');
    }
  }

  /// Sets `NSWindow.level` on all Flutter windows.
  ///
  /// Use [WindowLevel.screenSaver] for the overlay so it sits above fullscreen
  /// apps (matches `OverlayWindowController` in the original Swift source).
  ///
  /// No-ops on Linux and Windows.
  static Future<void> setWindowLevel(WindowLevel level) async {
    if (!isMacOS) return;
    try {
      await _channel.invokeMethod<void>(
        'setWindowLevel',
        <String, dynamic>{'level': level.name},
      );
    } on PlatformException catch (e) {
      assert(false, '[MacOSWindowChannel.setWindowLevel] $e');
    }
  }
}

/// Window level names understood by `macos/Runner/AppDelegate.swift`.
enum WindowLevel {
  normal,
  floating,
  screenSaver,
  tornOffMenu,
}

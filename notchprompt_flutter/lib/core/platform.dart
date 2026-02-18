import 'dart:io';

// ignore: avoid_classes_with_only_static_members
/// Platform detection abstraction.
///
/// All platform-specific guards MUST go through this class.
/// Do not import dart:io Platform directly in feature code.
abstract final class PlatformServices {
  static bool get isMacOS => Platform.isMacOS;
  static bool get isLinux => Platform.isLinux;
  static bool get isWindows => Platform.isWindows;

  /// Whether the OS supports window screen-capture blocking.
  /// Only macOS provides a reliable API (NSWindow.sharingType).
  static bool get supportsPrivacyMode => Platform.isMacOS;

  /// Whether the physical device has a notch that the overlay should blend into.
  static bool get hasNotch => Platform.isMacOS;
}

import 'dart:io';

/// Platform detection abstraction.
///
/// All platform-specific guards MUST go through these accessors.
/// Do not import dart:io Platform directly in feature code.
bool get isMacOS => Platform.isMacOS;
bool get isLinux => Platform.isLinux;
bool get isWindows => Platform.isWindows;

/// Whether the OS supports window screen-capture blocking.
/// Only macOS provides a reliable API (NSWindow.sharingType).
bool get supportsPrivacyMode => Platform.isMacOS;

/// Whether the physical device has a notch the overlay should blend into.
bool get hasNotch => Platform.isMacOS;

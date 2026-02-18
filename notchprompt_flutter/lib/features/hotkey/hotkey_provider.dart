import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'hotkey_service.dart';

export 'hotkey_service.dart' show HotkeyService;

/// Holds the single [HotkeyService] instance for the app lifetime.
///
/// Call `ref.read(hotkeyProvider).init()` once in `main()` after
/// `ProviderScope` is ready.
final hotkeyProvider = Provider<HotkeyService>(
  HotkeyService.new,
);

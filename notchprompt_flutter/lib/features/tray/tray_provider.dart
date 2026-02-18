import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'tray_service.dart';

export 'tray_service.dart' show settingsWindowRequestProvider;

/// Holds the single [TrayService] instance for the app lifetime.
///
/// The provider is read once in `main()` after `ProviderScope` is available;
/// callers should call `ref.read(trayProvider).init()` at startup and
/// rely on the service's internal listeners for subsequent updates.
final trayProvider = Provider<TrayService>(
  TrayService.new,
);

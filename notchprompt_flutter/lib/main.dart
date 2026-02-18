import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hotkey_manager/hotkey_manager.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'app.dart';
import 'features/hotkey/hotkey_provider.dart';
import 'features/settings/settings_provider.dart';
import 'features/tray/tray_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();
  await hotKeyManager.unregisterAll();

  // Settings window options — standard decorated window for script editing.
  const settingsWindowOptions = WindowOptions(
    size: Size(680, 560),
    minimumSize: Size(500, 400),
    center: true,
    title: 'Notchprompt',
    skipTaskbar: false,
    titleBarStyle: TitleBarStyle.normal,
  );
  await windowManager.waitUntilReadyToShow(settingsWindowOptions);

  final prefs = await SharedPreferences.getInstance();

  final container = ProviderContainer(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
    ],
  );

  // Initialise tray and global hotkeys using the root container.
  await container.read(trayProvider).init();
  await container.read(hotkeyProvider).init();

  runApp(
    UncontrolledProviderScope(
      container: container,
      child: const NotchpromptApp(),
    ),
  );
}

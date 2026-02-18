import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:window_manager/window_manager.dart';

import 'package:notchprompt/app.dart';
import 'package:notchprompt/features/settings/settings_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await windowManager.ensureInitialized();

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

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(prefs),
      ],
      child: const NotchpromptApp(),
    ),
  );
}

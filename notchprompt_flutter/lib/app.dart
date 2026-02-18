import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notchprompt/features/settings/settings_view.dart';
import 'package:notchprompt/shared/theme/app_theme.dart';

/// Root widget. Hosts the settings/script-editor window.
/// The overlay window is managed separately via window_manager.
class NotchpromptApp extends ConsumerWidget {
  const NotchpromptApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return MaterialApp(
      title: 'Notchprompt',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const SettingsView(),
    );
  }
}

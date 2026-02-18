import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:window_manager/window_manager.dart';

import 'features/overlay/overlay_window.dart';
import 'features/settings/settings_view.dart';
import 'features/tray/tray_provider.dart';
import 'shared/theme/app_theme.dart';

/// Root widget.
///
/// Switches between the settings window and the transparent overlay window
/// based on [overlayWindowProvider].  Both share the same Flutter engine
/// instance — the OS window chrome is managed by [OverlayWindowManager].
///
/// Also reacts to the [settingsWindowRequestProvider] signal emitted by the
/// tray "Settings…" menu item — when the overlay is visible it hides it so
/// the settings window is shown.
class NotchpromptApp extends ConsumerStatefulWidget {
  const NotchpromptApp({super.key});

  @override
  ConsumerState<NotchpromptApp> createState() => _NotchpromptAppState();
}

class _NotchpromptAppState extends ConsumerState<NotchpromptApp> {
  @override
  void initState() {
    super.initState();
    // Listen for tray "Settings…" requests.
    ref.listenManual<int>(
      settingsWindowRequestProvider,
      (_, __) => _handleSettingsRequest(),
    );
  }

  void _handleSettingsRequest() {
    final isOverlay = ref.read(overlayWindowProvider).isVisible;
    if (isOverlay) {
      // Hide overlay → revert window to settings mode.
      ref.read(overlayWindowProvider.notifier).hide();
    } else {
      // Already in settings mode — bring it to front in case it's behind.
      windowManager.show();
      windowManager.focus();
    }
  }

  @override
  Widget build(BuildContext context) {
    final overlayVisible = ref.watch(
      overlayWindowProvider.select((s) => s.isVisible),
    );

    return MaterialApp(
      title: 'Notchprompt',
      debugShowCheckedModeBanner: false,
      theme: appDarkTheme,
      home: overlayVisible ? const OverlayRoot() : const SettingsView(),
    );
  }
}

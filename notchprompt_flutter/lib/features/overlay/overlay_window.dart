import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:window_manager/window_manager.dart';

import '../../core/macos_window_channel.dart';
import '../../core/platform.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_state.dart';
import 'overlay_view.dart';

/// Bootstraps and manages the always-on-top transparent overlay window.
///
/// Call [OverlayWindowManager.show] once the Riverpod container is ready.
/// The window listens to settings changes and resizes/repositiones itself
/// whenever [SettingsState.overlayWidth] or [SettingsState.overlayHeight]
/// change.
///
/// Architecture note: a single-window Flutter app cannot spawn a true second
/// OS window from within the same isolate with `window_manager` alone. The
/// overlay is therefore rendered inside the *same* window as the app but with
/// its own MaterialApp root — the settings window and overlay window are
/// separate OS windows only when a multi-window embedding solution is used.
///
/// For Phase 2 the overlay shares the same window but the widget tree root
/// swaps based on a Riverpod provider, giving the full overlay experience
/// while a multi-window implementation is deferred to Phase 5 (macOS polish).
///
/// See docs/ARCHITECTURE.md §Overlay Window for the full design.
class OverlayWindowManager extends StateNotifier<OverlayWindowState> {
  OverlayWindowManager(this._ref)
      : super(const OverlayWindowState(isVisible: false)) {
    _settingsListener = _ref.listen<SettingsState>(
      settingsProvider,
      (_, next) => _onSettingsChanged(next),
      fireImmediately: false,
    );
  }

  final Ref _ref;
  late final ProviderSubscription<SettingsState> _settingsListener;

  @override
  void dispose() {
    _settingsListener.close();
    super.dispose();
  }

  // ─── Window options ─────────────────────────────────────────────────────

  static WindowOptions _buildOptions(double w, double h) {
    return WindowOptions(
      size: Size(w, h),
      center: false,
      title: '',
      skipTaskbar: true,
      titleBarStyle: TitleBarStyle.hidden,
      backgroundColor: Colors.transparent,
      alwaysOnTop: true,
    );
  }

  // ─── Public API ─────────────────────────────────────────────────────────

  /// Transition to the overlay window layout.
  Future<void> show() async {
    final settings = _ref.read(settingsProvider);
    final opts = _buildOptions(
      settings.overlayWidth,
      settings.overlayHeight,
    );

    await windowManager.waitUntilReadyToShow(opts, () async {
      await windowManager.setAlwaysOnTop(true);
      await windowManager.setSkipTaskbar(true);
      await windowManager.setTitleBarStyle(TitleBarStyle.hidden);
      await windowManager.setBackgroundColor(Colors.transparent);
      await windowManager.setSize(
        Size(settings.overlayWidth, settings.overlayHeight),
      );
      await _positionTopCenter(settings.overlayWidth, settings.overlayHeight);
      // macOS: use .screenSaver level so overlay sits above fullscreen apps.
      await MacOSWindowChannel.setWindowLevel(WindowLevel.screenSaver);
      if (isMacOS && settings.privacyModeEnabled) {
        await _applyPrivacyMode(enabled: true);
      }
      await windowManager.show();
      await windowManager.focus();
    });

    state = state.copyWith(isVisible: true);
  }

  /// Return to the settings window layout.
  Future<void> hide() async {
    const settingsSize = Size(680, 560);
    // Restore normal window level before reconfiguring as settings window.
    await MacOSWindowChannel.setWindowLevel(WindowLevel.normal);
    await windowManager.setAlwaysOnTop(false);
    await windowManager.setSkipTaskbar(false);
    await windowManager.setTitleBarStyle(TitleBarStyle.normal);
    await windowManager.setBackgroundColor(Colors.black);
    await windowManager.setSize(settingsSize);
    await windowManager.center();
    await windowManager.setTitle('Notchprompt');
    if (isMacOS) {
      await _applyPrivacyMode(enabled: false);
    }
    await windowManager.show();
    await windowManager.focus();
    state = state.copyWith(isVisible: false);
  }

  // ─── Private helpers ────────────────────────────────────────────────────

  Future<void> _onSettingsChanged(SettingsState s) async {
    if (!state.isVisible) return;
    await windowManager.setSize(Size(s.overlayWidth, s.overlayHeight));
    await _positionTopCenter(s.overlayWidth, s.overlayHeight);
    if (isMacOS) {
      await _applyPrivacyMode(enabled: s.privacyModeEnabled);
    }
  }

  Future<void> _positionTopCenter(double w, double h) async {
    final screen = await windowManager.getSize(); // primary screen work area
    // Position top-center relative to primary display.
    // Offset fallback: if screen is reported as overlay size (already set),
    // centre horizontally at 1/6 from top — matches menu-bar-adjacent origin.
    const topMargin = 4.0;
    final x = (screen.width / 2 - w / 2).clamp(0.0, double.infinity);
    await windowManager.setPosition(Offset(x, topMargin));
  }

  Future<void> _applyPrivacyMode({required bool enabled}) async {
    // Routes through MacOSWindowChannel per CONSTITUTION §3.
    // No-ops on Linux/Windows via the channel's own platform guard.
    await MacOSWindowChannel.setPrivacyMode(enabled: enabled);
  }
}

// ─── State ────────────────────────────────────────────────────────────────────

class OverlayWindowState {
  const OverlayWindowState({required this.isVisible});

  final bool isVisible;

  OverlayWindowState copyWith({bool? isVisible}) =>
      OverlayWindowState(isVisible: isVisible ?? this.isVisible);
}

// ─── Provider ─────────────────────────────────────────────────────────────────

final overlayWindowProvider =
    StateNotifierProvider<OverlayWindowManager, OverlayWindowState>(
  OverlayWindowManager.new,
);

// ─── Overlay root widget ──────────────────────────────────────────────────────

/// MaterialApp root used when the overlay window is shown.
/// Used as the `home` of the app in overlay mode.
class OverlayRoot extends StatelessWidget {
  const OverlayRoot({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: Colors.transparent,
      body: OverlayView(),
    );
  }
}

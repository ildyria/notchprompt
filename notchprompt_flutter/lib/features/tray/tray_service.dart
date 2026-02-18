import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:tray_manager/tray_manager.dart';

import '../../core/platform.dart';
import '../prompter/prompter_provider.dart';
import '../prompter/prompter_state.dart';
import '../script/script_file_io.dart';
import '../settings/settings_provider.dart';
import '../settings/settings_state.dart';

/// Manages the system-tray icon, tooltip, and dynamic context menu.
///
/// Rebuilds the menu whenever [PrompterState.transportState] or
/// [SettingsState.privacyModeEnabled] change.
class TrayService extends TrayListener {
  TrayService(this._ref);

  final Ref _ref;

  // Subscriptions closed in [dispose].
  ProviderSubscription<TransportState>? _transportSub;
  ProviderSubscription<bool>? _privacySub;

  // ─── Lifecycle ────────────────────────────────────────────────────────────

  Future<void> init() async {
    trayManager.addListener(this);

    await trayManager.setIcon(_iconPath());
    await trayManager.setToolTip('Notchprompt');
    await _rebuildMenu();

    // Rebuild on transport state changes.
    _transportSub = _ref.listen<TransportState>(
      prompterProvider.select((s) => s.transportState),
      (_, __) => _rebuildMenu(),
      fireImmediately: false,
    );

    // Rebuild on privacy mode changes (macOS — affects checkmark).
    _privacySub = _ref.listen<bool>(
      settingsProvider.select((s) => s.privacyModeEnabled),
      (_, __) => _rebuildMenu(),
      fireImmediately: false,
    );
  }

  void dispose() {
    trayManager.removeListener(this);
    _transportSub?.close();
    _privacySub?.close();
  }

  // ─── Menu construction ───────────────────────────────────────────────────

  Future<void> _rebuildMenu() async {
    final state = _ref.read(prompterProvider);
    final settings = _ref.read(settingsProvider);

    final isRunning = state.transportState == TransportState.running ||
        state.transportState == TransportState.countingDown;

    final items = <MenuItem>[
      MenuItem(
        key: _MenuKey.startPause,
        label: isRunning ? 'Pause' : 'Start',
      ),
      MenuItem(
        key: _MenuKey.reset,
        label: 'Reset Scroll',
      ),
      MenuItem(
        key: _MenuKey.jumpBack,
        label: 'Jump Back 5s',
      ),
      if (isMacOS)
        MenuItem.checkbox(
          key: _MenuKey.privacy,
          label: 'Privacy Mode',
          checked: settings.privacyModeEnabled,
        ),
      MenuItem.separator(),
      MenuItem(
        key: _MenuKey.importScript,
        label: 'Import Script…',
      ),
      MenuItem(
        key: _MenuKey.exportScript,
        label: 'Export Script…',
      ),
      MenuItem.separator(),
      MenuItem(
        key: _MenuKey.settings,
        label: 'Settings…',
      ),
      MenuItem.separator(),
      MenuItem(
        key: _MenuKey.quit,
        label: 'Quit Notchprompt',
      ),
    ];

    await trayManager.setContextMenu(Menu(items: items));
  }

  // ─── TrayListener callbacks ───────────────────────────────────────────────

  @override
  void onTrayIconMouseDown() {
    // Left-click: show the context menu directly.
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayIconRightMouseDown() {
    trayManager.popUpContextMenu();
  }

  @override
  void onTrayMenuItemClick(MenuItem menuItem) {
    switch (menuItem.key) {
      case _MenuKey.startPause:
        _ref.read(prompterProvider.notifier).toggleRunning();
      case _MenuKey.reset:
        _ref.read(prompterProvider.notifier).resetScroll();
      case _MenuKey.jumpBack:
        _ref.read(prompterProvider.notifier).jumpBack();
      case _MenuKey.privacy:
        _ref.read(settingsProvider.notifier).togglePrivacyMode();
      case _MenuKey.importScript:
        _handleImport();
      case _MenuKey.exportScript:
        _handleExport();
      case _MenuKey.settings:
        _openSettings();
      case _MenuKey.quit:
        _quit();
    }
  }

  // ─── Private actions ─────────────────────────────────────────────────────

  void _handleImport() {
    importScriptText().then((text) {
      if (text != null) {
        _ref.read(settingsProvider.notifier).updateScript(text);
      }
    }).catchError((Object e) {
      debugPrint('[TrayService] import error: $e');
    });
  }

  void _handleExport() {
    final script = _ref.read(settingsProvider).script;
    exportScriptText(script).catchError((Object e) {
      debugPrint('[TrayService] export error: $e');
    });
  }

  void _openSettings() {
    // Forwards to the overlay window manager to reveal the settings window.
    // Uses a simple flag provider read to keep the tray layer decoupled.
    _ref.read(_settingsWindowRequestProvider.notifier).request();
  }

  void _quit() {
    // Graceful shutdown — let the OS handle process exit.
    // ignore: do_not_use_environment
    // TODO(phase4): save unsaved state before exit
    trayManager.destroy();
  }

  // ─── Icon path ────────────────────────────────────────────────────────────

  static String _iconPath() {
    if (isWindows) return 'assets/tray_icon.ico';
    if (isMacOS) return 'assets/tray_icon_template.png';
    return 'assets/tray_icon.png';
  }
}

// ─── Menu key constants ───────────────────────────────────────────────────────

abstract final class _MenuKey {
  static const String startPause = 'start_pause';
  static const String reset = 'reset';
  static const String jumpBack = 'jump_back';
  static const String privacy = 'privacy';
  static const String importScript = 'import_script';
  static const String exportScript = 'export_script';
  static const String settings = 'settings';
  static const String quit = 'quit';
}

// ─── Settings-window request provider ────────────────────────────────────────
// A simple notifier that acts as a signal bus: incrementing the counter
// triggers the UI layer to reveal the settings window.

class _SettingsWindowRequestNotifier extends StateNotifier<int> {
  _SettingsWindowRequestNotifier() : super(0);

  void request() => state = state + 1;
}

final _settingsWindowRequestProvider =
    StateNotifierProvider<_SettingsWindowRequestNotifier, int>(
  (ref) => _SettingsWindowRequestNotifier(),
);

/// Public read-only provider for the settings-window request signal.
///
/// The root app widget watches this and opens the settings window each time
/// the value increments.
final settingsWindowRequestProvider = Provider<int>(
  (ref) => ref.watch(_settingsWindowRequestProvider),
);

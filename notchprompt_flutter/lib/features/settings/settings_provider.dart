import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notchprompt/features/settings/settings_notifier.dart';
import 'package:notchprompt/features/settings/settings_state.dart';

/// Provides the [SharedPreferences] instance.
/// Override in tests with a [ProviderContainer] override.
final sharedPreferencesProvider = Provider<SharedPreferences>(
  (ref) => throw UnimplementedError(
    'sharedPreferencesProvider must be overridden before use. '
    'Call SharedPreferences.getInstance() in main() and override this provider.',
  ),
);

/// The single source of truth for all user settings.
final settingsProvider =
    StateNotifierProvider<SettingsNotifier, SettingsState>((ref) {
  final prefs = ref.watch(sharedPreferencesProvider);
  final notifier = SettingsNotifier(prefs);
  notifier.loadSettings();
  return notifier;
});

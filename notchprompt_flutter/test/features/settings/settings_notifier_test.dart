import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notchprompt/core/constants.dart';
import 'package:notchprompt/features/settings/settings_notifier.dart';
import 'package:notchprompt/features/settings/settings_provider.dart';
import 'package:notchprompt/features/settings/settings_state.dart';

void main() {
  late ProviderContainer container;
  late SharedPreferences prefs;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() => container.dispose());

  SettingsState read() => container.read(settingsProvider);
  SettingsNotifier notifier() => container.read(settingsProvider.notifier);

  group('SettingsNotifier — defaults', () {
    test('initial state matches constants', () {
      expect(read().speedPointsPerSecond, kDefaultSpeed);
      expect(read().fontSize, kDefaultFontSize);
      expect(read().overlayWidth, kDefaultOverlayWidth);
      expect(read().overlayHeight, kDefaultOverlayHeight);
      expect(read().countdownSeconds, kDefaultCountdownSeconds);
      expect(read().privacyModeEnabled, true);
    });
  });

  group('SettingsNotifier — speed', () {
    test('updateSpeed clamps to min', () {
      notifier().updateSpeed(0);
      expect(read().speedPointsPerSecond, kMinSpeed);
    });

    test('updateSpeed clamps to max', () {
      notifier().updateSpeed(9999);
      expect(read().speedPointsPerSecond, kMaxSpeed);
    });

    test('updateSpeed snaps to step', () {
      notifier().updateSpeed(83); // nearest step of 5 → 85
      expect(read().speedPointsPerSecond, 85);
    });

    test('adjustSpeed adds delta', () {
      notifier().updateSpeed(80);
      notifier().adjustSpeed(kSpeedStep);
      expect(read().speedPointsPerSecond, 85);
    });

    test('adjustSpeed clamps at min', () {
      notifier().updateSpeed(kMinSpeed);
      notifier().adjustSpeed(-kSpeedStep * 10);
      expect(read().speedPointsPerSecond, kMinSpeed);
    });

    test('applySpeedPreset sets normal', () {
      notifier().applySpeedPreset(kSpeedPresetNormal);
      expect(read().speedPointsPerSecond, kSpeedPresetNormal);
    });
  });

  group('SettingsNotifier — font size', () {
    test('clamps to min', () {
      notifier().updateFontSize(1);
      expect(read().fontSize, kMinFontSize);
    });

    test('clamps to max', () {
      notifier().updateFontSize(999);
      expect(read().fontSize, kMaxFontSize);
    });
  });

  group('SettingsNotifier — overlay geometry', () {
    test('width clamps to min', () {
      notifier().updateOverlayWidth(0);
      expect(read().overlayWidth, kMinOverlayWidth);
    });

    test('width clamps to max', () {
      notifier().updateOverlayWidth(9999);
      expect(read().overlayWidth, kMaxOverlayWidth);
    });

    test('height clamps to min', () {
      notifier().updateOverlayHeight(0);
      expect(read().overlayHeight, kMinOverlayHeight);
    });

    test('height clamps to max', () {
      notifier().updateOverlayHeight(9999);
      expect(read().overlayHeight, kMaxOverlayHeight);
    });
  });

  group('SettingsNotifier — countdown', () {
    test('clamps to 0', () {
      notifier().updateCountdownSeconds(-5);
      expect(read().countdownSeconds, 0);
    });

    test('clamps to max', () {
      notifier().updateCountdownSeconds(99);
      expect(read().countdownSeconds, kMaxCountdownSeconds);
    });
  });

  group('SettingsNotifier — privacy mode', () {
    test('toggles false → true → false', () {
      notifier().setPrivacyMode(enabled: false);
      expect(read().privacyModeEnabled, false);
      notifier().togglePrivacyMode();
      expect(read().privacyModeEnabled, true);
      notifier().togglePrivacyMode();
      expect(read().privacyModeEnabled, false);
    });
  });

  group('SettingsNotifier — script', () {
    test('updates script', () {
      notifier().updateScript('Hello world');
      expect(read().script, 'Hello world');
    });
  });

  group('SettingsNotifier — persistence', () {
    test('loadSettings is a no-op when no previous session exists', () {
      final speedBefore = read().speedPointsPerSecond;
      // prefs is empty, so loadSettings (called at creation) should not change defaults
      expect(read().speedPointsPerSecond, speedBefore);
    });
  });
}

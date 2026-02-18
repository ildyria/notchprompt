import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:notchprompt/features/prompter/prompter_notifier.dart';
import 'package:notchprompt/features/prompter/prompter_provider.dart';
import 'package:notchprompt/features/prompter/prompter_state.dart';
import 'package:notchprompt/features/settings/settings_provider.dart';

void main() {
  late ProviderContainer container;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    container = ProviderContainer(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
    );
  });

  tearDown(() => container.dispose());

  PrompterState read() => container.read(prompterProvider);
  PrompterNotifier notifier() => container.read(prompterProvider.notifier);

  group('PrompterNotifier — initial state', () {
    test('starts idle', () {
      expect(read().transportState, TransportState.idle);
    });

    test('hasStartedSession is false', () {
      expect(read().hasStartedSession, false);
    });

    test('countdownRemaining is 0', () {
      expect(read().countdownRemaining, 0);
    });
  });

  group('PrompterNotifier — start (no countdown)', () {
    setUp(() {
      // Set countdown to 0 so we skip countdown phase.
      container
          .read(settingsProvider.notifier)
          .updateCountdownSeconds(0);
    });

    test('toggleRunning from idle goes to running', () {
      notifier().toggleRunning();
      expect(read().transportState, TransportState.running);
    });

    test('hasStartedSession becomes true on start', () {
      notifier().start();
      expect(read().hasStartedSession, true);
    });

    test('calling start while running is a no-op', () {
      notifier().start();
      notifier().start();
      expect(read().transportState, TransportState.running);
    });
  });

  group('PrompterNotifier — stop', () {
    setUp(() {
      container
          .read(settingsProvider.notifier)
          .updateCountdownSeconds(0);
      notifier().start();
    });

    test('stop transitions running → idle', () {
      notifier().stop();
      expect(read().transportState, TransportState.idle);
    });

    test('toggleRunning from running stops', () {
      notifier().toggleRunning();
      expect(read().transportState, TransportState.idle);
    });
  });

  group('PrompterNotifier — reset', () {
    setUp(() {
      container
          .read(settingsProvider.notifier)
          .updateCountdownSeconds(0);
      notifier().start();
    });

    test('reset returns to idle', () {
      notifier().resetScroll();
      expect(read().transportState, TransportState.idle);
    });

    test('reset clears hasStartedSession', () {
      notifier().resetScroll();
      expect(read().hasStartedSession, false);
    });

    test('reset changes resetToken', () {
      final tokenBefore = read().resetToken;
      notifier().resetScroll();
      expect(read().resetToken, isNot(tokenBefore));
    });
  });

  group('PrompterNotifier — jump back', () {
    setUp(() {
      container
          .read(settingsProvider.notifier)
          .updateCountdownSeconds(0);
      notifier().start();
    });

    test('jumpBack changes jumpBackToken when running', () {
      final tokenBefore = read().jumpBackToken;
      notifier().jumpBack();
      expect(read().jumpBackToken, isNot(tokenBefore));
    });

    test('jumpBack sets jumpBackDistancePoints > 0', () {
      notifier().jumpBack();
      expect(read().jumpBackDistancePoints, greaterThan(0));
    });

    test('jumpBack is a no-op when idle', () {
      notifier().stop();
      final tokenBefore = read().jumpBackToken;
      notifier().jumpBack();
      expect(read().jumpBackToken, tokenBefore);
    });
  });

  group('PrompterNotifier — countdown', () {
    setUp(() {
      container
          .read(settingsProvider.notifier)
          .updateCountdownSeconds(3);
    });

    test('start with countdown > 0 enters countingDown state', () {
      notifier().start();
      expect(read().transportState, TransportState.countingDown);
    });

    test('countdownRemaining set to countdownSeconds on start', () {
      notifier().start();
      expect(read().countdownRemaining, 3);
    });

    test('stop during countdown returns to idle', () {
      notifier().start();
      notifier().stop();
      expect(read().transportState, TransportState.idle);
      expect(read().countdownRemaining, 0);
    });
  });
}

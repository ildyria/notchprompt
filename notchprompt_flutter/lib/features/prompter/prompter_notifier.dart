import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:notchprompt/core/constants.dart';
import 'package:notchprompt/features/prompter/prompter_state.dart';
import 'package:notchprompt/features/settings/settings_provider.dart';

/// Manages all teleprompter transport logic.
///
/// The scroll view reacts to [resetToken] and [jumpBackToken] UUID changes
/// rather than storing an offset here — keeping animation inside the widget
/// layer. See ARCHITECTURE.md §Scroll Engine Detail.
class PrompterNotifier extends StateNotifier<PrompterState> {
  PrompterNotifier(this._ref) : super(const PrompterState());

  final Ref _ref;
  Task<void>? _countdownTask;

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Starts if idle; stops if running or counting down.
  void toggleRunning() {
    if (state.transportState == TransportState.running ||
        state.transportState == TransportState.countingDown) {
      stop();
    } else {
      start();
    }
  }

  void start() {
    if (state.transportState != TransportState.idle) return;

    final countdown =
        _ref.read(settingsProvider).countdownSeconds.clamp(0, 10);
    if (countdown == 0) {
      state = state.copyWith(
        transportState: TransportState.running,
        hasStartedSession: true,
      );
    } else {
      _beginCountdown(countdown);
    }
  }

  void stop() {
    _countdownTask?.cancel();
    _countdownTask = null;
    state = state.copyWith(
      transportState: TransportState.idle,
      countdownRemaining: 0,
    );
  }

  void resetScroll() {
    _countdownTask?.cancel();
    _countdownTask = null;
    state = state.copyWith(
      transportState: TransportState.idle,
      hasStartedSession: false,
      countdownRemaining: 0,
      resetToken: DateTime.now().microsecondsSinceEpoch.toString(),
      jumpBackDistancePoints: 0,
    );
  }

  void jumpBack() {
    if (state.transportState != TransportState.running) return;

    final speed = _ref.read(settingsProvider).speedPointsPerSecond;
    final distance = speed * kJumpBackSeconds;
    state = state.copyWith(
      jumpBackDistancePoints: distance,
      jumpBackToken: DateTime.now().microsecondsSinceEpoch.toString(),
    );
  }

  // ─── Countdown ────────────────────────────────────────────────────────────

  void _beginCountdown(int seconds) {
    state = state.copyWith(
      transportState: TransportState.countingDown,
      countdownRemaining: seconds,
    );

    _countdownTask = Task(_runCountdown(seconds));
  }

  Future<void> _runCountdown(int seconds) async {
    var remaining = seconds;

    while (remaining > 0) {
      try {
        await Future<void>.delayed(const Duration(seconds: 1));
      } catch (_) {
        // Task cancelled — cleanup handled in stop/reset.
        return;
      }

      if (!mounted) return;

      remaining -= 1;
      state = state.copyWith(countdownRemaining: remaining);
    }

    if (!mounted) return;

    state = state.copyWith(
      transportState: TransportState.running,
      hasStartedSession: true,
      countdownRemaining: 0,
    );
    _countdownTask = null;
  }

  @override
  void dispose() {
    _countdownTask?.cancel();
    super.dispose();
  }
}

/// Minimal cancellable task wrapper for the countdown loop.
class Task<T> {
  Task(Future<T> future) : _future = future;

  final Future<T> _future;
  bool _cancelled = false;

  bool get isCancelled => _cancelled;

  Future<T> get future => _future;

  void cancel() {
    _cancelled = true;
  }
}

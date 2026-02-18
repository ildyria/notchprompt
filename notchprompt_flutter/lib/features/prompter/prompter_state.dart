import 'package:freezed_annotation/freezed_annotation.dart';

part 'prompter_state.freezed.dart';

/// Transport lifecycle states.
enum TransportState {
  idle,
  countingDown,
  running,
}

/// Session-only state for the teleprompter transport.
/// Not persisted across launches.
@freezed
class PrompterState with _$PrompterState {
  const factory PrompterState({
    @Default(TransportState.idle) TransportState transportState,

    /// True once the user has started at least one session since last reset.
    @Default(false) bool hasStartedSession,

    /// Remaining countdown ticks (meaningful only when [transportState] is
    /// [TransportState.countingDown]).
    @Default(0) int countdownRemaining,

    /// Changing this UUID signals the scroll view to jump to offset 0.
    @Default('initial') String resetToken,

    /// Changing this UUID signals the scroll view to jump back by
    /// [jumpBackDistancePoints].
    @Default('initial') String jumpBackToken,

    /// Distance (logical pixels) to jump back when [jumpBackToken] changes.
    @Default(0.0) double jumpBackDistancePoints,
  }) = _PrompterState;
}

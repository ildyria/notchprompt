// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'prompter_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$PrompterState {
  TransportState get transportState => throw _privateConstructorUsedError;

  /// True once the user has started at least one session since last reset.
  bool get hasStartedSession => throw _privateConstructorUsedError;

  /// Remaining countdown ticks (meaningful only when [transportState] is
  /// [TransportState.countingDown]).
  int get countdownRemaining => throw _privateConstructorUsedError;

  /// Changing this UUID signals the scroll view to jump to offset 0.
  String get resetToken => throw _privateConstructorUsedError;

  /// Changing this UUID signals the scroll view to jump back by
  /// [jumpBackDistancePoints].
  String get jumpBackToken => throw _privateConstructorUsedError;

  /// Distance (logical pixels) to jump back when [jumpBackToken] changes.
  double get jumpBackDistancePoints => throw _privateConstructorUsedError;

  /// Create a copy of PrompterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $PrompterStateCopyWith<PrompterState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $PrompterStateCopyWith<$Res> {
  factory $PrompterStateCopyWith(
          PrompterState value, $Res Function(PrompterState) then) =
      _$PrompterStateCopyWithImpl<$Res, PrompterState>;
  @useResult
  $Res call(
      {TransportState transportState,
      bool hasStartedSession,
      int countdownRemaining,
      String resetToken,
      String jumpBackToken,
      double jumpBackDistancePoints});
}

/// @nodoc
class _$PrompterStateCopyWithImpl<$Res, $Val extends PrompterState>
    implements $PrompterStateCopyWith<$Res> {
  _$PrompterStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of PrompterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transportState = null,
    Object? hasStartedSession = null,
    Object? countdownRemaining = null,
    Object? resetToken = null,
    Object? jumpBackToken = null,
    Object? jumpBackDistancePoints = null,
  }) {
    return _then(_value.copyWith(
      transportState: null == transportState
          ? _value.transportState
          : transportState // ignore: cast_nullable_to_non_nullable
              as TransportState,
      hasStartedSession: null == hasStartedSession
          ? _value.hasStartedSession
          : hasStartedSession // ignore: cast_nullable_to_non_nullable
              as bool,
      countdownRemaining: null == countdownRemaining
          ? _value.countdownRemaining
          : countdownRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      resetToken: null == resetToken
          ? _value.resetToken
          : resetToken // ignore: cast_nullable_to_non_nullable
              as String,
      jumpBackToken: null == jumpBackToken
          ? _value.jumpBackToken
          : jumpBackToken // ignore: cast_nullable_to_non_nullable
              as String,
      jumpBackDistancePoints: null == jumpBackDistancePoints
          ? _value.jumpBackDistancePoints
          : jumpBackDistancePoints // ignore: cast_nullable_to_non_nullable
              as double,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$PrompterStateImplCopyWith<$Res>
    implements $PrompterStateCopyWith<$Res> {
  factory _$$PrompterStateImplCopyWith(
          _$PrompterStateImpl value, $Res Function(_$PrompterStateImpl) then) =
      __$$PrompterStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {TransportState transportState,
      bool hasStartedSession,
      int countdownRemaining,
      String resetToken,
      String jumpBackToken,
      double jumpBackDistancePoints});
}

/// @nodoc
class __$$PrompterStateImplCopyWithImpl<$Res>
    extends _$PrompterStateCopyWithImpl<$Res, _$PrompterStateImpl>
    implements _$$PrompterStateImplCopyWith<$Res> {
  __$$PrompterStateImplCopyWithImpl(
      _$PrompterStateImpl _value, $Res Function(_$PrompterStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of PrompterState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? transportState = null,
    Object? hasStartedSession = null,
    Object? countdownRemaining = null,
    Object? resetToken = null,
    Object? jumpBackToken = null,
    Object? jumpBackDistancePoints = null,
  }) {
    return _then(_$PrompterStateImpl(
      transportState: null == transportState
          ? _value.transportState
          : transportState // ignore: cast_nullable_to_non_nullable
              as TransportState,
      hasStartedSession: null == hasStartedSession
          ? _value.hasStartedSession
          : hasStartedSession // ignore: cast_nullable_to_non_nullable
              as bool,
      countdownRemaining: null == countdownRemaining
          ? _value.countdownRemaining
          : countdownRemaining // ignore: cast_nullable_to_non_nullable
              as int,
      resetToken: null == resetToken
          ? _value.resetToken
          : resetToken // ignore: cast_nullable_to_non_nullable
              as String,
      jumpBackToken: null == jumpBackToken
          ? _value.jumpBackToken
          : jumpBackToken // ignore: cast_nullable_to_non_nullable
              as String,
      jumpBackDistancePoints: null == jumpBackDistancePoints
          ? _value.jumpBackDistancePoints
          : jumpBackDistancePoints // ignore: cast_nullable_to_non_nullable
              as double,
    ));
  }
}

/// @nodoc

class _$PrompterStateImpl implements _PrompterState {
  const _$PrompterStateImpl(
      {this.transportState = TransportState.idle,
      this.hasStartedSession = false,
      this.countdownRemaining = 0,
      this.resetToken = 'initial',
      this.jumpBackToken = 'initial',
      this.jumpBackDistancePoints = 0.0});

  @override
  @JsonKey()
  final TransportState transportState;

  /// True once the user has started at least one session since last reset.
  @override
  @JsonKey()
  final bool hasStartedSession;

  /// Remaining countdown ticks (meaningful only when [transportState] is
  /// [TransportState.countingDown]).
  @override
  @JsonKey()
  final int countdownRemaining;

  /// Changing this UUID signals the scroll view to jump to offset 0.
  @override
  @JsonKey()
  final String resetToken;

  /// Changing this UUID signals the scroll view to jump back by
  /// [jumpBackDistancePoints].
  @override
  @JsonKey()
  final String jumpBackToken;

  /// Distance (logical pixels) to jump back when [jumpBackToken] changes.
  @override
  @JsonKey()
  final double jumpBackDistancePoints;

  @override
  String toString() {
    return 'PrompterState(transportState: $transportState, hasStartedSession: $hasStartedSession, countdownRemaining: $countdownRemaining, resetToken: $resetToken, jumpBackToken: $jumpBackToken, jumpBackDistancePoints: $jumpBackDistancePoints)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$PrompterStateImpl &&
            (identical(other.transportState, transportState) ||
                other.transportState == transportState) &&
            (identical(other.hasStartedSession, hasStartedSession) ||
                other.hasStartedSession == hasStartedSession) &&
            (identical(other.countdownRemaining, countdownRemaining) ||
                other.countdownRemaining == countdownRemaining) &&
            (identical(other.resetToken, resetToken) ||
                other.resetToken == resetToken) &&
            (identical(other.jumpBackToken, jumpBackToken) ||
                other.jumpBackToken == jumpBackToken) &&
            (identical(other.jumpBackDistancePoints, jumpBackDistancePoints) ||
                other.jumpBackDistancePoints == jumpBackDistancePoints));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      transportState,
      hasStartedSession,
      countdownRemaining,
      resetToken,
      jumpBackToken,
      jumpBackDistancePoints);

  /// Create a copy of PrompterState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$PrompterStateImplCopyWith<_$PrompterStateImpl> get copyWith =>
      __$$PrompterStateImplCopyWithImpl<_$PrompterStateImpl>(this, _$identity);
}

abstract class _PrompterState implements PrompterState {
  const factory _PrompterState(
      {final TransportState transportState,
      final bool hasStartedSession,
      final int countdownRemaining,
      final String resetToken,
      final String jumpBackToken,
      final double jumpBackDistancePoints}) = _$PrompterStateImpl;

  @override
  TransportState get transportState;

  /// True once the user has started at least one session since last reset.
  @override
  bool get hasStartedSession;

  /// Remaining countdown ticks (meaningful only when [transportState] is
  /// [TransportState.countingDown]).
  @override
  int get countdownRemaining;

  /// Changing this UUID signals the scroll view to jump to offset 0.
  @override
  String get resetToken;

  /// Changing this UUID signals the scroll view to jump back by
  /// [jumpBackDistancePoints].
  @override
  String get jumpBackToken;

  /// Distance (logical pixels) to jump back when [jumpBackToken] changes.
  @override
  double get jumpBackDistancePoints;

  /// Create a copy of PrompterState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$PrompterStateImplCopyWith<_$PrompterStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

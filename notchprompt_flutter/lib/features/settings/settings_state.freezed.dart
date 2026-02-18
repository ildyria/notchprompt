// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'settings_state.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

/// @nodoc
mixin _$SettingsState {
  double get speedPointsPerSecond => throw _privateConstructorUsedError;
  double get fontSize => throw _privateConstructorUsedError;
  double get overlayWidth => throw _privateConstructorUsedError;
  double get overlayHeight => throw _privateConstructorUsedError;
  int get countdownSeconds => throw _privateConstructorUsedError;
  bool get privacyModeEnabled => throw _privateConstructorUsedError;
  String get script => throw _privateConstructorUsedError;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  $SettingsStateCopyWith<SettingsState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $SettingsStateCopyWith<$Res> {
  factory $SettingsStateCopyWith(
          SettingsState value, $Res Function(SettingsState) then) =
      _$SettingsStateCopyWithImpl<$Res, SettingsState>;
  @useResult
  $Res call(
      {double speedPointsPerSecond,
      double fontSize,
      double overlayWidth,
      double overlayHeight,
      int countdownSeconds,
      bool privacyModeEnabled,
      String script});
}

/// @nodoc
class _$SettingsStateCopyWithImpl<$Res, $Val extends SettingsState>
    implements $SettingsStateCopyWith<$Res> {
  _$SettingsStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speedPointsPerSecond = null,
    Object? fontSize = null,
    Object? overlayWidth = null,
    Object? overlayHeight = null,
    Object? countdownSeconds = null,
    Object? privacyModeEnabled = null,
    Object? script = null,
  }) {
    return _then(_value.copyWith(
      speedPointsPerSecond: null == speedPointsPerSecond
          ? _value.speedPointsPerSecond
          : speedPointsPerSecond // ignore: cast_nullable_to_non_nullable
              as double,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      overlayWidth: null == overlayWidth
          ? _value.overlayWidth
          : overlayWidth // ignore: cast_nullable_to_non_nullable
              as double,
      overlayHeight: null == overlayHeight
          ? _value.overlayHeight
          : overlayHeight // ignore: cast_nullable_to_non_nullable
              as double,
      countdownSeconds: null == countdownSeconds
          ? _value.countdownSeconds
          : countdownSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      privacyModeEnabled: null == privacyModeEnabled
          ? _value.privacyModeEnabled
          : privacyModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$SettingsStateImplCopyWith<$Res>
    implements $SettingsStateCopyWith<$Res> {
  factory _$$SettingsStateImplCopyWith(
          _$SettingsStateImpl value, $Res Function(_$SettingsStateImpl) then) =
      __$$SettingsStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double speedPointsPerSecond,
      double fontSize,
      double overlayWidth,
      double overlayHeight,
      int countdownSeconds,
      bool privacyModeEnabled,
      String script});
}

/// @nodoc
class __$$SettingsStateImplCopyWithImpl<$Res>
    extends _$SettingsStateCopyWithImpl<$Res, _$SettingsStateImpl>
    implements _$$SettingsStateImplCopyWith<$Res> {
  __$$SettingsStateImplCopyWithImpl(
      _$SettingsStateImpl _value, $Res Function(_$SettingsStateImpl) _then)
      : super(_value, _then);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? speedPointsPerSecond = null,
    Object? fontSize = null,
    Object? overlayWidth = null,
    Object? overlayHeight = null,
    Object? countdownSeconds = null,
    Object? privacyModeEnabled = null,
    Object? script = null,
  }) {
    return _then(_$SettingsStateImpl(
      speedPointsPerSecond: null == speedPointsPerSecond
          ? _value.speedPointsPerSecond
          : speedPointsPerSecond // ignore: cast_nullable_to_non_nullable
              as double,
      fontSize: null == fontSize
          ? _value.fontSize
          : fontSize // ignore: cast_nullable_to_non_nullable
              as double,
      overlayWidth: null == overlayWidth
          ? _value.overlayWidth
          : overlayWidth // ignore: cast_nullable_to_non_nullable
              as double,
      overlayHeight: null == overlayHeight
          ? _value.overlayHeight
          : overlayHeight // ignore: cast_nullable_to_non_nullable
              as double,
      countdownSeconds: null == countdownSeconds
          ? _value.countdownSeconds
          : countdownSeconds // ignore: cast_nullable_to_non_nullable
              as int,
      privacyModeEnabled: null == privacyModeEnabled
          ? _value.privacyModeEnabled
          : privacyModeEnabled // ignore: cast_nullable_to_non_nullable
              as bool,
      script: null == script
          ? _value.script
          : script // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc

class _$SettingsStateImpl implements _SettingsState {
  const _$SettingsStateImpl(
      {this.speedPointsPerSecond = 80.0,
      this.fontSize = 20.0,
      this.overlayWidth = 600.0,
      this.overlayHeight = 150.0,
      this.countdownSeconds = 3,
      this.privacyModeEnabled = true,
      this.script =
          'Paste your script here.\n\nTip: Use the menu bar icon to start/pause or reset the scroll.'});

  @override
  @JsonKey()
  final double speedPointsPerSecond;
  @override
  @JsonKey()
  final double fontSize;
  @override
  @JsonKey()
  final double overlayWidth;
  @override
  @JsonKey()
  final double overlayHeight;
  @override
  @JsonKey()
  final int countdownSeconds;
  @override
  @JsonKey()
  final bool privacyModeEnabled;
  @override
  @JsonKey()
  final String script;

  @override
  String toString() {
    return 'SettingsState(speedPointsPerSecond: $speedPointsPerSecond, fontSize: $fontSize, overlayWidth: $overlayWidth, overlayHeight: $overlayHeight, countdownSeconds: $countdownSeconds, privacyModeEnabled: $privacyModeEnabled, script: $script)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$SettingsStateImpl &&
            (identical(other.speedPointsPerSecond, speedPointsPerSecond) ||
                other.speedPointsPerSecond == speedPointsPerSecond) &&
            (identical(other.fontSize, fontSize) ||
                other.fontSize == fontSize) &&
            (identical(other.overlayWidth, overlayWidth) ||
                other.overlayWidth == overlayWidth) &&
            (identical(other.overlayHeight, overlayHeight) ||
                other.overlayHeight == overlayHeight) &&
            (identical(other.countdownSeconds, countdownSeconds) ||
                other.countdownSeconds == countdownSeconds) &&
            (identical(other.privacyModeEnabled, privacyModeEnabled) ||
                other.privacyModeEnabled == privacyModeEnabled) &&
            (identical(other.script, script) || other.script == script));
  }

  @override
  int get hashCode => Object.hash(
      runtimeType,
      speedPointsPerSecond,
      fontSize,
      overlayWidth,
      overlayHeight,
      countdownSeconds,
      privacyModeEnabled,
      script);

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @JsonKey(includeFromJson: false, includeToJson: false)
  @override
  @pragma('vm:prefer-inline')
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      __$$SettingsStateImplCopyWithImpl<_$SettingsStateImpl>(this, _$identity);
}

abstract class _SettingsState implements SettingsState {
  const factory _SettingsState(
      {final double speedPointsPerSecond,
      final double fontSize,
      final double overlayWidth,
      final double overlayHeight,
      final int countdownSeconds,
      final bool privacyModeEnabled,
      final String script}) = _$SettingsStateImpl;

  @override
  double get speedPointsPerSecond;
  @override
  double get fontSize;
  @override
  double get overlayWidth;
  @override
  double get overlayHeight;
  @override
  int get countdownSeconds;
  @override
  bool get privacyModeEnabled;
  @override
  String get script;

  /// Create a copy of SettingsState
  /// with the given fields replaced by the non-null parameter values.
  @override
  @JsonKey(includeFromJson: false, includeToJson: false)
  _$$SettingsStateImplCopyWith<_$SettingsStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

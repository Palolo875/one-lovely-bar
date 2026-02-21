// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

UserProfile _$UserProfileFromJson(Map<String, dynamic> json) {
  return _UserProfile.fromJson(json);
}

/// @nodoc
mixin _$UserProfile {
  String get id => throw _privateConstructorUsedError;
  String get name => throw _privateConstructorUsedError;
  ProfileType get type => throw _privateConstructorUsedError;
  List<String> get defaultLayers => throw _privateConstructorUsedError;
  Map<String, double> get alertThresholds => throw _privateConstructorUsedError;
  String get speedUnit => throw _privateConstructorUsedError;
  String get tempUnit => throw _privateConstructorUsedError;
  String get distanceUnit => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $UserProfileCopyWith<UserProfile> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $UserProfileCopyWith<$Res> {
  factory $UserProfileCopyWith(
          UserProfile value, $Res Function(UserProfile) then) =
      _$UserProfileCopyWithImpl<$Res, UserProfile>;
  @useResult
  $Res call(
      {String id,
      String name,
      ProfileType type,
      List<String> defaultLayers,
      Map<String, double> alertThresholds,
      String speedUnit,
      String tempUnit,
      String distanceUnit});
}

/// @nodoc
class _$UserProfileCopyWithImpl<$Res, $Val extends UserProfile>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? defaultLayers = null,
    Object? alertThresholds = null,
    Object? speedUnit = null,
    Object? tempUnit = null,
    Object? distanceUnit = null,
  }) {
    return _then(_value.copyWith(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProfileType,
      defaultLayers: null == defaultLayers
          ? _value.defaultLayers
          : defaultLayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertThresholds: null == alertThresholds
          ? _value.alertThresholds
          : alertThresholds // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      speedUnit: null == speedUnit
          ? _value.speedUnit
          : speedUnit // ignore: cast_nullable_to_non_nullable
              as String,
      tempUnit: null == tempUnit
          ? _value.tempUnit
          : tempUnit // ignore: cast_nullable_to_non_nullable
              as String,
      distanceUnit: null == distanceUnit
          ? _value.distanceUnit
          : distanceUnit // ignore: cast_nullable_to_non_nullable
              as String,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$UserProfileImplCopyWith<$Res>
    implements $UserProfileCopyWith<$Res> {
  factory _$$UserProfileImplCopyWith(
          _$UserProfileImpl value, $Res Function(_$UserProfileImpl) then) =
      __$$UserProfileImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {String id,
      String name,
      ProfileType type,
      List<String> defaultLayers,
      Map<String, double> alertThresholds,
      String speedUnit,
      String tempUnit,
      String distanceUnit});
}

/// @nodoc
class __$$UserProfileImplCopyWithImpl<$Res>
    extends _$UserProfileCopyWithImpl<$Res, _$UserProfileImpl>
    implements _$$UserProfileImplCopyWith<$Res> {
  __$$UserProfileImplCopyWithImpl(
      _$UserProfileImpl _value, $Res Function(_$UserProfileImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? id = null,
    Object? name = null,
    Object? type = null,
    Object? defaultLayers = null,
    Object? alertThresholds = null,
    Object? speedUnit = null,
    Object? tempUnit = null,
    Object? distanceUnit = null,
  }) {
    return _then(_$UserProfileImpl(
      id: null == id
          ? _value.id
          : id // ignore: cast_nullable_to_non_nullable
              as String,
      name: null == name
          ? _value.name
          : name // ignore: cast_nullable_to_non_nullable
              as String,
      type: null == type
          ? _value.type
          : type // ignore: cast_nullable_to_non_nullable
              as ProfileType,
      defaultLayers: null == defaultLayers
          ? _value._defaultLayers
          : defaultLayers // ignore: cast_nullable_to_non_nullable
              as List<String>,
      alertThresholds: null == alertThresholds
          ? _value._alertThresholds
          : alertThresholds // ignore: cast_nullable_to_non_nullable
              as Map<String, double>,
      speedUnit: null == speedUnit
          ? _value.speedUnit
          : speedUnit // ignore: cast_nullable_to_non_nullable
              as String,
      tempUnit: null == tempUnit
          ? _value.tempUnit
          : tempUnit // ignore: cast_nullable_to_non_nullable
              as String,
      distanceUnit: null == distanceUnit
          ? _value.distanceUnit
          : distanceUnit // ignore: cast_nullable_to_non_nullable
              as String,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$UserProfileImpl implements _UserProfile {
  const _$UserProfileImpl(
      {required this.id,
      required this.name,
      required this.type,
      final List<String> defaultLayers = const [],
      final Map<String, double> alertThresholds = const {},
      this.speedUnit = 'km/h',
      this.tempUnit = '°C',
      this.distanceUnit = 'km'})
      : _defaultLayers = defaultLayers,
        _alertThresholds = alertThresholds;

  factory _$UserProfileImpl.fromJson(Map<String, dynamic> json) =>
      _$$UserProfileImplFromJson(json);

  @override
  final String id;
  @override
  final String name;
  @override
  final ProfileType type;
  final List<String> _defaultLayers;
  @override
  @JsonKey()
  List<String> get defaultLayers {
    if (_defaultLayers is EqualUnmodifiableListView) return _defaultLayers;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_defaultLayers);
  }

  final Map<String, double> _alertThresholds;
  @override
  @JsonKey()
  Map<String, double> get alertThresholds {
    if (_alertThresholds is EqualUnmodifiableMapView) return _alertThresholds;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableMapView(_alertThresholds);
  }

  @override
  @JsonKey()
  final String speedUnit;
  @override
  @JsonKey()
  final String tempUnit;
  @override
  @JsonKey()
  final String distanceUnit;

  @override
  String toString() {
    return 'UserProfile(id: $id, name: $name, type: $type, defaultLayers: $defaultLayers, alertThresholds: $alertThresholds, speedUnit: $speedUnit, tempUnit: $tempUnit, distanceUnit: $distanceUnit)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$UserProfileImpl &&
            (identical(other.id, id) || other.id == id) &&
            (identical(other.name, name) || other.name == name) &&
            (identical(other.type, type) || other.type == type) &&
            const DeepCollectionEquality()
                .equals(other._defaultLayers, _defaultLayers) &&
            const DeepCollectionEquality()
                .equals(other._alertThresholds, _alertThresholds) &&
            (identical(other.speedUnit, speedUnit) ||
                other.speedUnit == speedUnit) &&
            (identical(other.tempUnit, tempUnit) ||
                other.tempUnit == tempUnit) &&
            (identical(other.distanceUnit, distanceUnit) ||
                other.distanceUnit == distanceUnit));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      id,
      name,
      type,
      const DeepCollectionEquality().hash(_defaultLayers),
      const DeepCollectionEquality().hash(_alertThresholds),
      speedUnit,
      tempUnit,
      distanceUnit);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      __$$UserProfileImplCopyWithImpl<_$UserProfileImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$UserProfileImplToJson(
      this,
    );
  }
}

abstract class _UserProfile implements UserProfile {
  const factory _UserProfile(
      {required final String id,
      required final String name,
      required final ProfileType type,
      final List<String> defaultLayers,
      final Map<String, double> alertThresholds,
      final String speedUnit,
      final String tempUnit,
      final String distanceUnit}) = _$UserProfileImpl;

  factory _UserProfile.fromJson(Map<String, dynamic> json) =
      _$UserProfileImpl.fromJson;

  @override
  String get id;
  @override
  String get name;
  @override
  ProfileType get type;
  @override
  List<String> get defaultLayers;
  @override
  Map<String, double> get alertThresholds;
  @override
  String get speedUnit;
  @override
  String get tempUnit;
  @override
  String get distanceUnit;
  @override
  @JsonKey(ignore: true)
  _$$UserProfileImplCopyWith<_$UserProfileImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

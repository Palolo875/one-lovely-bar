// coverage:ignore-file
// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#adding-getters-and-methods-to-our-models');

RoutePoint _$RoutePointFromJson(Map<String, dynamic> json) {
  return _RoutePoint.fromJson(json);
}

/// @nodoc
mixin _$RoutePoint {
  double get latitude => throw _privateConstructorUsedError;
  double get longitude => throw _privateConstructorUsedError;
  DateTime? get timestamp => throw _privateConstructorUsedError;
  WeatherCondition? get weather => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RoutePointCopyWith<RoutePoint> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RoutePointCopyWith<$Res> {
  factory $RoutePointCopyWith(
          RoutePoint value, $Res Function(RoutePoint) then) =
      _$RoutePointCopyWithImpl<$Res, RoutePoint>;
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      DateTime? timestamp,
      WeatherCondition? weather});

  $WeatherConditionCopyWith<$Res>? get weather;
}

/// @nodoc
class _$RoutePointCopyWithImpl<$Res, $Val extends RoutePoint>
    implements $RoutePointCopyWith<$Res> {
  _$RoutePointCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = freezed,
    Object? weather = freezed,
  }) {
    return _then(_value.copyWith(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weather: freezed == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as WeatherCondition?,
    ) as $Val);
  }

  @override
  @pragma('vm:prefer-inline')
  $WeatherConditionCopyWith<$Res>? get weather {
    if (_value.weather == null) {
      return null;
    }

    return $WeatherConditionCopyWith<$Res>(_value.weather!, (value) {
      return _then(_value.copyWith(weather: value) as $Val);
    });
  }
}

/// @nodoc
abstract class _$$RoutePointImplCopyWith<$Res>
    implements $RoutePointCopyWith<$Res> {
  factory _$$RoutePointImplCopyWith(
          _$RoutePointImpl value, $Res Function(_$RoutePointImpl) then) =
      __$$RoutePointImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {double latitude,
      double longitude,
      DateTime? timestamp,
      WeatherCondition? weather});

  @override
  $WeatherConditionCopyWith<$Res>? get weather;
}

/// @nodoc
class __$$RoutePointImplCopyWithImpl<$Res>
    extends _$RoutePointCopyWithImpl<$Res, _$RoutePointImpl>
    implements _$$RoutePointImplCopyWith<$Res> {
  __$$RoutePointImplCopyWithImpl(
      _$RoutePointImpl _value, $Res Function(_$RoutePointImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? latitude = null,
    Object? longitude = null,
    Object? timestamp = freezed,
    Object? weather = freezed,
  }) {
    return _then(_$RoutePointImpl(
      latitude: null == latitude
          ? _value.latitude
          : latitude // ignore: cast_nullable_to_non_nullable
              as double,
      longitude: null == longitude
          ? _value.longitude
          : longitude // ignore: cast_nullable_to_non_nullable
              as double,
      timestamp: freezed == timestamp
          ? _value.timestamp
          : timestamp // ignore: cast_nullable_to_non_nullable
              as DateTime?,
      weather: freezed == weather
          ? _value.weather
          : weather // ignore: cast_nullable_to_non_nullable
              as WeatherCondition?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RoutePointImpl implements _RoutePoint {
  const _$RoutePointImpl(
      {required this.latitude,
      required this.longitude,
      this.timestamp,
      this.weather});

  factory _$RoutePointImpl.fromJson(Map<String, dynamic> json) =>
      _$$RoutePointImplFromJson(json);

  @override
  final double latitude;
  @override
  final double longitude;
  @override
  final DateTime? timestamp;
  @override
  final WeatherCondition? weather;

  @override
  String toString() {
    return 'RoutePoint(latitude: $latitude, longitude: $longitude, timestamp: $timestamp, weather: $weather)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RoutePointImpl &&
            (identical(other.latitude, latitude) ||
                other.latitude == latitude) &&
            (identical(other.longitude, longitude) ||
                other.longitude == longitude) &&
            (identical(other.timestamp, timestamp) ||
                other.timestamp == timestamp) &&
            (identical(other.weather, weather) || other.weather == weather));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode =>
      Object.hash(runtimeType, latitude, longitude, timestamp, weather);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RoutePointImplCopyWith<_$RoutePointImpl> get copyWith =>
      __$$RoutePointImplCopyWithImpl<_$RoutePointImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RoutePointImplToJson(
      this,
    );
  }
}

abstract class _RoutePoint implements RoutePoint {
  const factory _RoutePoint(
      {required final double latitude,
      required final double longitude,
      final DateTime? timestamp,
      final WeatherCondition? weather}) = _$RoutePointImpl;

  factory _RoutePoint.fromJson(Map<String, dynamic> json) =
      _$RoutePointImpl.fromJson;

  @override
  double get latitude;
  @override
  double get longitude;
  @override
  DateTime? get timestamp;
  @override
  WeatherCondition? get weather;
  @override
  @JsonKey(ignore: true)
  _$$RoutePointImplCopyWith<_$RoutePointImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

RouteData _$RouteDataFromJson(Map<String, dynamic> json) {
  return _RouteData.fromJson(json);
}

/// @nodoc
mixin _$RouteData {
  List<RoutePoint> get points => throw _privateConstructorUsedError;
  double get distanceKm => throw _privateConstructorUsedError;
  double get durationMinutes => throw _privateConstructorUsedError;
  String get profile => throw _privateConstructorUsedError;
  String? get gpxData => throw _privateConstructorUsedError;

  Map<String, dynamic> toJson() => throw _privateConstructorUsedError;
  @JsonKey(ignore: true)
  $RouteDataCopyWith<RouteData> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $RouteDataCopyWith<$Res> {
  factory $RouteDataCopyWith(RouteData value, $Res Function(RouteData) then) =
      _$RouteDataCopyWithImpl<$Res, RouteData>;
  @useResult
  $Res call(
      {List<RoutePoint> points,
      double distanceKm,
      double durationMinutes,
      String profile,
      String? gpxData});
}

/// @nodoc
class _$RouteDataCopyWithImpl<$Res, $Val extends RouteData>
    implements $RouteDataCopyWith<$Res> {
  _$RouteDataCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? distanceKm = null,
    Object? durationMinutes = null,
    Object? profile = null,
    Object? gpxData = freezed,
  }) {
    return _then(_value.copyWith(
      points: null == points
          ? _value.points
          : points // ignore: cast_nullable_to_non_nullable
              as List<RoutePoint>,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as double,
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as String,
      gpxData: freezed == gpxData
          ? _value.gpxData
          : gpxData // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$RouteDataImplCopyWith<$Res>
    implements $RouteDataCopyWith<$Res> {
  factory _$$RouteDataImplCopyWith(
          _$RouteDataImpl value, $Res Function(_$RouteDataImpl) then) =
      __$$RouteDataImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<RoutePoint> points,
      double distanceKm,
      double durationMinutes,
      String profile,
      String? gpxData});
}

/// @nodoc
class __$$RouteDataImplCopyWithImpl<$Res>
    extends _$RouteDataCopyWithImpl<$Res, _$RouteDataImpl>
    implements _$$RouteDataImplCopyWith<$Res> {
  __$$RouteDataImplCopyWithImpl(
      _$RouteDataImpl _value, $Res Function(_$RouteDataImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? points = null,
    Object? distanceKm = null,
    Object? durationMinutes = null,
    Object? profile = null,
    Object? gpxData = freezed,
  }) {
    return _then(_$RouteDataImpl(
      points: null == points
          ? _value._points
          : points // ignore: cast_nullable_to_non_nullable
              as List<RoutePoint>,
      distanceKm: null == distanceKm
          ? _value.distanceKm
          : distanceKm // ignore: cast_nullable_to_non_nullable
              as double,
      durationMinutes: null == durationMinutes
          ? _value.durationMinutes
          : durationMinutes // ignore: cast_nullable_to_non_nullable
              as double,
      profile: null == profile
          ? _value.profile
          : profile // ignore: cast_nullable_to_non_nullable
              as String,
      gpxData: freezed == gpxData
          ? _value.gpxData
          : gpxData // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc
@JsonSerializable()
class _$RouteDataImpl implements _RouteData {
  const _$RouteDataImpl(
      {required final List<RoutePoint> points,
      required this.distanceKm,
      required this.durationMinutes,
      required this.profile,
      this.gpxData})
      : _points = points;

  factory _$RouteDataImpl.fromJson(Map<String, dynamic> json) =>
      _$$RouteDataImplFromJson(json);

  final List<RoutePoint> _points;
  @override
  List<RoutePoint> get points {
    if (_points is EqualUnmodifiableListView) return _points;
    // ignore: implicit_dynamic_type
    return EqualUnmodifiableListView(_points);
  }

  @override
  final double distanceKm;
  @override
  final double durationMinutes;
  @override
  final String profile;
  @override
  final String? gpxData;

  @override
  String toString() {
    return 'RouteData(points: $points, distanceKm: $distanceKm, durationMinutes: $durationMinutes, profile: $profile, gpxData: $gpxData)';
  }

  @override
  bool operator ==(Object other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$RouteDataImpl &&
            const DeepCollectionEquality().equals(other._points, _points) &&
            (identical(other.distanceKm, distanceKm) ||
                other.distanceKm == distanceKm) &&
            (identical(other.durationMinutes, durationMinutes) ||
                other.durationMinutes == durationMinutes) &&
            (identical(other.profile, profile) || other.profile == profile) &&
            (identical(other.gpxData, gpxData) || other.gpxData == gpxData));
  }

  @JsonKey(ignore: true)
  @override
  int get hashCode => Object.hash(
      runtimeType,
      const DeepCollectionEquality().hash(_points),
      distanceKm,
      durationMinutes,
      profile,
      gpxData);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$RouteDataImplCopyWith<_$RouteDataImpl> get copyWith =>
      __$$RouteDataImplCopyWithImpl<_$RouteDataImpl>(this, _$identity);

  @override
  Map<String, dynamic> toJson() {
    return _$$RouteDataImplToJson(
      this,
    );
  }
}

abstract class _RouteData implements RouteData {
  const factory _RouteData(
      {required final List<RoutePoint> points,
      required final double distanceKm,
      required final double durationMinutes,
      required final String profile,
      final String? gpxData}) = _$RouteDataImpl;

  factory _RouteData.fromJson(Map<String, dynamic> json) =
      _$RouteDataImpl.fromJson;

  @override
  List<RoutePoint> get points;
  @override
  double get distanceKm;
  @override
  double get durationMinutes;
  @override
  String get profile;
  @override
  String? get gpxData;
  @override
  @JsonKey(ignore: true)
  _$$RouteDataImplCopyWith<_$RouteDataImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

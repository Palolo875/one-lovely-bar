// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'route_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$RoutePoint {

 double get latitude; double get longitude; DateTime? get timestamp; WeatherCondition? get weather;
/// Create a copy of RoutePoint
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RoutePointCopyWith<RoutePoint> get copyWith => _$RoutePointCopyWithImpl<RoutePoint>(this as RoutePoint, _$identity);

  /// Serializes this RoutePoint to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RoutePoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.weather, weather) || other.weather == weather));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,timestamp,weather);

@override
String toString() {
  return 'RoutePoint(latitude: $latitude, longitude: $longitude, timestamp: $timestamp, weather: $weather)';
}


}

/// @nodoc
abstract mixin class $RoutePointCopyWith<$Res>  {
  factory $RoutePointCopyWith(RoutePoint value, $Res Function(RoutePoint) _then) = _$RoutePointCopyWithImpl;
@useResult
$Res call({
 double latitude, double longitude, DateTime? timestamp, WeatherCondition? weather
});


$WeatherConditionCopyWith<$Res>? get weather;

}
/// @nodoc
class _$RoutePointCopyWithImpl<$Res>
    implements $RoutePointCopyWith<$Res> {
  _$RoutePointCopyWithImpl(this._self, this._then);

  final RoutePoint _self;
  final $Res Function(RoutePoint) _then;

/// Create a copy of RoutePoint
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? latitude = null,Object? longitude = null,Object? timestamp = freezed,Object? weather = freezed,}) {
  return _then(_self.copyWith(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as WeatherCondition?,
  ));
}
/// Create a copy of RoutePoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherConditionCopyWith<$Res>? get weather {
    if (_self.weather == null) {
    return null;
  }

  return $WeatherConditionCopyWith<$Res>(_self.weather!, (value) {
    return _then(_self.copyWith(weather: value));
  });
}
}


/// Adds pattern-matching-related methods to [RoutePoint].
extension RoutePointPatterns on RoutePoint {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RoutePoint value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RoutePoint() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RoutePoint value)  $default,){
final _that = this;
switch (_that) {
case _RoutePoint():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RoutePoint value)?  $default,){
final _that = this;
switch (_that) {
case _RoutePoint() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double latitude,  double longitude,  DateTime? timestamp,  WeatherCondition? weather)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RoutePoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.timestamp,_that.weather);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double latitude,  double longitude,  DateTime? timestamp,  WeatherCondition? weather)  $default,) {final _that = this;
switch (_that) {
case _RoutePoint():
return $default(_that.latitude,_that.longitude,_that.timestamp,_that.weather);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double latitude,  double longitude,  DateTime? timestamp,  WeatherCondition? weather)?  $default,) {final _that = this;
switch (_that) {
case _RoutePoint() when $default != null:
return $default(_that.latitude,_that.longitude,_that.timestamp,_that.weather);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RoutePoint implements RoutePoint {
  const _RoutePoint({required this.latitude, required this.longitude, this.timestamp, this.weather});
  factory _RoutePoint.fromJson(Map<String, dynamic> json) => _$RoutePointFromJson(json);

@override final  double latitude;
@override final  double longitude;
@override final  DateTime? timestamp;
@override final  WeatherCondition? weather;

/// Create a copy of RoutePoint
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RoutePointCopyWith<_RoutePoint> get copyWith => __$RoutePointCopyWithImpl<_RoutePoint>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RoutePointToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RoutePoint&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.weather, weather) || other.weather == weather));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,latitude,longitude,timestamp,weather);

@override
String toString() {
  return 'RoutePoint(latitude: $latitude, longitude: $longitude, timestamp: $timestamp, weather: $weather)';
}


}

/// @nodoc
abstract mixin class _$RoutePointCopyWith<$Res> implements $RoutePointCopyWith<$Res> {
  factory _$RoutePointCopyWith(_RoutePoint value, $Res Function(_RoutePoint) _then) = __$RoutePointCopyWithImpl;
@override @useResult
$Res call({
 double latitude, double longitude, DateTime? timestamp, WeatherCondition? weather
});


@override $WeatherConditionCopyWith<$Res>? get weather;

}
/// @nodoc
class __$RoutePointCopyWithImpl<$Res>
    implements _$RoutePointCopyWith<$Res> {
  __$RoutePointCopyWithImpl(this._self, this._then);

  final _RoutePoint _self;
  final $Res Function(_RoutePoint) _then;

/// Create a copy of RoutePoint
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? latitude = null,Object? longitude = null,Object? timestamp = freezed,Object? weather = freezed,}) {
  return _then(_RoutePoint(
latitude: null == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double,longitude: null == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double,timestamp: freezed == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime?,weather: freezed == weather ? _self.weather : weather // ignore: cast_nullable_to_non_nullable
as WeatherCondition?,
  ));
}

/// Create a copy of RoutePoint
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$WeatherConditionCopyWith<$Res>? get weather {
    if (_self.weather == null) {
    return null;
  }

  return $WeatherConditionCopyWith<$Res>(_self.weather!, (value) {
    return _then(_self.copyWith(weather: value));
  });
}
}


/// @nodoc
mixin _$RouteData {

 List<RoutePoint> get points; double get distanceKm; double get durationMinutes; String get profile; String? get gpxData;
/// Create a copy of RouteData
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$RouteDataCopyWith<RouteData> get copyWith => _$RouteDataCopyWithImpl<RouteData>(this as RouteData, _$identity);

  /// Serializes this RouteData to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is RouteData&&const DeepCollectionEquality().equals(other.points, points)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.gpxData, gpxData) || other.gpxData == gpxData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(points),distanceKm,durationMinutes,profile,gpxData);

@override
String toString() {
  return 'RouteData(points: $points, distanceKm: $distanceKm, durationMinutes: $durationMinutes, profile: $profile, gpxData: $gpxData)';
}


}

/// @nodoc
abstract mixin class $RouteDataCopyWith<$Res>  {
  factory $RouteDataCopyWith(RouteData value, $Res Function(RouteData) _then) = _$RouteDataCopyWithImpl;
@useResult
$Res call({
 List<RoutePoint> points, double distanceKm, double durationMinutes, String profile, String? gpxData
});




}
/// @nodoc
class _$RouteDataCopyWithImpl<$Res>
    implements $RouteDataCopyWith<$Res> {
  _$RouteDataCopyWithImpl(this._self, this._then);

  final RouteData _self;
  final $Res Function(RouteData) _then;

/// Create a copy of RouteData
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? points = null,Object? distanceKm = null,Object? durationMinutes = null,Object? profile = null,Object? gpxData = freezed,}) {
  return _then(_self.copyWith(
points: null == points ? _self.points : points // ignore: cast_nullable_to_non_nullable
as List<RoutePoint>,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as double,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,gpxData: freezed == gpxData ? _self.gpxData : gpxData // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [RouteData].
extension RouteDataPatterns on RouteData {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _RouteData value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _RouteData() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _RouteData value)  $default,){
final _that = this;
switch (_that) {
case _RouteData():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _RouteData value)?  $default,){
final _that = this;
switch (_that) {
case _RouteData() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<RoutePoint> points,  double distanceKm,  double durationMinutes,  String profile,  String? gpxData)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _RouteData() when $default != null:
return $default(_that.points,_that.distanceKm,_that.durationMinutes,_that.profile,_that.gpxData);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<RoutePoint> points,  double distanceKm,  double durationMinutes,  String profile,  String? gpxData)  $default,) {final _that = this;
switch (_that) {
case _RouteData():
return $default(_that.points,_that.distanceKm,_that.durationMinutes,_that.profile,_that.gpxData);case _:
  throw StateError('Unexpected subclass');

}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<RoutePoint> points,  double distanceKm,  double durationMinutes,  String profile,  String? gpxData)?  $default,) {final _that = this;
switch (_that) {
case _RouteData() when $default != null:
return $default(_that.points,_that.distanceKm,_that.durationMinutes,_that.profile,_that.gpxData);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _RouteData implements RouteData {
  const _RouteData({required final  List<RoutePoint> points, required this.distanceKm, required this.durationMinutes, required this.profile, this.gpxData}): _points = points;
  factory _RouteData.fromJson(Map<String, dynamic> json) => _$RouteDataFromJson(json);

 final  List<RoutePoint> _points;
@override List<RoutePoint> get points {
  if (_points is EqualUnmodifiableListView) return _points;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_points);
}

@override final  double distanceKm;
@override final  double durationMinutes;
@override final  String profile;
@override final  String? gpxData;

/// Create a copy of RouteData
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$RouteDataCopyWith<_RouteData> get copyWith => __$RouteDataCopyWithImpl<_RouteData>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$RouteDataToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _RouteData&&const DeepCollectionEquality().equals(other._points, _points)&&(identical(other.distanceKm, distanceKm) || other.distanceKm == distanceKm)&&(identical(other.durationMinutes, durationMinutes) || other.durationMinutes == durationMinutes)&&(identical(other.profile, profile) || other.profile == profile)&&(identical(other.gpxData, gpxData) || other.gpxData == gpxData));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_points),distanceKm,durationMinutes,profile,gpxData);

@override
String toString() {
  return 'RouteData(points: $points, distanceKm: $distanceKm, durationMinutes: $durationMinutes, profile: $profile, gpxData: $gpxData)';
}


}

/// @nodoc
abstract mixin class _$RouteDataCopyWith<$Res> implements $RouteDataCopyWith<$Res> {
  factory _$RouteDataCopyWith(_RouteData value, $Res Function(_RouteData) _then) = __$RouteDataCopyWithImpl;
@override @useResult
$Res call({
 List<RoutePoint> points, double distanceKm, double durationMinutes, String profile, String? gpxData
});




}
/// @nodoc
class __$RouteDataCopyWithImpl<$Res>
    implements _$RouteDataCopyWith<$Res> {
  __$RouteDataCopyWithImpl(this._self, this._then);

  final _RouteData _self;
  final $Res Function(_RouteData) _then;

/// Create a copy of RouteData
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? points = null,Object? distanceKm = null,Object? durationMinutes = null,Object? profile = null,Object? gpxData = freezed,}) {
  return _then(_RouteData(
points: null == points ? _self._points : points // ignore: cast_nullable_to_non_nullable
as List<RoutePoint>,distanceKm: null == distanceKm ? _self.distanceKm : distanceKm // ignore: cast_nullable_to_non_nullable
as double,durationMinutes: null == durationMinutes ? _self.durationMinutes : durationMinutes // ignore: cast_nullable_to_non_nullable
as double,profile: null == profile ? _self.profile : profile // ignore: cast_nullable_to_non_nullable
as String,gpxData: freezed == gpxData ? _self.gpxData : gpxData // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

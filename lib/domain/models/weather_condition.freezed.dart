// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'weather_condition.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$WeatherCondition {

 double get temperature; double get precipitation; double get windSpeed; double get windDirection; int get weatherCode; DateTime get timestamp; double? get visibility; double? get uvIndex; double? get cloudCover; double? get airQuality;
/// Create a copy of WeatherCondition
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$WeatherConditionCopyWith<WeatherCondition> get copyWith => _$WeatherConditionCopyWithImpl<WeatherCondition>(this as WeatherCondition, _$identity);

  /// Serializes this WeatherCondition to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is WeatherCondition&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.windDirection, windDirection) || other.windDirection == windDirection)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.uvIndex, uvIndex) || other.uvIndex == uvIndex)&&(identical(other.cloudCover, cloudCover) || other.cloudCover == cloudCover)&&(identical(other.airQuality, airQuality) || other.airQuality == airQuality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,precipitation,windSpeed,windDirection,weatherCode,timestamp,visibility,uvIndex,cloudCover,airQuality);

@override
String toString() {
  return 'WeatherCondition(temperature: $temperature, precipitation: $precipitation, windSpeed: $windSpeed, windDirection: $windDirection, weatherCode: $weatherCode, timestamp: $timestamp, visibility: $visibility, uvIndex: $uvIndex, cloudCover: $cloudCover, airQuality: $airQuality)';
}


}

/// @nodoc
abstract mixin class $WeatherConditionCopyWith<$Res>  {
  factory $WeatherConditionCopyWith(WeatherCondition value, $Res Function(WeatherCondition) _then) = _$WeatherConditionCopyWithImpl;
@useResult
$Res call({
 double temperature, double precipitation, double windSpeed, double windDirection, int weatherCode, DateTime timestamp, double? visibility, double? uvIndex, double? cloudCover, double? airQuality
});




}
/// @nodoc
class _$WeatherConditionCopyWithImpl<$Res>
    implements $WeatherConditionCopyWith<$Res> {
  _$WeatherConditionCopyWithImpl(this._self, this._then);

  final WeatherCondition _self;
  final $Res Function(WeatherCondition) _then;

/// Create a copy of WeatherCondition
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? temperature = null,Object? precipitation = null,Object? windSpeed = null,Object? windDirection = null,Object? weatherCode = null,Object? timestamp = null,Object? visibility = freezed,Object? uvIndex = freezed,Object? cloudCover = freezed,Object? airQuality = freezed,}) {
  return _then(_self.copyWith(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,windDirection: null == windDirection ? _self.windDirection : windDirection // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as double?,uvIndex: freezed == uvIndex ? _self.uvIndex : uvIndex // ignore: cast_nullable_to_non_nullable
as double?,cloudCover: freezed == cloudCover ? _self.cloudCover : cloudCover // ignore: cast_nullable_to_non_nullable
as double?,airQuality: freezed == airQuality ? _self.airQuality : airQuality // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}

}


/// Adds pattern-matching-related methods to [WeatherCondition].
extension WeatherConditionPatterns on WeatherCondition {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _WeatherCondition value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _WeatherCondition() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _WeatherCondition value)  $default,){
final _that = this;
switch (_that) {
case _WeatherCondition():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _WeatherCondition value)?  $default,){
final _that = this;
switch (_that) {
case _WeatherCondition() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( double temperature,  double precipitation,  double windSpeed,  double windDirection,  int weatherCode,  DateTime timestamp,  double? visibility,  double? uvIndex,  double? cloudCover,  double? airQuality)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _WeatherCondition() when $default != null:
return $default(_that.temperature,_that.precipitation,_that.windSpeed,_that.windDirection,_that.weatherCode,_that.timestamp,_that.visibility,_that.uvIndex,_that.cloudCover,_that.airQuality);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( double temperature,  double precipitation,  double windSpeed,  double windDirection,  int weatherCode,  DateTime timestamp,  double? visibility,  double? uvIndex,  double? cloudCover,  double? airQuality)  $default,) {final _that = this;
switch (_that) {
case _WeatherCondition():
return $default(_that.temperature,_that.precipitation,_that.windSpeed,_that.windDirection,_that.weatherCode,_that.timestamp,_that.visibility,_that.uvIndex,_that.cloudCover,_that.airQuality);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( double temperature,  double precipitation,  double windSpeed,  double windDirection,  int weatherCode,  DateTime timestamp,  double? visibility,  double? uvIndex,  double? cloudCover,  double? airQuality)?  $default,) {final _that = this;
switch (_that) {
case _WeatherCondition() when $default != null:
return $default(_that.temperature,_that.precipitation,_that.windSpeed,_that.windDirection,_that.weatherCode,_that.timestamp,_that.visibility,_that.uvIndex,_that.cloudCover,_that.airQuality);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _WeatherCondition implements WeatherCondition {
  const _WeatherCondition({required this.temperature, required this.precipitation, required this.windSpeed, required this.windDirection, required this.weatherCode, required this.timestamp, this.visibility, this.uvIndex, this.cloudCover, this.airQuality});
  factory _WeatherCondition.fromJson(Map<String, dynamic> json) => _$WeatherConditionFromJson(json);

@override final  double temperature;
@override final  double precipitation;
@override final  double windSpeed;
@override final  double windDirection;
@override final  int weatherCode;
@override final  DateTime timestamp;
@override final  double? visibility;
@override final  double? uvIndex;
@override final  double? cloudCover;
@override final  double? airQuality;

/// Create a copy of WeatherCondition
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$WeatherConditionCopyWith<_WeatherCondition> get copyWith => __$WeatherConditionCopyWithImpl<_WeatherCondition>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$WeatherConditionToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _WeatherCondition&&(identical(other.temperature, temperature) || other.temperature == temperature)&&(identical(other.precipitation, precipitation) || other.precipitation == precipitation)&&(identical(other.windSpeed, windSpeed) || other.windSpeed == windSpeed)&&(identical(other.windDirection, windDirection) || other.windDirection == windDirection)&&(identical(other.weatherCode, weatherCode) || other.weatherCode == weatherCode)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.visibility, visibility) || other.visibility == visibility)&&(identical(other.uvIndex, uvIndex) || other.uvIndex == uvIndex)&&(identical(other.cloudCover, cloudCover) || other.cloudCover == cloudCover)&&(identical(other.airQuality, airQuality) || other.airQuality == airQuality));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,temperature,precipitation,windSpeed,windDirection,weatherCode,timestamp,visibility,uvIndex,cloudCover,airQuality);

@override
String toString() {
  return 'WeatherCondition(temperature: $temperature, precipitation: $precipitation, windSpeed: $windSpeed, windDirection: $windDirection, weatherCode: $weatherCode, timestamp: $timestamp, visibility: $visibility, uvIndex: $uvIndex, cloudCover: $cloudCover, airQuality: $airQuality)';
}


}

/// @nodoc
abstract mixin class _$WeatherConditionCopyWith<$Res> implements $WeatherConditionCopyWith<$Res> {
  factory _$WeatherConditionCopyWith(_WeatherCondition value, $Res Function(_WeatherCondition) _then) = __$WeatherConditionCopyWithImpl;
@override @useResult
$Res call({
 double temperature, double precipitation, double windSpeed, double windDirection, int weatherCode, DateTime timestamp, double? visibility, double? uvIndex, double? cloudCover, double? airQuality
});




}
/// @nodoc
class __$WeatherConditionCopyWithImpl<$Res>
    implements _$WeatherConditionCopyWith<$Res> {
  __$WeatherConditionCopyWithImpl(this._self, this._then);

  final _WeatherCondition _self;
  final $Res Function(_WeatherCondition) _then;

/// Create a copy of WeatherCondition
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? temperature = null,Object? precipitation = null,Object? windSpeed = null,Object? windDirection = null,Object? weatherCode = null,Object? timestamp = null,Object? visibility = freezed,Object? uvIndex = freezed,Object? cloudCover = freezed,Object? airQuality = freezed,}) {
  return _then(_WeatherCondition(
temperature: null == temperature ? _self.temperature : temperature // ignore: cast_nullable_to_non_nullable
as double,precipitation: null == precipitation ? _self.precipitation : precipitation // ignore: cast_nullable_to_non_nullable
as double,windSpeed: null == windSpeed ? _self.windSpeed : windSpeed // ignore: cast_nullable_to_non_nullable
as double,windDirection: null == windDirection ? _self.windDirection : windDirection // ignore: cast_nullable_to_non_nullable
as double,weatherCode: null == weatherCode ? _self.weatherCode : weatherCode // ignore: cast_nullable_to_non_nullable
as int,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as DateTime,visibility: freezed == visibility ? _self.visibility : visibility // ignore: cast_nullable_to_non_nullable
as double?,uvIndex: freezed == uvIndex ? _self.uvIndex : uvIndex // ignore: cast_nullable_to_non_nullable
as double?,cloudCover: freezed == cloudCover ? _self.cloudCover : cloudCover // ignore: cast_nullable_to_non_nullable
as double?,airQuality: freezed == airQuality ? _self.airQuality : airQuality // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}

// dart format on

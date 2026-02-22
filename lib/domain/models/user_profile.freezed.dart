// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'user_profile.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UserProfile {

 String get id; String get name; ProfileType get type; List<String> get defaultLayers; Map<String, double> get alertThresholds; String get speedUnit; String get tempUnit; String get distanceUnit;
/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UserProfileCopyWith<UserProfile> get copyWith => _$UserProfileCopyWithImpl<UserProfile>(this as UserProfile, _$identity);

  /// Serializes this UserProfile to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other.defaultLayers, defaultLayers)&&const DeepCollectionEquality().equals(other.alertThresholds, alertThresholds)&&(identical(other.speedUnit, speedUnit) || other.speedUnit == speedUnit)&&(identical(other.tempUnit, tempUnit) || other.tempUnit == tempUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,const DeepCollectionEquality().hash(defaultLayers),const DeepCollectionEquality().hash(alertThresholds),speedUnit,tempUnit,distanceUnit);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, type: $type, defaultLayers: $defaultLayers, alertThresholds: $alertThresholds, speedUnit: $speedUnit, tempUnit: $tempUnit, distanceUnit: $distanceUnit)';
}


}

/// @nodoc
abstract mixin class $UserProfileCopyWith<$Res>  {
  factory $UserProfileCopyWith(UserProfile value, $Res Function(UserProfile) _then) = _$UserProfileCopyWithImpl;
@useResult
$Res call({
 String id, String name, ProfileType type, List<String> defaultLayers, Map<String, double> alertThresholds, String speedUnit, String tempUnit, String distanceUnit
});




}
/// @nodoc
class _$UserProfileCopyWithImpl<$Res>
    implements $UserProfileCopyWith<$Res> {
  _$UserProfileCopyWithImpl(this._self, this._then);

  final UserProfile _self;
  final $Res Function(UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? name = null,Object? type = null,Object? defaultLayers = null,Object? alertThresholds = null,Object? speedUnit = null,Object? tempUnit = null,Object? distanceUnit = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProfileType,defaultLayers: null == defaultLayers ? _self.defaultLayers : defaultLayers // ignore: cast_nullable_to_non_nullable
as List<String>,alertThresholds: null == alertThresholds ? _self.alertThresholds : alertThresholds // ignore: cast_nullable_to_non_nullable
as Map<String, double>,speedUnit: null == speedUnit ? _self.speedUnit : speedUnit // ignore: cast_nullable_to_non_nullable
as String,tempUnit: null == tempUnit ? _self.tempUnit : tempUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [UserProfile].
extension UserProfilePatterns on UserProfile {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UserProfile value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UserProfile value)  $default,){
final _that = this;
switch (_that) {
case _UserProfile():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UserProfile value)?  $default,){
final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id,  String name,  ProfileType type,  List<String> defaultLayers,  Map<String, double> alertThresholds,  String speedUnit,  String tempUnit,  String distanceUnit)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.defaultLayers,_that.alertThresholds,_that.speedUnit,_that.tempUnit,_that.distanceUnit);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id,  String name,  ProfileType type,  List<String> defaultLayers,  Map<String, double> alertThresholds,  String speedUnit,  String tempUnit,  String distanceUnit)  $default,) {final _that = this;
switch (_that) {
case _UserProfile():
return $default(_that.id,_that.name,_that.type,_that.defaultLayers,_that.alertThresholds,_that.speedUnit,_that.tempUnit,_that.distanceUnit);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id,  String name,  ProfileType type,  List<String> defaultLayers,  Map<String, double> alertThresholds,  String speedUnit,  String tempUnit,  String distanceUnit)?  $default,) {final _that = this;
switch (_that) {
case _UserProfile() when $default != null:
return $default(_that.id,_that.name,_that.type,_that.defaultLayers,_that.alertThresholds,_that.speedUnit,_that.tempUnit,_that.distanceUnit);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UserProfile implements UserProfile {
  const _UserProfile({required this.id, required this.name, required this.type, final  List<String> defaultLayers = const [], final  Map<String, double> alertThresholds = const {}, this.speedUnit = 'km/h', this.tempUnit = '°C', this.distanceUnit = 'km'}): _defaultLayers = defaultLayers,_alertThresholds = alertThresholds;
  factory _UserProfile.fromJson(Map<String, dynamic> json) => _$UserProfileFromJson(json);

@override final  String id;
@override final  String name;
@override final  ProfileType type;
 final  List<String> _defaultLayers;
@override@JsonKey() List<String> get defaultLayers {
  if (_defaultLayers is EqualUnmodifiableListView) return _defaultLayers;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_defaultLayers);
}

 final  Map<String, double> _alertThresholds;
@override@JsonKey() Map<String, double> get alertThresholds {
  if (_alertThresholds is EqualUnmodifiableMapView) return _alertThresholds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_alertThresholds);
}

@override@JsonKey() final  String speedUnit;
@override@JsonKey() final  String tempUnit;
@override@JsonKey() final  String distanceUnit;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UserProfileCopyWith<_UserProfile> get copyWith => __$UserProfileCopyWithImpl<_UserProfile>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UserProfileToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UserProfile&&(identical(other.id, id) || other.id == id)&&(identical(other.name, name) || other.name == name)&&(identical(other.type, type) || other.type == type)&&const DeepCollectionEquality().equals(other._defaultLayers, _defaultLayers)&&const DeepCollectionEquality().equals(other._alertThresholds, _alertThresholds)&&(identical(other.speedUnit, speedUnit) || other.speedUnit == speedUnit)&&(identical(other.tempUnit, tempUnit) || other.tempUnit == tempUnit)&&(identical(other.distanceUnit, distanceUnit) || other.distanceUnit == distanceUnit));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,name,type,const DeepCollectionEquality().hash(_defaultLayers),const DeepCollectionEquality().hash(_alertThresholds),speedUnit,tempUnit,distanceUnit);

@override
String toString() {
  return 'UserProfile(id: $id, name: $name, type: $type, defaultLayers: $defaultLayers, alertThresholds: $alertThresholds, speedUnit: $speedUnit, tempUnit: $tempUnit, distanceUnit: $distanceUnit)';
}


}

/// @nodoc
abstract mixin class _$UserProfileCopyWith<$Res> implements $UserProfileCopyWith<$Res> {
  factory _$UserProfileCopyWith(_UserProfile value, $Res Function(_UserProfile) _then) = __$UserProfileCopyWithImpl;
@override @useResult
$Res call({
 String id, String name, ProfileType type, List<String> defaultLayers, Map<String, double> alertThresholds, String speedUnit, String tempUnit, String distanceUnit
});




}
/// @nodoc
class __$UserProfileCopyWithImpl<$Res>
    implements _$UserProfileCopyWith<$Res> {
  __$UserProfileCopyWithImpl(this._self, this._then);

  final _UserProfile _self;
  final $Res Function(_UserProfile) _then;

/// Create a copy of UserProfile
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? name = null,Object? type = null,Object? defaultLayers = null,Object? alertThresholds = null,Object? speedUnit = null,Object? tempUnit = null,Object? distanceUnit = null,}) {
  return _then(_UserProfile(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,name: null == name ? _self.name : name // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as ProfileType,defaultLayers: null == defaultLayers ? _self._defaultLayers : defaultLayers // ignore: cast_nullable_to_non_nullable
as List<String>,alertThresholds: null == alertThresholds ? _self._alertThresholds : alertThresholds // ignore: cast_nullable_to_non_nullable
as Map<String, double>,speedUnit: null == speedUnit ? _self.speedUnit : speedUnit // ignore: cast_nullable_to_non_nullable
as String,tempUnit: null == tempUnit ? _self.tempUnit : tempUnit // ignore: cast_nullable_to_non_nullable
as String,distanceUnit: null == distanceUnit ? _self.distanceUnit : distanceUnit // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

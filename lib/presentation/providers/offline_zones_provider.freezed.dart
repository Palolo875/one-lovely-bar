// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'offline_zones_provider.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;
/// @nodoc
mixin _$OfflineZonesState {

 List<OfflineZone> get zones; bool get isLoading; String? get error;
/// Create a copy of OfflineZonesState
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$OfflineZonesStateCopyWith<OfflineZonesState> get copyWith => _$OfflineZonesStateCopyWithImpl<OfflineZonesState>(this as OfflineZonesState, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is OfflineZonesState&&const DeepCollectionEquality().equals(other.zones, zones)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(zones),isLoading,error);



}

/// @nodoc
abstract mixin class $OfflineZonesStateCopyWith<$Res>  {
  factory $OfflineZonesStateCopyWith(OfflineZonesState value, $Res Function(OfflineZonesState) _then) = _$OfflineZonesStateCopyWithImpl;
@useResult
$Res call({
 List<OfflineZone> zones, bool isLoading, String? error
});




}
/// @nodoc
class _$OfflineZonesStateCopyWithImpl<$Res>
    implements $OfflineZonesStateCopyWith<$Res> {
  _$OfflineZonesStateCopyWithImpl(this._self, this._then);

  final OfflineZonesState _self;
  final $Res Function(OfflineZonesState) _then;

/// Create a copy of OfflineZonesState
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? zones = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_self.copyWith(
zones: null == zones ? _self.zones : zones // ignore: cast_nullable_to_non_nullable
as List<OfflineZone>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [OfflineZonesState].
extension OfflineZonesStatePatterns on OfflineZonesState {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _OfflineZonesState value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _OfflineZonesState() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _OfflineZonesState value)  $default,){
final _that = this;
switch (_that) {
case _OfflineZonesState():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _OfflineZonesState value)?  $default,){
final _that = this;
switch (_that) {
case _OfflineZonesState() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<OfflineZone> zones,  bool isLoading,  String? error)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _OfflineZonesState() when $default != null:
return $default(_that.zones,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<OfflineZone> zones,  bool isLoading,  String? error)  $default,) {final _that = this;
switch (_that) {
case _OfflineZonesState():
return $default(_that.zones,_that.isLoading,_that.error);case _:
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<OfflineZone> zones,  bool isLoading,  String? error)?  $default,) {final _that = this;
switch (_that) {
case _OfflineZonesState() when $default != null:
return $default(_that.zones,_that.isLoading,_that.error);case _:
  return null;

}
}

}

/// @nodoc


class _OfflineZonesState extends OfflineZonesState {
  const _OfflineZonesState({final  List<OfflineZone> zones = const [], this.isLoading = false, this.error}): _zones = zones,super._();
  

 final  List<OfflineZone> _zones;
@override@JsonKey() List<OfflineZone> get zones {
  if (_zones is EqualUnmodifiableListView) return _zones;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_zones);
}

@override@JsonKey() final  bool isLoading;
@override final  String? error;

/// Create a copy of OfflineZonesState
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$OfflineZonesStateCopyWith<_OfflineZonesState> get copyWith => __$OfflineZonesStateCopyWithImpl<_OfflineZonesState>(this, _$identity);



@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _OfflineZonesState&&const DeepCollectionEquality().equals(other._zones, _zones)&&(identical(other.isLoading, isLoading) || other.isLoading == isLoading)&&(identical(other.error, error) || other.error == error));
}


@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_zones),isLoading,error);



}

/// @nodoc
abstract mixin class _$OfflineZonesStateCopyWith<$Res> implements $OfflineZonesStateCopyWith<$Res> {
  factory _$OfflineZonesStateCopyWith(_OfflineZonesState value, $Res Function(_OfflineZonesState) _then) = __$OfflineZonesStateCopyWithImpl;
@override @useResult
$Res call({
 List<OfflineZone> zones, bool isLoading, String? error
});




}
/// @nodoc
class __$OfflineZonesStateCopyWithImpl<$Res>
    implements _$OfflineZonesStateCopyWith<$Res> {
  __$OfflineZonesStateCopyWithImpl(this._self, this._then);

  final _OfflineZonesState _self;
  final $Res Function(_OfflineZonesState) _then;

/// Create a copy of OfflineZonesState
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? zones = null,Object? isLoading = null,Object? error = freezed,}) {
  return _then(_OfflineZonesState(
zones: null == zones ? _self._zones : zones // ignore: cast_nullable_to_non_nullable
as List<OfflineZone>,isLoading: null == isLoading ? _self.isLoading : isLoading // ignore: cast_nullable_to_non_nullable
as bool,error: freezed == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}

// dart format on

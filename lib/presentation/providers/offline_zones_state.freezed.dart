part of 'offline_zones_provider.dart';

// GENERATED CODE - DO NOT MODIFY BY HAND

// **************************************************************************
// FreezedGenerator
// **************************************************************************

T _$identity<T>(T value) => value;

final _privateConstructorUsedError = UnsupportedError(
    'It seems like you constructed your class using `MyClass._()`. This constructor is only meant to be used by freezed and you are not supposed to need it nor use it.\nPlease check the documentation here for more information: https://github.com/rrousselGit/freezed#custom-getters-and-methods');

/// @nodoc
mixin _$OfflineZonesState {
  List<OfflineZone> get zones => throw _privateConstructorUsedError;
  bool get isLoading => throw _privateConstructorUsedError;
  String? get error => throw _privateConstructorUsedError;

  @JsonKey(ignore: true)
  $OfflineZonesStateCopyWith<OfflineZonesState> get copyWith =>
      throw _privateConstructorUsedError;
}

/// @nodoc
abstract class $OfflineZonesStateCopyWith<$Res> {
  factory $OfflineZonesStateCopyWith(
          OfflineZonesState value, $Res Function(OfflineZonesState) then) =
      _$OfflineZonesStateCopyWithImpl<$Res, OfflineZonesState>;
  @useResult
  $Res call(
      {List<OfflineZone> zones,
      bool isLoading,
      String? error});
}

/// @nodoc
class _$OfflineZonesStateCopyWithImpl<$Res, $Val extends OfflineZonesState>
    implements $OfflineZonesStateCopyWith<$Res> {
  _$OfflineZonesStateCopyWithImpl(this._value, this._then);

  // ignore: unused_field
  final $Val _value;
  // ignore: unused_field
  final $Res Function($Val) _then;

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? zones = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_value.copyWith(
      zones: null == zones
          ? _value.zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<OfflineZone>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ) as $Val);
  }
}

/// @nodoc
abstract class _$$OfflineZonesStateImplCopyWith<$Res>
    implements $OfflineZonesStateCopyWith<$Res> {
  factory _$$OfflineZonesStateImplCopyWith(_$OfflineZonesStateImpl value,
          $Res Function(_$OfflineZonesStateImpl) then) =
      __$$OfflineZonesStateImplCopyWithImpl<$Res>;
  @override
  @useResult
  $Res call(
      {List<OfflineZone> zones,
      bool isLoading,
      String? error});
}

/// @nodoc
class __$$OfflineZonesStateImplCopyWithImpl<$Res>
    extends _$OfflineZonesStateCopyWithImpl<$Res, _$OfflineZonesStateImpl>
    implements _$$OfflineZonesStateImplCopyWith<$Res> {
  __$$OfflineZonesStateImplCopyWithImpl(
      _$OfflineZonesStateImpl _value, $Res Function(_$OfflineZonesStateImpl) _then)
      : super(_value, _then);

  @pragma('vm:prefer-inline')
  @override
  $Res call({
    Object? zones = null,
    Object? isLoading = null,
    Object? error = freezed,
  }) {
    return _then(_$OfflineZonesStateImpl(
      zones: null == zones
          ? _value.zones
          : zones // ignore: cast_nullable_to_non_nullable
              as List<OfflineZone>,
      isLoading: null == isLoading
          ? _value.isLoading
          : isLoading // ignore: cast_nullable_to_non_nullable
              as bool,
      error: freezed == error
          ? _value.error
          : error // ignore: cast_nullable_to_non_nullable
              as String?,
    ));
  }
}

/// @nodoc

class _$OfflineZonesStateImpl implements _OfflineZonesState {
  const _$OfflineZonesStateImpl(
      {required this.zones, required this.isLoading, this.error});

  @override
  final List<OfflineZone> zones;
  @override
  final bool isLoading;
  @override
  final String? error;

  @override
  String toString() {
    return 'OfflineZonesState(zones: $zones, isLoading: $isLoading, error: $error)';
  }

  @override
  bool operator ==(dynamic other) {
    return identical(this, other) ||
        (other.runtimeType == runtimeType &&
            other is _$OfflineZonesStateImpl &&
            (identical(other.zones, zones) ||
                const DeepCollectionEquality().equals(other.zones, zones)) &&
            (identical(other.isLoading, isLoading) ||
                other.isLoading == isLoading) &&
            (identical(other.error, error) || other.error == error));
  }

  @override
  int get hashCode => Object.hash(runtimeType, zones, isLoading, error);

  @JsonKey(ignore: true)
  @override
  @pragma('vm:prefer-inline')
  _$$OfflineZonesStateImplCopyWith<_$OfflineZonesStateImpl> get copyWith =>
      __$$OfflineZonesStateImplCopyWithImpl<_$OfflineZonesStateImpl>(
          this, _$identity);
}

abstract class _OfflineZonesState implements OfflineZonesState {
  const factory _OfflineZonesState(
      {final List<OfflineZone> zones,
      final bool isLoading,
      final String? error}) = _$OfflineZonesStateImpl;

  @override
  List<OfflineZone> get zones;
  @override
  bool get isLoading;
  @override
  String? get error;
  @override
  @JsonKey(ignore: true)
  _$$OfflineZonesStateImplCopyWith<_$OfflineZonesStateImpl> get copyWith =>
      throw _privateConstructorUsedError;
}

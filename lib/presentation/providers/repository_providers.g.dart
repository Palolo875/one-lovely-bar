// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(dio)
final dioProvider = DioProvider._();

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'63358ca468925a6ed469aec08373fff5010e504e';

@ProviderFor(weatherRepository)
final weatherRepositoryProvider = WeatherRepositoryProvider._();

final class WeatherRepositoryProvider
    extends
        $FunctionalProvider<
          WeatherRepository,
          WeatherRepository,
          WeatherRepository
        >
    with $Provider<WeatherRepository> {
  WeatherRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'weatherRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$weatherRepositoryHash();

  @$internal
  @override
  $ProviderElement<WeatherRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  WeatherRepository create(Ref ref) {
    return weatherRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(WeatherRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<WeatherRepository>(value),
    );
  }
}

String _$weatherRepositoryHash() => r'9958aa63d962e203e1154b9562adb3824fa4c615';

@ProviderFor(routingRepository)
final routingRepositoryProvider = RoutingRepositoryProvider._();

final class RoutingRepositoryProvider
    extends
        $FunctionalProvider<
          RoutingRepository,
          RoutingRepository,
          RoutingRepository
        >
    with $Provider<RoutingRepository> {
  RoutingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'routingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$routingRepositoryHash();

  @$internal
  @override
  $ProviderElement<RoutingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RoutingRepository create(Ref ref) {
    return routingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RoutingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RoutingRepository>(value),
    );
  }
}

String _$routingRepositoryHash() => r'2829fbc73085c60021d005519ff3f98b9c3854e4';

@ProviderFor(geocodingRepository)
final geocodingRepositoryProvider = GeocodingRepositoryProvider._();

final class GeocodingRepositoryProvider
    extends
        $FunctionalProvider<
          GeocodingRepository,
          GeocodingRepository,
          GeocodingRepository
        >
    with $Provider<GeocodingRepository> {
  GeocodingRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'geocodingRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$geocodingRepositoryHash();

  @$internal
  @override
  $ProviderElement<GeocodingRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GeocodingRepository create(Ref ref) {
    return geocodingRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GeocodingRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GeocodingRepository>(value),
    );
  }
}

String _$geocodingRepositoryHash() =>
    r'c3c0d50de925b2c7007817251b567666fe8fba3d';

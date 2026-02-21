// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'repository_providers.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$dioHash() => r'58eeefbd0832498ca2574c1fe69ed783c58d1d8f';

/// See also [dio].
@ProviderFor(dio)
final dioProvider = AutoDisposeProvider<Dio>.internal(
  dio,
  name: r'dioProvider',
  debugGetCreateSourceHash:
      const bool.fromEnvironment('dart.vm.product') ? null : _$dioHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef DioRef = AutoDisposeProviderRef<Dio>;
String _$weatherRepositoryHash() => r'cb100eeac6489c650e562b39e9faaf2eca88330d';

/// See also [weatherRepository].
@ProviderFor(weatherRepository)
final weatherRepositoryProvider =
    AutoDisposeProvider<WeatherRepository>.internal(
  weatherRepository,
  name: r'weatherRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$weatherRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef WeatherRepositoryRef = AutoDisposeProviderRef<WeatherRepository>;
String _$routingRepositoryHash() => r'2829fbc73085c60021d005519ff3f98b9c3854e4';

/// See also [routingRepository].
@ProviderFor(routingRepository)
final routingRepositoryProvider =
    AutoDisposeProvider<RoutingRepository>.internal(
  routingRepository,
  name: r'routingRepositoryProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$routingRepositoryHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef RoutingRepositoryRef = AutoDisposeProviderRef<RoutingRepository>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

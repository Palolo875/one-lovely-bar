// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$weatherTimelineHash() => r'2dcf66112aa67415cb46d46ea1bf34dcc25270d7';

/// Copied from Dart SDK
class _SystemHash {
  _SystemHash._();

  static int combine(int hash, int value) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + value);
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x0007ffff & hash) << 10));
    return hash ^ (hash >> 6);
  }

  static int finish(int hash) {
    // ignore: parameter_assignments
    hash = 0x1fffffff & (hash + ((0x03ffffff & hash) << 3));
    // ignore: parameter_assignments
    hash = hash ^ (hash >> 11);
    return 0x1fffffff & (hash + ((0x00003fff & hash) << 15));
  }
}

/// See also [weatherTimeline].
@ProviderFor(weatherTimeline)
const weatherTimelineProvider = WeatherTimelineFamily();

/// See also [weatherTimeline].
class WeatherTimelineFamily extends Family<AsyncValue<List<WeatherCondition>>> {
  /// See also [weatherTimeline].
  const WeatherTimelineFamily();

  /// See also [weatherTimeline].
  WeatherTimelineProvider call(
    RouteData route,
  ) {
    return WeatherTimelineProvider(
      route,
    );
  }

  @override
  WeatherTimelineProvider getProviderOverride(
    covariant WeatherTimelineProvider provider,
  ) {
    return call(
      provider.route,
    );
  }

  static const Iterable<ProviderOrFamily>? _dependencies = null;

  @override
  Iterable<ProviderOrFamily>? get dependencies => _dependencies;

  static const Iterable<ProviderOrFamily>? _allTransitiveDependencies = null;

  @override
  Iterable<ProviderOrFamily>? get allTransitiveDependencies =>
      _allTransitiveDependencies;

  @override
  String? get name => r'weatherTimelineProvider';
}

/// See also [weatherTimeline].
class WeatherTimelineProvider
    extends AutoDisposeFutureProvider<List<WeatherCondition>> {
  /// See also [weatherTimeline].
  WeatherTimelineProvider(
    RouteData route,
  ) : this._internal(
          (ref) => weatherTimeline(
            ref as WeatherTimelineRef,
            route,
          ),
          from: weatherTimelineProvider,
          name: r'weatherTimelineProvider',
          debugGetCreateSourceHash:
              const bool.fromEnvironment('dart.vm.product')
                  ? null
                  : _$weatherTimelineHash,
          dependencies: WeatherTimelineFamily._dependencies,
          allTransitiveDependencies:
              WeatherTimelineFamily._allTransitiveDependencies,
          route: route,
        );

  WeatherTimelineProvider._internal(
    super._createNotifier, {
    required super.name,
    required super.dependencies,
    required super.allTransitiveDependencies,
    required super.debugGetCreateSourceHash,
    required super.from,
    required this.route,
  }) : super.internal();

  final RouteData route;

  @override
  Override overrideWith(
    FutureOr<List<WeatherCondition>> Function(WeatherTimelineRef provider)
        create,
  ) {
    return ProviderOverride(
      origin: this,
      override: WeatherTimelineProvider._internal(
        (ref) => create(ref as WeatherTimelineRef),
        from: from,
        name: null,
        dependencies: null,
        allTransitiveDependencies: null,
        debugGetCreateSourceHash: null,
        route: route,
      ),
    );
  }

  @override
  AutoDisposeFutureProviderElement<List<WeatherCondition>> createElement() {
    return _WeatherTimelineProviderElement(this);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherTimelineProvider && other.route == route;
  }

  @override
  int get hashCode {
    var hash = _SystemHash.combine(0, runtimeType.hashCode);
    hash = _SystemHash.combine(hash, route.hashCode);

    return _SystemHash.finish(hash);
  }
}

mixin WeatherTimelineRef
    on AutoDisposeFutureProviderRef<List<WeatherCondition>> {
  /// The parameter `route` of this provider.
  RouteData get route;
}

class _WeatherTimelineProviderElement
    extends AutoDisposeFutureProviderElement<List<WeatherCondition>>
    with WeatherTimelineRef {
  _WeatherTimelineProviderElement(super.provider);

  @override
  RouteData get route => (origin as WeatherTimelineProvider).route;
}
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_timeline_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(weatherTimeline)
final weatherTimelineProvider = WeatherTimelineFamily._();

final class WeatherTimelineProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<WeatherCondition>>,
          List<WeatherCondition>,
          FutureOr<List<WeatherCondition>>
        >
    with
        $FutureModifier<List<WeatherCondition>>,
        $FutureProvider<List<WeatherCondition>> {
  WeatherTimelineProvider._({
    required WeatherTimelineFamily super.from,
    required RouteData super.argument,
  }) : super(
         retry: null,
         name: r'weatherTimelineProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$weatherTimelineHash();

  @override
  String toString() {
    return r'weatherTimelineProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<WeatherCondition>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<WeatherCondition>> create(Ref ref) {
    final argument = this.argument as RouteData;
    return weatherTimeline(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is WeatherTimelineProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$weatherTimelineHash() => r'cfca937fb08fc0c1d6280e89b0e953327ea7b02d';

final class WeatherTimelineFamily extends $Family
    with
        $FunctionalFamilyOverride<FutureOr<List<WeatherCondition>>, RouteData> {
  WeatherTimelineFamily._()
    : super(
        retry: null,
        name: r'weatherTimelineProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  WeatherTimelineProvider call(RouteData route) =>
      WeatherTimelineProvider._(argument: route, from: this);

  @override
  String toString() => r'weatherTimelineProvider';
}

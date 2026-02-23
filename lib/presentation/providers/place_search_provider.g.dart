// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'place_search_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(placeSearch)
final placeSearchProvider = PlaceSearchFamily._();

final class PlaceSearchProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<PlaceSuggestion>>,
          List<PlaceSuggestion>,
          FutureOr<List<PlaceSuggestion>>
        >
    with
        $FutureModifier<List<PlaceSuggestion>>,
        $FutureProvider<List<PlaceSuggestion>> {
  PlaceSearchProvider._({
    required PlaceSearchFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'placeSearchProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$placeSearchHash();

  @override
  String toString() {
    return r'placeSearchProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  $FutureProviderElement<List<PlaceSuggestion>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<PlaceSuggestion>> create(Ref ref) {
    final argument = this.argument as String;
    return placeSearch(ref, argument);
  }

  @override
  bool operator ==(Object other) {
    return other is PlaceSearchProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$placeSearchHash() => r'332890827616c8066db5285a1c8328d312c258cc';

final class PlaceSearchFamily extends $Family
    with $FunctionalFamilyOverride<FutureOr<List<PlaceSuggestion>>, String> {
  PlaceSearchFamily._()
    : super(
        retry: null,
        name: r'placeSearchProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  PlaceSearchProvider call(String query) =>
      PlaceSearchProvider._(argument: query, from: this);

  @override
  String toString() => r'placeSearchProvider';
}

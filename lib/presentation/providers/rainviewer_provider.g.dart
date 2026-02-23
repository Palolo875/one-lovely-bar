// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'rainviewer_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(rainViewerRepository)
final rainViewerRepositoryProvider = RainViewerRepositoryProvider._();

final class RainViewerRepositoryProvider
    extends
        $FunctionalProvider<
          RainViewerRepository,
          RainViewerRepository,
          RainViewerRepository
        >
    with $Provider<RainViewerRepository> {
  RainViewerRepositoryProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rainViewerRepositoryProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rainViewerRepositoryHash();

  @$internal
  @override
  $ProviderElement<RainViewerRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  RainViewerRepository create(Ref ref) {
    return rainViewerRepository(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(RainViewerRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<RainViewerRepository>(value),
    );
  }
}

String _$rainViewerRepositoryHash() =>
    r'17b38db9748ddc78051393e33c18904e2fe351f3';

@ProviderFor(rainViewerLatestTime)
final rainViewerLatestTimeProvider = RainViewerLatestTimeProvider._();

final class RainViewerLatestTimeProvider
    extends $FunctionalProvider<AsyncValue<int?>, int?, FutureOr<int?>>
    with $FutureModifier<int?>, $FutureProvider<int?> {
  RainViewerLatestTimeProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'rainViewerLatestTimeProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$rainViewerLatestTimeHash();

  @$internal
  @override
  $FutureProviderElement<int?> $createElement($ProviderPointer pointer) =>
      $FutureProviderElement(pointer);

  @override
  FutureOr<int?> create(Ref ref) {
    return rainViewerLatestTime(ref);
  }
}

String _$rainViewerLatestTimeHash() =>
    r'5b57d07a29281fb177481c34d53a3f7eacd3ff9c';

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileNotifier)
final profileProvider = ProfileNotifierProvider._();

final class ProfileNotifierProvider
    extends $NotifierProvider<ProfileNotifier, UserProfile> {
  ProfileNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileNotifierHash();

  @$internal
  @override
  ProfileNotifier create() => ProfileNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UserProfile value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UserProfile>(value),
    );
  }
}

String _$profileNotifierHash() => r'a0d428485b2de3f53b168f5de25b46fc8687fb40';

abstract class _$ProfileNotifier extends $Notifier<UserProfile> {
  UserProfile build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<UserProfile, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<UserProfile, UserProfile>,
              UserProfile,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

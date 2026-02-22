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

String _$profileNotifierHash() => r'a1b7fb8acd5dcc6d727b5a61a54b0ead19c8c10e';

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

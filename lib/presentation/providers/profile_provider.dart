import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/models/user_profile.dart';

part 'profile_provider.g.dart';

@riverpod
class ProfileNotifier extends _$ProfileNotifier {
  @override
  UserProfile build() {
    return const UserProfile(
      id: 'default',
      name: 'Utilisateur Universel',
      type: ProfileType.universal,
      defaultLayers: ['precipitation', 'temp', 'wind'],
    );
  }

  void setProfile(UserProfile profile) {
    state = profile;
  }

  void setProfileByType(ProfileType type) {
    switch (type) {
      case ProfileType.cyclist:
        state = const UserProfile(
          id: 'cyclist',
          name: 'Cycliste',
          type: ProfileType.cyclist,
          defaultLayers: ['precipitation', 'wind', 'air_quality'],
          speedUnit: 'km/h',
        );
        break;
      case ProfileType.hiker:
        state = const UserProfile(
          id: 'hiker',
          name: 'Randonneur',
          type: ProfileType.hiker,
          defaultLayers: ['precipitation', 'cloud_cover', 'uv'],
        );
        break;
      // Add other profiles as needed
      default:
        state = const UserProfile(
          id: 'universal',
          name: 'Universel',
          type: ProfileType.universal,
        );
    }
  }
}

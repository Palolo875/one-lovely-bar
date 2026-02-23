import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weathernav/domain/models/user_profile.dart';

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
      case ProfileType.universal:
        state = const UserProfile(
          id: 'universal',
          name: 'Universel',
          type: ProfileType.universal,
        );
        return;
      case ProfileType.cyclist:
        state = const UserProfile(
          id: 'cyclist',
          name: 'Cycliste',
          type: ProfileType.cyclist,
          defaultLayers: ['precipitation', 'wind', 'air_quality'],
        );
        return;
      case ProfileType.hiker:
        state = const UserProfile(
          id: 'hiker',
          name: 'Randonneur',
          type: ProfileType.hiker,
          defaultLayers: ['precipitation', 'cloud_cover', 'uv'],
        );
        return;
      case ProfileType.driver:
        state = const UserProfile(
          id: 'driver',
          name: 'Conducteur',
          type: ProfileType.driver,
        );
        return;
      case ProfileType.nautical:
        state = const UserProfile(
          id: 'nautical',
          name: 'Nautique',
          type: ProfileType.nautical,
        );
        return;
      case ProfileType.paraglider:
        state = const UserProfile(
          id: 'paraglider',
          name: 'Parapente',
          type: ProfileType.paraglider,
        );
        return;
      case ProfileType.camper:
        state = const UserProfile(
          id: 'camper',
          name: 'Campeur',
          type: ProfileType.camper,
        );
        return;
    }
  }
}

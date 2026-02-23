import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';

class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(profileProvider);

    return Container(
      padding: const EdgeInsets.all(16),
      child: GridView.count(
        shrinkWrap: true,
        crossAxisCount: 3,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        children: ProfileType.values.map((type) {
          final isActive = activeProfile.type == type;
          return GestureDetector(
            onTap: () =>
                ref.read(profileProvider.notifier).setProfileByType(type),
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isActive ? Colors.blue : Colors.grey[100],
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Icon(
                    _getIcon(type),
                    color: isActive ? Colors.white : Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getName(type),
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }

  IconData _getIcon(ProfileType type) {
    switch (type) {
      case ProfileType.universal:
        return LucideIcons.globe;
      case ProfileType.cyclist:
        return LucideIcons.bike;
      case ProfileType.hiker:
        return LucideIcons.footprints;
      case ProfileType.driver:
        return LucideIcons.car;
      case ProfileType.nautical:
        return LucideIcons.ship;
      case ProfileType.paraglider:
        return LucideIcons.wind;
      case ProfileType.camper:
        return LucideIcons.tent;
    }
  }

  String _getName(ProfileType type) {
    switch (type) {
      case ProfileType.universal:
        return 'Universel';
      case ProfileType.cyclist:
        return 'Cycliste';
      case ProfileType.hiker:
        return 'Randonneur';
      case ProfileType.driver:
        return 'Conducteur';
      case ProfileType.nautical:
        return 'Nautique';
      case ProfileType.paraglider:
        return 'Aéro';
      case ProfileType.camper:
        return 'Campeur';
    }
  }
}

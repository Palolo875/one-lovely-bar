import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';

class ProfileSwitcher extends ConsumerWidget {
  const ProfileSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeProfile = ref.watch(profileProvider);
    final scheme = Theme.of(context).colorScheme;

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
                Tooltip(
                  message: _getName(type),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? scheme.primary
                          : scheme.surfaceVariant.withOpacity(0.55),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      _getIcon(type),
                      color: isActive ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _getName(type),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    fontWeight: isActive ? FontWeight.w800 : FontWeight.w600,
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

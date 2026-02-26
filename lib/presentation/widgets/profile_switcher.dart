import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/l10n/l10n_ext.dart';
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
                  message: profileName(context, type),
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: isActive
                          ? scheme.primary
                          : scheme.surfaceContainerHighest.withValues(alpha: 0.55),
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Icon(
                      profileIcon(type),
                      color: isActive ? scheme.onPrimary : scheme.onSurface,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  profileName(context, type),
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

  /// Returns the icon for a given [ProfileType].
  static IconData profileIcon(ProfileType type) {
    return switch (type) {
      ProfileType.universal => LucideIcons.globe,
      ProfileType.cyclist => LucideIcons.bike,
      ProfileType.hiker => LucideIcons.footprints,
      ProfileType.driver => LucideIcons.car,
      ProfileType.nautical => LucideIcons.ship,
      ProfileType.paraglider => LucideIcons.wind,
      ProfileType.camper => LucideIcons.tent,
    };
  }

  /// Returns the localized name for a given [ProfileType].
  static String profileName(BuildContext context, ProfileType type) {
    final l = context.l10n;
    return switch (type) {
      ProfileType.universal => l.profileUniversal,
      ProfileType.cyclist => l.profileCyclist,
      ProfileType.hiker => l.profileHiker,
      ProfileType.driver => l.profileDriver,
      ProfileType.nautical => l.profileNautical,
      ProfileType.paraglider => l.profileParaglider,
      ProfileType.camper => l.profileCamper,
    };
  }
}

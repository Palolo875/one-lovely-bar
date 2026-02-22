import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';
import 'package:weathernav/presentation/providers/settings_provider.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;
  ProfileType? _selectedProfile;
  bool _requestingPermissions = false;

  static const _profileKey = 'primary_profile_type';

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _setCompletedAndExit() async {
    await ref.read(onboardingCompletedProvider.notifier).setCompleted(true);
    if (!mounted) return;
    context.go('/');
  }

  Future<void> _persistProfile(ProfileType type) async {
    final settings = ref.read(settingsRepositoryProvider);
    await settings.put(_profileKey, type.name);
  }

  Future<void> _next() async {
    if (_index == 1 && _selectedProfile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Choisissez un profil pour continuer.')),
      );
      return;
    }

    if (_index < 2) {
      await _controller.nextPage(duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
      return;
    }

    await _setCompletedAndExit();
  }

  Future<void> _skip() async {
    await _setCompletedAndExit();
  }

  Future<void> _requestPermissions() async {
    if (_requestingPermissions) return;
    setState(() => _requestingPermissions = true);
    try {
      await Permission.locationWhenInUse.request();
      await Permission.notification.request();
    } catch (_) {
      // ignore
    }
    if (mounted) setState(() => _requestingPermissions = false);
  }

  void _selectProfile(ProfileType type) {
    setState(() => _selectedProfile = type);
    ref.read(profileNotifierProvider.notifier).setProfileByType(type);
    _persistProfile(type);
  }

  List<ProfileType> get _profiles => const [
        ProfileType.cyclist,
        ProfileType.hiker,
        ProfileType.driver,
        ProfileType.nautical,
        ProfileType.paraglider,
        ProfileType.camper,
      ];

  @override
  Widget build(BuildContext context) {
    final canSkip = _index >= 0;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  const Spacer(),
                  if (canSkip)
                    TextButton(
                      onPressed: _skip,
                      child: const Text('Passer'),
                    ),
                ],
              ),
            ),
            Expanded(
              child: PageView(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                children: [
                  _Slide(
                    title: 'Votre météo, sur votre chemin',
                    subtitle: 'Découvrez la météo exactement là où vous serez, au bon moment.',
                    icon: LucideIcons.mapPinned,
                  ),
                  _ProfileSlide(
                    profiles: _profiles,
                    selected: _selectedProfile,
                    onSelect: _selectProfile,
                  ),
                  _PermissionsSlide(
                    requesting: _requestingPermissions,
                    onRequest: _requestPermissions,
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _next,
                      child: Text(_index == 2 ? 'Commencer' : 'Continuer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Slide extends StatelessWidget {

  const _Slide({required this.title, required this.subtitle, required this.icon});
  final String title;
  final String subtitle;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Icon(icon, size: 56),
          const SizedBox(height: 24),
          Text(
            title,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const Spacer(),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: Center(
              child: Icon(LucideIcons.cloudRain, size: 48, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

class _ProfileSlide extends StatelessWidget {

  const _ProfileSlide({required this.profiles, required this.selected, required this.onSelect});
  final List<ProfileType> profiles;
  final ProfileType? selected;
  final ValueChanged<ProfileType> onSelect;

  String _label(ProfileType t) {
    switch (t) {
      case ProfileType.cyclist:
        return 'Cycliste';
      case ProfileType.hiker:
        return 'Randonneur';
      case ProfileType.driver:
        return 'Conducteur';
      case ProfileType.nautical:
        return 'Nautique';
      case ProfileType.paraglider:
        return 'Parapente';
      case ProfileType.camper:
        return 'Campeur';
      default:
        return 'Profil';
    }
  }

  IconData _icon(ProfileType t) {
    switch (t) {
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
      default:
        return LucideIcons.user;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Choisissez votre profil',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            'On adapte les couches météo et les alertes à votre usage.',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 1.25,
              children: profiles.map((p) {
                final isSelected = selected == p;
                return InkWell(
                  onTap: () => onSelect(p),
                  borderRadius: BorderRadius.circular(20),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: isSelected ? Theme.of(context).colorScheme.primary.withOpacity(0.12) : Theme.of(context).colorScheme.surface,
                      border: Border.all(
                        color: isSelected ? Theme.of(context).colorScheme.primary : Theme.of(context).dividerColor.withOpacity(0.25),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(_icon(p), size: 28, color: isSelected ? Theme.of(context).colorScheme.primary : null),
                        const Spacer(),
                        Text(
                          _label(p),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          isSelected ? 'Sélectionné' : 'Tap pour choisir',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _PermissionsSlide extends StatelessWidget {

  const _PermissionsSlide({required this.requesting, required this.onRequest});
  final bool requesting;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Text(
            'Permissions',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 12),
          Text(
            "La localisation permet de centrer la carte et d'afficher la météo exacte. Les notifications servent à vous prévenir en cas d'alerte météo.",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: requesting ? null : onRequest,
              child: Text(requesting ? 'Demande en cours…' : 'Autoriser'),
            ),
          ),
          const Spacer(),
          Container(
            height: 200,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Theme.of(context).colorScheme.surface,
              border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
            ),
            child: Center(
              child: Icon(LucideIcons.bell, size: 48, color: Theme.of(context).colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
}

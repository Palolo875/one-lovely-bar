import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:weathernav/l10n/l10n_ext.dart';

class AppShell extends StatelessWidget {
  const AppShell({required this.navigationShell, super.key});
  final StatefulNavigationShell navigationShell;

  void _onTap(BuildContext context, int index) {
    navigationShell.goBranch(
      index,
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    return Scaffold(
      body: navigationShell,
      bottomNavigationBar: NavigationBar(
        selectedIndex: navigationShell.currentIndex,
        onDestinationSelected: (i) => _onTap(context, i),
        destinations: [
          NavigationDestination(icon: const Icon(LucideIcons.map), label: l.tabMap),
          NavigationDestination(
            icon: const Icon(LucideIcons.navigation),
            label: l.tabItinerary,
          ),
          NavigationDestination(
            icon: const Icon(LucideIcons.history),
            label: l.tabHistory,
          ),
          NavigationDestination(icon: const Icon(LucideIcons.user), label: l.tabProfile),
        ],
      ),
    );
  }
}

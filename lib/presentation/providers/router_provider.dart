import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weathernav/presentation/providers/route_provider.dart';
import 'package:weathernav/presentation/providers/settings_provider.dart';
import 'package:weathernav/presentation/screens/guidance_screen.dart';
import 'package:weathernav/presentation/screens/history_screen.dart';
import 'package:weathernav/presentation/screens/home_screen.dart';
import 'package:weathernav/presentation/screens/itinerary_screen.dart';
import 'package:weathernav/presentation/screens/onboarding_screen.dart';
import 'package:weathernav/presentation/screens/profile_screen.dart';
import 'package:weathernav/presentation/screens/route_simulation_screen.dart';
import 'package:weathernav/presentation/screens/search_screen.dart';
import 'package:weathernav/presentation/widgets/app_shell.dart';

part 'router_provider.g.dart';

@riverpod
GoRouter router(Ref ref) {
  ref.keepAlive();
  final refresh = ValueNotifier<int>(0);
  ref.onDispose(refresh.dispose);

  ref.listen<bool>(onboardingCompletedProvider, (prev, next) {
    if (prev == next) return;
    refresh.value++;
  });

  return GoRouter(
    initialLocation: '/',
    refreshListenable: refresh,
    redirect: (context, state) {
      final completed = ref.read(onboardingCompletedProvider);
      final isOnboarding = state.uri.path == '/onboarding';

      if (!completed && !isOnboarding) return '/onboarding';
      if (completed && isOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) {
          return AppShell(navigationShell: navigationShell);
        },
        branches: [
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/itinerary',
                builder: (context, state) => const ItineraryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/history',
                builder: (context, state) => const HistoryScreen(),
              ),
            ],
          ),
          StatefulShellBranch(
            routes: [
              GoRoute(
                path: '/profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),
        ],
      ),
      GoRoute(path: '/planning', redirect: (context, state) => '/itinerary'),
      GoRoute(
        path: '/simulation',
        builder: (context, state) {
          final request = state.extra is RouteRequest
              ? state.extra! as RouteRequest
              : null;
          return RouteSimulationScreen(request: request);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) {
          final title = state.uri.queryParameters['title'] ?? 'Rechercher';
          return SearchScreen(title: title);
        },
      ),
      GoRoute(
        path: '/guidance',
        builder: (context, state) {
          final req = state.extra is RouteRequest
              ? state.extra! as RouteRequest
              : null;
          if (req == null) {
            return const ItineraryScreen();
          }
          return GuidanceScreen(request: req);
        },
      ),
    ],
  );
}

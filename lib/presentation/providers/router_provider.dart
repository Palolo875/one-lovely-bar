import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../screens/home_screen.dart';
import '../screens/planning_screen.dart';
import '../screens/route_simulation_screen.dart';
import '../screens/search_screen.dart';
import '../screens/guidance_screen.dart';
import 'route_provider.dart';

part 'router_provider.g.dart';

@riverpod
GoRouter router(RouterRef ref) {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: '/planning',
        builder: (context, state) => const PlanningScreen(),
      ),
      GoRoute(
        path: '/simulation',
        builder: (context, state) {
          final request = state.extra is RouteRequest ? state.extra as RouteRequest : null;
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
          final req = state.extra is RouteRequest ? state.extra as RouteRequest : null;
          if (req == null) {
            return const PlanningScreen();
          }
          return GuidanceScreen(request: req);
        },
      ),
    ],
  );
}

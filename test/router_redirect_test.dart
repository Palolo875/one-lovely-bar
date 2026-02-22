import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:weathernav/presentation/providers/router_provider.dart';
import 'package:weathernav/presentation/providers/settings_provider.dart';

class _FakeOnboardingNotifier extends StateNotifier<bool> {
  _FakeOnboardingNotifier(super.state);

  Future<void> setCompleted(bool value) async {
    state = value;
  }
}

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(routerConfig: router);
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  static const keyValue = Key('home');

  @override
  Widget build(BuildContext context) {
    return const SizedBox(key: keyValue);
  }
}

class _OnboardingPlaceholder extends StatelessWidget {
  const _OnboardingPlaceholder();

  static const keyValue = Key('onboarding');

  @override
  Widget build(BuildContext context) {
    return const SizedBox(key: keyValue);
  }
}

GoRouter _createTestRouter(WidgetRef ref) {
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
      final isOnboarding = state.matchedLocation == '/onboarding';
      if (!completed && !isOnboarding) return '/onboarding';
      if (completed && isOnboarding) return '/';
      return null;
    },
    routes: [
      GoRoute(
        path: '/',
        builder: (context, state) => const _HomePlaceholder(),
      ),
      GoRoute(
        path: '/onboarding',
        builder: (context, state) => const _OnboardingPlaceholder(),
      ),
    ],
  );
}

void main() {
  testWidgets('Redirects to onboarding when onboarding is not completed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompletedProvider.overrideWith((ref) => _FakeOnboardingNotifier(false)),
          routerProvider.overrideWith(_createTestRouter),
        ],
        child: const _TestApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(_OnboardingPlaceholder.keyValue), findsOneWidget);
    expect(find.byKey(_HomePlaceholder.keyValue), findsNothing);
  });

  testWidgets('Shows home when onboarding is completed', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          onboardingCompletedProvider.overrideWith((ref) => _FakeOnboardingNotifier(true)),
          routerProvider.overrideWith(_createTestRouter),
        ],
        child: const _TestApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byKey(_HomePlaceholder.keyValue), findsOneWidget);
    expect(find.byKey(_OnboardingPlaceholder.keyValue), findsNothing);
  });
}

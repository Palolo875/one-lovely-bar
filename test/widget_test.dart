import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/router_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';
import 'package:weathernav/presentation/screens/onboarding_screen.dart';

class _FakeSettingsRepository implements SettingsRepository {
  _FakeSettingsRepository(this._data);
  final Map<String, Object?> _data;

  @override
  T? get<T>(String key) => _data[key] is T ? _data[key] as T : null;

  @override
  T getOrDefault<T>(String key, T defaultValue) {
    final v = _data[key];
    if (v is T) return v;
    return defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    _data[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
  }

  @override
  Stream<void> watch(String key) => const Stream<void>.empty();
}

class _TestApp extends ConsumerWidget {
  const _TestApp();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    return MaterialApp.router(routerConfig: router);
  }
}

void main() {
  testWidgets('App redirects to onboarding when not completed', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(
            _FakeSettingsRepository({SettingsKeys.onboardingCompleted: false}),
          ),
        ],
        child: const _TestApp(),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
  });
}

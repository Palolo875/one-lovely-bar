import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';
import 'package:weathernav/presentation/providers/weather_layers_provider.dart';

class FakeSettingsRepository implements SettingsRepository {
  FakeSettingsRepository([Map<String, Object?>? seed]) : _data = {...?seed};
  final Map<String, Object?> _data;

  @override
  T? get<T>(String key) {
    final v = _data[key];
    if (v is T) return v;
    return null;
  }

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
  Stream<void> watch(String key) {
    return const Stream<void>.empty();
  }
}

void main() {
  test('load() falls back to profile defaults with mapping and maxEnabled', () {
    final settings = FakeSettingsRepository();
    const profile = UserProfile(
      id: 'p1',
      name: 'P1',
      type: ProfileType.universal,
      defaultLayers: ['precipitation', 'temp', 'wind', 'unknown'],
    );

    final enabled = WeatherLayersNotifier.load(settings, profile);
    expect(enabled.length, WeatherLayersNotifier.maxEnabled);
    expect(enabled, contains(WeatherLayer.radar));
    expect(enabled, contains(WeatherLayer.temperature));
    expect(enabled, contains(WeatherLayer.wind));
  });

  test('toggle() updates enabled set and respects maxEnabled', () {
    final settings = FakeSettingsRepository();
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        profileProvider.overrideWithValue(
          const UserProfile(
            id: 'p',
            name: 'P',
            type: ProfileType.universal,
            defaultLayers: ['precipitation'],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    container.read(weatherLayersProvider);
    final notifier = container.read(weatherLayersProvider.notifier);

    notifier.toggle(WeatherLayer.wind);
    notifier.toggle(WeatherLayer.temperature);
    expect(container.read(weatherLayersProvider).enabled.length, 3);

    notifier.toggle(WeatherLayer.radar);
    expect(
      container.read(weatherLayersProvider).enabled,
      isNot(contains(WeatherLayer.radar)),
    );

    notifier.toggle(WeatherLayer.radar);
    expect(
      container.read(weatherLayersProvider).enabled,
      contains(WeatherLayer.radar),
    );

    notifier.toggle(WeatherLayer.radar);
    expect(
      container.read(weatherLayersProvider).enabled,
      isNot(contains(WeatherLayer.radar)),
    );

    notifier.toggle(WeatherLayer.radar);
    expect(
      container.read(weatherLayersProvider).enabled,
      contains(WeatherLayer.radar),
    );
  });

  test('resetToProfile() uses mapping and enforces maxEnabled', () {
    final settings = FakeSettingsRepository({
      SettingsKeys.enabledWeatherLayers: ['radar', 'wind', 'temperature'],
    });
    final container = ProviderContainer(
      overrides: [
        settingsRepositoryProvider.overrideWithValue(settings),
        profileProvider.overrideWithValue(
          const UserProfile(
            id: 'p',
            name: 'P',
            type: ProfileType.universal,
            defaultLayers: ['precipitation'],
          ),
        ),
      ],
    );
    addTearDown(container.dispose);
    container.read(weatherLayersProvider);
    final notifier = container.read(weatherLayersProvider.notifier);

    notifier.resetToProfile(
      const UserProfile(
        id: 'p2',
        name: 'P2',
        type: ProfileType.universal,
        defaultLayers: ['temp', 'wind', 'precipitation', 'temp'],
      ),
    );

    final enabled = container.read(weatherLayersProvider).enabled;
    expect(enabled.length, WeatherLayersNotifier.maxEnabled);
    expect(enabled, contains(WeatherLayer.temperature));
    expect(enabled, contains(WeatherLayer.wind));
    expect(enabled, contains(WeatherLayer.radar));
  });

  test(
    'applyProfileDefaultsIfUnset() only applies when selection is not explicit',
    () {
      final settings = FakeSettingsRepository();
      final container = ProviderContainer(
        overrides: [
          settingsRepositoryProvider.overrideWithValue(settings),
          profileProvider.overrideWithValue(
            const UserProfile(
              id: 'p',
              name: 'P',
              type: ProfileType.universal,
              defaultLayers: ['precipitation'],
            ),
          ),
        ],
      );
      addTearDown(container.dispose);
      container.read(weatherLayersProvider);
      final notifier = container.read(weatherLayersProvider.notifier);

      notifier.applyProfileDefaultsIfUnset(
        const UserProfile(
          id: 'p3',
          name: 'P3',
          type: ProfileType.universal,
          defaultLayers: ['wind'],
        ),
      );
      expect(container.read(weatherLayersProvider).enabled, {
        WeatherLayer.wind,
      });

      notifier.toggle(WeatherLayer.temperature);
      notifier.applyProfileDefaultsIfUnset(
        const UserProfile(
          id: 'p4',
          name: 'P4',
          type: ProfileType.universal,
          defaultLayers: ['precipitation'],
        ),
      );

      final enabled = container.read(weatherLayersProvider).enabled;
      expect(enabled, contains(WeatherLayer.wind));
      expect(enabled, contains(WeatherLayer.temperature));
    },
  );
}

import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/settings_provider.dart';
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

  test('toggle() updates enabled set and respects maxEnabled', () async {
    final settings = FakeSettingsRepository();
    final notifier = WeatherLayersNotifier(settings, {WeatherLayer.radar}, hasExplicitSelection: false);

    notifier.toggle(WeatherLayer.wind);
    notifier.toggle(WeatherLayer.temperature);
    expect(notifier.state.enabled.length, 3);

    notifier.toggle(WeatherLayer.radar);
    expect(notifier.state.enabled, isNot(contains(WeatherLayer.radar)));

    notifier.toggle(WeatherLayer.radar);
    expect(notifier.state.enabled, contains(WeatherLayer.radar));

    notifier.toggle(WeatherLayer.radar);
    expect(notifier.state.enabled, isNot(contains(WeatherLayer.radar)));

    notifier.toggle(WeatherLayer.radar);
    expect(notifier.state.enabled, contains(WeatherLayer.radar));
  });

  test('resetToProfile() uses mapping and enforces maxEnabled', () {
    final settings = FakeSettingsRepository({
      SettingsKeys.enabledWeatherLayers: ['radar', 'wind', 'temperature'],
    });
    final notifier = WeatherLayersNotifier(settings, {WeatherLayer.radar}, hasExplicitSelection: true);

    notifier.resetToProfile(
      const UserProfile(
        id: 'p2',
        name: 'P2',
        type: ProfileType.universal,
        defaultLayers: ['temp', 'wind', 'precipitation', 'temp'],
      ),
    );

    expect(notifier.state.enabled.length, WeatherLayersNotifier.maxEnabled);
    expect(notifier.state.enabled, contains(WeatherLayer.temperature));
    expect(notifier.state.enabled, contains(WeatherLayer.wind));
    expect(notifier.state.enabled, contains(WeatherLayer.radar));
  });

  test('applyProfileDefaultsIfUnset() only applies when selection is not explicit', () {
    final settings = FakeSettingsRepository();
    final notifier = WeatherLayersNotifier(settings, {WeatherLayer.radar}, hasExplicitSelection: false);

    notifier.applyProfileDefaultsIfUnset(
      const UserProfile(
        id: 'p3',
        name: 'P3',
        type: ProfileType.universal,
        defaultLayers: ['wind'],
      ),
    );
    expect(notifier.state.enabled, {WeatherLayer.wind});

    notifier.toggle(WeatherLayer.temperature);
    notifier.applyProfileDefaultsIfUnset(
      const UserProfile(
        id: 'p4',
        name: 'P4',
        type: ProfileType.universal,
        defaultLayers: ['precipitation'],
      ),
    );

    expect(notifier.state.enabled, contains(WeatherLayer.wind));
    expect(notifier.state.enabled, contains(WeatherLayer.temperature));
  });
}

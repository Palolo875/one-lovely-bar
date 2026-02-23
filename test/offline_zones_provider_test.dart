import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/presentation/providers/offline_zones_provider.dart';
import 'package:weathernav/presentation/providers/offline_zones_repository_provider.dart';

class _InMemorySettingsRepository implements SettingsRepository {
  final Map<String, Object?> _data = {};
  final Map<String, StreamController<void>> _controllers = {};

  StreamController<void> _controllerFor(String key) {
    return _controllers.putIfAbsent(key, StreamController<void>.broadcast);
  }

  void _emit(String key) {
    if (_controllers.containsKey(key) && !_controllers[key]!.isClosed) {
      _controllers[key]!.add(null);
    }
  }

  @override
  T? get<T>(String key) {
    final v = _data[key];
    if (v is T) return v;
    return null;
  }

  @override
  T getOrDefault<T>(String key, T defaultValue) {
    final v = _data.containsKey(key) ? _data[key] : defaultValue;
    if (v is T) return v;
    return defaultValue;
  }

  @override
  Future<void> put(String key, Object? value) async {
    _data[key] = value;
    _emit(key);
  }

  @override
  Future<void> delete(String key) async {
    _data.remove(key);
    _emit(key);
  }

  @override
  Stream<void> watch(String key) => _controllerFor(key).stream;

  Future<void> dispose() async {
    for (final c in _controllers.values) {
      await c.close();
    }
  }
}

class _InMemoryOfflineZonesRepository implements OfflineZonesRepository {
  _InMemoryOfflineZonesRepository(this._settings);

  static const String _key = 'offline_zones';
  final _InMemorySettingsRepository _settings;

  @override
  List<OfflineZone> read() {
    final raw = _settings.get<Object?>(_key);
    if (raw is! List) return const <OfflineZone>[];
    final out = <OfflineZone>[];
    for (final item in raw) {
      if (item is! Map) continue;
      final m = Map<String, Object?>.from(item as Map);
      final id = m['id']?.toString();
      final name = m['name']?.toString();
      final lat = m['lat'];
      final lng = m['lng'];
      final radius = m['radiusKm'];
      final createdMs = m['createdAtMs'];
      if (id == null || name == null || lat is! num || lng is! num || radius is! num || createdMs is! num) continue;
      out.add(
        OfflineZone(
          id: id,
          name: name,
          lat: lat.toDouble(),
          lng: lng.toDouble(),
          radiusKm: radius.toDouble(),
          createdAt: DateTime.fromMillisecondsSinceEpoch(createdMs.toInt()),
        ),
      );
    }
    return out;
  }

  @override
  Stream<List<OfflineZone>> watch() {
    return _settings.watch(_key).map((_) => read());
  }

  @override
  Future<void> save(List<OfflineZone> zones) {
    final payload = zones
        .map(
          (z) => {
            'id': z.id,
            'name': z.name,
            'lat': z.lat,
            'lng': z.lng,
            'radiusKm': z.radiusKm,
            'createdAtMs': z.createdAt.millisecondsSinceEpoch,
          },
        )
        .toList();
    return _settings.put(_key, payload);
  }
}

void main() {
  test('add returns true and persists map payload', () async {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    final offlineRepo = _InMemoryOfflineZonesRepository(repo);

    final container = ProviderContainer(
      overrides: [
        offlineZonesRepositoryProvider.overrideWithValue(offlineRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(offlineZonesProvider.notifier);

    final ok = notifier.add(
      name: 'Paris',
      lat: 48.8566,
      lng: 2.3522,
      radiusKm: 25,
    );

    expect(ok, isTrue);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    final zones = container.read(offlineZonesProvider);
    expect(zones.length, 1);
    expect(zones.first.name, 'Paris');
  });

  test('add returns false on invalid values and does not modify state', () {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    final offlineRepo = _InMemoryOfflineZonesRepository(repo);

    final container = ProviderContainer(
      overrides: [
        offlineZonesRepositoryProvider.overrideWithValue(offlineRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(offlineZonesProvider.notifier);

    expect(
      notifier.add(name: ' ', lat: 0, lng: 0, radiusKm: 1),
      isFalse,
    );
    expect(
      notifier.add(name: 'Ok', lat: 91, lng: 0, radiusKm: 1),
      isFalse,
    );
    expect(
      notifier.add(name: 'Ok', lat: 0, lng: 181, radiusKm: 1),
      isFalse,
    );
    expect(
      notifier.add(name: 'Ok', lat: 0, lng: 0, radiusKm: 0),
      isFalse,
    );

    expect(container.read(offlineZonesProvider), isEmpty);
  });

  test('remove updates state and persists', () async {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    final offlineRepo = _InMemoryOfflineZonesRepository(repo);

    final container = ProviderContainer(
      overrides: [
        offlineZonesRepositoryProvider.overrideWithValue(offlineRepo),
      ],
    );
    addTearDown(container.dispose);

    final notifier = container.read(offlineZonesProvider.notifier);

    expect(
      notifier.add(name: 'A', lat: 0, lng: 0, radiusKm: 1),
      isTrue,
    );

    final id = container.read(offlineZonesProvider).single.id;
    notifier.remove(id);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(container.read(offlineZonesProvider), isEmpty);
    expect(repo.get<Object?>('offline_zones'), isA<List>());
    expect((repo.get<Object?>('offline_zones') as List).length, 0);
  });

  test('syncs from repository watch events', () async {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    final offlineRepo = _InMemoryOfflineZonesRepository(repo);

    final container = ProviderContainer(
      overrides: [
        offlineZonesRepositoryProvider.overrideWithValue(offlineRepo),
      ],
    );
    addTearDown(container.dispose);

    container.read(offlineZonesProvider);

    await repo.put('offline_zones', [
      {
        'id': 'z1',
        'name': 'Injected',
        'lat': 1,
        'lng': 2,
        'radiusKm': 3,
        'createdAtMs': DateTime(2020).millisecondsSinceEpoch,
      },
    ]);

    await Future<void>.delayed(const Duration(milliseconds: 1));

    final zones = container.read(offlineZonesProvider);
    expect(zones.length, 1);
    expect(zones.single.id, 'z1');
  });
}

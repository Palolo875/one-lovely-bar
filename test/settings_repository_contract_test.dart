import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';

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

void main() {
  test('getOrDefault returns default when missing or wrong type', () async {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    expect(repo.getOrDefault<String>('k', 'd'), 'd');
    await repo.put('k', 123);
    expect(repo.getOrDefault<String>('k', 'd'), 'd');
  });

  test('get returns null when missing or wrong type', () async {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    expect(repo.get<String>('k'), isNull);
    await repo.put('k', 123);
    expect(repo.get<String>('k'), isNull);
  });

  test('watch emits on put and delete', () async {
    final repo = _InMemorySettingsRepository();
    addTearDown(repo.dispose);

    final events = <int>[];
    final sub = repo.watch('k').listen((_) => events.add(events.length));
    addTearDown(sub.cancel);

    await repo.put('k', 'v');
    await repo.delete('k');

    await Future<void>.delayed(const Duration(milliseconds: 1));

    expect(events.length, 2);
  });
}

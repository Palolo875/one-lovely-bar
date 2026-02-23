import 'package:hive_ce/hive.dart';

import 'package:weathernav/domain/repositories/cache_repository.dart';

class HiveCacheRepository implements CacheRepository {
  static const String boxName = 'cache';

  Box get _box {
    if (!Hive.isBoxOpen(boxName)) {
      throw StateError('Hive box "$boxName" is not open. Call Hive.openBox("$boxName") at startup.');
    }
    return Hive.box(boxName);
  }

  @override
  T? get<T>(String key) {
    final v = _box.get(key);
    if (v is T) return v;
    return null;
  }

  @override
  Future<void> put(String key, Object? value) => _box.put(key, value);

  @override
  Future<void> delete(String key) => _box.delete(key);

  @override
  Iterable<String> keys() {
    return _box.keys.map((k) => k.toString());
  }

  @override
  Stream<void> watch(String key) {
    return _box.watch(key: key).map((_) {});
  }
}

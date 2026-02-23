abstract class CacheRepository {
  T? get<T>(String key);

  Future<void> put(String key, Object? value);

  Future<void> delete(String key);

  Iterable<String> keys();

  Stream<void> watch(String key);
}

abstract class SettingsRepository {
  T? get<T>(String key);

  T getOrDefault<T>(String key, T defaultValue);

  Future<void> put(String key, Object? value);

  Future<void> delete(String key);

  Stream<void> watch(String key);
}

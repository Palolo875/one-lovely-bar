import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:weathernav/data/repositories/weather_repository_impl.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/repositories/cache_repository.dart';

import 'utils/dio_test_adapter.dart';

class _MemoryCacheRepository implements CacheRepository {
  final Map<String, Object?> _store = {};

  @override
  T? get<T>(String key) {
    final v = _store[key];
    if (v is T) return v;
    return null;
  }

  @override
  Future<void> put(String key, Object? value) async {
    _store[key] = value;
  }

  @override
  Future<void> delete(String key) async {
    _store.remove(key);
  }

  @override
  Iterable<String> keys() => _store.keys;

  @override
  Stream<void> watch(String key) => const Stream<void>.empty();
}

void main() {
  test('OpenMeteoRepository getBatchWeather parses multi-location list payload', () async {
    final dio = Dio();
    dio.httpClientAdapter = TestDioAdapter(
      handler: (options) {
        final body = [
          {
            'hourly': {
              'time': ['2026-01-01T00:00'],
              'temperature_2m': [10],
              'precipitation': [0],
              'windspeed_10m': [5],
              'weathercode': [1],
            }
          },
          {
            'hourly': {
              'time': ['2026-01-01T00:00'],
              'temperature_2m': [12],
              'precipitation': [1],
              'windspeed_10m': [6],
              'weathercode': [2],
            }
          },
        ];
        return TestDioAdapter.jsonBody(body);
      },
    );

    final repo = OpenMeteoRepository(dio, _MemoryCacheRepository());

    final result = await repo.getBatchWeather([
      const RoutePoint(latitude: 48, longitude: 2),
      const RoutePoint(latitude: 48.1, longitude: 2.1),
    ]);

    expect(result.length, 2);
    expect(result[0].temperature, 10);
    expect(result[1].temperature, 12);
  });

  test('OpenMeteoRepository getBatchWeather falls back to per-point requests if payload is not parseable', () async {
    var callCount = 0;
    final dio = Dio();
    dio.httpClientAdapter = TestDioAdapter(
      handler: (options) {
        callCount++;
        if (callCount == 1) {
          return TestDioAdapter.jsonBody({'unexpected': true});
        }

        final lat = (options.queryParameters['latitude'] as num).toDouble();
        final body = {
          'current_weather': {
            'temperature': lat == 48.0 ? 10 : 12,
            'windspeed': 5,
            'winddirection': 0,
            'weathercode': 1,
            'time': '2026-01-01T00:00',
          }
        };
        return TestDioAdapter.jsonBody(body);
      },
    );

    final repo = OpenMeteoRepository(dio, _MemoryCacheRepository());

    final result = await repo.getBatchWeather([
      const RoutePoint(latitude: 48, longitude: 2),
      const RoutePoint(latitude: 48.1, longitude: 2.1),
    ]);

    expect(result.length, 2);
    expect(result[0].temperature, 10);
    expect(result[1].temperature, 12);
    expect(callCount, 3);
  });
}

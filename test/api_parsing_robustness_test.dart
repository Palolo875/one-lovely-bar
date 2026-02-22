import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'dart:io';
import 'package:hive_ce/hive.dart';
import 'package:weathernav/data/repositories/geocoding_repository_impl.dart';
import 'package:weathernav/data/repositories/poi_repository_impl.dart';
import 'package:weathernav/data/repositories/rainviewer_repository_impl.dart';
import 'package:weathernav/data/repositories/routing_repository_impl.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/poi.dart';

import 'utils/dio_test_adapter.dart';

void main() {
  setUpAll(() async {
    final dir = await Directory.systemTemp.createTemp('weathernav_test_hive_');
    Hive.init(dir.path);
    await Hive.openBox('settings');
  });

  tearDownAll(() async {
    await Hive.close();
  });

  test('PhotonGeocodingRepository returns empty list on invalid payload', () async {
    final dio = Dio();
    dio.httpClientAdapter = TestDioAdapter(
      handler: (options) {
        return TestDioAdapter.jsonBody('not-a-map');
      },
    );

    final repo = PhotonGeocodingRepository(dio);
    final result = await repo.search('paris');
    expect(result, isEmpty);
  });

  test('OverpassPoiRepository returns empty list on invalid payload', () async {
    final dio = Dio();
    dio.httpClientAdapter = TestDioAdapter(
      handler: (options) {
        return TestDioAdapter.jsonBody({'no_elements': true});
      },
    );

    final repo = OverpassPoiRepository(dio);
    final result = await repo.searchAround(
      lat: 48,
      lng: 2,
      radiusMeters: 1000,
      categories: {PoiCategory.shelter},
    );
    expect(result, isEmpty);
  });

  test('RainViewerRepositoryImpl returns null on invalid payload', () async {
    final dio = Dio();
    dio.httpClientAdapter = TestDioAdapter(
      handler: (options) {
        return TestDioAdapter.jsonBody({'radar': 'invalid'});
      },
    );

    final repo = RainViewerRepositoryImpl(dio);
    final t = await repo.getLatestRadarTime();
    expect(t, isNull);
  });

  test('ValhallaRoutingRepository throws AppFailure on invalid payload', () async {
    final dio = Dio();
    dio.httpClientAdapter = TestDioAdapter(
      handler: (options) {
        return TestDioAdapter.jsonBody('not-a-map');
      },
    );

    final repo = ValhallaRoutingRepository(dio);

    expect(
      () => repo.getRoute(
        startLat: 48,
        startLng: 2,
        endLat: 48.1,
        endLng: 2.1,
        profile: 'driver',
      ),
      throwsA(
        isA<AppFailure>().having((e) => e.message, 'message', contains('Réponse itinéraire invalide')),
      ),
    );
  });
}

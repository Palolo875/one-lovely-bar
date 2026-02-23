import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:riverpod/riverpod.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/network/dio_factory.dart';
import 'package:weathernav/data/repositories/geocoding_repository_impl.dart';
import 'package:weathernav/data/repositories/routing_repository_impl.dart';
import 'package:weathernav/data/repositories/weather_repository_impl.dart';
import 'package:weathernav/domain/repositories/geocoding_repository.dart';
import 'package:weathernav/domain/repositories/routing_repository.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';
import 'package:weathernav/presentation/providers/cache_repository_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

part 'repository_providers.g.dart';

@riverpod
Dio dio(Ref ref) {
  return createAppDio(enableLogging: !AppConfig.isProd);
}

@riverpod
WeatherRepository weatherRepository(Ref ref) {
  return OpenMeteoRepository(
    ref.watch(dioProvider),
    ref.watch(cacheRepositoryProvider),
    legacy: ref.watch(settingsRepositoryProvider),
  );
}

@riverpod
RoutingRepository routingRepository(Ref ref) {
  return ValhallaRoutingRepository(ref.watch(dioProvider));
}

@riverpod
GeocodingRepository geocodingRepository(Ref ref) {
  return PhotonGeocodingRepository(ref.watch(dioProvider));
}

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weathernav/core/network/dio_factory.dart';
import 'package:weathernav/data/repositories/geocoding_repository_impl.dart';
import 'package:weathernav/data/repositories/weather_repository_impl.dart';
import 'package:weathernav/data/repositories/routing_repository_impl.dart';
import 'package:weathernav/domain/repositories/geocoding_repository.dart';
import 'package:weathernav/domain/repositories/weather_repository.dart';
import 'package:weathernav/domain/repositories/routing_repository.dart';

part 'repository_providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return createAppDio();
}

@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  return OpenMeteoRepository(ref.watch(dioProvider));
}

@riverpod
RoutingRepository routingRepository(RoutingRepositoryRef ref) {
  return ValhallaRoutingRepository(ref.watch(dioProvider));
}

final geocodingRepositoryProvider = Provider.autoDispose<GeocodingRepository>((ref) {
  return PhotonGeocodingRepository(ref.watch(dioProvider));
});

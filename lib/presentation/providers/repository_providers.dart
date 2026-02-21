import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/geocoding_repository_impl.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/repositories/routing_repository_impl.dart';
import '../../domain/repositories/geocoding_repository.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/routing_repository.dart';

part 'repository_providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'accept': 'application/json',
      },
    ),
  );
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

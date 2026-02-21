import 'package:dio/dio.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/repositories/weather_repository_impl.dart';
import '../../data/repositories/routing_repository_impl.dart';
import '../../domain/repositories/weather_repository.dart';
import '../../domain/repositories/routing_repository.dart';

part 'repository_providers.g.dart';

@riverpod
Dio dio(DioRef ref) {
  return Dio();
}

@riverpod
WeatherRepository weatherRepository(WeatherRepositoryRef ref) {
  return OpenMeteoRepository(ref.watch(dioProvider));
}

@riverpod
RoutingRepository routingRepository(RoutingRepositoryRef ref) {
  return ValhallaRoutingRepository(ref.watch(dioProvider));
}

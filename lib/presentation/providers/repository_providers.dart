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
  final dio = Dio(
    BaseOptions(
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 15),
      sendTimeout: const Duration(seconds: 10),
      headers: {
        'accept': 'application/json',
      },
    ),
  );

  dio.interceptors.add(
    LogInterceptor(
      requestBody: false,
      responseBody: false,
      requestHeader: false,
      responseHeader: false,
    ),
  );

  dio.interceptors.add(_RetryInterceptor(dio));
  return dio;
}

class _RetryInterceptor extends Interceptor {
  final Dio _dio;
  _RetryInterceptor(this._dio);

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;

    final isGet = req.method.toUpperCase() == 'GET';
    final alreadyRetried = (req.extra['retried'] == true);
    final isNetwork = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (isGet && isNetwork && !alreadyRetried) {
      try {
        req.extra['retried'] = true;
        await Future.delayed(const Duration(milliseconds: 350));
        final response = await _dio.fetch(req);
        return handler.resolve(response);
      } catch (_) {
        // fall through
      }
    }

    return handler.next(err);
  }
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

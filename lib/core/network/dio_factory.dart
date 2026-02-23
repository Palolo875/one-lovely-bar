import 'package:dio/dio.dart';

import 'package:weathernav/core/logging/app_logger.dart';

Dio createAppDio({bool enableLogging = false}) {
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

  if (enableLogging) {
    dio.interceptors.add(
      LogInterceptor(
        requestHeader: false,
        responseHeader: false,
      ),
    );
  }

  dio.interceptors.add(_RetryInterceptor(dio));
  return dio;
}

class _RetryInterceptor extends Interceptor {
  _RetryInterceptor(this._dio);
  final Dio _dio;

  static const int _maxRetries = 1;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final req = err.requestOptions;

    final method = req.method.toUpperCase();
    final isIdempotent = method == 'GET' || method == 'HEAD';
    final retryCount = (req.extra['retryCount'] is int) ? (req.extra['retryCount'] as int) : 0;
    final isNetwork = err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout ||
        err.type == DioExceptionType.receiveTimeout;

    if (isIdempotent && isNetwork && retryCount < _maxRetries) {
      try {
        req.extra['retryCount'] = retryCount + 1;
        await Future.delayed(Duration(milliseconds: 250 * (retryCount + 1)));
        final response = await _dio.fetch(req);
        return handler.resolve(response);
      } catch (e, st) {
        AppLogger.warn(
          'Network retry failed',
          name: 'network',
          error: e,
          stackTrace: st,
        );
      }
    }

    return handler.next(err);
  }
}

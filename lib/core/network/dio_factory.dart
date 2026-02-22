import 'package:dio/dio.dart';

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
        responseBody: false,
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
      } catch (_) {}
    }

    return handler.next(err);
  }
}

import 'dart:async';
import 'dart:convert';

import 'package:dio/dio.dart';

class TestDioAdapter implements HttpClientAdapter {

  TestDioAdapter({required this.handler});
  final FutureOr<ResponseBody> Function(RequestOptions options) handler;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<List<int>>? requestStream,
    Future? cancelFuture,
  ) async {
    return await handler(options);
  }

  static ResponseBody jsonBody(Object? data, {int statusCode = 200, Map<String, List<String>>? headers}) {
    final encoded = utf8.encode(jsonEncode(data));
    return ResponseBody.fromBytes(
      encoded,
      statusCode,
      headers: headers ?? {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  static ResponseBody textBody(String data, {int statusCode = 200, Map<String, List<String>>? headers}) {
    final encoded = utf8.encode(data);
    return ResponseBody.fromBytes(
      encoded,
      statusCode,
      headers: headers ?? {
        Headers.contentTypeHeader: [Headers.textPlainContentType],
      },
    );
  }
}

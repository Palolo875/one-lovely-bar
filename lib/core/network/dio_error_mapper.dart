import 'package:dio/dio.dart';

String mapDioExceptionToMessage(
  DioException e, {
  required String defaultMessage,
}) {
  final code = e.response?.statusCode;

  if (code == 429) {
    return 'Trop de requêtes. Réessaie dans quelques instants.';
  }

  if (code != null && code >= 500) {
    return 'Service temporairement indisponible. Réessaie plus tard.';
  }

  switch (e.type) {
    case DioExceptionType.connectionError:
      return 'Connexion impossible. Vérifie Internet.';
    case DioExceptionType.connectionTimeout:
    case DioExceptionType.receiveTimeout:
    case DioExceptionType.sendTimeout:
      return 'Connexion trop lente. Réessaie.';
    case DioExceptionType.badCertificate:
      return 'Connexion sécurisée impossible.';
    case DioExceptionType.cancel:
      return defaultMessage;
    case DioExceptionType.badResponse:
    case DioExceptionType.unknown:
      return defaultMessage;
  }
}

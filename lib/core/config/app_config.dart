import 'package:flutter/foundation.dart';

enum Environment {
  dev,
  staging,
  prod,
}

class AppConfig {
  static const String _envString = String.fromEnvironment('ENV', defaultValue: 'dev');

  static Environment get currentEnvironment {
    switch (_envString) {
      case 'prod':
        return Environment.prod;
      case 'staging':
        return Environment.staging;
      case 'dev':
      default:
        return Environment.dev;
    }
  }

  static bool get isProd => currentEnvironment == Environment.prod;
  
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN', defaultValue: '');

  static const String openMeteoBaseUrl = String.fromEnvironment(
    'OPEN_METEO_BASE_URL',
    defaultValue: 'https://api.open-meteo.com/v1',
  );

  static const String valhallaBaseUrl = String.fromEnvironment(
    'VALHALLA_BASE_URL',
    defaultValue: 'https://valhalla.openstreetmap.de',
  );
}

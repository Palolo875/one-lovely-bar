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
  
  static const String sentryDsn = String.fromEnvironment('SENTRY_DSN');

  static const String openMeteoBaseUrl = String.fromEnvironment(
    'OPEN_METEO_BASE_URL',
    defaultValue: 'https://api.open-meteo.com/v1',
  );

  static const String valhallaBaseUrl = String.fromEnvironment(
    'VALHALLA_BASE_URL',
    defaultValue: 'https://valhalla.openstreetmap.de',
  );

  static const String photonBaseUrl = String.fromEnvironment(
    'PHOTON_BASE_URL',
    defaultValue: 'https://photon.komoot.io',
  );

  static const String overpassBaseUrl = String.fromEnvironment(
    'OVERPASS_BASE_URL',
    defaultValue: 'https://overpass-api.de',
  );

  static const String rainviewerApiBaseUrl = String.fromEnvironment(
    'RAINVIEWER_API_BASE_URL',
    defaultValue: 'https://api.rainviewer.com',
  );

  static const String rainviewerTileBaseUrl = String.fromEnvironment(
    'RAINVIEWER_TILE_BASE_URL',
    defaultValue: 'https://tilecache.rainviewer.com',
  );

  static const String openFreeMapStyleUrl = String.fromEnvironment(
    'OPENFREEMAP_STYLE_URL',
    defaultValue: 'https://tiles.openfreemap.org/styles/positron',
  );

  static const String cartoPositronStyleUrl = String.fromEnvironment(
    'CARTO_POSITRON_STYLE_URL',
    defaultValue: 'https://basemaps.cartocdn.com/gl/positron-gl-style/style.json',
  );

  static const String stamenTonerStyleUrl = String.fromEnvironment(
    'STAMEN_TONER_STYLE_URL',
    defaultValue: 'https://tiles.stadiamaps.com/styles/stamen_toner.json',
  );
}

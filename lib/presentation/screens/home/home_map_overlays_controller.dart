import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:weathernav/core/config/app_config.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/domain/models/weather_condition.dart';
import 'package:weathernav/presentation/providers/weather_layers_provider.dart';

class HomeMapOverlaysController {
  HomeMapOverlaysController();

  MapLibreMapController? _controller;

  final List<Symbol> _poiSymbols = [];
  final List<Symbol> _gridSymbols = [];
  Set<String> _poiIds = const {};

  static const radarSourceId = 'rainviewer_radar_source';
  static const radarLayerId = 'rainviewer_radar_layer';

  void attach(MapLibreMapController controller) {
    _controller = controller;
  }

  Future<void> dispose() async {
    final controller = _controller;
    if (controller == null) return;

    for (final s in _poiSymbols) {
      try {
        await controller.removeSymbol(s);
      } catch (e, st) {
        AppLogger.warn('Home: remove POI symbol failed', name: 'home', error: e, stackTrace: st);
      }
    }
    _poiSymbols.clear();

    for (final s in _gridSymbols) {
      try {
        await controller.removeSymbol(s);
      } catch (e, st) {
        AppLogger.warn('Home: remove grid symbol failed', name: 'home', error: e, stackTrace: st);
      }
    }
    _gridSymbols.clear();

    try {
      await controller.removeLayer(radarLayerId);
    } catch (e, st) {
      AppLogger.warn('Home: remove radar layer failed', name: 'home', error: e, stackTrace: st);
    }
    try {
      await controller.removeSource(radarSourceId);
    } catch (e, st) {
      AppLogger.warn('Home: remove radar source failed', name: 'home', error: e, stackTrace: st);
    }
  }

  Future<void> applyGridSymbols(List<GridPointWeather> grid, WeatherLayersState layers) async {
    final controller = _controller;
    if (controller == null) return;

    for (final s in _gridSymbols) {
      try {
        await controller.removeSymbol(s);
      } catch (e, st) {
        AppLogger.warn('Home: remove grid symbol failed', name: 'home', error: e, stackTrace: st);
      }
    }
    _gridSymbols.clear();

    final showWind = layers.enabled.contains(WeatherLayer.wind);
    final showTemp = layers.enabled.contains(WeatherLayer.temperature);
    if (!showWind && !showTemp) return;

    for (final g in grid) {
      final textParts = <String>[];
      if (showTemp) {
        textParts.add('${g.condition.temperature.round()}°');
      }
      if (showWind) {
        textParts.add('${g.condition.windSpeed.round()}');
      }

      final text = textParts.join(' ');
      final rotate = showWind ? g.condition.windDirection : 0.0;

      try {
        final sym = await controller.addSymbol(
          SymbolOptions(
            geometry: LatLng(g.latitude, g.longitude),
            iconImage: showWind ? 'triangle-15' : 'marker-15',
            iconRotate: rotate,
            iconSize: 1,
            textField: text.isEmpty ? null : text,
            textSize: 11,
            textOffset: const Offset(0, 1.2),
          ),
        );
        _gridSymbols.add(sym);
      } catch (e, st) {
        AppLogger.warn('Home: add grid symbol failed', name: 'home', error: e, stackTrace: st);
      }
    }
  }

  Future<void> applyPois(List<Poi> pois) async {
    final controller = _controller;
    if (controller == null) return;

    final nextIds = pois.map((p) => p.id).toSet();
    if (nextIds.length == _poiIds.length && nextIds.difference(_poiIds).isEmpty) {
      return;
    }

    for (final s in _poiSymbols) {
      try {
        await controller.removeSymbol(s);
      } catch (e, st) {
        AppLogger.warn('Home: remove POI symbol failed', name: 'home', error: e, stackTrace: st);
      }
    }
    _poiSymbols.clear();

    for (final p in pois) {
      try {
        final sym = await controller.addSymbol(
          SymbolOptions(
            geometry: LatLng(p.latitude, p.longitude),
            iconImage: 'marker-15',
            iconSize: 1.2,
            textField: p.name,
            textSize: 11,
            textOffset: const Offset(0, 1.2),
          ),
        );
        _poiSymbols.add(sym);
      } catch (e, st) {
        AppLogger.warn('Home: add POI symbol failed', name: 'home', error: e, stackTrace: st);
      }
    }

    _poiIds = nextIds;
  }

  Future<void> applyRadarLayerIfNeeded(WeatherLayersState layers, int? radarTime) async {
    final controller = _controller;
    if (controller == null) return;

    final enabled = layers.enabled.contains(WeatherLayer.radar);
    if (!enabled || radarTime == null) {
      try {
        await controller.removeLayer(radarLayerId);
      } catch (e, st) {
        AppLogger.warn('Home: remove radar layer failed', name: 'home', error: e, stackTrace: st);
      }
      try {
        await controller.removeSource(radarSourceId);
      } catch (e, st) {
        AppLogger.warn('Home: remove radar source failed', name: 'home', error: e, stackTrace: st);
      }
      return;
    }

    final tilesUrl = '${AppConfig.rainviewerTileBaseUrl}/v2/radar/$radarTime/256/{z}/{x}/{y}/2/1_1.png';

    try {
      await controller.removeLayer(radarLayerId);
    } catch (e, st) {
      AppLogger.warn('Home: cleanup radar layer failed', name: 'home', error: e, stackTrace: st);
    }
    try {
      await controller.removeSource(radarSourceId);
    } catch (e, st) {
      AppLogger.warn('Home: cleanup radar source failed', name: 'home', error: e, stackTrace: st);
    }

    await controller.addSource(
      radarSourceId,
      RasterSourceProperties(
        tiles: [tilesUrl],
        tileSize: 256,
      ),
    );

    final opacity = layers.opacity[WeatherLayer.radar] ?? 0.65;
    await controller.addLayer(
      radarSourceId,
      radarLayerId,
      RasterLayerProperties(
        rasterOpacity: opacity,
      ),
    );
  }
}

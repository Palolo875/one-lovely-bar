import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import '../../domain/models/weather_condition.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/poi.dart';
import '../../domain/failures/app_failure.dart';
import '../providers/profile_provider.dart';
import '../providers/current_weather_provider.dart';
import '../providers/forecast_provider.dart';
import '../providers/rainviewer_provider.dart';
import '../providers/weather_layers_provider.dart';
import '../providers/poi_provider.dart';
import '../providers/weather_grid_provider.dart';
import '../providers/map_style_provider.dart';
import '../providers/settings_repository_provider.dart';
import '../widgets/profile_switcher.dart';
import '../widgets/weather_timeline.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapLibreMapController? mapController;
  final List<Symbol> _poiSymbols = [];
  final List<Symbol> _gridSymbols = [];
  Set<String> _poiIds = const {};
  LatLng _mapCenter = const LatLng(48.8566, 2.3522);
  LatLng _debouncedCenter = const LatLng(48.8566, 2.3522);
  Timer? _cameraDebounce;
  String? _poiRequestKey;
  String? _gridRequestKey;

  bool _centering = false;

  static const _radarSourceId = 'rainviewer_radar_source';
  static const _radarLayerId = 'rainviewer_radar_layer';

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.locationWhenInUse.request();
      }
    } catch (_) {}
  }

  Future<void> _centerOnUser() async {
    if (_centering) return;
    setState(() => _centering = true);
    try {
      await _ensureLocationPermission();

      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      final perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        await Geolocator.requestPermission();
      }

      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      final target = LatLng(pos.latitude, pos.longitude);

      // Best-effort camera movement (dynamic to avoid compilation issues across maplibre_gl versions)
      final controller = mapController;
      if (controller != null) {
        final dyn = controller as dynamic;
        try {
          await dyn.animateCamera(CameraUpdate.newLatLngZoom(target, 13.5));
        } catch (_) {
          try {
            await dyn.moveCamera(CameraUpdate.newLatLngZoom(target, 13.5));
          } catch (_) {}
        }
      }

      if (!mounted) return;
      setState(() {
        _mapCenter = target;
        _debouncedCenter = _roundCenter(target);
      });
    } catch (_) {
      // ignore
    }
    if (mounted) setState(() => _centering = false);
  }

  @override
  void dispose() {
    _cameraDebounce?.cancel();
    super.dispose();
  }

  LatLng _roundCenter(LatLng c) {
    double r(double v) => double.parse(v.toStringAsFixed(3));
    return LatLng(r(c.latitude), r(c.longitude));
  }

  void _onCameraIdle() {
    final controller = mapController;
    if (controller == null) return;
    final pos = controller.cameraPosition;
    if (pos == null) return;

    _mapCenter = pos.target;
    _cameraDebounce?.cancel();
    _cameraDebounce = Timer(const Duration(milliseconds: 600), () {
      if (!mounted) return;
      setState(() {
        _debouncedCenter = _roundCenter(_mapCenter);
      });
    });
  }

  Future<void> _applyGridSymbols(List<GridPointWeather> grid, WeatherLayersState layers) async {
    final controller = mapController;
    if (controller == null) return;

    for (final s in _gridSymbols) {
      try {
        await controller.removeSymbol(s);
      } catch (_) {}
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
            iconSize: 1.0,
            textField: text.isEmpty ? null : text,
            textSize: 11,
            textOffset: const Offset(0, 1.2),
          ),
        );
        _gridSymbols.add(sym);
      } catch (_) {}
    }
  }

  

  Future<void> _applyPois(List<Poi> pois) async {
    final controller = mapController;
    if (controller == null) return;

    final nextIds = pois.map((p) => p.id).toSet();
    if (nextIds.length == _poiIds.length && nextIds.difference(_poiIds).isEmpty) {
      return;
    }

    for (final s in _poiSymbols) {
      try {
        await controller.removeSymbol(s);
      } catch (_) {}
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
      } catch (_) {}
    }

    _poiIds = nextIds;
  }

  Future<void> _applyRadarLayerIfNeeded(WeatherLayersState layers, int? radarTime) async {
    final controller = mapController;
    if (controller == null) return;

    final enabled = layers.enabled.contains(WeatherLayer.radar);

    if (!enabled || radarTime == null) {
      try {
        await controller.removeLayer(_radarLayerId);
      } catch (_) {}
      try {
        await controller.removeSource(_radarSourceId);
      } catch (_) {}
      return;
    }

    final tilesUrl = 'https://tilecache.rainviewer.com/v2/radar/$radarTime/256/{z}/{x}/{y}/2/1_1.png';

    try {
      await controller.removeLayer(_radarLayerId);
    } catch (_) {}
    try {
      await controller.removeSource(_radarSourceId);
    } catch (_) {}

    await controller.addSource(
      _radarSourceId,
      RasterSourceProperties(
        tiles: [tilesUrl],
        tileSize: 256,
      ),
    );

    final opacity = layers.opacity[WeatherLayer.radar] ?? 0.65;

    await controller.addLayer(
      _radarSourceId,
      _radarLayerId,
      RasterLayerProperties(
        rasterOpacity: opacity,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(profileNotifierProvider);
    final center = _debouncedCenter;
    final currentWeatherAsync = ref.watch(
      currentWeatherProvider(LatLngRequest(lat: center.latitude, lng: center.longitude)),
    );
    final forecastAsync = ref.watch(
      forecastProvider(ForecastRequest(lat: center.latitude, lng: center.longitude, days: 7)),
    );

    final layers = ref.watch(weatherLayersProvider);
    final layersNotifier = ref.read(weatherLayersProvider.notifier);
    final radarTimeAsync = ref.watch(rainViewerLatestTimeProvider);
    final mapStyle = ref.watch(mapStyleProvider);

    final poiFilter = ref.watch(poiFilterProvider);

    final showGrid = layers.enabled.contains(WeatherLayer.wind) || layers.enabled.contains(WeatherLayer.temperature);
    final nextGridKey = '${center.latitude},${center.longitude}|${showGrid ? '1' : '0'}';
    final gridAsync = showGrid
        ? ref.watch(
            weatherGridProvider(
              WeatherGridRequest(
                centerLat: center.latitude,
                centerLng: center.longitude,
              ),
            ),
          )
        : const AsyncValue.data(<GridPointWeather>[]);

    gridAsync.whenData((grid) {
      if (_gridRequestKey != nextGridKey) {
        _gridRequestKey = nextGridKey;
        _applyGridSymbols(grid, layers);
      }
    });

    final nextPoiKey = '${center.latitude},${center.longitude}|${poiFilter.radiusMeters}|${poiFilter.categories.map((c) => c.name).join(',')}|${poiFilter.enabled ? '1' : '0'}';
    final poisAsync = poiFilter.enabled
        ? ref.watch(
            poiSearchProvider(
              PoiRequest(
                lat: center.latitude,
                lng: center.longitude,
                radiusMeters: poiFilter.radiusMeters,
                categories: poiFilter.categories,
              ),
            ),
          )
        : const AsyncValue.data(<Poi>[]);

    poisAsync.whenData((items) {
      if (_poiRequestKey != nextPoiKey) {
        _poiRequestKey = nextPoiKey;
        if (!poiFilter.enabled) {
          _applyPois(const <Poi>[]);
        } else {
          _applyPois(items);
        }
      }
    });

    // Apply radar layer when state changes (best-effort)
    radarTimeAsync.whenData((t) {
      _applyRadarLayerIfNeeded(layers, t);
    });

    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onCameraIdle: _onCameraIdle,
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.3522), // Paris
              zoom: 12.0,
            ),
            styleString: mapStyle.styleUrl,
            myLocationEnabled: true,
            trackCameraPosition: true,
          ),

          if (layers.enabled.contains(WeatherLayer.wind) || layers.enabled.contains(WeatherLayer.temperature))
            Positioned(
              left: 16,
              right: 16,
              top: 110,
              child: IgnorePointer(
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.92),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: Colors.grey[200]!),
                  ),
                  child: Text(
                    _buildOverlayStatusText(layers),
                    style: const TextStyle(color: Colors.black87),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            ),

          // Top Search Bar
          Positioned(
            top: 50,
            left: 16,
            right: 16,
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => context.go('/planning'),
                borderRadius: BorderRadius.circular(30),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(30),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      const Icon(LucideIcons.search, color: Colors.grey),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Text(
                          'Où allez-vous ?',
                          style: TextStyle(color: Colors.grey, fontSize: 16),
                        ),
                      ),
                      GestureDetector(
                        onTap: () => _showProfileSwitcher(context),
                        child: CircleAvatar(
                          backgroundColor: Colors.blue.withOpacity(0.1),
                          radius: 18,
                          child: Icon(
                            _getProfileIcon(activeProfile.type),
                            size: 18,
                            color: Colors.blue,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          // Active layer chips
          Positioned(
            top: 110,
            left: 16,
            right: 16,
            child: _ActiveLayerChips(
              layers: layers,
              onToggle: (l) => layersNotifier.toggle(l),
            ),
          ),

          // Floating Action Buttons (Right)
          Positioned(
            right: 16,
            bottom: 120,
            child: Column(
              children: [
                _buildFloatingButton(LucideIcons.layers, () => _showLayersSheet(context)),
                const SizedBox(height: 12),
                _buildFloatingButton(LucideIcons.mapPin, () => _showPoiSheet(context)),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  LucideIcons.crosshair,
                  _centerOnUser,
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomCenter,
            child: _PersistentWeatherSheet(
              currentWeather: currentWeatherAsync,
              forecast: forecastAsync,
              profile: activeProfile,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFloatingButton(IconData icon, VoidCallback onPressed) {
    return FloatingActionButton.small(
      onPressed: onPressed,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black87,
      child: Icon(icon),
    );
  }

  IconData _getProfileIcon(ProfileType type) {
    switch (type) {
      case ProfileType.cyclist: return LucideIcons.bike;
      case ProfileType.hiker: return LucideIcons.footprints;
      case ProfileType.driver: return LucideIcons.car;
      default: return LucideIcons.user;
    }
  }

  void _showProfileSwitcher(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ProfileSwitcher(),
    );
  }

  void _showWeatherDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.6,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (context, scrollController) => ListView(
          controller: scrollController,
          padding: const EdgeInsets.all(24),
          children: [
            const Text('Météo détaillée', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            const SizedBox(height: 16),
            WeatherTimeline(
              conditions: List.generate(10, (i) => WeatherCondition(
                temperature: 18.0 + i,
                precipitation: 0.0,
                windSpeed: 10.0 + i,
                windDirection: 0.0,
                weatherCode: i % 3 == 0 ? 0 : (i % 3 == 1 ? 2 : 61),
                timestamp: DateTime.now().add(Duration(minutes: i * 30)),
              )),
            ),
            const SizedBox(height: 24),
            const Text('Prévisions 7 jours', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),
            // Add more detailed info here
          ],
        ),
      ),
    );
  }

  void _showLayersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final layers = ref.watch(weatherLayersProvider);
            final notifier = ref.read(weatherLayersProvider.notifier);
            final profile = ref.watch(profileNotifierProvider);
            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Couches météo', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  Text(
                    'Max 3 couches actives pour garder la carte lisible.',
                    style: TextStyle(color: Colors.grey[700]),
                  ),
                  const SizedBox(height: 8),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => notifier.resetToProfile(profile),
                      child: const Text('Réinitialiser selon profil'),
                    ),
                  ),
                  SwitchListTile(
                    value: layers.enabled.contains(WeatherLayer.radar),
                    onChanged: (_) => notifier.toggle(WeatherLayer.radar),
                    title: const Text('Radar précipitations'),
                    subtitle: const Text('RainViewer'),
                  ),
                  if (layers.enabled.contains(WeatherLayer.radar))
                    Padding(
                      padding: const EdgeInsets.only(left: 16, right: 16, bottom: 8),
                      child: Row(
                        children: [
                          const Text('Opacité'),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Slider(
                              value: (layers.opacity[WeatherLayer.radar] ?? 0.65).clamp(0.0, 1.0),
                              min: 0.0,
                              max: 1.0,
                              divisions: 10,
                              label: '${(((layers.opacity[WeatherLayer.radar] ?? 0.65) * 100).round())}%',
                              onChanged: (v) => notifier.setOpacity(WeatherLayer.radar, v),
                            ),
                          ),
                        ],
                      ),
                    ),
                  SwitchListTile(
                    value: layers.enabled.contains(WeatherLayer.wind),
                    onChanged: (_) => notifier.toggle(WeatherLayer.wind),
                    title: const Text('Vent'),
                    subtitle: const Text('Overlay simple (P0)'),
                  ),
                  SwitchListTile(
                    value: layers.enabled.contains(WeatherLayer.temperature),
                    onChanged: (_) => notifier.toggle(WeatherLayer.temperature),
                    title: const Text('Température'),
                    subtitle: const Text('Overlay simple (P0)'),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _buildOverlayStatusText(WeatherLayersState layers) {
    final parts = <String>[];
    if (layers.enabled.contains(WeatherLayer.wind)) parts.add('Vent');
    if (layers.enabled.contains(WeatherLayer.temperature)) parts.add('Température');
    return 'Overlays actifs: ${parts.join(' + ')}';
  }

  void _showPoiSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: false,
      builder: (context) {
        return Consumer(
          builder: (context, ref, _) {
            final filter = ref.watch(poiFilterProvider);
            final notifier = ref.read(poiFilterProvider.notifier);

            return Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Points d’intérêt', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 12),
                  SwitchListTile(
                    value: filter.enabled,
                    onChanged: (_) => notifier.toggleEnabled(),
                    title: const Text('Afficher les POIs'),
                    subtitle: const Text('Source: OpenStreetMap (Overpass)'),
                  ),
                  if (filter.enabled) ...[
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: PoiCategory.values.map((c) {
                        final selected = filter.categories.contains(c);
                        return FilterChip(
                          selected: selected,
                          onSelected: (_) => notifier.toggleCategory(c),
                          label: Text(_poiLabel(c)),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Text('Rayon'),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Slider(
                            value: filter.radiusMeters.toDouble().clamp(500, 10000),
                            min: 500,
                            max: 10000,
                            divisions: 19,
                            label: '${filter.radiusMeters} m',
                            onChanged: (v) => notifier.setRadius(v.round()),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Centre: ${_debouncedCenter.latitude.toStringAsFixed(4)}, ${_debouncedCenter.longitude.toStringAsFixed(4)}',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  String _poiLabel(PoiCategory c) {
    switch (c) {
      case PoiCategory.shelter:
        return 'Abris';
      case PoiCategory.hut:
        return 'Refuges';
      case PoiCategory.weatherStation:
        return 'Stations météo';
      case PoiCategory.port:
        return 'Ports';
    }
  }
}

class _BottomWeatherIndicator extends StatelessWidget {
  final AsyncValue<WeatherCondition> weather;
  final DateTime? cachedAt;

  const _BottomWeatherIndicator({required this.weather, required this.cachedAt});

  @override
  Widget build(BuildContext context) {
    return weather.when(
      data: (w) {
        final icon = _iconForCode(w.weatherCode);
        final subtitle = '${w.temperature.round()}°C • Vent ${w.windSpeed.round()} km/h';
        final cacheText = cachedAt == null
            ? null
            : 'Données: ${cachedAt!.hour.toString().padLeft(2, '0')}:${cachedAt!.minute.toString().padLeft(2, '0')}';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                if (cacheText != null) Text(cacheText, style: const TextStyle(color: Colors.grey, fontSize: 12)),
              ],
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: Text(
                  subtitle,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.grey),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
            Icon(icon, color: Colors.orange, size: 32),
          ],
        );
      },
      loading: () => const Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
              Text('Chargement…', style: TextStyle(color: Colors.grey)),
            ],
          ),
          SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(strokeWidth: 2),
          ),
        ],
      ),
      error: (err, st) {
        final msg = err is AppFailure ? err.message : 'Météo indisponible';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                Text(msg, style: const TextStyle(color: Colors.grey)),
              ],
            ),
            const Icon(LucideIcons.alertTriangle, color: Colors.orange, size: 28),
          ],
        );
      },
    );
  }

  IconData _iconForCode(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code < 3) return LucideIcons.cloudSun;
    if (code < 50) return LucideIcons.cloud;
    if (code < 70) return LucideIcons.cloudRain;
    return LucideIcons.cloudLightning;
  }

  String _conditionLabel(int code) {
    if (code == 0) return 'Ciel clair';
    if (code < 3) return 'Peu nuageux';
    if (code < 50) return 'Nuageux';
    if (code < 70) return 'Pluie';
    return 'Orage';
  }
}

class _ActiveLayerChips extends StatelessWidget {
  final WeatherLayersState layers;
  final void Function(WeatherLayer layer) onToggle;

  const _ActiveLayerChips({required this.layers, required this.onToggle});

  String _label(WeatherLayer l) {
    switch (l) {
      case WeatherLayer.radar:
        return 'Rain';
      case WeatherLayer.wind:
        return 'Wind';
      case WeatherLayer.temperature:
        return 'Temp';
    }
  }

  IconData _icon(WeatherLayer l) {
    switch (l) {
      case WeatherLayer.radar:
        return LucideIcons.cloudRain;
      case WeatherLayer.wind:
        return LucideIcons.wind;
      case WeatherLayer.temperature:
        return LucideIcons.thermometer;
    }
  }

  @override
  Widget build(BuildContext context) {
    final enabled = layers.enabled.toList();
    if (enabled.isEmpty) return const SizedBox.shrink();

    return Align(
      alignment: Alignment.centerLeft,
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: [
            for (final l in enabled) ...[
              FilterChip(
                selected: true,
                onSelected: (_) => onToggle(l),
                avatar: Icon(_icon(l), size: 16),
                label: Text(_label(l)),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

class _WeatherMetricsRow extends StatelessWidget {
  final AsyncValue<WeatherCondition> currentWeather;
  final AsyncValue<List<WeatherCondition>> forecast;
  final Widget Function(BuildContext context, String label, String value) metricTile;

  const _WeatherMetricsRow({
    required this.currentWeather,
    required this.forecast,
    required this.metricTile,
  });

  WeatherCondition? _nearestForecast(List<WeatherCondition> list) {
    if (list.isEmpty) return null;
    final now = DateTime.now();
    WeatherCondition best = list.first;
    int bestDelta = (best.timestamp.difference(now).inMinutes).abs();
    for (final e in list) {
      final d = (e.timestamp.difference(now).inMinutes).abs();
      if (d < bestDelta) {
        best = e;
        bestDelta = d;
      }
    }
    return best;
  }

  @override
  Widget build(BuildContext context) {
    return currentWeather.when(
      data: (w) {
        return forecast.when(
          data: (list) {
            final near = _nearestForecast(list);
            final visibility = w.visibility ?? near?.visibility;
            final uv = w.uvIndex ?? near?.uvIndex;

            String visText;
            if (visibility == null) {
              visText = '—';
            } else if (visibility >= 10000) {
              visText = '${(visibility / 1000).toStringAsFixed(0)} km';
            } else {
              visText = '${visibility.toStringAsFixed(0)} m';
            }

            final uvText = uv == null ? '—' : uv.toStringAsFixed(0);

            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Temp.', '${w.temperature.round()}°')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'Vent', '${w.windSpeed.round()} km/h')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Visib.', visText)),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'UV', uvText)),
                  ],
                ),
              ],
            );
          },
          loading: () {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Temp.', '${w.temperature.round()}°')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'Vent', '${w.windSpeed.round()} km/h')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Visib.', '—')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'UV', '—')),
                  ],
                ),
              ],
            );
          },
          error: (_, __) {
            return Column(
              children: [
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Temp.', '${w.temperature.round()}°')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'Vent', '${w.windSpeed.round()} km/h')),
                  ],
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(child: metricTile(context, 'Visib.', '—')),
                    const SizedBox(width: 12),
                    Expanded(child: metricTile(context, 'UV', '—')),
                  ],
                ),
              ],
            );
          },
        );
      },
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

class _PersistentWeatherSheet extends StatelessWidget {
  final AsyncValue<WeatherCondition> currentWeather;
  final AsyncValue<List<WeatherCondition>> forecast;
  final UserProfile profile;

  const _PersistentWeatherSheet({
    required this.currentWeather,
    required this.forecast,
    required this.profile,
  });

  String _hhmm(DateTime dt) {
    final h = dt.hour.toString().padLeft(2, '0');
    final m = dt.minute.toString().padLeft(2, '0');
    return '$h:$m';
  }

  String _dmy(DateTime dt) {
    final d = dt.day.toString().padLeft(2, '0');
    final m = dt.month.toString().padLeft(2, '0');
    return '$d/$m';
  }

  IconData _iconForCode(int code) {
    if (code == 0) return LucideIcons.sun;
    if (code < 3) return LucideIcons.cloudSun;
    if (code < 50) return LucideIcons.cloud;
    if (code < 70) return LucideIcons.cloudRain;
    return LucideIcons.cloudLightning;
  }

  List<WeatherCondition> _nextHours(List<WeatherCondition> items, int hours) {
    final now = DateTime.now();
    final future = items.where((e) => e.timestamp.isAfter(now.subtract(const Duration(minutes: 1)))).toList();
    future.sort((a, b) => a.timestamp.compareTo(b.timestamp));
    if (future.length <= hours) return future;
    return future.take(hours).toList();
  }

  List<WeatherCondition> _dailySummary(List<WeatherCondition> items) {
    final byDay = <String, List<WeatherCondition>>{};
    for (final e in items) {
      final key = '${e.timestamp.year}-${e.timestamp.month}-${e.timestamp.day}';
      (byDay[key] ??= []).add(e);
    }

    final days = byDay.values.toList();
    days.sort((a, b) => a.first.timestamp.compareTo(b.first.timestamp));

    final out = <WeatherCondition>[];
    for (final day in days) {
      day.sort((a, b) => a.timestamp.compareTo(b.timestamp));
      final best = day.firstWhere(
        (e) => e.timestamp.hour == 12,
        orElse: () => day[day.length ~/ 2],
      );
      out.add(best);
      if (out.length >= 7) break;
    }
    return out;
  }

  Widget _metricTile(BuildContext context, String label, String value) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: Theme.of(context).textTheme.bodySmall),
          const SizedBox(height: 6),
          Text(value, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    DateTime? cachedAt;
    try {
      final settings = ref.read(settingsRepositoryProvider);
      final raw = settings.get<dynamic>('wx_current:48.857,2.352');
      if (raw is Map && raw['ts'] is int) {
        cachedAt = DateTime.fromMillisecondsSinceEpoch(raw['ts'] as int);
      }
    } catch (_) {}

    return DraggableScrollableSheet(
      initialChildSize: 0.14,
      minChildSize: 0.14,
      maxChildSize: 0.90,
      snap: true,
      snapSizes: const [0.14, 0.48, 0.90],
      builder: (context, scrollController) {
        return Material(
          elevation: 12,
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
          child: ListView(
            controller: scrollController,
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 24),
            children: [
              Center(
                child: Container(
                  width: 44,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              currentWeather.when(
                data: (w) {
                  final icon = _iconForCode(w.weatherCode);
                  return Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(icon, size: 32, color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${w.temperature.round()}°',
                              style: Theme.of(context).textTheme.displayLarge?.copyWith(
                                    fontSize: 72,
                                    height: 0.9,
                                    fontWeight: FontWeight.w800,
                                  ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _conditionLabel(w.weatherCode),
                              style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Vent ${w.windSpeed.round()} km/h',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                      Text(
                        _hhmm(w.timestamp),
                        style: Theme.of(context).textTheme.bodySmall,
                      ),
                      if (cachedAt != null)
                        Padding(
                          padding: const EdgeInsets.only(left: 10, top: 2),
                          child: Text(
                            'Cache: ${_hhmm(cachedAt!)}',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey),
                          ),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox(
                  height: 28,
                  child: Center(child: LinearProgressIndicator(minHeight: 2)),
                ),
                error: (err, st) {
                  final msg = err is AppFailure ? err.message : 'Météo indisponible';
                  return Row(
                    children: [
                      const Icon(LucideIcons.alertTriangle, size: 20),
                      const SizedBox(width: 8),
                      Expanded(child: Text(msg, overflow: TextOverflow.ellipsis)),
                    ],
                  );
                },
              ),
              const SizedBox(height: 16),
              _WeatherMetricsRow(currentWeather: currentWeather, forecast: forecast, metricTile: _metricTile),
              const SizedBox(height: 18),
              Text('Prochaines 24h', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              forecast.when(
                data: (items) {
                  final hours = _nextHours(items, 24);
                  if (hours.isEmpty) return const Text('Prévisions indisponibles.');
                  return SizedBox(
                    height: 92,
                    child: ListView.separated(
                      scrollDirection: Axis.horizontal,
                      itemCount: hours.length,
                      separatorBuilder: (_, __) => const SizedBox(width: 10),
                      itemBuilder: (context, i) {
                        final h = hours[i];
                        return Container(
                          width: 76,
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: Theme.of(context).colorScheme.surface,
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.2)),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(_hhmm(h.timestamp), style: Theme.of(context).textTheme.bodySmall),
                              const SizedBox(height: 6),
                              Icon(_iconForCode(h.weatherCode), size: 18),
                              const SizedBox(height: 6),
                              Text('${h.temperature.round()}°', style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w700)),
                            ],
                          ),
                        );
                      },
                    ),
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8),
                  child: LinearProgressIndicator(minHeight: 2),
                ),
                error: (err, st) {
                  final msg = err is AppFailure ? err.message : 'Prévisions indisponibles';
                  return Text(msg);
                },
              ),
              const SizedBox(height: 18),
              Text('Prévisions 7 jours', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              forecast.when(
                data: (items) {
                  final daily = _dailySummary(items);
                  if (daily.isEmpty) return const Text('Prévisions indisponibles.');
                  return Column(
                    children: [
                      for (final d in daily)
                        ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: Icon(_iconForCode(d.weatherCode)),
                          title: Text(_dmy(d.timestamp)),
                          trailing: Text('${d.temperature.round()}°'),
                        ),
                    ],
                  );
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
              const SizedBox(height: 18),
              Text('Pour votre profil', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              currentWeather.when(
                data: (w) {
                  final line = profile.type == ProfileType.cyclist
                      ? 'Vent: ${w.windSpeed.round()} km/h (utile pour l’effort / vent de face)'
                      : profile.type == ProfileType.driver
                          ? 'Précip.: ${w.precipitation.toStringAsFixed(1)} mm (adhérence / visibilité)'
                          : 'Vent: ${w.windSpeed.round()} km/h • UV: ${w.uvIndex?.toStringAsFixed(0) ?? '—'}';
                  return Text(line, style: Theme.of(context).textTheme.bodyLarge);
                },
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
              ),
            ],
          ),
        );
      },
    );
  }
}

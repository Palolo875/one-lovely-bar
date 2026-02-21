import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import '../../domain/models/weather_condition.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/models/poi.dart';
import '../../domain/failures/app_failure.dart';
import '../providers/profile_provider.dart';
import '../providers/current_weather_provider.dart';
import '../providers/rainviewer_provider.dart';
import '../providers/weather_layers_provider.dart';
import '../providers/poi_provider.dart';
import '../providers/weather_grid_provider.dart';
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

  static const _radarSourceId = 'rainviewer_radar_source';
  static const _radarLayerId = 'rainviewer_radar_layer';

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
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

    await controller.addLayer(
      _radarSourceId,
      _radarLayerId,
      RasterLayerProperties(
        rasterOpacity: 0.65,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(profileNotifierProvider);
    final parisWeather = ref.watch(
      currentWeatherProvider(const LatLngRequest(lat: 48.8566, lng: 2.3522)),
    );

    final layers = ref.watch(weatherLayersProvider);
    final radarTimeAsync = ref.watch(rainViewerLatestTimeProvider);

    final poiFilter = ref.watch(poiFilterProvider);
    final center = _debouncedCenter;

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          if (index == 1) context.push('/planning');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(LucideIcons.map), label: 'Carte'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.calendar), label: 'Planifier'),
          BottomNavigationBarItem(icon: Icon(LucideIcons.user), label: 'Profil'),
        ],
      ),
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
            styleString: 'https://tiles.openfreemap.org/styles/positron',
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
                      child: Icon(_getProfileIcon(activeProfile.type),
                        size: 18, color: Colors.blue),
                    ),
                  ),
                ],
              ),
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
                _buildFloatingButton(LucideIcons.crosshair, () {
                  // Center on user
                }),
              ],
            ),
          ),

          // Bottom Sheet Handle (Indicator)
          Align(
            alignment: Alignment.bottomCenter,
            child: GestureDetector(
              onTap: () => _showWeatherDetails(context),
              child: Container(
                height: 80,
                width: double.infinity,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black12,
                      blurRadius: 10,
                      offset: Offset(0, -2),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 8),
                    Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _BottomWeatherIndicator(weather: parisWeather),
                    ),
                  ],
                ),
              ),
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

  const _BottomWeatherIndicator({required this.weather});

  @override
  Widget build(BuildContext context) {
    return weather.when(
      data: (w) {
        final icon = _iconForCode(w.weatherCode);
        final subtitle = '${w.temperature.round()}°C • Vent ${w.windSpeed.round()} km/h';
        return Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Paris', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
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
}

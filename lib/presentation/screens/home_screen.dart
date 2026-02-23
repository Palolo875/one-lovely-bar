import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/current_weather_provider.dart';
import 'package:weathernav/presentation/providers/forecast_provider.dart';
import 'package:weathernav/presentation/providers/rainviewer_provider.dart';
import 'package:weathernav/presentation/providers/weather_layers_provider.dart';
import 'package:weathernav/presentation/providers/poi_provider.dart';
import 'package:weathernav/presentation/providers/weather_grid_provider.dart';
import 'package:weathernav/presentation/providers/map_style_provider.dart';
import 'package:weathernav/presentation/widgets/profile_switcher.dart';
import 'package:weathernav/presentation/screens/home/home_weather_sheet.dart';
import 'package:weathernav/presentation/screens/home/home_map_overlays_controller.dart';
import 'package:weathernav/presentation/map/maplibre_camera_utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapLibreMapController? mapController;
  final HomeMapOverlaysController _overlays = HomeMapOverlaysController();
  LatLng _mapCenter = const LatLng(48.8566, 2.3522);
  LatLng _debouncedCenter = const LatLng(48.8566, 2.3522);
  Timer? _cameraDebounce;
  String? _poiRequestKey;
  String? _gridRequestKey;

  ProviderSubscription<AsyncValue<List<GridPointWeather>>>? _gridSub;
  ProviderSubscription<AsyncValue<List<Poi>>>? _poiSub;
  ProviderSubscription<AsyncValue<int?>>? _radarTimeSub;
  ProviderSubscription<WeatherLayersState>? _layersSub;
  ProviderSubscription<PoiFilterState>? _poiFilterSub;

  List<GridPointWeather> _lastGrid = const <GridPointWeather>[];
  List<Poi> _lastPois = const <Poi>[];
  int? _latestRadarTime;

  bool _centering = false;

  @override
  void initState() {
    super.initState();

    _layersSub = ref.listenManual<WeatherLayersState>(weatherLayersProvider, (prev, next) {
      _overlays.applyGridSymbols(_lastGrid, next);
      _overlays.applyRadarLayerIfNeeded(next, _latestRadarTime);
      _syncGridSubscription(layers: next);
    });

    _poiFilterSub = ref.listenManual<PoiFilterState>(poiFilterProvider, (prev, next) {
      _syncPoiSubscription(poiFilter: next);
    });

    _radarTimeSub = ref.listenManual<AsyncValue<int?>>(rainViewerLatestTimeProvider, (prev, next) {
      next.whenData((t) {
        _latestRadarTime = t;
        final layers = ref.read(weatherLayersProvider);
        _overlays.applyRadarLayerIfNeeded(layers, t);
      });
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncGridSubscription(layers: ref.read(weatherLayersProvider));
      _syncPoiSubscription(poiFilter: ref.read(poiFilterProvider));
    });
  }

  void _syncGridSubscription({required WeatherLayersState layers}) {
    final center = _debouncedCenter;
    final showGrid = layers.enabled.contains(WeatherLayer.wind) || layers.enabled.contains(WeatherLayer.temperature);
    final nextGridKey = '${center.latitude},${center.longitude}|${showGrid ? '1' : '0'}';
    if (_gridRequestKey == nextGridKey) return;
    _gridRequestKey = nextGridKey;

    _gridSub?.close();
    _gridSub = null;

    if (!showGrid) {
      _lastGrid = const <GridPointWeather>[];
      _overlays.applyGridSymbols(_lastGrid, layers);
      return;
    }

    final req = WeatherGridRequest(
      centerLat: center.latitude,
      centerLng: center.longitude,
    );
    _gridSub = ref.listenManual<AsyncValue<List<GridPointWeather>>>(
      weatherGridProvider(req),
      (prev, next) {
        next.whenData((grid) {
          _lastGrid = grid;
          final currentLayers = ref.read(weatherLayersProvider);
          _overlays.applyGridSymbols(grid, currentLayers);
        });
      },
    );
  }

  void _syncPoiSubscription({required PoiFilterState poiFilter}) {
    final center = _debouncedCenter;
    final nextPoiKey = '${center.latitude},${center.longitude}|${poiFilter.radiusMeters}|${poiFilter.categories.map((c) => c.name).join(',')}|${poiFilter.enabled ? '1' : '0'}';
    if (_poiRequestKey == nextPoiKey) return;
    _poiRequestKey = nextPoiKey;

    _poiSub?.close();
    _poiSub = null;

    if (!poiFilter.enabled) {
      _lastPois = const <Poi>[];
      _overlays.applyPois(_lastPois);
      return;
    }

    final req = PoiRequest(
      lat: center.latitude,
      lng: center.longitude,
      radiusMeters: poiFilter.radiusMeters,
      categories: poiFilter.categories,
    );
    _poiSub = ref.listenManual<AsyncValue<List<Poi>>>(
      poiSearchProvider(req),
      (prev, next) {
        next.whenData((items) {
          _lastPois = items;
          _overlays.applyPois(items);
        });
      },
    );
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _overlays.attach(controller);
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    try {
      final status = await Permission.locationWhenInUse.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.locationWhenInUse.request();
      }
    } catch (e, st) {
      AppLogger.warn('Home: location permission check/request failed', name: 'home', error: e, stackTrace: st);
    }
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
        try {
          await MapLibreCameraUtils.animateCameraCompat(
            controller,
            CameraUpdate.newLatLngZoom(target, 13.5),
          );
        } catch (e, st) {
          AppLogger.warn('Home: animateCamera failed', name: 'home', error: e, stackTrace: st);
          try {
            await MapLibreCameraUtils.moveCameraCompat(
              controller,
              CameraUpdate.newLatLngZoom(target, 13.5),
            );
          } catch (e2, st2) {
            AppLogger.warn('Home: moveCamera failed', name: 'home', error: e2, stackTrace: st2);
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _mapCenter = target;
        _debouncedCenter = _roundCenter(target);
      });
    } catch (e, st) {
      AppLogger.warn('Home: centerOnUser failed', name: 'home', error: e, stackTrace: st);
    }
    if (mounted) setState(() => _centering = false);
  }

  @override
  void dispose() {
    _cameraDebounce?.cancel();
    _gridSub?.close();
    _poiSub?.close();
    _poiFilterSub?.close();
    _radarTimeSub?.close();
    _layersSub?.close();
    unawaited(_overlays.dispose());
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

      final layers = ref.read(weatherLayersProvider);
      _syncGridSubscription(layers: layers);
      _syncPoiSubscription(poiFilter: ref.read(poiFilterProvider));
    });
  }

  @override
  Widget build(BuildContext context) {
    final activeProfile = ref.watch(profileNotifierProvider);
    final center = _debouncedCenter;
    final currentWeatherAsync = ref.watch(
      currentWeatherProvider(LatLngRequest(lat: center.latitude, lng: center.longitude)),
    );
    final forecastAsync = ref.watch(
      forecastProvider(ForecastRequest(lat: center.latitude, lng: center.longitude)),
    );

    final layers = ref.watch(weatherLayersProvider);
    final layersNotifier = ref.read(weatherLayersProvider.notifier);
    final mapStyle = ref.watch(mapStyleProvider);

    return Scaffold(
      body: Stack(
        children: [
          // Map
          MapLibreMap(
            onMapCreated: _onMapCreated,
            onCameraIdle: _onCameraIdle,
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.3522), // Paris
              zoom: 12,
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
                    border: Border.all(color: Colors.grey.shade200),
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
                      Expanded(
                        child: Text(
                          AppLocalizations.of(context)?.searchDestination ?? 'Rechercher',
                          style: const TextStyle(color: Colors.grey, fontSize: 16),
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
            child: HomePersistentWeatherSheet(
              currentWeather: currentWeatherAsync,
              forecast: forecastAsync,
              profile: activeProfile,
              center: center,
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

  void _showLayersSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
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
                              divisions: 10,
                              label: '${((layers.opacity[WeatherLayer.radar] ?? 0.65) * 100).round()}%',
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

class _ActiveLayerChips extends StatelessWidget {

  const _ActiveLayerChips({required this.layers, required this.onToggle});
  final WeatherLayersState layers;
  final void Function(WeatherLayer layer) onToggle;

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

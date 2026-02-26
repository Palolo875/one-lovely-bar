import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'dart:async';
import 'package:permission_handler/permission_handler.dart';
import 'package:geolocator/geolocator.dart';
import 'package:weathernav/core/config/app_constants.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/domain/models/grid_point_weather.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/l10n/l10n_ext.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/current_weather_provider.dart';
import 'package:weathernav/presentation/providers/forecast_provider.dart';
import 'package:weathernav/presentation/providers/rainviewer_provider.dart';
import 'package:weathernav/presentation/providers/weather_layers_provider.dart';
import 'package:weathernav/presentation/providers/poi_provider.dart';
import 'package:weathernav/presentation/providers/weather_grid_provider.dart';
import 'package:weathernav/presentation/providers/map_style_provider.dart';
import 'package:weathernav/presentation/widgets/profile_switcher.dart';
import 'package:weathernav/presentation/widgets/app_card.dart';
import 'package:weathernav/presentation/widgets/app_pill.dart';
import 'package:weathernav/presentation/widgets/app_toggle_pill.dart';
import 'package:weathernav/presentation/widgets/weather_layers_sheet.dart';
import 'package:weathernav/presentation/widgets/poi_filter_sheet.dart';
import 'package:weathernav/presentation/screens/home/home_weather_sheet.dart';
import 'package:weathernav/presentation/screens/home/home_map_overlays_controller.dart';
import 'package:weathernav/presentation/map/maplibre_camera_utils.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/presentation/widgets/app_snackbar.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  MapLibreMapController? mapController;
  final HomeMapOverlaysController _overlays = HomeMapOverlaysController();
  LatLng _mapCenter = AppConstants.defaultCenter;
  LatLng _debouncedCenter = AppConstants.defaultCenter;
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

  PlaceSuggestion? _lastSearch;

  bool _centering = false;

  @override
  void initState() {
    super.initState();

    _layersSub = ref.listenManual<WeatherLayersState>(weatherLayersProvider, (
      prev,
      next,
    ) {
      _overlays.applyGridSymbols(_lastGrid, next);
      _overlays.applyRadarLayerIfNeeded(next, _latestRadarTime);
      _syncGridSubscription(layers: next);
    });

    _poiFilterSub = ref.listenManual<PoiFilterState>(poiFilterProvider, (
      prev,
      next,
    ) {
      _syncPoiSubscription(poiFilter: next);
    });

    _radarTimeSub = ref.listenManual<AsyncValue<int?>>(
      rainViewerLatestTimeProvider,
      (prev, next) {
        next.whenData((t) {
          _latestRadarTime = t;
          final layers = ref.read(weatherLayersProvider);
          _overlays.applyRadarLayerIfNeeded(layers, t);
        });
      },
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _syncGridSubscription(layers: ref.read(weatherLayersProvider));
      _syncPoiSubscription(poiFilter: ref.read(poiFilterProvider));
    });
  }

  Future<void> _openSearch() async {
    final l = context.l10n;
    final result = await context.push<PlaceSuggestion>(
      '/search?title=${Uri.encodeComponent(l.arrival)}',
    );
    if (result == null) return;

    _lastSearch = result;

    final target = LatLng(result.latitude, result.longitude);
    final controller = mapController;
    if (controller != null) {
      try {
        await MapLibreCameraUtils.animateCameraCompat(
          controller,
          CameraUpdate.newLatLngZoom(target, 13.5),
        );
      } catch (e, st) {
        AppLogger.warn(
          'Home: animateCamera to search result failed',
          name: 'home',
          error: e,
          stackTrace: st,
        );
      }
    }

    if (!mounted) return;
    setState(() {
      _mapCenter = target;
      _debouncedCenter = _roundCenter(target);
    });

    final layers = ref.read(weatherLayersProvider);
    _syncGridSubscription(layers: layers);
    _syncPoiSubscription(poiFilter: ref.read(poiFilterProvider));
  }

  void _syncGridSubscription({required WeatherLayersState layers}) {
    final center = _debouncedCenter;
    final showGrid =
        layers.enabled.contains(WeatherLayer.wind) ||
        layers.enabled.contains(WeatherLayer.temperature);
    final nextGridKey =
        '${center.latitude},${center.longitude}|${showGrid ? '1' : '0'}';
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
    final nextPoiKey =
        '${center.latitude},${center.longitude}|${poiFilter.radiusMeters}|${poiFilter.categories.map((c) => c.name).join(',')}|${poiFilter.enabled ? '1' : '0'}';
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
    _poiSub = ref.listenManual<AsyncValue<List<Poi>>>(poiSearchProvider(req), (
      prev,
      next,
    ) {
      next.whenData((items) {
        _lastPois = items;
        _overlays.applyPois(items);
      });
    });
  }

  void _onMapCreated(MapLibreMapController controller) {
    mapController = controller;
    _overlays.attach(controller);
    _ensureLocationPermission();
  }

  Future<void> _ensureLocationPermission() async {
    try {
      if (kIsWeb) return;
      final status = await Permission.locationWhenInUse.status;
      if (status.isDenied || status.isRestricted) {
        await Permission.locationWhenInUse.request();
      }
    } catch (e, st) {
      AppLogger.warn(
        'Home: location permission check/request failed',
        name: 'home',
        error: e,
        stackTrace: st,
      );
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

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.medium,
      );
      final target = LatLng(pos.latitude, pos.longitude);

      final controller = mapController;
      if (controller != null) {
        try {
          await MapLibreCameraUtils.animateCameraCompat(
            controller,
            CameraUpdate.newLatLngZoom(target, 13.5),
          );
        } catch (e, st) {
          AppLogger.warn(
            'Home: animateCamera failed',
            name: 'home',
            error: e,
            stackTrace: st,
          );
          try {
            await MapLibreCameraUtils.moveCameraCompat(
              controller,
              CameraUpdate.newLatLngZoom(target, 13.5),
            );
          } catch (e2, st2) {
            AppLogger.warn(
              'Home: moveCamera failed',
              name: 'home',
              error: e2,
              stackTrace: st2,
            );
          }
        }
      }

      if (!mounted) return;
      setState(() {
        _mapCenter = target;
        _debouncedCenter = _roundCenter(target);
      });
    } catch (e, st) {
      AppLogger.warn(
        'Home: centerOnUser failed',
        name: 'home',
        error: e,
        stackTrace: st,
      );
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

  String _buildOverlayStatusText(WeatherLayersState layers) {
    final l = context.l10n;
    final parts = <String>[];
    if (layers.enabled.contains(WeatherLayer.wind)) parts.add(l.wind);
    if (layers.enabled.contains(WeatherLayer.temperature))
      parts.add(l.temperature);
    return l.overlayStatusPrefix(parts.join(' + '));
  }

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final scheme = Theme.of(context).colorScheme;
    final activeProfile = ref.watch(profileProvider);
    final center = _debouncedCenter;
    final currentWeatherAsync = ref.watch(
      currentWeatherProvider(
        LatLngRequest(lat: center.latitude, lng: center.longitude),
      ),
    );
    final forecastAsync = ref.watch(
      forecastProvider(
        ForecastRequest(lat: center.latitude, lng: center.longitude),
      ),
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
            initialCameraPosition: CameraPosition(
              target: AppConstants.defaultCenter,
              zoom: 12,
            ),
            styleString: mapStyle.styleUrl,
            myLocationEnabled: true,
            trackCameraPosition: true,
          ),

          if (layers.enabled.contains(WeatherLayer.wind) ||
              layers.enabled.contains(WeatherLayer.temperature))
            Positioned(
              left: 16,
              right: 16,
              top: 110,
              child: IgnorePointer(
                child: AppCard(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                  backgroundColor: scheme.surface.withValues(alpha: 0.92),
                  borderColor: scheme.outlineVariant.withValues(alpha: 0.6),
                  child: Text(
                    _buildOverlayStatusText(layers),
                    style: Theme.of(
                      context,
                    ).textTheme.bodyMedium?.copyWith(color: scheme.onSurface),
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
              child: AppCard(
                borderRadius: 30,
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                backgroundColor: scheme.surface,
                borderColor: scheme.outlineVariant.withValues(alpha: 0.6),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: _openSearch,
                        borderRadius: BorderRadius.circular(30),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 6),
                          child: Row(
                            children: [
                              Icon(
                                LucideIcons.search,
                                color: scheme.onSurfaceVariant,
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  l.searchDestination,
                                  style: Theme.of(context).textTheme.bodyLarge
                                      ?.copyWith(
                                        color: scheme.onSurfaceVariant,
                                      ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    InkWell(
                      onTap: () => _showProfileSwitcher(context),
                      borderRadius: BorderRadius.circular(999),
                      child: AppPill(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 10,
                          vertical: 8,
                        ),
                        backgroundColor: scheme.primary.withValues(alpha: 0.10),
                        borderColor: scheme.primary.withValues(alpha: 0.18),
                        child: Icon(
                          ProfileSwitcher.profileIcon(activeProfile.type),
                          size: 18,
                          color: scheme.primary,
                        ),
                      ),
                    ),
                  ],
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
              onToggle: (l) {
                final ok = layersNotifier.toggle(l);
                if (!ok && context.mounted) {
                  AppSnackbar.error(context, context.l10n.max3LayersError);
                }
              },
            ),
          ),

          Positioned(
            top: 154,
            left: 16,
            right: 16,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  AppTogglePill(
                    selected: false,
                    onPressed: () {
                      final d = _lastSearch;
                      final end = d == null
                          ? _debouncedCenter
                          : LatLng(d.latitude, d.longitude);
                      context.go(
                        '/itinerary?from=home&endLat=${end.latitude}&endLng=${end.longitude}',
                      );
                    },
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.navigation),
                        const SizedBox(width: 6),
                        Text(l.itineraryButton),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  AppTogglePill(
                    selected: false,
                    onPressed: () => context.go('/history'),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(LucideIcons.history),
                        const SizedBox(width: 6),
                        Text(l.historyButton),
                      ],
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
                _buildFloatingButton(
                  icon: LucideIcons.layers,
                  tooltip: l.weatherLayersTooltip,
                  onPressed: () => _showLayersSheet(context),
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  icon: LucideIcons.mapPin,
                  tooltip: l.poisTooltip,
                  onPressed: () => _showPoiSheet(context),
                ),
                const SizedBox(height: 12),
                _buildFloatingButton(
                  icon: LucideIcons.crosshair,
                  tooltip: l.centerOnPosition,
                  onPressed: _centerOnUser,
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

  Widget _buildFloatingButton({
    required IconData icon,
    required String tooltip,
    required VoidCallback onPressed,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return FloatingActionButton.small(
      tooltip: tooltip,
      onPressed: onPressed,
      backgroundColor: scheme.surface,
      foregroundColor: scheme.onSurface,
      elevation: 0,
      highlightElevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(999),
        side: BorderSide(color: scheme.outlineVariant),
      ),
      child: Icon(icon),
    );
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
      builder: (context) => const WeatherLayersSheet(),
    );
  }

  void _showPoiSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => PoiFilterSheet(center: _debouncedCenter),
    );
  }
}

class _ActiveLayerChips extends StatelessWidget {
  const _ActiveLayerChips({required this.layers, required this.onToggle});
  final WeatherLayersState layers;
  final void Function(WeatherLayer layer) onToggle;

  String _label(BuildContext context, WeatherLayer l) {
    final loc = context.l10n;
    return switch (l) {
      WeatherLayer.radar => loc.layerRain,
      WeatherLayer.wind => loc.layerWind,
      WeatherLayer.temperature => loc.layerTemp,
    };
  }

  IconData _icon(WeatherLayer l) {
    return switch (l) {
      WeatherLayer.radar => LucideIcons.cloudRain,
      WeatherLayer.wind => LucideIcons.wind,
      WeatherLayer.temperature => LucideIcons.thermometer,
    };
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
              AppTogglePill(
                selected: true,
                onPressed: () => onToggle(l),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_icon(l)),
                    const SizedBox(width: 6),
                    Text(_label(context, l)),
                  ],
                ),
              ),
              const SizedBox(width: 8),
            ],
          ],
        ),
      ),
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/presentation/map/maplibre_camera_utils.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/usecases/export_route_to_gpx.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/route_provider.dart';
import 'package:weathernav/presentation/providers/route_alerts_provider.dart';
import 'package:weathernav/presentation/providers/trip_history_provider.dart';
import 'package:weathernav/presentation/providers/weather_timeline_eta_provider.dart';
import 'package:weathernav/presentation/providers/map_style_provider.dart';
import 'package:weathernav/presentation/widgets/weather_timeline.dart';

class ItineraryScreen extends ConsumerStatefulWidget {
  const ItineraryScreen({super.key});

  @override
  ConsumerState<ItineraryScreen> createState() => _ItineraryScreenState();
}

class _ItineraryScreenState extends ConsumerState<ItineraryScreen> {
  final _startLatController = TextEditingController(text: '48.8566');
  final _startLngController = TextEditingController(text: '2.3522');
  final _endLatController = TextEditingController(text: '48.8049');
  final _endLngController = TextEditingController(text: '2.1204');

  DateTime _departureTime = DateTime.now();
  double _departureOffsetMinutes = 0;

  MapLibreMapController? _map;
  Line? _routeLine;
  Timer? _drawDebounce;
  String? _routeKey;

  @override
  void dispose() {
    _startLatController.dispose();
    _startLngController.dispose();
    _endLatController.dispose();
    _endLngController.dispose();
    _drawDebounce?.cancel();
    super.dispose();
  }

  DateTime _effectiveDeparture() {
    return _departureTime.add(Duration(minutes: _departureOffsetMinutes.round()));
  }

  String _profileToRoutingProfile(ProfileType type) {
    switch (type) {
      case ProfileType.cyclist:
        return 'cyclist';
      case ProfileType.hiker:
        return 'hiker';
      case ProfileType.driver:
        return 'driver';
      case ProfileType.nautical:
        return 'driver';
      case ProfileType.paraglider:
        return 'hiker';
      case ProfileType.camper:
        return 'driver';
      case ProfileType.universal:
        return 'driver';
    }
  }

  Future<void> _selectPlace({required String title, required TextEditingController lat, required TextEditingController lng}) async {
    final result = await context.push<PlaceSuggestion>('/search?title=${Uri.encodeComponent(title)}');
    if (result == null) return;
    lat.text = result.latitude.toStringAsFixed(6);
    lng.text = result.longitude.toStringAsFixed(6);
    if (mounted) setState(() {});
  }

  void _swapStartEnd() {
    final slat = _startLatController.text;
    final slng = _startLngController.text;
    _startLatController.text = _endLatController.text;
    _startLngController.text = _endLngController.text;
    _endLatController.text = slat;
    _endLngController.text = slng;
    setState(() {});
  }

  Future<void> _useCurrentLocationForStart() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;
      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied || perm == LocationPermission.deniedForever) {
        return;
      }
      final pos = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.medium);
      _startLatController.text = pos.latitude.toStringAsFixed(6);
      _startLngController.text = pos.longitude.toStringAsFixed(6);
      if (mounted) setState(() {});
    } catch (e, st) {
      AppLogger.warn('Itinerary: getCurrentPosition failed', name: 'itinerary', error: e, stackTrace: st);
    }
  }

  Future<void> _drawRoute(RouteData route) async {
    final controller = _map;
    if (controller == null) return;

    final nextKey = '${route.points.length}:${route.points.first.latitude},${route.points.first.longitude}:${route.points.last.latitude},${route.points.last.longitude}:${route.distanceKm}:${route.durationMinutes}';
    if (_routeKey == nextKey && _routeLine != null) return;
    _routeKey = nextKey;

    _drawDebounce?.cancel();
    _drawDebounce = Timer(const Duration(milliseconds: 150), () async {
      if (!mounted) return;

      try {
        if (_routeLine != null) {
          final line = _routeLine;
          if (line != null) {
            await controller.removeLine(line);
          }
        }
      } catch (e, st) {
        AppLogger.warn('Itinerary: removeLine failed', name: 'itinerary', error: e, stackTrace: st);
      }

      try {
        _routeLine = await controller.addLine(
          LineOptions(
            geometry: route.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
            lineColor: '#2563EB',
            lineWidth: 5,
            lineOpacity: 0.85,
          ),
        );
      } catch (e, st) {
        AppLogger.warn('Itinerary: addLine failed', name: 'itinerary', error: e, stackTrace: st);
      }

      try {
        final pts = route.points;
        if (pts.isNotEmpty) {
          final start = pts.first;
          await MapLibreCameraUtils.animateCameraCompat(
            controller,
            CameraUpdate.newLatLngZoom(LatLng(start.latitude, start.longitude), 11.5),
          );
        }
      } catch (e, st) {
        AppLogger.warn('Itinerary: animateCamera failed', name: 'itinerary', error: e, stackTrace: st);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileNotifierProvider);
    final mapStyle = ref.watch(mapStyleProvider);
    final startLat = double.tryParse(_startLatController.text.trim());
    final startLng = double.tryParse(_startLngController.text.trim());
    final endLat = double.tryParse(_endLatController.text.trim());
    final endLng = double.tryParse(_endLngController.text.trim());

    final canCompute = startLat != null && startLng != null && endLat != null && endLng != null;

    final routeReq = canCompute
        ? RouteRequest(
            startLat: startLat,
            startLng: startLng,
            endLat: endLat,
            endLng: endLng,
            profile: _profileToRoutingProfile(profile.type),
            departureTime: _effectiveDeparture(),
          )
        : null;

    final routeAsync = routeReq == null ? null : ref.watch(routeProvider(routeReq));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Itinéraire'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPlacesCard(profile),
          const SizedBox(height: 12),
          _buildDepartureCard(),
          const SizedBox(height: 12),
          SizedBox(
            height: 220,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(20),
              child: MapLibreMap(
                onMapCreated: (c) => _map = c,
                initialCameraPosition: const CameraPosition(target: LatLng(48.8566, 2.3522), zoom: 10.5),
                styleString: mapStyle.styleUrl,
                myLocationEnabled: true,
                rotateGesturesEnabled: false,
                tiltGesturesEnabled: false,
              ),
            ),
          ),
          const SizedBox(height: 12),
          if (routeReq == null || routeAsync == null) const Text('Renseignez un départ et une arrivée pour calculer un itinéraire.') else routeAsync.when(
                  data: (route) {
                    _drawRoute(route);

                    final departure = _effectiveDeparture();
                    final arrivingAt = departure.add(Duration(minutes: route.durationMinutes.round()));
                    final weatherAsync = ref.watch(
                      weatherTimelineEtaProvider(WeatherTimelineEtaRequest(route: route, departureTime: departure)),
                    );
                    final alertsAsync = ref.watch(
                      routeAlertsProvider(WeatherTimelineEtaRequest(route: route, departureTime: departure)),
                    );

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildSummaryCards(route, departure: departure, arrivingAt: arrivingAt),
                        const SizedBox(height: 12),
                        Text('Alertes', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        alertsAsync.when(
                          data: (alerts) {
                            if (alerts.isEmpty) {
                              return const Text('Aucune alerte détectée pour ce départ.');
                            }
                            return Card(
                              elevation: 0,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                              child: Column(
                                children: alerts
                                    .map(
                                      (a) => ListTile(
                                        title: Text(a.title),
                                        subtitle: Text(a.message),
                                      ),
                                    )
                                    .toList(),
                              ),
                            );
                          },
                          loading: () => const LinearProgressIndicator(minHeight: 2),
                          error: (err, st) {
                            final msg = err is AppFailure ? err.message : err.toString();
                            return Text(msg);
                          },
                        ),
                        const SizedBox(height: 12),
                        Text('Timeline météo', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700)),
                        const SizedBox(height: 8),
                        weatherAsync.when(
                          data: (conditions) => WeatherTimeline(conditions: conditions),
                          loading: () => const Center(child: Padding(padding: EdgeInsets.all(12), child: CircularProgressIndicator())),
                          error: (err, st) {
                            final msg = err is AppFailure ? err.message : err.toString();
                            return Text(msg);
                          },
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: ElevatedButton.icon(
                                onPressed: routeAsync.isLoading ? null : () => context.push('/guidance', extra: routeReq),
                                icon: const Icon(LucideIcons.play),
                                label: const Text('Démarrer'),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: OutlinedButton.icon(
                                onPressed: routeAsync.isLoading
                                    ? null
                                    : () {
                                      final repo = ref.read(tripHistoryRepositoryProvider);
                                      final gpx = const ExportRouteToGpx()(route);
                                      repo.addTrip(
                                        createdAt: DateTime.now(),
                                        departureTime: departure,
                                        profile: routeReq.profile,
                                        startLat: routeReq.startLat,
                                        startLng: routeReq.startLng,
                                        endLat: routeReq.endLat,
                                        endLng: routeReq.endLng,
                                        distanceKm: route.distanceKm,
                                        durationMinutes: route.durationMinutes,
                                        gpx: gpx,
                                      );
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(content: Text('Trajet sauvegardé dans l’historique.')),
                                      );
                                    },
                                icon: const Icon(LucideIcons.save),
                                label: const Text('Sauvegarder'),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        SizedBox(
                          width: double.infinity,
                          child: OutlinedButton.icon(
                            onPressed: routeAsync.isLoading ? null : () => context.push('/simulation', extra: routeReq),
                            icon: const Icon(LucideIcons.slidersHorizontal),
                            label: const Text('Ouvrir la simulation avancée'),
                          ),
                        ),
                      ],
                    );
                  },
                  loading: () => const Center(child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator())),
                  error: (err, st) {
                    final msg = err is AppFailure ? err.message : err.toString();
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg),
                        const SizedBox(height: 8),
                        OutlinedButton(
                          onPressed: () => ref.invalidate(routeProvider(routeReq)),
                          child: const Text('Réessayer'),
                        ),
                      ],
                    );
                  },
                ),
        ],
      ),
    );
  }

  Widget _buildPlacesCard(UserProfile profile) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.route, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Départ / Arrivée',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                IconButton(
                  onPressed: _useCurrentLocationForStart,
                  tooltip: 'Utiliser ma position',
                  icon: const Icon(LucideIcons.locateFixed),
                ),
                IconButton(
                  onPressed: _swapStartEnd,
                  tooltip: 'Inverser',
                  icon: const Icon(LucideIcons.arrowLeftRight),
                ),
                Text(
                  profile.name,
                  style: Theme.of(context).textTheme.bodySmall,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildCoordinateRow(
              icon: LucideIcons.mapPin,
              title: 'Départ',
              latController: _startLatController,
              lngController: _startLngController,
            ),
            const SizedBox(height: 10),
            _buildCoordinateRow(
              icon: LucideIcons.navigation,
              title: 'Arrivée',
              latController: _endLatController,
              lngController: _endLngController,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDepartureCard() {
    final dep = _effectiveDeparture();
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(LucideIcons.clock, color: Theme.of(context).colorScheme.primary),
                const SizedBox(width: 10),
                Text(
                  'Heure de départ',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
                ),
                const Spacer(),
                TextButton(
                  onPressed: () async {
                    final pickedDate = await showDatePicker(
                      context: context,
                      initialDate: _departureTime,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime.now().add(const Duration(days: 14)),
                    );
                    if (pickedDate == null) return;
                    if (!context.mounted) return;
                    final pickedTime = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(_departureTime),
                    );
                    if (pickedTime == null) return;
                    setState(() {
                      _departureTime = DateTime(
                        pickedDate.year,
                        pickedDate.month,
                        pickedDate.day,
                        pickedTime.hour,
                        pickedTime.minute,
                      );
                      _departureOffsetMinutes = 0;
                    });
                  },
                  child: const Text('Modifier'),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              '${dep.day.toString().padLeft(2, '0')}/${dep.month.toString().padLeft(2, '0')}/${dep.year} '
              '${dep.hour.toString().padLeft(2, '0')}:${dep.minute.toString().padLeft(2, '0')}',
            ),
            Slider(
              value: _departureOffsetMinutes.clamp(-720, 720),
              min: -720,
              max: 720,
              divisions: 48,
              label: '${(_departureOffsetMinutes / 60).round()}h',
              onChanged: (v) => setState(() => _departureOffsetMinutes = v),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryCards(RouteData route, {required DateTime departure, required DateTime arrivingAt}) {
    final eta = '${arrivingAt.hour.toString().padLeft(2, '0')}:${arrivingAt.minute.toString().padLeft(2, '0')}';
    Widget card({required String title, required String value}) {
      return Card(
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
              const SizedBox(height: 6),
              Text(value, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800)),
            ],
          ),
        ),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final w = constraints.maxWidth;
        final itemW = (w - 12) / 2;
        return Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            SizedBox(width: itemW, child: card(title: 'Distance', value: '${route.distanceKm.toStringAsFixed(1)} km')),
            SizedBox(width: itemW, child: card(title: 'Durée', value: '${route.durationMinutes.toStringAsFixed(0)} min')),
            SizedBox(width: itemW, child: card(title: 'Arrivée', value: eta)),
            SizedBox(width: itemW, child: card(title: 'Dénivelé', value: '—')),
          ],
        );
      },
    );
  }

  Widget _buildCoordinateRow({
    required IconData icon,
    required String title,
    required TextEditingController latController,
    required TextEditingController lngController,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, size: 18),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
              const Spacer(),
              TextButton(
                onPressed: () => _selectPlace(title: title, lat: latController, lng: lngController),
                child: const Text('Rechercher'),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: latController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Latitude'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextField(
                  controller: lngController,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
                  decoration: const InputDecoration(labelText: 'Longitude'),
                  onChanged: (_) => setState(() {}),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

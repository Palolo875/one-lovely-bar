import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart' hide RouteData;
import 'package:lucide_icons/lucide_icons.dart';
import 'package:maplibre_gl/maplibre_gl.dart';
import 'package:wakelock_plus/wakelock_plus.dart';
import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/tts/tts_service.dart';
import 'package:weathernav/core/tts/tts_service_factory_impl.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/domain/models/route_alert.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/presentation/map/maplibre_camera_utils.dart';
import 'package:weathernav/presentation/screens/guidance/guidance_progress_controller.dart';
import 'package:weathernav/presentation/providers/route_instructions_provider.dart';
import 'package:weathernav/presentation/providers/route_provider.dart';
import 'package:weathernav/presentation/providers/poi_provider.dart';
import 'package:weathernav/presentation/providers/route_alerts_provider.dart';
import 'package:weathernav/presentation/providers/weather_timeline_eta_provider.dart';
import 'package:weathernav/presentation/providers/map_style_provider.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';

class GuidanceScreen extends ConsumerStatefulWidget {
  const GuidanceScreen({required this.request, super.key});
  final RouteRequest request;

  @override
  ConsumerState<GuidanceScreen> createState() => _GuidanceScreenState();
}

class _GuidanceScreenState extends ConsumerState<GuidanceScreen> {
  late final TtsService _tts;
  bool _speaking = false;

  final GuidanceProgressController _progress = GuidanceProgressController();

  MapLibreMapController? _map;
  Line? _routeLine;
  bool _centering = false;

  StreamSubscription<Position>? _posSub;
  LatLng? _user;
  DateTime? _lastUserUiUpdate;
  String? _routeKey;

  bool _followUser = true;
  DateTime? _lastManualMove;

  @override
  void initState() {
    super.initState();
    _tts = createTtsService();
    WakelockPlus.enable();
    _startLocationStream();
  }

  Future<void> _startLocationStream() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return;
      }

      _posSub?.cancel();
      _posSub =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen(
            (pos) async {
              if (!mounted) return;
              final next = LatLng(pos.latitude, pos.longitude);

              final lastUi = _lastUserUiUpdate;
              final now = DateTime.now();
              final shouldUpdateUi =
                  lastUi == null ||
                  now.difference(lastUi).inMilliseconds >= 650;
              if (shouldUpdateUi) {
                _lastUserUiUpdate = now;
                setState(() => _user = next);
              } else {
                _user = next;
              }

              if (_followUser && _map != null) {
                final lastManualMove = _lastManualMove;
                final sinceManual = lastManualMove == null
                    ? null
                    : DateTime.now().difference(lastManualMove);
                if (sinceManual == null || sinceManual.inSeconds > 8) {
                  try {
                    final controller = _map;
                    if (controller != null) {
                      await MapLibreCameraUtils.animateCameraCompat(
                        controller,
                        CameraUpdate.newLatLng(next),
                      );
                    }
                  } catch (e, st) {
                    AppLogger.warn(
                      'Guidance: animateCamera failed',
                      name: 'guidance',
                      error: e,
                      stackTrace: st,
                    );
                  }
                }
              }

              if (shouldUpdateUi) {
                final changed = _progress.updateUserPosition(next);
                if (changed && mounted) {
                  setState(() {});
                }
              }
            },
            onError: (Object e, StackTrace st) {
              AppLogger.warn(
                'Guidance: position stream error',
                name: 'guidance',
                error: e,
                stackTrace: st,
              );
            },
          );
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: startLocationStream failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
    }
  }

  @override
  void dispose() {
    _tts.dispose();
    _posSub?.cancel();
    WakelockPlus.disable();
    super.dispose();
  }

  Future<void> _speakAll(List<String> lines) async {
    setState(() => _speaking = true);
    try {
      await _tts.speakLines(lines);
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: TTS speak failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
    }
    if (mounted) setState(() => _speaking = false);
  }

  Future<void> _stop() async {
    setState(() => _speaking = false);
    try {
      await _tts.stop();
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: TTS stop failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
    }
  }

  Future<LatLng?> _getUserLatLng() async {
    try {
      final enabled = await Geolocator.isLocationServiceEnabled();
      if (!enabled) return null;

      var perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.denied ||
          perm == LocationPermission.deniedForever) {
        return null;
      }

      final pos = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );
      return LatLng(pos.latitude, pos.longitude);
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: getUserLatLng failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
      return null;
    }
  }

  Future<void> _centerOnUser() async {
    if (_centering) return;
    setState(() => _centering = true);
    try {
      final user = await _getUserLatLng();
      final controller = _map;
      if (user != null && controller != null) {
        setState(() => _followUser = true);
        try {
          await MapLibreCameraUtils.animateCameraCompat(
            controller,
            CameraUpdate.newLatLng(user),
          );
        } catch (e, st) {
          AppLogger.warn(
            'Guidance: animateCamera failed',
            name: 'guidance',
            error: e,
            stackTrace: st,
          );
        }
      }
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: centerOnUser failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
    }
    if (mounted) setState(() => _centering = false);
  }

  Future<void> _drawRoute(RouteData route) async {
    final controller = _map;
    if (controller == null) return;

    final key =
        '${route.points.length}:${route.points.first.latitude},${route.points.first.longitude}:${route.points.last.latitude},${route.points.last.longitude}:${route.distanceKm}:${route.durationMinutes}';
    if (_routeKey == key && _routeLine != null) return;
    _routeKey = key;

    _progress.setRoutePoints(
      route.points.map((p) => LatLng(p.latitude, p.longitude)).toList(),
    );

    try {
      if (_routeLine != null) {
        final line = _routeLine;
        if (line != null) {
          await controller.removeLine(line);
        }
      }
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: removeLine failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
    }

    try {
      _routeLine = await controller.addLine(
        LineOptions(
          geometry: route.points
              .map((p) => LatLng(p.latitude, p.longitude))
              .toList(),
          lineColor: '#2563EB',
          lineWidth: 6,
          lineOpacity: 0.9,
        ),
      );
    } catch (e, st) {
      AppLogger.warn(
        'Guidance: addLine failed',
        name: 'guidance',
        error: e,
        stackTrace: st,
      );
    }
  }

  String _formatDuration(Duration d) {
    final totalMin = d.inMinutes;
    if (totalMin < 60) return '$totalMin min';
    final h = totalMin ~/ 60;
    final m = totalMin % 60;
    return '${h}h${m.toString().padLeft(2, '0')}';
  }

  Future<void> _showShelters() async {
    final user = await _getUserLatLng();
    if (!mounted) return;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Localisation indisponible.')),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Consumer(
            builder: (context, ref, _) {
              final async = ref.watch(
                poiSearchProvider(
                  PoiRequest(
                    lat: user.latitude,
                    lng: user.longitude,
                    radiusMeters: 2500,
                    categories: const {PoiCategory.shelter, PoiCategory.hut},
                  ),
                ),
              );

              return async.when(
                data: (pois) {
                  if (pois.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Text('Aucun abri trouvé autour de vous.'),
                    );
                  }

                  return ListView.separated(
                    padding: const EdgeInsets.all(16),
                    itemCount: pois.length,
                    separatorBuilder: (_, __) => const Divider(height: 1),
                    itemBuilder: (context, i) {
                      final p = pois[i];
                      return ListTile(
                        leading: const Icon(LucideIcons.home),
                        title: Text(p.name),
                        subtitle: Text(p.category.name),
                        onTap: () async {
                          if (context.mounted) Navigator.of(context).pop();

                          try {
                            final controller = _map;
                            if (controller != null) {
                              await MapLibreCameraUtils.animateCameraCompat(
                                controller,
                                CameraUpdate.newLatLngZoom(
                                  LatLng(p.latitude, p.longitude),
                                  15,
                                ),
                              );
                            }
                          } catch (e, st) {
                            AppLogger.warn(
                              'Guidance: animateCamera to shelter failed',
                              name: 'guidance',
                              error: e,
                              stackTrace: st,
                            );
                          }

                          if (!mounted) return;
                          showModalBottomSheet(
                            context: context,
                            builder: (ctx) {
                              return SafeArea(
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    mainAxisSize: MainAxisSize.min,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Text(
                                        p.name,
                                        style: Theme.of(
                                          context,
                                        ).textTheme.titleMedium,
                                      ),
                                      const SizedBox(height: 6),
                                      Text(
                                        'Abri • rayon 2.5 km',
                                        style: Theme.of(
                                          context,
                                        ).textTheme.bodySmall,
                                      ),
                                      const SizedBox(height: 12),
                                      ElevatedButton.icon(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          final req = widget.request;
                                          final nextReq = RouteRequest(
                                            startLat: user.latitude,
                                            startLng: user.longitude,
                                            endLat: p.latitude,
                                            endLng: p.longitude,
                                            profile: req.profile,
                                            waypoints: const [],
                                            departureTime: DateTime.now(),
                                          );
                                          Future.microtask(() {
                                            if (mounted)
                                              context.pushReplacement(
                                                '/guidance',
                                                extra: nextReq,
                                              );
                                          });
                                        },
                                        icon: const Icon(
                                          LucideIcons.navigation,
                                        ),
                                        label: const Text(
                                          'Remplacer le guidage vers cet abri',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () {
                                          Navigator.of(ctx).pop();
                                          final req = widget.request;
                                          final nextReq = RouteRequest(
                                            startLat: user.latitude,
                                            startLng: user.longitude,
                                            endLat: p.latitude,
                                            endLng: p.longitude,
                                            profile: req.profile,
                                            waypoints: const [],
                                            departureTime: DateTime.now(),
                                          );
                                          Future.microtask(() {
                                            if (mounted)
                                              context.push(
                                                '/guidance',
                                                extra: nextReq,
                                              );
                                          });
                                        },
                                        icon: const Icon(LucideIcons.layers),
                                        label: const Text(
                                          'Empiler un nouveau guidage',
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      OutlinedButton.icon(
                                        onPressed: () =>
                                            Navigator.of(ctx).pop(),
                                        icon: const Icon(LucideIcons.x),
                                        label: const Text('Fermer'),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => const Padding(
                  padding: EdgeInsets.all(16),
                  child: Center(child: AppLoadingIndicator(size: 32)),
                ),
                error: (err, st) {
                  final msg = err is AppFailure ? err.message : err.toString();
                  return Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(msg),
                  );
                },
              );
            },
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final instructionsAsync = ref.watch(
      routeInstructionsProvider(widget.request),
    );
    final routeAsync = ref.watch(routeProvider(widget.request));
    final MapStyleState mapStyle = ref.watch(mapStyleProvider);
    final departure = widget.request.departureTime ?? DateTime.now();

    final alertsAsync = routeAsync.when(
      data: (route) => ref.watch(
        routeAlertsProvider(
          WeatherTimelineEtaRequest(route: route, departureTime: departure),
        ),
      ),
      loading: () => const AsyncValue<List<RouteAlert>>.loading(),
      error: AsyncValue<List<RouteAlert>>.error,
    );

    return Scaffold(
      body: Stack(
        children: [
          MapLibreMap(
            onMapCreated: (c) {
              _map = c;
              _centerOnUser();
            },
            onCameraTrackingDismissed: () {
              if (!_followUser) return;
              setState(() {
                _followUser = false;
                _lastManualMove = DateTime.now();
              });
            },
            initialCameraPosition: const CameraPosition(
              target: LatLng(48.8566, 2.3522),
              zoom: 12,
              tilt: 60,
            ),
            styleString: mapStyle.styleUrl,
            myLocationEnabled: true,
          ),

          routeAsync.when(
            data: (route) {
              _drawRoute(route);
              return const SizedBox.shrink();
            },
            loading: () => const SizedBox.shrink(),
            error: (_, __) => const SizedBox.shrink(),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      IconButton.filledTonal(
                        onPressed: () => Navigator.of(context).maybePop(),
                        tooltip: 'Fermer',
                        icon: const Icon(LucideIcons.x),
                      ),
                      const Spacer(),
                      IconButton.filledTonal(
                        onPressed: _showShelters,
                        tooltip: 'Trouver des abris',
                        icon: const Icon(LucideIcons.umbrella),
                      ),
                      const SizedBox(width: 8),
                      IconButton.filledTonal(
                        onPressed: _centering ? null : _centerOnUser,
                        tooltip: _followUser
                            ? 'Suivi activé'
                            : 'Centrer sur ma position',
                        icon: _centering
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: AppLoadingIndicator(
                                  size: 18,
                                  strokeWidth: 2,
                                ),
                              )
                            : Icon(
                                _followUser
                                    ? LucideIcons.locateFixed
                                    : LucideIcons.locateOff,
                              ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  instructionsAsync.when(
                    data: (items) {
                      if (items.isEmpty) {
                        return _InfoBanner(
                          icon: LucideIcons.navigation,
                          title: 'Guidage',
                          subtitle: 'Aucune instruction disponible.',
                        );
                      }
                      var idx = 0;
                      final totalM = _progress.totalMeters;
                      final cum = _progress.cumMeters;
                      final nearestIdx = _progress.nearestIndex;
                      if (totalM > 0 && nearestIdx < cum.length) {
                        final progressedM = cum[nearestIdx];
                        final progressedKm = progressedM / 1000.0;

                        double accKm = 0;
                        for (var i = 0; i < items.length; i++) {
                          final d = items[i].distanceKm;
                          if (d == null) {
                            idx = (progressedM / totalM * items.length)
                                .floor()
                                .clamp(0, items.length - 1);
                            break;
                          }
                          accKm += d;
                          if (accKm >= progressedKm) {
                            idx = i;
                            break;
                          }
                          if (i == items.length - 1) idx = items.length - 1;
                        }
                      }

                      final next = items[idx];
                      final dist = next.distanceKm != null
                          ? '${(next.distanceKm! * 1000).round()} m'
                          : null;
                      return _InfoBanner(
                        icon: LucideIcons.navigation,
                        title: next.instruction,
                        subtitle: dist,
                      );
                    },
                    loading: () => const _InfoBanner(
                      icon: LucideIcons.navigation,
                      title: 'Chargement...',
                      subtitle: null,
                    ),
                    error: (err, st) {
                      final msg = err is AppFailure
                          ? err.message
                          : err.toString();
                      return _InfoBanner(
                        icon: LucideIcons.alertTriangle,
                        title: 'Erreur',
                        subtitle: msg,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) return const SizedBox.shrink();
                      final a = alerts.first;
                      return _AlertBanner(text: a.message);
                    },
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),

                  const Spacer(),

                  routeAsync.when(
                    data: (route) {
                      final totalM = _progress.totalMeters > 0
                          ? _progress.totalMeters
                          : (route.distanceKm * 1000);
                      final progressedM = _progress.progressedMeters;
                      final remainingM = (totalM - progressedM).clamp(
                        0.0,
                        totalM,
                      );
                      final remainingRatio = totalM > 0
                          ? (remainingM / totalM)
                          : 1.0;

                      final remaining = Duration(
                        minutes: (route.durationMinutes * remainingRatio)
                            .round(),
                      );
                      final eta = DateTime.now().add(remaining);
                      final km = remainingM / 1000.0;
                      return _BottomStatsBar(
                        left: 'Restant: ${_formatDuration(remaining)}',
                        center: 'Distance: ${km.toStringAsFixed(1)} km',
                        right:
                            'Arrivée: ${eta.hour.toString().padLeft(2, '0')}:${eta.minute.toString().padLeft(2, '0')}',
                      );
                    },
                    loading: () => const _BottomStatsBar(
                      left: 'Restant: —',
                      center: 'Distance: —',
                      right: 'Arrivée: —',
                    ),
                    error: (err, st) {
                      final msg = err is AppFailure
                          ? err.message
                          : err.toString();
                      return _BottomStatsBar(
                        left: 'Route: erreur',
                        center: msg,
                        right: ' ',
                      );
                    },
                  ),
                ],
              ),
            ),
          ),

          Positioned(
            right: 12,
            bottom: 110,
            child: instructionsAsync.maybeWhen(
              data: (items) {
                if (items.isEmpty) return const SizedBox.shrink();
                final lines = items.map((e) => e.instruction).toList();
                return FloatingActionButton(
                  onPressed: _speaking ? _stop : () => _speakAll(lines),
                  tooltip: _speaking
                      ? 'Arrêter la lecture'
                      : 'Lire les instructions',
                  child: Icon(
                    _speaking ? LucideIcons.volumeX : LucideIcons.volume2,
                  ),
                );
              },
              orElse: () => const SizedBox.shrink(),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({
    required this.icon,
    required this.title,
    required this.subtitle,
  });
  final IconData icon;
  final String title;
  final String? subtitle;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.94),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.soft(Theme.of(context).shadowColor),
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (subtitle != null) ...[
                  Text(subtitle!, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _AlertBanner extends StatelessWidget {
  const _AlertBanner({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: scheme.tertiaryContainer.withOpacity(0.96),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.soft(Theme.of(context).shadowColor),
      ),
      child: Row(
        children: [
          Icon(LucideIcons.alertTriangle, color: scheme.onTertiaryContainer),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: scheme.onTertiaryContainer,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _BottomStatsBar extends StatelessWidget {
  const _BottomStatsBar({
    required this.left,
    required this.center,
    required this.right,
  });
  final String left;
  final String center;
  final String right;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      decoration: BoxDecoration(
        color: scheme.surface.withOpacity(0.95),
        borderRadius: BorderRadius.circular(AppRadii.md),
        boxShadow: AppShadows.soft(Theme.of(context).shadowColor),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(left, style: Theme.of(context).textTheme.bodyMedium),
          ),
          Expanded(
            child: Text(
              center,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
          Expanded(
            child: Text(
              right,
              textAlign: TextAlign.end,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}

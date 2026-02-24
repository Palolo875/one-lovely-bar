import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/domain/models/route_models.dart';
import 'package:weathernav/domain/models/user_profile.dart';
import 'package:weathernav/domain/usecases/export_route_to_gpx.dart';
import 'package:weathernav/presentation/providers/profile_provider.dart';
import 'package:weathernav/presentation/providers/route_alerts_provider.dart';
import 'package:weathernav/presentation/providers/route_provider.dart';
import 'package:weathernav/presentation/providers/trip_history_provider.dart';
import 'package:weathernav/presentation/providers/weather_timeline_eta_provider.dart';
import 'package:weathernav/presentation/widgets/weather_timeline.dart';
import 'package:weathernav/core/theme/app_tokens.dart';
import 'package:weathernav/presentation/widgets/app_loading_indicator.dart';

class RouteSimulationScreen extends ConsumerStatefulWidget {
  const RouteSimulationScreen({super.key, this.request});
  final RouteRequest? request;

  @override
  ConsumerState<RouteSimulationScreen> createState() =>
      _RouteSimulationScreenState();
}

class _RouteSimulationScreenState extends ConsumerState<RouteSimulationScreen> {
  // minutes offset from base departure time
  double _departureOffsetMinutes = 0;
  String? _lastSavedKey;

  String _profileToRoutingCosting(ProfileType type) {
    switch (type) {
      case ProfileType.universal:
        return 'driver';
      case ProfileType.cyclist:
        return 'cyclist';
      case ProfileType.hiker:
        return 'hiker';
      case ProfileType.driver:
        return 'driver';
      case ProfileType.nautical:
        return 'driver';
      case ProfileType.paraglider:
        return 'driver';
      case ProfileType.camper:
        return 'driver';
    }
  }

  DateTime _applyOffset(DateTime base) {
    return base.add(Duration(minutes: _departureOffsetMinutes.round()));
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final profile = ref.watch(profileProvider);

    final request = widget.request;
    final effectiveRequest =
        request ??
        RouteRequest(
          startLat: 48.8566,
          startLng: 2.3522,
          endLat: 48.8049,
          endLng: 2.1204,
          profile: _profileToRoutingCosting(profile.type),
          departureTime: DateTime.now(),
        );

    final baseDeparture = effectiveRequest.departureTime ?? DateTime.now();
    final departure = _applyOffset(baseDeparture);

    final routeAsync = ref.watch(routeProvider(effectiveRequest));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo sur le trajet'),
        actions: [
          TextButton(
            onPressed: () => context.go('/itinerary'),
            child: const Text('Replanifier'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: routeAsync.when(
          data: (route) {
            final saveKey =
                '${effectiveRequest.startLat},${effectiveRequest.startLng}|${effectiveRequest.endLat},${effectiveRequest.endLng}|${effectiveRequest.profile}|${departure.millisecondsSinceEpoch}';
            if (_lastSavedKey != saveKey) {
              _lastSavedKey = saveKey;
              final repo = ref.read(tripHistoryRepositoryProvider);
              final gpx = const ExportRouteToGpx()(route);
              // Best-effort save (no await to keep UI smooth)
              repo.addTrip(
                createdAt: DateTime.now(),
                departureTime: departure,
                profile: effectiveRequest.profile,
                startLat: effectiveRequest.startLat,
                startLng: effectiveRequest.startLng,
                endLat: effectiveRequest.endLat,
                endLng: effectiveRequest.endLng,
                distanceKm: route.distanceKm,
                durationMinutes: route.durationMinutes,
                gpx: gpx,
              );
            }

            final weatherAsync = ref.watch(
              weatherTimelineEtaProvider(
                WeatherTimelineEtaRequest(
                  route: route,
                  departureTime: departure,
                ),
              ),
            );
            final alertsAsync = ref.watch(
              routeAlertsProvider(
                WeatherTimelineEtaRequest(
                  route: route,
                  departureTime: departure,
                ),
              ),
            );
            final pointRows = _buildPointRows(route.points);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: Theme.of(context).textTheme.titleMedium
                                ?.copyWith(fontWeight: FontWeight.w800),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Distance: ${route.distanceKm.toStringAsFixed(1)} km',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Durée: ${route.durationMinutes.toStringAsFixed(0)} min',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Points: ${route.points.length}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Heure de départ',
                            style: Theme.of(context).textTheme.titleSmall
                                ?.copyWith(fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${departure.day.toString().padLeft(2, '0')}/${departure.month.toString().padLeft(2, '0')}/${departure.year} '
                            '${departure.hour.toString().padLeft(2, '0')}:${departure.minute.toString().padLeft(2, '0')}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Slider(
                            value: _departureOffsetMinutes.clamp(-720, 720),
                            min: -720,
                            max: 720,
                            divisions: 48,
                            label: '${(_departureOffsetMinutes / 60).round()}h',
                            onChanged: (v) =>
                                setState(() => _departureOffsetMinutes = v),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'Départ: ${effectiveRequest.startLat.toStringAsFixed(5)}, ${effectiveRequest.startLng.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          Text(
                            'Arrivée: ${effectiveRequest.endLat.toStringAsFixed(5)}, ${effectiveRequest.endLng.toStringAsFixed(5)}',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () async {
                                final gpx = const ExportRouteToGpx()(route);
                                await Clipboard.setData(
                                  ClipboardData(text: gpx),
                                );
                                if (!context.mounted) return;
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                    content: Text(
                                      'GPX copié dans le presse-papiers.',
                                    ),
                                  ),
                                );
                              },
                              child: const Text('Copier GPX'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => context.push(
                                '/guidance',
                                extra: effectiveRequest,
                              ),
                              child: const Text('Voir instructions'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Alertes',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  alertsAsync.when(
                    data: (alerts) {
                      if (alerts.isEmpty) {
                        return Card(
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(AppRadii.md),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.all(16),
                            child: Text(
                              'Aucune alerte détectée pour ce départ.',
                            ),
                          ),
                        );
                      }

                      return Card(
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadii.md),
                        ),
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
                    loading: () => const Center(child: AppLoadingIndicator()),
                    error: (err, st) {
                      final msg = err is AppFailure
                          ? err.message
                          : err.toString();
                      return Text(
                        'Erreur alertes: $msg',
                        style: Theme.of(
                          context,
                        ).textTheme.bodyMedium?.copyWith(color: scheme.error),
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Timeline météo (échantillonnage du trajet)',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  weatherAsync.when(
                    data: (conditions) =>
                        WeatherTimeline(conditions: conditions),
                    loading: () => const Center(child: AppLoadingIndicator()),
                    error: (err, st) {
                      final msg = err is AppFailure
                          ? err.message
                          : err.toString();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Erreur météo: $msg',
                            style: Theme.of(context).textTheme.bodyMedium
                                ?.copyWith(color: scheme.error),
                          ),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => ref.invalidate(
                              weatherTimelineEtaProvider(
                                WeatherTimelineEtaRequest(
                                  route: route,
                                  departureTime: departure,
                                ),
                              ),
                            ),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Aperçu des points',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadii.md),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(children: pointRows),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/itinerary'),
                      child: const Text('Modifier le trajet'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: AppLoadingIndicator(size: 32)),
          error: (err, st) {
            final msg = err is AppFailure ? err.message : err.toString();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Erreur routing: $msg',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyMedium?.copyWith(color: scheme.error),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () =>
                      ref.invalidate(routeProvider(effectiveRequest)),
                  child: const Text('Réessayer'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/itinerary'),
                  child: const Text('Retour à l’itinéraire'),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  List<Widget> _buildPointRows(List<RoutePoint> points) {
    if (points.isEmpty) {
      return const [ListTile(dense: true, title: Text('Aucun point'))];
    }

    const headCount = 10;
    const tailCount = 10;

    final showAll = points.length <= headCount + tailCount + 1;
    final visible = <_PointRow>[];

    if (showAll) {
      for (var i = 0; i < points.length; i++) {
        visible.add(_PointRow(index: i, point: points[i]));
      }
    } else {
      for (var i = 0; i < headCount; i++) {
        visible.add(_PointRow(index: i, point: points[i]));
      }
      visible.add(_PointRow.skipped(points.length - headCount - tailCount));
      for (var i = points.length - tailCount; i < points.length; i++) {
        visible.add(_PointRow(index: i, point: points[i]));
      }
    }

    return visible
        .map(
          (r) => r.isSkipped
              ? ListTile(
                  dense: true,
                  title: Text('${r.skippedCount} points masqués'),
                )
              : () {
                  final idx = r.index;
                  final p = r.point;
                  if (idx == null || p == null) {
                    return const SizedBox.shrink();
                  }
                  return ListTile(
                    dense: true,
                    title: Text('Point ${idx + 1}'),
                    subtitle: Text(
                      '${p.latitude.toStringAsFixed(5)}, ${p.longitude.toStringAsFixed(5)}',
                    ),
                  );
                }(),
        )
        .toList();
  }
}

class _PointRow {
  const _PointRow({required this.index, required this.point})
    : skippedCount = null;

  const _PointRow.skipped(this.skippedCount) : index = null, point = null;
  final int? index;
  final RoutePoint? point;
  final int? skippedCount;

  bool get isSkipped => skippedCount != null;
}

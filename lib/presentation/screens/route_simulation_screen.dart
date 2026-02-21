import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_models.dart';
import '../../domain/models/user_profile.dart';
import '../../domain/failures/app_failure.dart';
import 'package:go_router/go_router.dart';
import '../providers/profile_provider.dart';
import '../providers/route_provider.dart';
import '../providers/weather_timeline_provider.dart';
import '../widgets/weather_timeline.dart';

class RouteSimulationScreen extends ConsumerWidget {
  final RouteRequest? request;

  const RouteSimulationScreen({super.key, this.request});

  String _profileToRoutingCosting(ProfileType type) {
    switch (type) {
      case ProfileType.cyclist:
        return 'cyclist';
      case ProfileType.hiker:
        return 'hiker';
      case ProfileType.driver:
        return 'driver';
      default:
        return 'driver';
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profile = ref.watch(profileNotifierProvider);

    final effectiveRequest = request ??
        RouteRequest(
          startLat: 48.8566,
          startLng: 2.3522,
          endLat: 48.8049,
          endLng: 2.1204,
          profile: _profileToRoutingCosting(profile.type),
        );

    final routeAsync = ref.watch(routeProvider(effectiveRequest));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Météo sur le trajet'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          TextButton(
            onPressed: () => context.go('/planning'),
            child: const Text('Replanifier'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: routeAsync.when(
          data: (route) {
            final weatherAsync = ref.watch(weatherTimelineProvider(route));
            final pointRows = _buildPointRows(route.points);

            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            profile.name,
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          Text('Distance: ${route.distanceKm.toStringAsFixed(1)} km'),
                          Text('Durée: ${route.durationMinutes.toStringAsFixed(0)} min'),
                          Text('Points: ${route.points.length}'),
                          const SizedBox(height: 12),
                          Text(
                            'Départ: ${effectiveRequest.startLat.toStringAsFixed(5)}, ${effectiveRequest.startLng.toStringAsFixed(5)}',
                          ),
                          Text(
                            'Arrivée: ${effectiveRequest.endLat.toStringAsFixed(5)}, ${effectiveRequest.endLng.toStringAsFixed(5)}',
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Timeline météo (échantillonnage du trajet)',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  weatherAsync.when(
                    data: (conditions) => WeatherTimeline(conditions: conditions),
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (err, st) {
                      final msg = err is AppFailure ? err.message : err.toString();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Erreur météo: $msg'),
                          const SizedBox(height: 8),
                          OutlinedButton(
                            onPressed: () => ref.invalidate(weatherTimelineProvider(route)),
                            child: const Text('Réessayer'),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 24),
                  const Text(
                    'Aperçu des points',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Card(
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Column(children: pointRows),
                    ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton(
                      onPressed: () => context.go('/planning'),
                      child: const Text('Modifier le trajet'),
                    ),
                  ),
                ],
              ),
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (err, st) {
            final msg = err is AppFailure ? err.message : err.toString();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Erreur routing: $msg'),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => ref.invalidate(routeProvider(effectiveRequest)),
                  child: const Text('Réessayer'),
                ),
                const SizedBox(height: 12),
                OutlinedButton(
                  onPressed: () => context.go('/planning'),
                  child: const Text('Retour à la planification'),
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
      return const [
        ListTile(
          dense: true,
          title: Text('Aucun point'),
        ),
      ];
    }

    const headCount = 10;
    const tailCount = 10;

    final showAll = points.length <= headCount + tailCount + 1;
    final visible = <_PointRow>[];

    if (showAll) {
      for (int i = 0; i < points.length; i++) {
        visible.add(_PointRow(index: i, point: points[i]));
      }
    } else {
      for (int i = 0; i < headCount; i++) {
        visible.add(_PointRow(index: i, point: points[i]));
      }
      visible.add(_PointRow.skipped(points.length - headCount - tailCount));
      for (int i = points.length - tailCount; i < points.length; i++) {
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
              : ListTile(
                  dense: true,
                  title: Text('Point ${r.index! + 1}'),
                  subtitle: Text(
                    '${r.point!.latitude.toStringAsFixed(5)}, ${r.point!.longitude.toStringAsFixed(5)}',
                  ),
                ),
        )
        .toList();
  }
}

class _PointRow {
  final int? index;
  final RoutePoint? point;
  final int? skippedCount;

  const _PointRow({required this.index, required this.point}) : skippedCount = null;

  const _PointRow.skipped(this.skippedCount)
      : index = null,
        point = null;

  bool get isSkipped => skippedCount != null;
}

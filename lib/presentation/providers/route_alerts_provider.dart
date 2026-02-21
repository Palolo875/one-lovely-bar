import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_alert.dart';
import '../../domain/usecases/evaluate_route_alerts.dart';
import 'alert_thresholds_provider.dart';
import 'profile_provider.dart';
import 'weather_timeline_eta_provider.dart';

final routeAlertsProvider = FutureProvider.autoDispose.family<List<RouteAlert>, WeatherTimelineEtaRequest>((ref, req) async {
  final profile = ref.watch(profileNotifierProvider);
  final thresholds = ref.watch(alertThresholdsProvider).values;
  final timeline = await ref.watch(weatherTimelineEtaProvider(req).future);
  return const EvaluateRouteAlerts()(profile: profile.copyWith(alertThresholds: thresholds), timeline: timeline);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/route_instruction.dart';
import '../../domain/usecases/get_route_instructions.dart';
import 'repository_providers.dart';
import 'route_provider.dart';

final routeInstructionsProvider = FutureProvider.autoDispose.family<List<RouteInstruction>, RouteRequest>((ref, req) async {
  final repo = ref.watch(routingRepositoryProvider);
  return GetRouteInstructions(repo)(
    startLat: req.startLat,
    startLng: req.startLng,
    endLat: req.endLat,
    endLng: req.endLng,
    profile: req.profile,
    waypoints: req.waypoints,
  );
});

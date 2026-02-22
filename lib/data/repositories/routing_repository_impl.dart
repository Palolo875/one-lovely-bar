import 'dart:convert';
import 'package:dio/dio.dart';
import '../../domain/failures/app_failure.dart';
import '../../domain/models/route_instruction.dart';
import '../../domain/models/route_models.dart';
import '../../domain/repositories/routing_repository.dart';

class ValhallaRoutingRepository implements RoutingRepository {
  final Dio _dio;

  ValhallaRoutingRepository(this._dio);

  Map<String, dynamic>? _asMap(dynamic v) {
    if (v is Map<String, dynamic>) return v;
    if (v is Map) return Map<String, dynamic>.from(v);
    return null;
  }

  List<dynamic>? _asList(dynamic v) {
    if (v is List) return v;
    return null;
  }

  double _asDouble(dynamic v, {double fallback = 0.0}) {
    if (v is num) return v.toDouble();
    return fallback;
  }

  Map<String, dynamic> _buildRequestJson({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  }) {
    final locations = <Map<String, dynamic>>[
      {'lat': startLat, 'lon': startLng},
      ...?waypoints?.map((p) => {'lat': p.latitude, 'lon': p.longitude}),
      {'lat': endLat, 'lon': endLng},
    ];

    return {
      'locations': locations,
      'costing': _mapProfileToCosting(profile),
      'units': 'kilometers',
    };
  }

  Future<Response> _callValhalla(Map<String, dynamic> requestJson) async {
    return _dio.get(
      'https://valhalla.openstreetmap.de/route',
      queryParameters: {
        'json': jsonEncode(requestJson),
      },
    );
  }

  @override
  Future<RouteData> getRoute({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  }) async {
    late final Response response;
    try {
      response = await _callValhalla(
        _buildRequestJson(
          startLat: startLat,
          startLng: startLng,
          endLat: endLat,
          endLng: endLng,
          profile: profile,
          waypoints: waypoints,
        ),
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de calculer l’itinéraire.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors du calcul de l’itinéraire.', cause: e);
    }

    final parsed = () {
      try {
        final data = _asMap(response.data);
        if (data == null) {
          throw const FormatException('Invalid Valhalla response root');
        }

        final trip = _asMap(data['trip']) ?? const <String, dynamic>{};
        final summary = _asMap(trip['summary']) ?? const <String, dynamic>{};

        final distanceKm = _asDouble(summary['length']);
        final durationSeconds = _asDouble(summary['time']);

        final legs = _asList(trip['legs']) ?? const <dynamic>[];
        final leg0 = legs.isNotEmpty ? _asMap(legs.first) : null;
        final shape = leg0 == null ? null : leg0['shape']?.toString();

        final decoded = shape == null
            ? <RoutePoint>[
                RoutePoint(latitude: startLat, longitude: startLng),
                RoutePoint(latitude: endLat, longitude: endLng),
              ]
            : _decodeValhallaPolyline(shape);

        final points = decoded.isEmpty
            ? <RoutePoint>[
                RoutePoint(latitude: startLat, longitude: startLng),
                RoutePoint(latitude: endLat, longitude: endLng),
              ]
            : decoded;

        return (points: points, distanceKm: distanceKm, durationSeconds: durationSeconds);
      } catch (e) {
        throw AppFailure('Réponse itinéraire invalide.', cause: e);
      }
    }();

    return RouteData(
      points: parsed.points,
      distanceKm: parsed.distanceKm,
      durationMinutes: parsed.durationSeconds / 60.0,
      profile: profile,
    );
  }

  @override
  Future<List<RouteInstruction>> getRouteInstructions({
    required double startLat,
    required double startLng,
    required double endLat,
    required double endLng,
    required String profile,
    List<RoutePoint>? waypoints,
  }) async {
    late final Response response;
    try {
      response = await _callValhalla(
        _buildRequestJson(
          startLat: startLat,
          startLng: startLng,
          endLat: endLat,
          endLng: endLng,
          profile: profile,
          waypoints: waypoints,
        ),
      );
    } on DioException catch (e) {
      throw AppFailure('Impossible de récupérer les instructions.', cause: e);
    } catch (e) {
      throw AppFailure('Erreur inattendue lors de la récupération des instructions.', cause: e);
    }

    final data = _asMap(response.data);
    if (data == null) {
      throw AppFailure('Réponse instructions invalide.', cause: const FormatException('Invalid Valhalla response root'));
    }
    final trip = _asMap(data['trip']) ?? const <String, dynamic>{};
    final legs = _asList(trip['legs']) ?? const <dynamic>[];

    final instructions = <RouteInstruction>[];
    for (final leg in legs) {
      final legMap = _asMap(leg);
      if (legMap == null) continue;
      final maneuvers = _asList(legMap['maneuvers']);
      if (maneuvers == null) continue;

      for (final m in maneuvers) {
        final mm = _asMap(m);
        if (mm == null) continue;
        final instr = mm['instruction']?.toString();
        if (instr == null || instr.trim().isEmpty) continue;

        final len = mm['length'];
        final time = mm['time'];

        instructions.add(
          RouteInstruction(
            instruction: instr,
            distanceKm: len is num ? len.toDouble() : null,
            timeSeconds: time is num ? time.toDouble() : null,
          ),
        );
      }
    }

    return instructions;
  }

  List<RoutePoint> _decodeValhallaPolyline(String encoded) {
    final points6 = _decodePolyline(encoded, precision: 6);
    if (points6.isNotEmpty) {
      final p0 = points6.first;
      if (p0.latitude.abs() <= 90 && p0.longitude.abs() <= 180) {
        return points6;
      }
    }
    final points5 = _decodePolyline(encoded, precision: 5);
    return points5;
  }

  List<RoutePoint> _decodePolyline(String encoded, {required int precision}) {
    final factor = 1 / (pow10(precision));
    int index = 0;
    int lat = 0;
    int lng = 0;
    final coordinates = <RoutePoint>[];

    try {
      while (index < encoded.length) {
        final latResult = _decodePolylineValue(encoded, index);
        index = latResult.nextIndex;
        lat += latResult.delta;

        if (index >= encoded.length) break;

        final lngResult = _decodePolylineValue(encoded, index);
        index = lngResult.nextIndex;
        lng += lngResult.delta;

        coordinates.add(RoutePoint(
          latitude: lat * factor,
          longitude: lng * factor,
        ));
      }
    } catch (_) {
      return const <RoutePoint>[];
    }

    return coordinates;
  }

  _PolylineDelta _decodePolylineValue(String encoded, int startIndex) {
    int index = startIndex;
    int result = 0;
    int shift = 0;
    int b;
    do {
      if (index >= encoded.length) {
        throw const FormatException('Invalid polyline');
      }
      b = encoded.codeUnitAt(index++) - 63;
      result |= (b & 0x1f) << shift;
      shift += 5;
    } while (b >= 0x20 && index < encoded.length);

    final delta = ((result & 1) != 0) ? ~(result >> 1) : (result >> 1);
    return _PolylineDelta(delta: delta, nextIndex: index);
  }

  double pow10(int precision) {
    double v = 1;
    for (var i = 0; i < precision; i++) {
      v *= 10;
    }
    return v;
  }

  String _mapProfileToCosting(String profile) {
    switch (profile) {
      case 'cyclist': return 'bicycle';
      case 'hiker': return 'pedestrian';
      case 'driver': return 'auto';
      default: return 'auto';
    }
  }
}

class _PolylineDelta {
  final int delta;
  final int nextIndex;

  const _PolylineDelta({required this.delta, required this.nextIndex});
}

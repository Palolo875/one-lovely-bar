import 'dart:math';

import 'package:maplibre_gl/maplibre_gl.dart';

class GuidanceProgressController {
  List<LatLng> _points = const <LatLng>[];
  List<double> _cumMeters = const <double>[];
  double _totalMeters = 0;
  int _nearestIndex = 0;

  List<double> get cumMeters => _cumMeters;
  double get totalMeters => _totalMeters;
  int get nearestIndex => _nearestIndex;

  double get progressedMeters {
    final cum = _cumMeters;
    final idx = _nearestIndex;
    if (cum.isEmpty || idx < 0 || idx >= cum.length) return 0;
    return cum[idx];
  }

  void reset() {
    _points = const <LatLng>[];
    _cumMeters = const <double>[];
    _totalMeters = 0;
    _nearestIndex = 0;
  }

  void setRoutePoints(List<LatLng> points) {
    _points = points;
    _nearestIndex = 0;

    if (points.length < 2) {
      _cumMeters = const <double>[0];
      _totalMeters = 0;
      return;
    }

    final cum = <double>[0];
    var sum = 0.0;
    for (var i = 1; i < points.length; i++) {
      sum += _haversineMeters(points[i - 1], points[i]);
      cum.add(sum);
    }

    _cumMeters = cum;
    _totalMeters = sum;
  }

  bool updateUserPosition(
    LatLng user, {
    int searchBack = 50,
    int searchForward = 200,
  }) {
    final pts = _points;
    if (pts.isEmpty) return false;

    final current = _nearestIndex;
    final start = max(0, current - searchBack);
    final end = min(pts.length - 1, current + searchForward);

    var bestIdx = current.clamp(0, pts.length - 1);
    var best = double.infinity;

    for (var i = start; i <= end; i++) {
      final d = _haversineMeters(user, pts[i]);
      if (d < best) {
        best = d;
        bestIdx = i;
      }
    }

    if (bestIdx != _nearestIndex) {
      _nearestIndex = bestIdx;
      return true;
    }
    return false;
  }

  double remainingMeters({double? fallbackTotalMeters}) {
    final total = _totalMeters > 0 ? _totalMeters : (fallbackTotalMeters ?? 0);
    final progressed = progressedMeters;
    return (total - progressed).clamp(0.0, total);
  }

  double _haversineMeters(LatLng a, LatLng b) {
    const r = 6371000.0;
    final dLat = _toRad(b.latitude - a.latitude);
    final dLon = _toRad(b.longitude - a.longitude);
    final lat1 = _toRad(a.latitude);
    final lat2 = _toRad(b.latitude);

    final sinDLat = sin(dLat / 2);
    final sinDLon = sin(dLon / 2);

    final h = sinDLat * sinDLat + cos(lat1) * cos(lat2) * sinDLon * sinDLon;
    final c = 2 * atan2(sqrt(h), sqrt(1 - h));
    return r * c;
  }

  double _toRad(double deg) => deg * (pi / 180.0);
}

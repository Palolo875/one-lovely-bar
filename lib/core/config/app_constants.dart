import 'package:maplibre_gl/maplibre_gl.dart';

/// Application-wide constants shared across multiple screens.
class AppConstants {
  /// Default map center (Paris).
  static const LatLng defaultCenter = LatLng(48.8566, 2.3522);

  /// Default end point used as placeholder (Versailles).
  static const LatLng defaultEnd = LatLng(48.8049, 2.1204);

  /// Hex color used for route polylines on the map.
  static const String routeLineColor = '#2563EB';

  /// Default route line width.
  static const double routeLineWidth = 5;

  /// Route line width during guidance.
  static const double guidanceLineWidth = 6;

  /// Route line opacity.
  static const double routeLineOpacity = 0.85;

  /// Guidance route line opacity.
  static const double guidanceLineOpacity = 0.9;
}

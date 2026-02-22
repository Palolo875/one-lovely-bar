import 'package:maplibre_gl/maplibre_gl.dart';

class MapLibreCameraUtils {
  const MapLibreCameraUtils._();

  static Future<void> animateCameraCompat(
    MapLibreMapController controller,
    CameraUpdate update,
  ) async {
    final dyn = controller as dynamic;
    await dyn.animateCamera(update);
  }

  static Future<void> moveCameraCompat(
    MapLibreMapController controller,
    CameraUpdate update,
  ) async {
    final dyn = controller as dynamic;
    await dyn.moveCamera(update);
  }
}

import 'package:weathernav/domain/models/poi.dart';

abstract class PoiRepository {
  Future<List<Poi>> searchAround({
    required double lat,
    required double lng,
    required int radiusMeters,
    required Set<PoiCategory> categories,
    int limit = 50,
  });
}

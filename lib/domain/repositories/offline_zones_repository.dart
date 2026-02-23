import 'package:weathernav/domain/models/offline_zone.dart';

abstract class OfflineZonesRepository {
  List<OfflineZone> read();

  Stream<List<OfflineZone>> watch();

  Future<void> save(List<OfflineZone> zones);
}

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/data/repositories/offline_zones_repository_impl.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

final offlineZonesRepositoryProvider = Provider<OfflineZonesRepository>((ref) {
  final settings = ref.watch(settingsRepositoryProvider);
  return OfflineZonesRepositoryImpl(settings);
});

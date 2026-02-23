import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/data/repositories/cache_repository_hive.dart';
import 'package:weathernav/domain/repositories/cache_repository.dart';

final cacheRepositoryProvider = Provider<CacheRepository>((ref) {
  return HiveCacheRepository();
});

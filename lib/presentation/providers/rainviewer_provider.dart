import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weathernav/data/repositories/rainviewer_repository_impl.dart';
import 'package:weathernav/domain/repositories/rainviewer_repository.dart';
import 'package:weathernav/presentation/providers/cache_repository_provider.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

part 'rainviewer_provider.g.dart';

@riverpod
RainViewerRepository rainViewerRepository(Ref ref) {
  return RainViewerRepositoryImpl(
    ref.watch(dioProvider),
    ref.watch(cacheRepositoryProvider),
    legacy: ref.watch(settingsRepositoryProvider),
  );
}

@riverpod
Future<int?> rainViewerLatestTime(Ref ref) async {
  final repo = ref.watch(rainViewerRepositoryProvider);
  return repo.getLatestRadarTime();
}

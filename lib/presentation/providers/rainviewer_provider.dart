import 'package:weathernav/presentation/providers/repository_providers.dart';
import 'package:weathernav/data/repositories/rainviewer_repository_impl.dart';
import 'package:weathernav/domain/repositories/rainviewer_repository.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'rainviewer_provider.g.dart';

@riverpod
RainViewerRepository rainViewerRepository(RainViewerRepositoryRef ref) {
  return RainViewerRepositoryImpl(ref.watch(dioProvider), ref.watch(settingsRepositoryProvider));
}

@riverpod
Future<int?> rainViewerLatestTime(RainViewerLatestTimeRef ref) async {
  final repo = ref.watch(rainViewerRepositoryProvider);
  return repo.getLatestRadarTime();
}

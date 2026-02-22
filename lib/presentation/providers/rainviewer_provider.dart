import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';
import 'package:weathernav/data/repositories/rainviewer_repository_impl.dart';
import 'package:weathernav/domain/repositories/rainviewer_repository.dart';

final rainViewerRepositoryProvider = Provider.autoDispose<RainViewerRepository>((ref) {
  return RainViewerRepositoryImpl(ref.watch(dioProvider));
});

final rainViewerLatestTimeProvider = FutureProvider.autoDispose<int?>((ref) async {
  final repo = ref.watch(rainViewerRepositoryProvider);
  return repo.getLatestRadarTime();
});

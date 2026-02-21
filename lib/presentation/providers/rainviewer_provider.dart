import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'repository_providers.dart';
import '../../data/repositories/rainviewer_repository_impl.dart';
import '../../domain/repositories/rainviewer_repository.dart';

final rainViewerRepositoryProvider = Provider.autoDispose<RainViewerRepository>((ref) {
  return RainViewerRepositoryImpl(ref.watch(dioProvider));
});

final rainViewerLatestTimeProvider = FutureProvider.autoDispose<int?>((ref) async {
  final repo = ref.watch(rainViewerRepositoryProvider);
  return repo.getLatestRadarTime();
});

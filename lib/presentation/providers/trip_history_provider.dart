import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/repositories/trip_history_repository_impl.dart';
import '../../domain/models/trip_history_item.dart';
import '../../domain/repositories/trip_history_repository.dart';

final tripHistoryRepositoryProvider = Provider.autoDispose<TripHistoryRepository>((ref) {
  return createTripHistoryRepository();
});

final tripHistoryListProvider = FutureProvider.autoDispose<List<TripHistoryItem>>((ref) async {
  final repo = ref.watch(tripHistoryRepositoryProvider);
  return repo.listTrips();
});

final tripHistoryItemProvider = FutureProvider.autoDispose.family<TripHistoryItem?, int>((ref, id) async {
  final repo = ref.watch(tripHistoryRepositoryProvider);
  return repo.getTrip(id);
});

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/data/repositories/trip_history_repository_impl.dart';
import 'package:weathernav/domain/models/trip_history_item.dart';
import 'package:weathernav/domain/repositories/trip_history_repository.dart';

final tripHistoryRepositoryProvider = Provider<TripHistoryRepository>((ref) {
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

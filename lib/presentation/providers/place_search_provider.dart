import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/place_suggestion.dart';
import 'repository_providers.dart';

final placeSearchProvider = FutureProvider.autoDispose.family<List<PlaceSuggestion>, String>((ref, query) async {
  final repo = ref.watch(geocodingRepositoryProvider);
  return repo.search(query);
});

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:weathernav/domain/models/place_suggestion.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';

part 'place_search_provider.g.dart';

@riverpod
Future<List<PlaceSuggestion>> placeSearch(PlaceSearchRef ref, String query) async {
  final repo = ref.watch(geocodingRepositoryProvider);
  return repo.search(query);
}

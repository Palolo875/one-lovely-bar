import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:weathernav/data/repositories/poi_repository_impl.dart';
import 'package:weathernav/domain/models/poi.dart';
import 'package:weathernav/domain/repositories/poi_repository.dart';
import 'package:weathernav/domain/failures/app_failure.dart';
import 'package:weathernav/presentation/providers/repository_providers.dart';
import 'package:weathernav/presentation/providers/cache_repository_provider.dart';
import 'package:weathernav/presentation/providers/settings_repository_provider.dart';

class PoiRequest {

  const PoiRequest({
    required this.lat,
    required this.lng,
    required this.radiusMeters,
    required this.categories,
  });
  final double lat;
  final double lng;
  final int radiusMeters;
  final Set<PoiCategory> categories;

  @override
  bool operator ==(Object other) {
    return other is PoiRequest &&
        other.lat == lat &&
        other.lng == lng &&
        other.radiusMeters == radiusMeters &&
        _setEquals(other.categories, categories);
  }

  @override
  int get hashCode => Object.hash(lat, lng, radiusMeters, _setHash(categories));
}

bool _setEquals(Set<PoiCategory> a, Set<PoiCategory> b) {
  if (a.length != b.length) return false;
  for (final x in a) {
    if (!b.contains(x)) return false;
  }
  return true;
}

int _setHash(Set<PoiCategory> s) {
  var h = 0;
  for (final x in s) {
    h = 0x1fffffff & (h + x.hashCode);
  }
  return h;
}

final poiRepositoryProvider = Provider<PoiRepository>((ref) {
  return OverpassPoiRepository(ref.watch(dioProvider));
});

final poiSearchProvider = FutureProvider.autoDispose.family<List<Poi>, PoiRequest>((ref, req) async {
  final repo = ref.watch(poiRepositoryProvider);

  final cache = ref.watch(cacheRepositoryProvider);
  final legacy = ref.watch(settingsRepositoryProvider);

  const ttl = Duration(minutes: 10);

  String cacheKey() {
    final cats = req.categories.map((c) => c.name).toList()..sort();
    return 'pois:${req.lat.toStringAsFixed(3)},${req.lng.toStringAsFixed(3)}:${req.radiusMeters}:${cats.join(',')}';
  }

  List<Poi>? readCache({required bool freshOnly}) {
    final key = cacheKey();
    final raw = cache.get<Object?>(key) ?? legacy.get<Object?>(key);
    if (raw is! Map) return null;
    final ts = raw['ts'];
    final data = raw['data'];
    if (ts is! int || data is! List) return null;
    if (freshOnly) {
      final age = DateTime.now().difference(DateTime.fromMillisecondsSinceEpoch(ts));
      if (age > ttl) return null;
    }

    final out = <Poi>[];
    for (final m in data) {
      if (m is! Map) continue;
      final mm = Map<String, Object?>.from(m as Map);
      final id = mm['id']?.toString();
      final name = mm['name']?.toString();
      final lat = mm['lat'];
      final lng = mm['lng'];
      final cat = mm['category']?.toString();
      if (id == null || name == null || lat is! num || lng is! num || cat == null) continue;
      final match = PoiCategory.values.where((c) => c.name == cat).toList();
      if (match.isEmpty) continue;
      out.add(
        Poi(
          id: id,
          name: name,
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
          category: match.first,
        ),
      );
    }
    return out;
  }

  void writeCache(List<Poi> list) {
    cache.put(cacheKey(), {
      'ts': DateTime.now().millisecondsSinceEpoch,
      'data': list
          .map(
            (p) => {
              'id': p.id,
              'name': p.name,
              'lat': p.latitude,
              'lng': p.longitude,
              'category': p.category.name,
            },
          )
          .toList(),
    });
  }

  final cached = readCache(freshOnly: true);
  if (cached != null) return cached;

  try {
    final result = await repo.searchAround(
      lat: req.lat,
      lng: req.lng,
      radiusMeters: req.radiusMeters,
      categories: req.categories,
    );
    writeCache(result);
    return result;
  } on AppFailure {
    final stale = readCache(freshOnly: false);
    if (stale != null) return stale;
    rethrow;
  } catch (e, st) {
    final stale = readCache(freshOnly: false);
    if (stale != null) return stale;
    throw AppFailure('Impossible de charger les POIs.', cause: e, stackTrace: st);
  }
});

class PoiFilterState {

  const PoiFilterState({
    required this.enabled,
    required this.categories,
    required this.radiusMeters,
  });
  final bool enabled;
  final Set<PoiCategory> categories;
  final int radiusMeters;

  PoiFilterState copyWith({bool? enabled, Set<PoiCategory>? categories, int? radiusMeters}) {
    return PoiFilterState(
      enabled: enabled ?? this.enabled,
      categories: categories ?? this.categories,
      radiusMeters: radiusMeters ?? this.radiusMeters,
    );
  }
}

class PoiFilterNotifier extends StateNotifier<PoiFilterState> {
  PoiFilterNotifier()
      : super(
          const PoiFilterState(
            enabled: false,
            categories: {PoiCategory.shelter, PoiCategory.hut},
            radiusMeters: 2500,
          ),
        );

  void toggleEnabled() => state = state.copyWith(enabled: !state.enabled);

  void toggleCategory(PoiCategory c) {
    final next = Set<PoiCategory>.from(state.categories);
    if (next.contains(c)) {
      next.remove(c);
    } else {
      next.add(c);
    }
    state = state.copyWith(categories: next);
  }

  void setRadius(int meters) => state = state.copyWith(radiusMeters: meters);
}

final poiFilterProvider = StateNotifierProvider<PoiFilterNotifier, PoiFilterState>((ref) {
  return PoiFilterNotifier();
});

import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/presentation/providers/offline_zones_repository_provider.dart';

class OfflineZonesNotifier extends StateNotifier<List<OfflineZone>> {
  OfflineZonesNotifier(this._repo) : super(_repo.read()) {
    var syncScheduled = false;
    void sync() {
      final next = _repo.read();
      if (!_same(next, state)) state = next;
    }

    void scheduleSync() {
      if (syncScheduled) return;
      syncScheduled = true;
      scheduleMicrotask(() {
        syncScheduled = false;
        sync();
      });
    }

    _sub = _repo.watch().listen((_) => scheduleSync());
  }
  final OfflineZonesRepository _repo;
  StreamSubscription<List<OfflineZone>>? _sub;
  Future<void> _persistQueue = Future<void>.value();
  static final Random _rng = Random.secure();

  static bool _same(List<OfflineZone> a, List<OfflineZone> b) {
    return listEquals(a, b);
  }

  Future<void> _persist(List<OfflineZone> list) {
    _persistQueue = _persistQueue.then((_) async {
      try {
        await _repo.save(list);
      } catch (e, st) {
        AppLogger.error('Failed to persist offline zones', name: 'settings', error: e, stackTrace: st);
        final next = _repo.read();
        if (!_same(next, state)) state = next;
      }
    });
    return _persistQueue;
  }

  bool add({required String name, required double lat, required double lng, required double radiusKm}) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return false;
    if (lat.isNaN || lng.isNaN || radiusKm.isNaN) return false;
    if (lat < -90 || lat > 90) return false;
    if (lng < -180 || lng > 180) return false;
    if (radiusKm <= 0) return false;

    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}_${_rng.nextInt(1 << 32)}';
    final next = [
      OfflineZone(
        id: id,
        name: trimmedName,
        lat: lat,
        lng: lng,
        radiusKm: radiusKm,
        createdAt: now,
      ),
      ...state,
    ];
    state = next;
    unawaited(_persist(next));
    return true;
  }

  void remove(String id) {
    final next = state.where((z) => z.id != id).toList();
    state = next;
    unawaited(_persist(next));
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

final offlineZonesProvider = StateNotifierProvider<OfflineZonesNotifier, List<OfflineZone>>((ref) {
  final repo = ref.watch(offlineZonesRepositoryProvider);
  return OfflineZonesNotifier(repo);
});

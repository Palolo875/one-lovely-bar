import 'dart:async';
import 'dart:math';

import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:weathernav/core/logging/app_logger.dart';
import 'package:weathernav/core/storage/settings_keys.dart';
import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/presentation/providers/offline_zones_repository_provider.dart';

part 'offline_zones_provider.freezed.dart';

@freezed
class OfflineZonesState with _$OfflineZonesState {
  const factory OfflineZonesState({
    @Default([]) List<OfflineZone> zones,
    @Default(false) bool isLoading,
    String? error,
  }) = _OfflineZonesState;

  const OfflineZonesState._();

  bool get hasError => error != null;
  bool get isEmpty => zones.isEmpty;
  int get zoneCount => zones.length;
}

class OfflineZonesNotifier extends AsyncNotifier<OfflineZonesState> {
  late final OfflineZonesRepository _repo;
  StreamSubscription<List<OfflineZone>>? _subscription;
  static final Random _rng = Random.secure();

  @override
  Future<OfflineZonesState> build() async {
    _repo = ref.watch(offlineZonesRepositoryProvider);

    try {
      final zones = await _loadInitialZones();
      _setupWatchListener();
      return OfflineZonesState(zones: zones);
    } catch (e, st) {
      AppLogger.error(
        'Failed to initialize offline zones',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );
      return OfflineZonesState(error: 'Failed to load offline zones: ${e}');
    }
  }

  Future<List<OfflineZone>> _loadInitialZones() async {
    try {
      return await Future.value(_repo.read());
    } catch (e, st) {
      AppLogger.error(
        'Failed to load initial zones',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );
      rethrow;
    }
  }

  void _setupWatchListener() {
    _subscription = _repo.watch().listen(
      _handleExternalChange,
      onError: (e, st) {
        AppLogger.error(
          'Error in zones watch stream',
          name: 'OfflineZonesNotifier',
          error: e,
          stackTrace: st,
        );
        state = AsyncValue.data(
          state.value?.copyWith(error: 'Sync error: ${e}') ??
              OfflineZonesState(error: 'Sync error: ${e}'),
        );
      },
    );
  }

  void _handleExternalChange(List<OfflineZone> zones) {
    if (state.value == null) return;

    if (!_same(zones, state.value!.zones)) {
      state = AsyncValue.data(state.value!.copyWith(zones: zones, error: null));
    }
  }

  static bool _same(List<OfflineZone> a, List<OfflineZone> b) {
    return listEquals(a, b);
  }

  Future<void> _persist(List<OfflineZone> zones) async {
    try {
      await _repo.save(zones);
      AppLogger.info(
        'Successfully persisted ${zones.length} offline zones',
        name: 'OfflineZonesNotifier',
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to persist offline zones',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );

      try {
        final currentZones = await _loadInitialZones();
        if (!_same(currentZones, state.value?.zones)) {
          state = AsyncValue.data(
            state.value?.copyWith(
                  zones: currentZones,
                  error: 'Failed to save changes',
                ) ??
                const OfflineZonesState(error: 'Failed to save changes'),
          );
        }
      } catch (recoveryError) {
        state = AsyncValue.data(
          state.value?.copyWith(error: 'Failed to save and sync data') ??
              const OfflineZonesState(error: 'Failed to save and sync data'),
        );
      }
    }
  }

  Future<bool> add({
    required String name,
    required double lat,
    required double lng,
    required double radiusKm,
  }) async {
    if (state.value == null) {
      AppLogger.warning(
        'Attempted to add zone while not initialized',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    final validationError = _validateZoneData(name, lat, lng, radiusKm);
    if (validationError != null) {
      AppLogger.warning(
        'Invalid zone data: $validationError',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    try {
      final newZone = _createZone(name, lat, lng, radiusKm);
      final updatedZones = [newZone, ...state.value!.zones];

      state = AsyncValue.data(
        state.value!.copyWith(
          zones: updatedZones,
          isLoading: true,
          error: null,
        ),
      );

      await _persist(updatedZones);

      state = AsyncValue.data(state.value!.copyWith(isLoading: false));

      AppLogger.info(
        'Successfully added offline zone: ${newZone.name}',
        name: 'OfflineZonesNotifier',
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to add offline zone',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.data(
        state.value!.copyWith(isLoading: false, error: 'Failed to add zone'),
      );
      return false;
    }
  }

  String? _validateZoneData(
    String name,
    double lat,
    double lng,
    double radiusKm,
  ) {
    final trimmedName = name.trim();
    if (trimmedName.isEmpty) return 'Name cannot be empty';
    if (trimmedName.length > 100) return 'Name too long (max 100 characters)';

    if (lat.isNaN || lng.isNaN || radiusKm.isNaN)
      return 'Invalid coordinates or radius';
    if (lat < -90 || lat > 90) return 'Latitude must be between -90 and 90';
    if (lng < -180 || lng > 180)
      return 'Longitude must be between -180 and 180';
    if (radiusKm <= 0 || radiusKm > 1000)
      return 'Radius must be between 0 and 1000 km';

    return null;
  }

  OfflineZone _createZone(
    String name,
    double lat,
    double lng,
    double radiusKm,
  ) {
    final now = DateTime.now();
    final id = '${now.microsecondsSinceEpoch}_${_rng.nextInt(1 << 32)}';

    return OfflineZone(
      id: id,
      name: name.trim(),
      lat: lat,
      lng: lng,
      radiusKm: radiusKm,
      createdAt: now,
    );
  }

  Future<bool> remove(String id) async {
    if (state.value == null) {
      AppLogger.warning(
        'Attempted to remove zone while not initialized',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    final zoneToRemove = state.value!.zones
        .where((z) => z.id == id)
        .firstOrNull;
    if (zoneToRemove == null) {
      AppLogger.warning(
        'Zone not found for removal: $id',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    try {
      final updatedZones = state.value!.zones.where((z) => z.id != id).toList();

      state = AsyncValue.data(
        state.value!.copyWith(
          zones: updatedZones,
          isLoading: true,
          error: null,
        ),
      );

      await _persist(updatedZones);

      state = AsyncValue.data(state.value!.copyWith(isLoading: false));

      AppLogger.info(
        'Successfully removed offline zone: ${zoneToRemove.name}',
        name: 'OfflineZonesNotifier',
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to remove offline zone',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.data(
        state.value!.copyWith(isLoading: false, error: 'Failed to remove zone'),
      );
      return false;
    }
  }

  @override
  Future<bool> update(
    String id, {
    String? name,
    double? lat,
    double? lng,
    double? radiusKm,
  }) async {
    if (state.value == null) {
      AppLogger.warning(
        'Attempted to update zone while not initialized',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    final existingZone = state.value!.zones
        .where((z) => z.id == id)
        .firstOrNull;
    if (existingZone == null) {
      AppLogger.warning(
        'Zone not found for update: $id',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    final updatedZone = OfflineZone(
      id: existingZone.id,
      name: name?.trim() ?? existingZone.name,
      lat: lat ?? existingZone.lat,
      lng: lng ?? existingZone.lng,
      radiusKm: radiusKm ?? existingZone.radiusKm,
      createdAt: existingZone.createdAt,
    );

    final validationError = _validateZoneData(
      updatedZone.name,
      updatedZone.lat,
      updatedZone.lng,
      updatedZone.radiusKm,
    );
    if (validationError != null) {
      AppLogger.warning(
        'Invalid updated zone data: $validationError',
        name: 'OfflineZonesNotifier',
      );
      return false;
    }

    try {
      final updatedZones = state.value!.zones
          .map((z) => z.id == id ? updatedZone : z)
          .toList();

      state = AsyncValue.data(
        state.value!.copyWith(
          zones: updatedZones,
          isLoading: true,
          error: null,
        ),
      );

      await _persist(updatedZones);

      state = AsyncValue.data(state.value!.copyWith(isLoading: false));

      AppLogger.info(
        'Successfully updated offline zone: ${updatedZone.name}',
        name: 'OfflineZonesNotifier',
      );
      return true;
    } catch (e, st) {
      AppLogger.error(
        'Failed to update offline zone',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.data(
        state.value!.copyWith(isLoading: false, error: 'Failed to update zone'),
      );
      return false;
    }
  }

  Future<void> refresh() async {
    if (state.value == null) return;

    state = AsyncValue.data(state.value!.copyWith(isLoading: true));

    try {
      final zones = await _loadInitialZones();
      state = AsyncValue.data(
        state.value!.copyWith(zones: zones, isLoading: false, error: null),
      );
    } catch (e, st) {
      AppLogger.error(
        'Failed to refresh offline zones',
        name: 'OfflineZonesNotifier',
        error: e,
        stackTrace: st,
      );
      state = AsyncValue.data(
        state.value!.copyWith(
          isLoading: false,
          error: 'Failed to refresh data',
        ),
      );
    }
  }

  void clearError() {
    if (state.value?.hasError ?? false) {
      state = AsyncValue.data(state.value!.copyWith(error: null));
    }
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }
}

final offlineZonesProvider =
    AsyncNotifierProvider<OfflineZonesNotifier, OfflineZonesState>(
      OfflineZonesNotifier.new,
    );

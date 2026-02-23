import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/presentation/providers/offline_zones_provider.dart';

import 'offline_zones_provider_test.mocks.dart';

@GenerateMocks([OfflineZonesRepository])
void main() {
  group('OfflineZonesNotifier', () {
    late MockOfflineZonesRepository mockRepository;
    late ProviderContainer container;
    late OfflineZonesNotifier notifier;

    setUp(() {
      mockRepository = MockOfflineZonesRepository();
      container = ProviderContainer(
        overrides: [
          offlineZonesRepositoryProvider.overrideWithValue(mockRepository),
        ],
      );
      notifier = container.read(offlineZonesProvider.notifier);
    });

    tearDown(() {
      container.dispose();
    });

    group('initialization', () {
      test('should load initial zones successfully', () async {
        // Arrange
        final zones = [
          OfflineZone(
            id: '1',
            name: 'Test Zone',
            lat: 48.8566,
            lng: 2.3522,
            radiusKm: 10,
            createdAt: DateTime.now(),
          ),
        ];
        when(mockRepository.read()).thenReturn(zones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(zones));

        // Act
        final state = await notifier.build();

        // Assert
        expect(state.zones, zones);
        expect(state.isLoading, false);
        expect(state.error, null);
        verify(mockRepository.read()).called(1);
        verify(mockRepository.watch()).called(1);
      });

      test('should handle initialization error', () async {
        // Arrange
        final error = Exception('Failed to load zones');
        when(mockRepository.read()).thenThrow(error);
        when(mockRepository.watch()).thenAnswer((_) => Stream.error(error));

        // Act
        final state = await notifier.build();

        // Assert
        expect(state.zones, []);
        expect(state.isLoading, false);
        expect(state.error, contains('Failed to load offline zones'));
        verify(mockRepository.read()).called(1);
        verify(mockRepository.watch()).called(1);
      });
    });

    group('add zone', () {
      setUp(() {
        final zones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(zones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(zones));
        when(mockRepository.save(any)).thenAnswer((_) async {
          return null;
        });
      });

      test('should add valid zone successfully', () async {
        // Arrange
        final initialZones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(initialZones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(initialZones));

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.add(
          name: 'New Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
        );

        // Assert
        expect(result, true);
        verify(mockRepository.save(any)).called(1);
        
        final savedZones = verify(mockRepository.save(captureAny)).captured.single as List<OfflineZone>;
        expect(savedZones.length, 1);
        expect(savedZones.first.name, 'New Zone');
        expect(savedZones.first.lat, 48.8566);
        expect(savedZones.first.lng, 2.3522);
        expect(savedZones.first.radiusKm, 10.0);
      });

      test('should reject invalid zone data', () async {
        // Arrange
        final initialZones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(initialZones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(initialZones));

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.add(
          name: '', // Invalid empty name
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
        );

        // Assert
        expect(result, false);
        verifyNever(mockRepository.save(any));
      });

      test('should reject coordinates out of range', () async {
        // Arrange
        final initialZones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(initialZones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(initialZones));

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.add(
          name: 'Invalid Zone',
          lat: 91, // Invalid latitude
          lng: 2.3522,
          radiusKm: 10,
        );

        // Assert
        expect(result, false);
        verifyNever(mockRepository.save(any));
      });

      test('should handle save error during add', () async {
        // Arrange
        final initialZones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(initialZones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(initialZones));
        when(mockRepository.save(any)).thenThrow(Exception('Save failed'));

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.add(
          name: 'New Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
        );

        // Assert
        expect(result, false);
        verify(mockRepository.save(any)).called(1);
        
        final currentState = container.read(offlineZonesProvider);
        expect(currentState.value?.error, contains('Failed to add zone'));
      });
    });

    group('remove zone', () {
      test('should remove existing zone successfully', () async {
        // Arrange
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: DateTime.now(),
        );
        final zones = [zone];
        when(mockRepository.read()).thenReturn(zones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(zones));
        when(mockRepository.save(any)).thenAnswer((_) async {
          return null;
        });

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.remove(zone.id);

        // Assert
        expect(result, true);
        verify(mockRepository.save(any)).called(1);
        
        final savedZones = verify(mockRepository.save(captureAny)).captured.single as List<OfflineZone>;
        expect(savedZones.length, 0);
      });

      test('should return false for non-existent zone', () async {
        // Arrange
        final zones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(zones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(zones));

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.remove('non-existent');

        // Assert
        expect(result, false);
        verifyNever(mockRepository.save(any));
      });
    });

    group('update zone', () {
      test('should update existing zone successfully', () async {
        // Arrange
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: DateTime.now(),
        );
        final zones = [zone];
        when(mockRepository.read()).thenReturn(zones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(zones));
        when(mockRepository.save(any)).thenAnswer((_) async {
          return null;
        });

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.update(
          zone.id,
          name: 'Updated Zone',
          radiusKm: 15,
        );

        // Assert
        expect(result, true);
        verify(mockRepository.save(any)).called(1);
        
        final savedZones = verify(mockRepository.save(captureAny)).captured.single as List<OfflineZone>;
        expect(savedZones.length, 1);
        expect(savedZones.first.name, 'Updated Zone');
        expect(savedZones.first.radiusKm, 15.0);
        expect(savedZones.first.lat, 48.8566); // Unchanged
      });

      test('should return false for non-existent zone', () async {
        // Arrange
        final zones = <OfflineZone>[];
        when(mockRepository.read()).thenReturn(zones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(zones));

        // Initialize notifier
        await notifier.build();

        // Act
        final result = await notifier.update('non-existent', name: 'Updated');

        // Assert
        expect(result, false);
        verifyNever(mockRepository.save(any));
      });
    });

    group('refresh', () {
      test('should refresh zones successfully', () async {
        // Arrange
        final initialZones = <OfflineZone>[];
        final refreshedZones = [
          OfflineZone(
            id: '1',
            name: 'Refreshed Zone',
            lat: 48.8566,
            lng: 2.3522,
            radiusKm: 10,
            createdAt: DateTime.now(),
          ),
        ];
        
        when(mockRepository.read()).thenReturn(initialZones).thenReturn(refreshedZones);
        when(mockRepository.watch()).thenAnswer((_) => Stream.value(initialZones));

        // Initialize notifier
        await notifier.build();

        // Act
        await notifier.refresh();

        // Assert
        final currentState = container.read(offlineZonesProvider);
        expect(currentState.value?.zones.length, 1);
        expect(currentState.value?.zones.first.name, 'Refreshed Zone');
        verify(mockRepository.read()).called(2); // Initial + refresh
      });
    });

    group('clearError', () {
      test('should clear error state', () async {
        // Arrange
        when(mockRepository.read()).thenThrow(Exception('Test error'));
        when(mockRepository.watch()).thenAnswer((_) => Stream.error(Exception('Test error')));

        // Initialize notifier with error
        await notifier.build();

        // Verify error state
        var currentState = container.read(offlineZonesProvider);
        expect(currentState.value?.hasError, true);

        // Act
        notifier.clearError();

        // Assert
        currentState = container.read(offlineZonesProvider);
        expect(currentState.value?.hasError, false);
      });
    });
  });

  group('OfflineZonesState', () {
    test('should compute getters correctly', () {
      // Arrange
      final state = OfflineZonesState(
        zones: [
          OfflineZone(
            id: '1',
            name: 'Test Zone',
            lat: 48.8566,
            lng: 2.3522,
            radiusKm: 10,
            createdAt: DateTime.now(),
          ),
        ],
        isLoading: false,
      );

      // Assert
      expect(state.hasError, false);
      expect(state.isEmpty, false);
      expect(state.zoneCount, 1);
    });

    test('should handle empty state correctly', () {
      // Arrange
      const state = OfflineZonesState(
        zones: [],
        isLoading: false,
      );

      // Assert
      expect(state.hasError, false);
      expect(state.isEmpty, true);
      expect(state.zoneCount, 0);
    });

    test('should handle error state correctly', () {
      // Arrange
      const state = OfflineZonesState(
        zones: [],
        isLoading: false,
        error: 'Test error',
      );

      // Assert
      expect(state.hasError, true);
      expect(state.isEmpty, true);
      expect(state.zoneCount, 0);
    });
  });
}

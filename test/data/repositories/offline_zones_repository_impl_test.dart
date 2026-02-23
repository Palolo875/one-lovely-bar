import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:weathernav/domain/models/offline_zone.dart';
import 'package:weathernav/domain/repositories/offline_zones_repository.dart';
import 'package:weathernav/domain/repositories/settings_repository.dart';
import 'package:weathernav/data/repositories/offline_zones_repository_impl.dart';

import 'offline_zones_repository_impl_test.mocks.dart';

@GenerateMocks([SettingsRepository])
void main() {
  group('OfflineZonesRepositoryImpl', () {
    late MockSettingsRepository mockSettingsRepository;
    late OfflineZonesRepositoryImpl repository;

    setUp(() {
      mockSettingsRepository = MockSettingsRepository();
      repository = OfflineZonesRepositoryImpl(mockSettingsRepository);
    });

    group('read', () {
      test('should return empty list when no data exists', () {
        // Arrange
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(null);

        // Act
        final result = repository.read();

        // Assert
        expect(result, []);
        verify(mockSettingsRepository.get<Object?>(any)).called(1);
      });

      test('should decode valid zones data', () {
        // Arrange
        final zonesData = [
          {
            'id': '1',
            'name': 'Test Zone',
            'lat': 48.8566,
            'lng': 2.3522,
            'radiusKm': 10.0,
            'createdAtMs': DateTime.now().millisecondsSinceEpoch,
          },
        ];
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(zonesData);

        // Act
        final result = repository.read();

        // Assert
        expect(result.length, 1);
        expect(result.first.id, '1');
        expect(result.first.name, 'Test Zone');
        expect(result.first.lat, 48.8566);
        expect(result.first.lng, 2.3522);
        expect(result.first.radiusKm, 10.0);
        verify(mockSettingsRepository.get<Object?>(any)).called(1);
      });

      test('should handle invalid data format', () {
        // Arrange
        when(mockSettingsRepository.get<Object?>(any)).thenReturn('invalid data');

        // Act
        final result = repository.read();

        // Assert
        expect(result, []);
        verify(mockSettingsRepository.get<Object?>(any)).called(1);
      });

      test('should handle partial invalid data', () {
        // Arrange
        final zonesData = [
          {
            'id': '1',
            'name': 'Valid Zone',
            'lat': 48.8566,
            'lng': 2.3522,
            'radiusKm': 10.0,
            'createdAtMs': DateTime.now().millisecondsSinceEpoch,
          },
          {
            'id': '2',
            'name': '', // Invalid empty name
            'lat': 48.8566,
            'lng': 2.3522,
            'radiusKm': 10.0,
            'createdAtMs': DateTime.now().millisecondsSinceEpoch,
          },
        ];
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(zonesData);

        // Act
        final result = repository.read();

        // Assert
        expect(result.length, 1); // Only valid zone should be returned
        expect(result.first.id, '1');
        verify(mockSettingsRepository.get<Object?>(any)).called(1);
      });

      test('should handle storage read errors', () {
        // Arrange
        when(mockSettingsRepository.get<Object?>(any)).thenThrow(Exception('Storage error'));

        // Act
        final result = repository.read();

        // Assert
        expect(result, []);
        verify(mockSettingsRepository.get<Object?>(any)).called(1);
      });
    });

    group('watch', () {
      test('should emit zones when data changes', () async {
        // Arrange
        final zonesData = [
          {
            'id': '1',
            'name': 'Test Zone',
            'lat': 48.8566,
            'lng': 2.3522,
            'radiusKm': 10.0,
            'createdAtMs': DateTime.now().millisecondsSinceEpoch,
          },
        ];
        final streamController = StreamController<void>();
        when(mockSettingsRepository.watch(any)).thenAnswer((_) => streamController.stream);
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(zonesData);

        // Act
        final stream = repository.watch();
        final expectStream = expectLater(stream, emits(isA<List<OfflineZone>>()));

        // Assert
        streamController.add(null);
        await expectStream;
        verify(mockSettingsRepository.watch(any)).called(1);
        verify(mockSettingsRepository.get<Object?>(any)).called(1);

        streamController.close();
      });

      test('should handle watch stream errors', () async {
        // Arrange
        final streamController = StreamController<void>();
        when(mockSettingsRepository.watch(any)).thenAnswer((_) => streamController.stream);
        when(mockSettingsRepository.get<Object?>(any)).thenReturn([]);

        // Act
        final stream = repository.watch();
        final expectStream = expectLater(stream, emits([]));

        // Assert
        streamController.addError(Exception('Stream error'));
        await expectStream;
        verify(mockSettingsRepository.watch(any)).called(1);

        streamController.close();
      });

      test('should handle watch setup errors', () {
        // Arrange
        when(mockSettingsRepository.watch(any)).thenThrow(Exception('Setup error'));

        // Act
        final stream = repository.watch();

        // Assert
        expect(stream, emits([]));
        verify(mockSettingsRepository.watch(any)).called(1);
      });
    });

    group('save', () {
      test('should save valid zones successfully', () async {
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
        when(mockSettingsRepository.put(any, any)).thenAnswer((_) async {
          return null;
        });

        // Act
        await repository.save(zones);

        // Assert
        verify(mockSettingsRepository.put(any, argThat(isA<List>()))).called(1);
        
        final capturedData = verify(mockSettingsRepository.put(captureAny, captureAny)).captured[1] as List;
        expect(capturedData.length, 1);
        expect(capturedData.first['id'], '1');
        expect(capturedData.first['name'], 'Test Zone');
      });

      test('should reject too many zones', () async {
        // Arrange
        final zones = List.generate(1001, (index) => OfflineZone(
          id: index.toString(),
          name: 'Zone $index',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: DateTime.now(),
        ));

        // Act & Assert
        expect(
          () => repository.save(zones),
          throwsA(isA<ArgumentError>()),
        );
        verifyNever(mockSettingsRepository.put(any, any));
      });

      test('should handle save errors', () async {
        // Arrange
        final zones = <OfflineZone>[];
        when(mockSettingsRepository.put(any, any)).thenThrow(Exception('Save error'));

        // Act & Assert
        expect(
          () => repository.save(zones),
          throwsA(isA<Exception>()),
        );
        verify(mockSettingsRepository.put(any, any)).called(1);
      });
    });

    group('data validation', () {
      test('should validate zone coordinates', () {
        // Arrange
        final zonesData = [
          {
            'id': '1',
            'name': 'Invalid Lat',
            'lat': 91.0, // Invalid latitude
            'lng': 2.3522,
            'radiusKm': 10.0,
            'createdAtMs': DateTime.now().millisecondsSinceEpoch,
          },
        ];
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(zonesData);

        // Act
        final result = repository.read();

        // Assert
        expect(result, []); // Invalid zone should be filtered out
      });

      test('should validate timestamp', () {
        // Arrange
        final zonesData = [
          {
            'id': '1',
            'name': 'Future Zone',
            'lat': 48.8566,
            'lng': 2.3522,
            'radiusKm': 10.0,
            'createdAtMs': DateTime.now().add(const Duration(days: 1)).millisecondsSinceEpoch, // Future timestamp
          },
        ];
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(zonesData);

        // Act
        final result = repository.read();

        // Assert
        expect(result, []); // Invalid zone should be filtered out
      });

      test('should validate radius bounds', () {
        // Arrange
        final zonesData = [
          {
            'id': '1',
            'name': 'Large Zone',
            'lat': 48.8566,
            'lng': 2.3522,
            'radiusKm': 1001.0, // Too large
            'createdAtMs': DateTime.now().millisecondsSinceEpoch,
          },
        ];
        when(mockSettingsRepository.get<Object?>(any)).thenReturn(zonesData);

        // Act
        final result = repository.read();

        // Assert
        expect(result, []); // Invalid zone should be filtered out
      });
    });
  });
}

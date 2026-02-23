import 'package:flutter_test/flutter_test.dart';

import 'package:weathernav/domain/models/offline_zone.dart';

void main() {
  group('OfflineZone', () {
    final testDateTime = DateTime(2024, 1, 1, 12, 0);

    group('creation and validation', () {
      test('should create valid zone', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone.id, '1');
        expect(zone.name, 'Test Zone');
        expect(zone.lat, 48.8566);
        expect(zone.lng, 2.3522);
        expect(zone.radiusKm, 10.0);
        expect(zone.createdAt, testDateTime);
      });

      test('should validate zone data correctly', () {
        final validZone = OfflineZone.validated(
          id: '1',
          name: 'Valid Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(validZone, isNotNull);
        expect(validZone!.name, 'Valid Zone');
      });

      test('should reject empty ID', () {
        final zone = OfflineZone.validated(
          id: '',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject empty name', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: '',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject name too long', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: 'a' * 101, // 101 characters
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject invalid latitude', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: 'Test Zone',
          lat: 91, // Invalid latitude
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject invalid longitude', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 181, // Invalid longitude
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject negative radius', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: -1, // Negative radius
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject radius too large', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 1001, // Too large
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });

      test('should reject NaN values', () {
        final zone = OfflineZone.validated(
          id: '1',
          name: 'Test Zone',
          lat: double.nan, // NaN
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone, isNull);
      });
    });

    group('copyWith', () {
      test('should create copy with updated values', () {
        final original = OfflineZone(
          id: '1',
          name: 'Original Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final updated = original.copyWith(
          name: 'Updated Zone',
          radiusKm: 15,
        );

        expect(updated.id, '1'); // Unchanged
        expect(updated.name, 'Updated Zone'); // Changed
        expect(updated.lat, 48.8566); // Unchanged
        expect(updated.lng, 2.3522); // Unchanged
        expect(updated.radiusKm, 15.0); // Changed
        expect(updated.createdAt, testDateTime); // Unchanged
      });

      test('should handle all null parameters', () {
        final original = OfflineZone(
          id: '1',
          name: 'Original Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final copy = original.copyWith();

        expect(copy, equals(original));
      });
    });

    group('contains', () {
      test('should return true for coordinates within zone', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Paris Zone',
          lat: 48.8566, // Paris coordinates
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        // Coordinates very close to Paris center
        final result = zone.contains(48.8570, 2.3526);

        expect(result, true);
      });

      test('should return false for coordinates outside zone', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Paris Zone',
          lat: 48.8566, // Paris coordinates
          lng: 2.3522,
          radiusKm: 1, // Small radius
          createdAt: testDateTime,
        );

        // Coordinates far from Paris
        final result = zone.contains(51.5074, -0.1278); // London

        expect(result, false);
      });

      test('should return true for coordinates on zone boundary', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 0,
          lng: 0,
          radiusKm: 1,
          createdAt: testDateTime,
        );

        // Coordinates approximately 1km from center
        final result = zone.contains(0.0090, 0); // ~1km north

        expect(result, true);
      });
    });

    group('areaKm2', () {
      test('should calculate correct area', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 0,
          lng: 0,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final area = zone.areaKm2;

        expect(area, closeTo(314.159, 0.001)); // π * r²
      });
    });

    group('equality', () {
      test('should be equal when all properties match', () {
        final zone1 = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final zone2 = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone1, equals(zone2));
        expect(zone1.hashCode, equals(zone2.hashCode));
      });

      test('should not be equal when properties differ', () {
        final zone1 = OfflineZone(
          id: '1',
          name: 'Zone 1',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final zone2 = OfflineZone(
          id: '2', // Different ID
          name: 'Zone 1',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        expect(zone1, isNot(equals(zone2)));
      });
    });

    group('serialization', () {
      test('should convert to JSON correctly', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final json = zone.toJson();

        expect(json['id'], '1');
        expect(json['name'], 'Test Zone');
        expect(json['lat'], 48.8566);
        expect(json['lng'], 2.3522);
        expect(json['radiusKm'], 10.0);
        expect(json['createdAtMs'], testDateTime.millisecondsSinceEpoch);
      });

      test('should create from valid JSON', () {
        final json = {
          'id': '1',
          'name': 'Test Zone',
          'lat': 48.8566,
          'lng': 2.3522,
          'radiusKm': 10.0,
          'createdAtMs': testDateTime.millisecondsSinceEpoch,
        };

        final zone = OfflineZone.fromJson(json);

        expect(zone, isNotNull);
        expect(zone!.id, '1');
        expect(zone.name, 'Test Zone');
        expect(zone.lat, 48.8566);
        expect(zone.lng, 2.3522);
        expect(zone.radiusKm, 10.0);
        expect(zone.createdAt, testDateTime);
      });

      test('should return null for invalid JSON', () {
        final json = {
          'id': '1',
          'name': 'Test Zone',
          'lat': 'invalid', // Invalid type
          'lng': 2.3522,
          'radiusKm': 10.0,
          'createdAtMs': testDateTime.millisecondsSinceEpoch,
        };

        final zone = OfflineZone.fromJson(json);

        expect(zone, isNull);
      });

      test('should return null for incomplete JSON', () {
        final json = {
          'id': '1',
          'name': 'Test Zone',
          // Missing lat, lng, radiusKm, createdAtMs
        };

        final zone = OfflineZone.fromJson(json);

        expect(zone, isNull);
      });
    });

    group('toString', () {
      test('should provide readable string representation', () {
        final zone = OfflineZone(
          id: '1',
          name: 'Test Zone',
          lat: 48.8566,
          lng: 2.3522,
          radiusKm: 10,
          createdAt: testDateTime,
        );

        final string = zone.toString();

        expect(string, contains('OfflineZone'));
        expect(string, contains('id: 1'));
        expect(string, contains('name: Test Zone'));
        expect(string, contains('lat: 48.8566'));
        expect(string, contains('lng: 2.3522'));
        expect(string, contains('radiusKm: 10.0'));
        expect(string, contains('createdAt: $testDateTime'));
      });
    });
  });
}

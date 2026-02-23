import 'package:weathernav/domain/models/offline_zone.dart';

/// Abstract repository interface for managing offline zones data.
/// 
/// This repository provides CRUD operations and real-time synchronization
/// capabilities for offline geographical zones used in weather monitoring.
/// 
/// Implementations should handle persistence, caching, and data validation.
/// All operations should be thread-safe and handle errors gracefully.
abstract class OfflineZonesRepository {
  /// Reads all offline zones from storage.
  /// 
  /// Returns a list of all available zones.
  /// If no zones exist, returns an empty list.
  /// 
  /// Throws [RepositoryException] if storage access fails.
  List<OfflineZone> read();

  /// Creates a stream that emits updates when offline zones change.
  /// 
  /// The stream emits the current list of zones whenever:
  /// - Zones are added, updated, or removed
  /// - External storage changes are detected
  /// 
  /// The stream should not close unless there's an unrecoverable error.
  /// 
  /// Throws [RepositoryException] if stream setup fails.
  Stream<List<OfflineZone>> watch();

  /// Saves all offline zones to storage.
  /// 
  /// This is a complete replacement operation - the provided list
  /// will replace all existing zones in storage.
  /// 
  /// [zones] - Complete list of zones to save
  /// 
  /// Throws [RepositoryException] if save operation fails.
  /// Throws [ArgumentError] if zones list is invalid.
  Future<void> save(List<OfflineZone> zones);
}

/// Exception thrown when repository operations fail.
class RepositoryException implements Exception {
  /// Creates a new repository exception.
  const RepositoryException(this.message, {this.cause, this.stackTrace});
  
  /// Human-readable error message
  final String message;
  
  /// Optional underlying cause
  final Object? cause;
  
  /// Optional stack trace
  final StackTrace? stackTrace;
  
  @override
  String toString() => 'RepositoryException: $message${cause != null ? ' (caused by: $cause)' : ''}';
}

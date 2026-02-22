import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';
import 'package:weathernav/core/logging/app_logger.dart';

class LocalDatabase {
  LocalDatabase._();

  static final LocalDatabase instance = LocalDatabase._();

  Database? _db;

  Future<Database> open() async {
    final existing = _db;
    if (existing != null) return existing;

    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}${Platform.pathSeparator}weathernav.sqlite');

    final db = sqlite3.open(file.path);
    _db = db;

    _configure(db);
    _migrate(db);
    return db;
  }

  Future<void> close() async {
    final db = _db;
    if (db == null) return;
    _db = null;
    db.dispose();
  }

  void _configure(Database db) {
    db.execute('PRAGMA foreign_keys = ON;');
    db.execute('PRAGMA journal_mode = WAL;');
    db.execute('PRAGMA synchronous = NORMAL;');
    db.execute('PRAGMA temp_store = MEMORY;');
    db.execute('PRAGMA busy_timeout = 5000;');
  }

  void _migrate(Database db) {
    try {
      db.execute('BEGIN;');

      final rs = db.select('PRAGMA user_version;');
      final current = rs.isNotEmpty ? (rs.first['user_version'] as int? ?? 0) : 0;
      var v = current;

      if (v < 1) {
        db.execute('''
CREATE TABLE IF NOT EXISTS trips (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  created_at_ms INTEGER NOT NULL,
  departure_time_ms INTEGER,
  profile TEXT NOT NULL,
  start_lat REAL NOT NULL,
  start_lng REAL NOT NULL,
  end_lat REAL NOT NULL,
  end_lng REAL NOT NULL,
  distance_km REAL NOT NULL,
  duration_minutes REAL NOT NULL,
  gpx TEXT
);
''');

        db.execute('CREATE INDEX IF NOT EXISTS idx_trips_created_at ON trips(created_at_ms DESC);');
        v = 1;
      }

      if (v != current) {
        db.execute('PRAGMA user_version = $v;');
      }

      db.execute('COMMIT;');
    } catch (e, st) {
      try {
        db.execute('ROLLBACK;');
      } catch (_) {
        // best-effort
      }
      AppLogger.error('SQLite migration failed', name: 'db', error: e, stackTrace: st);
      rethrow;
    }
  }
}

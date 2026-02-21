import 'dart:io';

import 'package:path_provider/path_provider.dart';
import 'package:sqlite3/sqlite3.dart';

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

    _migrate(db);
    return db;
  }

  void _migrate(Database db) {
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
  }
}

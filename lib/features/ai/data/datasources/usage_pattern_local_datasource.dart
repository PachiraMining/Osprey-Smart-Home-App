import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';

/// SQLite-backed log of user device actions used by [AnalyzeUsagePatterns].
///
/// Schema:
///   curtain_actions(
///     id INTEGER PRIMARY KEY AUTOINCREMENT,
///     device_id TEXT NOT NULL,
///     command TEXT NOT NULL,
///     ts INTEGER NOT NULL,        -- millis since epoch
///     weekday INTEGER NOT NULL,   -- 1..7 ISO
///     hour INTEGER NOT NULL       -- 0..23
///   )
class UsagePatternLocalDataSource {
  static const _dbFileName = 'curtain_ai_usage.db';
  static const _table = 'curtain_actions';

  Database? _db;

  Future<Database> _open() async {
    if (_db != null) return _db!;
    final dir = await getApplicationDocumentsDirectory();
    final dbPath = '${dir.path}/$_dbFileName';
    _db = await openDatabase(
      dbPath,
      version: 1,
      onCreate: (db, _) async {
        await db.execute('''
          CREATE TABLE $_table (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            device_id TEXT NOT NULL,
            command TEXT NOT NULL,
            ts INTEGER NOT NULL,
            weekday INTEGER NOT NULL,
            hour INTEGER NOT NULL
          )
        ''');
        await db.execute(
          'CREATE INDEX idx_actions_device_time ON $_table(device_id, weekday, hour)',
        );
      },
    );
    return _db!;
  }

  Future<void> insert({
    required String deviceId,
    required String command,
    required DateTime at,
  }) async {
    final db = await _open();
    await db.insert(_table, {
      'device_id': deviceId,
      'command': command,
      'ts': at.millisecondsSinceEpoch,
      'weekday': at.weekday,
      'hour': at.hour,
    });
  }

  Future<List<Map<String, Object?>>> queryRecent({required int lookbackDays}) async {
    final db = await _open();
    final cutoff = DateTime.now()
        .subtract(Duration(days: lookbackDays))
        .millisecondsSinceEpoch;
    return db.query(
      _table,
      where: 'ts >= ?',
      whereArgs: [cutoff],
    );
  }
}

import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/seizure.dart';

/// Service für die Verwaltung der Anfalls-Datenbank
/// Verwendet SQLite für lokale Datenspeicherung
class SeizureDatabaseService {
  static final SeizureDatabaseService _instance = SeizureDatabaseService._internal();
  static Database? _database;

  factory SeizureDatabaseService() {
    return _instance;
  }

  SeizureDatabaseService._internal();

  /// Getter für die Datenbank
  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDatabase();
    return _database!;
  }

  /// Initialisiert die Datenbank
  Future<Database> _initDatabase() async {
    final databasesPath = await getDatabasesPath();
    final path = join(databasesPath, 'epilepsy_tracker.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _onCreate,
    );
  }

  /// Erstellt die Tabellen
  Future<void> _onCreate(Database db, int version) async {
    await db.execute('''
      CREATE TABLE seizures (
        id TEXT PRIMARY KEY,
        dateTime TEXT NOT NULL,
        type INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        severity INTEGER NOT NULL,
        auraSymptoms TEXT,
        symptomsD​uring TEXT,
        symptomsAfter TEXT,
        triggers TEXT,
        location TEXT,
        activity TEXT,
        medicationTaken INTEGER NOT NULL,
        medicationName TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  /// Fügt einen neuen Anfall hinzu
  Future<int> insertSeizure(Seizure seizure) async {
    final db = await database;
    return await db.insert(
      'seizures',
      seizure.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Aktualisiert einen Anfall
  Future<int> updateSeizure(Seizure seizure) async {
    final db = await database;
    final updatedSeizure = seizure.copyWith(updatedAt: DateTime.now());
    return await db.update(
      'seizures',
      updatedSeizure.toMap(),
      where: 'id = ?',
      whereArgs: [seizure.id],
    );
  }

  /// Löscht einen Anfall
  Future<int> deleteSeizure(String id) async {
    final db = await database;
    return await db.delete(
      'seizures',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Holt einen einzelnen Anfall nach ID
  Future<Seizure?> getSeizure(String id) async {
    final db = await database;
    final maps = await db.query(
      'seizures',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return Seizure.fromMap(maps.first);
  }

  /// Holt alle Anfälle
  Future<List<Seizure>> getAllSeizures() async {
    final db = await database;
    final maps = await db.query(
      'seizures',
      orderBy: 'dateTime DESC',
    );

    return List.generate(maps.length, (i) {
      return Seizure.fromMap(maps[i]);
    });
  }

  /// Holt Anfälle nach Zeitraum
  Future<List<Seizure>> getSeizuresByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'seizures',
      where: 'dateTime >= ? AND dateTime <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'dateTime DESC',
    );

    return List.generate(maps.length, (i) {
      return Seizure.fromMap(maps[i]);
    });
  }

  /// Holt Anfälle des aktuellen Monats
  Future<List<Seizure>> getCurrentMonthSeizures() async {
    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1);
    final endOfMonth = DateTime(now.year, now.month + 1, 0, 23, 59, 59);

    return await getSeizuresByDateRange(startOfMonth, endOfMonth);
  }

  /// Holt die letzten N Anfälle
  Future<List<Seizure>> getRecentSeizures(int limit) async {
    final db = await database;
    final maps = await db.query(
      'seizures',
      orderBy: 'dateTime DESC',
      limit: limit,
    );

    return List.generate(maps.length, (i) {
      return Seizure.fromMap(maps[i]);
    });
  }

  /// Zählt die Gesamtanzahl der Anfälle
  Future<int> getSeizureCount() async {
    final db = await database;
    final result = await db.rawQuery('SELECT COUNT(*) FROM seizures');
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Zählt Anfälle für einen bestimmten Zeitraum
  Future<int> getSeizureCountByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM seizures WHERE dateTime >= ? AND dateTime <= ?',
      [startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Statistiken: Durchschnittliche Schwere
  Future<double> getAverageSeverity() async {
    final db = await database;
    final result = await db.rawQuery('SELECT AVG(severity) FROM seizures');
    return (result.first.values.first as num?)?.toDouble() ?? 0.0;
  }

  /// Statistiken: Häufigste Trigger
  Future<Map<String, int>> getMostCommonTriggers() async {
    final seizures = await getAllSeizures();
    final triggerCount = <String, int>{};

    for (final seizure in seizures) {
      for (final trigger in seizure.triggers) {
        triggerCount[trigger] = (triggerCount[trigger] ?? 0) + 1;
      }
    }

    // Sortiere nach Häufigkeit
    final sortedTriggers = Map.fromEntries(
      triggerCount.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value)),
    );

    return sortedTriggers;
  }

  /// Statistiken: Verteilung nach Typ
  Future<Map<SeizureType, int>> getSeizureTypeDistribution() async {
    final seizures = await getAllSeizures();
    final typeCount = <SeizureType, int>{};

    for (final seizure in seizures) {
      typeCount[seizure.type] = (typeCount[seizure.type] ?? 0) + 1;
    }

    return typeCount;
  }

  /// Löscht alle Anfälle (Vorsicht!)
  Future<int> deleteAllSeizures() async {
    final db = await database;
    return await db.delete('seizures');
  }

  /// Schließt die Datenbank
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

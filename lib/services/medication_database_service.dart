import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../core/models/medication.dart';
import 'package:flutter/material.dart';

/// Service für die Verwaltung der Medikamenten-Datenbank
/// Verwendet SQLite für lokale Datenspeicherung
class MedicationDatabaseService {
  static final MedicationDatabaseService _instance = MedicationDatabaseService._internal();
  static Database? _database;

  factory MedicationDatabaseService() {
    return _instance;
  }

  MedicationDatabaseService._internal();

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
      version: 2, // Version erhöht wegen neuer Tabelle
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
    );
  }

  /// Erstellt die Tabellen bei erster Initialisierung
  Future<void> _onCreate(Database db, int version) async {
    // Erstellt auch die seizures Tabelle falls noch nicht vorhanden
    await db.execute('''
      CREATE TABLE IF NOT EXISTS seizures (
        id TEXT PRIMARY KEY,
        dateTime TEXT NOT NULL,
        type INTEGER NOT NULL,
        duration INTEGER NOT NULL,
        severity INTEGER NOT NULL,
        auraSymptoms TEXT,
        symptomsDuring TEXT,
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

    // Erstellt die medications Tabelle
    await _createMedicationsTable(db);
  }

  /// Upgrade bei neuer Datenbankversion
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      await _createMedicationsTable(db);
    }
  }

  /// Erstellt die Medikamenten-Tabelle
  Future<void> _createMedicationsTable(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS medications (
        id TEXT PRIMARY KEY,
        name TEXT NOT NULL,
        dosage TEXT NOT NULL,
        quantity INTEGER NOT NULL,
        scheduledDate TEXT NOT NULL,
        scheduledTimeHour INTEGER NOT NULL,
        scheduledTimeMinute INTEGER NOT NULL,
        timeOfDay TEXT NOT NULL,
        status TEXT NOT NULL,
        actualIntakeTime TEXT,
        notes TEXT,
        createdAt TEXT NOT NULL,
        updatedAt TEXT
      )
    ''');
  }

  /// Konvertiert Medication zu Map für Datenbank
  Map<String, dynamic> _medicationToMap(Medication medication) {
    return {
      'id': medication.id,
      'name': medication.name,
      'dosage': medication.dosage,
      'quantity': medication.quantity,
      'scheduledDate': medication.scheduledDate.toIso8601String(),
      'scheduledTimeHour': medication.scheduledTime.hour,
      'scheduledTimeMinute': medication.scheduledTime.minute,
      'timeOfDay': medication.timeOfDay,
      'status': medication.status.toString(),
      'actualIntakeTime': medication.actualIntakeTime?.toIso8601String(),
      'notes': medication.notes,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };
  }

  /// Konvertiert Map zu Medication
  Medication _mapToMedication(Map<String, dynamic> map) {
    return Medication(
      id: map['id'] as String,
      name: map['name'] as String,
      dosage: map['dosage'] as String,
      quantity: map['quantity'] as int,
      scheduledDate: DateTime.parse(map['scheduledDate'] as String),
      scheduledTime: TimeOfDay(
        hour: map['scheduledTimeHour'] as int,
        minute: map['scheduledTimeMinute'] as int,
      ),
      timeOfDay: map['timeOfDay'] as String,
      status: MedicationStatus.values.firstWhere(
        (e) => e.toString() == map['status'],
        orElse: () => MedicationStatus.pending,
      ),
      actualIntakeTime: map['actualIntakeTime'] != null
          ? DateTime.parse(map['actualIntakeTime'] as String)
          : null,
      notes: map['notes'] as String?,
    );
  }

  /// Fügt ein neues Medikament hinzu
  Future<int> insertMedication(Medication medication) async {
    final db = await database;
    return await db.insert(
      'medications',
      _medicationToMap(medication),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Aktualisiert ein Medikament
  Future<int> updateMedication(Medication medication) async {
    final db = await database;
    final map = _medicationToMap(medication);
    map['updatedAt'] = DateTime.now().toIso8601String();

    return await db.update(
      'medications',
      map,
      where: 'id = ?',
      whereArgs: [medication.id],
    );
  }

  /// Löscht ein Medikament
  Future<int> deleteMedication(String id) async {
    final db = await database;
    return await db.delete(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  /// Holt ein einzelnes Medikament nach ID
  Future<Medication?> getMedication(String id) async {
    final db = await database;
    final maps = await db.query(
      'medications',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isEmpty) return null;
    return _mapToMedication(maps.first);
  }

  /// Holt alle Medikamente
  Future<List<Medication>> getAllMedications() async {
    final db = await database;
    final maps = await db.query(
      'medications',
      orderBy: 'scheduledDate DESC, scheduledTimeHour ASC, scheduledTimeMinute ASC',
    );

    return List.generate(maps.length, (i) {
      return _mapToMedication(maps[i]);
    });
  }

  /// Holt Medikamente nach Datum
  Future<List<Medication>> getMedicationsByDate(DateTime date) async {
    final db = await database;
    final startOfDay = DateTime(date.year, date.month, date.day);
    final endOfDay = DateTime(date.year, date.month, date.day, 23, 59, 59);

    final maps = await db.query(
      'medications',
      where: 'scheduledDate >= ? AND scheduledDate <= ?',
      whereArgs: [startOfDay.toIso8601String(), endOfDay.toIso8601String()],
      orderBy: 'scheduledTimeHour ASC, scheduledTimeMinute ASC',
    );

    return List.generate(maps.length, (i) {
      return _mapToMedication(maps[i]);
    });
  }

  /// Holt heutige Medikamente
  Future<List<Medication>> getTodayMedications() async {
    return await getMedicationsByDate(DateTime.now());
  }

  /// Holt morgige Medikamente
  Future<List<Medication>> getTomorrowMedications() async {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return await getMedicationsByDate(tomorrow);
  }

  /// Holt Medikamente nach Zeitraum
  Future<List<Medication>> getMedicationsByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    final db = await database;
    final maps = await db.query(
      'medications',
      where: 'scheduledDate >= ? AND scheduledDate <= ?',
      whereArgs: [startDate.toIso8601String(), endDate.toIso8601String()],
      orderBy: 'scheduledDate ASC, scheduledTimeHour ASC, scheduledTimeMinute ASC',
    );

    return List.generate(maps.length, (i) {
      return _mapToMedication(maps[i]);
    });
  }

  /// Holt ausstehende (pending) Medikamente
  Future<List<Medication>> getPendingMedications() async {
    final db = await database;
    final maps = await db.query(
      'medications',
      where: 'status = ?',
      whereArgs: [MedicationStatus.pending.toString()],
      orderBy: 'scheduledDate ASC, scheduledTimeHour ASC, scheduledTimeMinute ASC',
    );

    return List.generate(maps.length, (i) {
      return _mapToMedication(maps[i]);
    });
  }

  /// Holt überfällige Medikamente
  Future<List<Medication>> getOverdueMedications() async {
    final medications = await getPendingMedications();
    final now = DateTime.now();

    return medications.where((medication) {
      final scheduled = DateTime(
        medication.scheduledDate.year,
        medication.scheduledDate.month,
        medication.scheduledDate.day,
        medication.scheduledTime.hour,
        medication.scheduledTime.minute,
      );
      return now.isAfter(scheduled);
    }).toList();
  }

  /// Markiert Medikament als genommen
  Future<int> markAsTaken(String id) async {
    final medication = await getMedication(id);
    if (medication == null) return 0;

    final updated = medication.copyWith(
      status: MedicationStatus.taken,
      actualIntakeTime: DateTime.now(),
    );

    return await updateMedication(updated);
  }

  /// Markiert Medikament als übersprungen
  Future<int> markAsSkipped(String id) async {
    final medication = await getMedication(id);
    if (medication == null) return 0;

    final updated = medication.copyWith(
      status: MedicationStatus.skipped,
    );

    return await updateMedication(updated);
  }

  /// Statistiken: Einnahmerate für Zeitraum
  Future<double> getComplianceRate(DateTime startDate, DateTime endDate) async {
    final medications = await getMedicationsByDateRange(startDate, endDate);
    if (medications.isEmpty) return 0.0;

    final taken = medications.where((m) => m.status == MedicationStatus.taken).length;
    return (taken / medications.length) * 100;
  }

  /// Statistiken: Anzahl genommener Medikamente
  Future<int> getTakenCount(DateTime startDate, DateTime endDate) async {
    final db = await database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) FROM medications WHERE status = ? AND scheduledDate >= ? AND scheduledDate <= ?',
      [MedicationStatus.taken.toString(), startDate.toIso8601String(), endDate.toIso8601String()],
    );
    return Sqflite.firstIntValue(result) ?? 0;
  }

  /// Löscht alle Medikamente (Vorsicht!)
  Future<int> deleteAllMedications() async {
    final db = await database;
    return await db.delete('medications');
  }

  /// Schließt die Datenbank
  Future<void> close() async {
    final db = await database;
    await db.close();
    _database = null;
  }
}

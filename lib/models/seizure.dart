import 'package:flutter/material.dart';

/// Modelo für Anfälle (Seizures)
/// Repräsentiert einen epileptischen Anfall mit allen relevanten medizinischen Informationen
class Seizure {
  final String id;
  final DateTime dateTime;
  final SeizureType type;
  final Duration duration;
  final int severity; // 1-5 Skala
  final String? auraSymptoms; // Symptome vor dem Anfall
  final List<String> symptomsDuring; // Symptome während des Anfalls
  final List<String> symptomsAfter; // Symptome nach dem Anfall
  final List<String> triggers; // Mögliche Auslöser
  final String? location; // Wo der Anfall passierte
  final String? activity; // Was die Person gerade gemacht hat
  final bool medicationTaken; // Wurde Notfallmedikation genommen?
  final String? medicationName; // Name der Notfallmedikation
  final String? notes; // Zusätzliche Notizen
  final DateTime createdAt;
  final DateTime? updatedAt;

  Seizure({
    required this.id,
    required this.dateTime,
    required this.type,
    required this.duration,
    required this.severity,
    this.auraSymptoms,
    this.symptomsDuring = const [],
    this.symptomsAfter = const [],
    this.triggers = const [],
    this.location,
    this.activity,
    this.medicationTaken = false,
    this.medicationName,
    this.notes,
    DateTime? createdAt,
    this.updatedAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Erstellt eine Kopie mit geänderten Werten
  Seizure copyWith({
    String? id,
    DateTime? dateTime,
    SeizureType? type,
    Duration? duration,
    int? severity,
    String? auraSymptoms,
    List<String>? symptomsDuring,
    List<String>? symptomsAfter,
    List<String>? triggers,
    String? location,
    String? activity,
    bool? medicationTaken,
    String? medicationName,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Seizure(
      id: id ?? this.id,
      dateTime: dateTime ?? this.dateTime,
      type: type ?? this.type,
      duration: duration ?? this.duration,
      severity: severity ?? this.severity,
      auraSymptoms: auraSymptoms ?? this.auraSymptoms,
      symptomsDuring: symptomsDuring ?? this.symptomsDuring,
      symptomsAfter: symptomsAfter ?? this.symptomsAfter,
      triggers: triggers ?? this.triggers,
      location: location ?? this.location,
      activity: activity ?? this.activity,
      medicationTaken: medicationTaken ?? this.medicationTaken,
      medicationName: medicationName ?? this.medicationName,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Konvertiert zu Map für Datenbank
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'dateTime': dateTime.toIso8601String(),
      'type': type.index,
      'duration': duration.inSeconds,
      'severity': severity,
      'auraSymptoms': auraSymptoms,
      'symptomsDuring': symptomsDuring.join(','),
      'symptomsAfter': symptomsAfter.join(','),
      'triggers': triggers.join(','),
      'location': location,
      'activity': activity,
      'medicationTaken': medicationTaken ? 1 : 0,
      'medicationName': medicationName,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  /// Erstellt Seizure aus Map (Datenbank)
  factory Seizure.fromMap(Map<String, dynamic> map) {
    return Seizure(
      id: map['id'] as String,
      dateTime: DateTime.parse(map['dateTime'] as String),
      type: SeizureType.values[map['type'] as int],
      duration: Duration(seconds: map['duration'] as int),
      severity: map['severity'] as int,
      auraSymptoms: map['auraSymptoms'] as String?,
      symptomsDuring: (map['symptomsDuring'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      symptomsAfter: (map['symptomsAfter'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      triggers: (map['triggers'] as String?)
              ?.split(',')
              .where((s) => s.isNotEmpty)
              .toList() ??
          [],
      location: map['location'] as String?,
      activity: map['activity'] as String?,
      medicationTaken: (map['medicationTaken'] as int) == 1,
      medicationName: map['medicationName'] as String?,
      notes: map['notes'] as String?,
      createdAt: DateTime.parse(map['createdAt'] as String),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  /// Gibt formatierte Dauer zurück (z.B. "2 Min 30 Sek")
  String get formattedDuration {
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    if (minutes > 0) {
      return '$minutes Min ${seconds > 0 ? "$seconds Sek" : ""}';
    }
    return '$seconds Sekunden';
  }

  /// Gibt formatiertes Datum und Zeit zurück
  String get formattedDateTime {
    return '${dateTime.day.toString().padLeft(2, '0')}.${dateTime.month.toString().padLeft(2, '0')}.${dateTime.year} ${dateTime.hour.toString().padLeft(2, '0')}:${dateTime.minute.toString().padLeft(2, '0')}';
  }

  /// Gibt die Farbe basierend auf der Schwere zurück
  Color get severityColor {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }
}

/// Typen von epileptischen Anfällen
enum SeizureType {
  focal, // Fokaler Anfall
  generalizedTonicClonic, // Generalisierter tonisch-klonischer Anfall
  absence, // Absence (Petit-mal)
  myoclonic, // Myoklonischer Anfall
  tonic, // Tonischer Anfall
  clonic, // Klonischer Anfall
  atonic, // Atonischer Anfall
  unknown, // Unbekannt
}

/// Extension für SeizureType
extension SeizureTypeExtension on SeizureType {
  String get displayName {
    switch (this) {
      case SeizureType.focal:
        return 'Fokal';
      case SeizureType.generalizedTonicClonic:
        return 'Generalisiert tonisch-klonisch';
      case SeizureType.absence:
        return 'Absence';
      case SeizureType.myoclonic:
        return 'Myoklonisch';
      case SeizureType.tonic:
        return 'Tonisch';
      case SeizureType.clonic:
        return 'Klonisch';
      case SeizureType.atonic:
        return 'Atonisch';
      case SeizureType.unknown:
        return 'Unbekannt';
    }
  }

  String get description {
    switch (this) {
      case SeizureType.focal:
        return 'Beginnt in einem Teil des Gehirns';
      case SeizureType.generalizedTonicClonic:
        return 'Betrifft das ganze Gehirn, mit Verkrampfungen und Zuckungen';
      case SeizureType.absence:
        return 'Kurze Bewusstseinspausen';
      case SeizureType.myoclonic:
        return 'Kurze Muskelzuckungen';
      case SeizureType.tonic:
        return 'Muskelversteifungen';
      case SeizureType.clonic:
        return 'Rhythmische Muskelzuckungen';
      case SeizureType.atonic:
        return 'Plötzlicher Verlust der Muskelspannung';
      case SeizureType.unknown:
        return 'Typ noch nicht identifiziert';
    }
  }
}

/// Häufige Symptome während eines Anfalls
class SeizureSymptoms {
  static const List<String> duringSymptoms = [
    'Bewusstlosigkeit',
    'Muskelzuckungen',
    'Verkrampfungen',
    'Starrer Blick',
    'Verwirrtheit',
    'Unkontrollierte Bewegungen',
    'Zungenbiss',
    'Schaum vor dem Mund',
    'Sturz',
    'Augenrollen',
  ];

  static const List<String> afterSymptoms = [
    'Müdigkeit',
    'Verwirrtheit',
    'Kopfschmerzen',
    'Muskelschmerzen',
    'Gedächtnisverlust',
    'Schwäche',
    'Übelkeit',
    'Schlafbedürfnis',
    'Orientierungslosigkeit',
  ];

  static const List<String> commonTriggers = [
    'Schlafmangel',
    'Stress',
    'Alkohol',
    'Vergessene Medikation',
    'Flackernde Lichter',
    'Hormonelle Veränderungen',
    'Fieber/Krankheit',
    'Hitze/Dehydration',
    'Körperliche Anstrengung',
    'Koffein',
  ];
}

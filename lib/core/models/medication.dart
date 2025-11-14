import 'package:flutter/material.dart';

/// Modelo para Medikamente
/// Representa ein Medikament mit allen relevanten Informationen
class Medication {
  final String id;
  final String name;
  final String dosage;
  final int quantity; // Anzahl der Tabletten/Einheiten
  final DateTime scheduledDate;
  final TimeOfDay scheduledTime;
  final String timeOfDay; // "Morgens", "Mittags", "Abends", "Nachts"
  MedicationStatus status;
  DateTime? actualIntakeTime;
  String? notes;

  Medication({
    required this.id,
    required this.name,
    required this.dosage,
    required this.quantity,
    required this.scheduledDate,
    required this.scheduledTime,
    required this.timeOfDay,
    this.status = MedicationStatus.pending,
    this.actualIntakeTime,
    this.notes,
  });

  /// Erstellt eine Kopie mit geänderten Werten
  Medication copyWith({
    String? id,
    String? name,
    String? dosage,
    int? quantity,
    DateTime? scheduledDate,
    TimeOfDay? scheduledTime,
    String? timeOfDay,
    MedicationStatus? status,
    DateTime? actualIntakeTime,
    String? notes,
  }) {
    return Medication(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      quantity: quantity ?? this.quantity,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      timeOfDay: timeOfDay ?? this.timeOfDay,
      status: status ?? this.status,
      actualIntakeTime: actualIntakeTime ?? this.actualIntakeTime,
      notes: notes ?? this.notes,
    );
  }

  /// Konvertiert zu JSON für API/Datenbank
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'dosage': dosage,
      'quantity': quantity,
      'scheduledDate': scheduledDate.toIso8601String(),
      'scheduledTime': '${scheduledTime.hour}:${scheduledTime.minute}',
      'timeOfDay': timeOfDay,
      'status': status.toString(),
      'actualIntakeTime': actualIntakeTime?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Erstellt Medication aus JSON
  factory Medication.fromJson(Map<String, dynamic> json) {
    final timeParts = (json['scheduledTime'] as String).split(':');
    return Medication(
      id: json['id'] as String,
      name: json['name'] as String,
      dosage: json['dosage'] as String,
      quantity: json['quantity'] as int,
      scheduledDate: DateTime.parse(json['scheduledDate'] as String),
      scheduledTime: TimeOfDay(
        hour: int.parse(timeParts[0]),
        minute: int.parse(timeParts[1]),
      ),
      timeOfDay: json['timeOfDay'] as String,
      status: MedicationStatus.values.firstWhere(
        (e) => e.toString() == json['status'],
        orElse: () => MedicationStatus.pending,
      ),
      actualIntakeTime: json['actualIntakeTime'] != null
          ? DateTime.parse(json['actualIntakeTime'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Gibt formatierte Zeit zurück (z.B. "08:00")
  String get formattedTime {
    final hour = scheduledTime.hour.toString().padLeft(2, '0');
    final minute = scheduledTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  /// Prüft ob das Medikament heute fällig ist
  bool get isDueToday {
    final now = DateTime.now();
    return scheduledDate.year == now.year &&
        scheduledDate.month == now.month &&
        scheduledDate.day == now.day;
  }

  /// Prüft ob das Medikament überfällig ist
  bool get isOverdue {
    final now = DateTime.now();
    final scheduled = DateTime(
      scheduledDate.year,
      scheduledDate.month,
      scheduledDate.day,
      scheduledTime.hour,
      scheduledTime.minute,
    );
    return now.isAfter(scheduled) && status == MedicationStatus.pending;
  }
}

/// Status eines Medikaments
enum MedicationStatus {
  pending,    // Noch nicht eingenommen
  taken,      // Eingenommen
  skipped,    // Übersprungen
  delayed,    // Verspätet
}

/// Extension für MedicationStatus
extension MedicationStatusExtension on MedicationStatus {
  String get displayName {
    switch (this) {
      case MedicationStatus.pending:
        return 'Offen';
      case MedicationStatus.taken:
        return 'Genommen';
      case MedicationStatus.skipped:
        return 'Übersprungen';
      case MedicationStatus.delayed:
        return 'Verspätet';
    }
  }
}

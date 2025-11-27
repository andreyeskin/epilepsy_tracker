import 'package:flutter/material.dart';

/// Risikolevel für Räume
enum RiskLevel {
  low,    // Niedriges Risiko (z.B. Wohnzimmer, Schlafzimmer)
  medium, // Mittleres Risiko (z.B. Küche)
  high;   // Hohes Risiko (z.B. Badezimmer, Treppe)

  /// Gibt die Farbe für das Risikolevel zurück
  Color get color {
    switch (this) {
      case RiskLevel.low:
        return Colors.green;
      case RiskLevel.medium:
        return Colors.orange;
      case RiskLevel.high:
        return Colors.red;
    }
  }

  /// Gibt den deutschen Namen für das Risikolevel zurück
  String get displayName {
    switch (this) {
      case RiskLevel.low:
        return 'Niedrig';
      case RiskLevel.medium:
        return 'Mittel';
      case RiskLevel.high:
        return 'Hoch';
    }
  }
}

/// Modell für einen Raum
/// Enthält ID, Name, Risikolevel und zugeordnete Beacon-UUIDs
class RoomModel {
  final String id;
  final String name;
  final RiskLevel riskLevel;
  final List<String> beaconUuids;
  final IconData icon;
  final String? description;

  RoomModel({
    required this.id,
    required this.name,
    required this.riskLevel,
    required this.beaconUuids,
    required this.icon,
    this.description,
  });

  /// Erstellt ein RoomModel aus JSON
  factory RoomModel.fromJson(Map<String, dynamic> json) {
    return RoomModel(
      id: json['id'] as String,
      name: json['name'] as String,
      riskLevel: RiskLevel.values.firstWhere(
        (e) => e.name == json['riskLevel'],
        orElse: () => RiskLevel.low,
      ),
      beaconUuids: (json['beaconUuids'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      icon: _iconFromString(json['icon'] as String),
      description: json['description'] as String?,
    );
  }

  /// Konvertiert das RoomModel zu JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'riskLevel': riskLevel.name,
      'beaconUuids': beaconUuids,
      'icon': _iconToString(icon),
      'description': description,
    };
  }

  /// Kopiert das RoomModel mit optionalen Änderungen
  RoomModel copyWith({
    String? id,
    String? name,
    RiskLevel? riskLevel,
    List<String>? beaconUuids,
    IconData? icon,
    String? description,
  }) {
    return RoomModel(
      id: id ?? this.id,
      name: name ?? this.name,
      riskLevel: riskLevel ?? this.riskLevel,
      beaconUuids: beaconUuids ?? this.beaconUuids,
      icon: icon ?? this.icon,
      description: description ?? this.description,
    );
  }

  /// Hilfsmethode: Icon zu String
  static String _iconToString(IconData icon) {
    return icon.codePoint.toString();
  }

  /// Hilfsmethode: String zu Icon
  static IconData _iconFromString(String iconCode) {
    try {
      return IconData(int.parse(iconCode), fontFamily: 'MaterialIcons');
    } catch (e) {
      return Icons.room;
    }
  }

  @override
  String toString() {
    return 'RoomModel(id: $id, name: $name, riskLevel: ${riskLevel.displayName})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is RoomModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

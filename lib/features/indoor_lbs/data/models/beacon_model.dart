/// Modell für einen BLE-Beacon
/// Enthält UUID, Name, zugeordneten Raum und Signalstärke (RSSI)
class BeaconModel {
  final String uuid;
  final String name;
  final String? roomId;
  final int rssi;
  final DateTime lastSeen;

  BeaconModel({
    required this.uuid,
    required this.name,
    this.roomId,
    required this.rssi,
    required this.lastSeen,
  });

  /// Erstellt ein BeaconModel aus JSON
  factory BeaconModel.fromJson(Map<String, dynamic> json) {
    return BeaconModel(
      uuid: json['uuid'] as String,
      name: json['name'] as String,
      roomId: json['roomId'] as String?,
      rssi: json['rssi'] as int,
      lastSeen: DateTime.parse(json['lastSeen'] as String),
    );
  }

  /// Konvertiert das BeaconModel zu JSON
  Map<String, dynamic> toJson() {
    return {
      'uuid': uuid,
      'name': name,
      'roomId': roomId,
      'rssi': rssi,
      'lastSeen': lastSeen.toIso8601String(),
    };
  }

  /// Kopiert das BeaconModel mit optionalen Änderungen
  BeaconModel copyWith({
    String? uuid,
    String? name,
    String? roomId,
    int? rssi,
    DateTime? lastSeen,
  }) {
    return BeaconModel(
      uuid: uuid ?? this.uuid,
      name: name ?? this.name,
      roomId: roomId ?? this.roomId,
      rssi: rssi ?? this.rssi,
      lastSeen: lastSeen ?? this.lastSeen,
    );
  }

  /// Berechnet die geschätzte Entfernung basierend auf RSSI
  /// Rückgabe in Metern (approximativ)
  double getEstimatedDistance() {
    // Simplified distance calculation
    // RSSI bei 1m (tx power) angenommen: -59 dBm
    const int txPower = -59;
    if (rssi == 0) {
      return -1.0; // Ungültig
    }

    final double ratio = rssi / txPower.toDouble();
    if (ratio < 1.0) {
      return ratio.abs();
    } else {
      // Environmental factor (n) zwischen 2-4, hier 2.5
      return (0.89976 * (ratio).abs() + 0.111);
    }
  }

  @override
  String toString() {
    return 'BeaconModel(uuid: $uuid, name: $name, roomId: $roomId, rssi: $rssi, distance: ${getEstimatedDistance().toStringAsFixed(2)}m)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is BeaconModel && other.uuid == uuid;
  }

  @override
  int get hashCode => uuid.hashCode;
}

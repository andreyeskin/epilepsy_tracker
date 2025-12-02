import '../../data/models/beacon_model.dart';
import '../../data/models/room_model.dart';
import '../../data/repositories/beacon_repository.dart';

/// Use Case: Erkennt den aktuellen Raum basierend auf Beacon-Signalen
///
/// Algorithmus:
/// 1. Empfange Liste der gescannten Beacons mit RSSI
/// 2. Filtere nach konfigurierten Beacons
/// 3. Bestimme nächsten Raum durch stärkstes Signal
/// 4. Gib RoomModel zurück oder null wenn unbekannt
class DetectCurrentRoom {
  final BeaconRepository _repository;

  DetectCurrentRoom(this._repository);

  /// Führt die Raumerkennung aus
  ///
  /// [scannedBeacons] - Liste der aktuell gescannten Beacons mit RSSI
  /// [minRssiThreshold] - Minimaler RSSI-Wert für gültige Erkennung (Standard: -90)
  /// [requireMultipleReadings] - Ob mehrere Messungen erforderlich sind (Standard: false)
  ///
  /// Gibt den erkannten Raum zurück oder null wenn kein Raum erkannt wurde
  RoomModel? call({
    required List<BeaconModel> scannedBeacons,
    int minRssiThreshold = -90,
    bool requireMultipleReadings = false,
  }) {
    // 1. Filtere zu schwache Signale
    final validBeacons = scannedBeacons
        .where((beacon) => beacon.rssi >= minRssiThreshold)
        .toList();

    if (validBeacons.isEmpty) {
      return null;
    }

    // 2. Mappe Beacons zu konfigurierten Räumen
    final Map<RoomModel, List<BeaconModel>> roomBeacons = {};

    for (var beacon in validBeacons) {
      final room = _repository.findRoomByBeaconUuid(beacon.uuid);
      if (room != null) {
        roomBeacons.putIfAbsent(room, () => []);
        roomBeacons[room]!.add(beacon);
      }
    }

    if (roomBeacons.isEmpty) {
      return null;
    }

    // 3. Bestimme Raum mit stärkstem Signal
    RoomModel? bestRoom;
    int bestRssi = minRssiThreshold;

    for (var entry in roomBeacons.entries) {
      final room = entry.key;
      final beacons = entry.value;

      // CRITICAL FIX: Check if beacons list is empty before reduce()
      // Verwende durchschnittlichen RSSI wenn mehrere Beacons im Raum
      if (beacons.isEmpty) {
        continue; // Skip this room if no beacons
      }

      final avgRssi = beacons.map((b) => b.rssi).reduce((a, b) => a + b) ~/
          beacons.length;

      // Aktualisiere besten Raum wenn RSSI stärker
      if (avgRssi > bestRssi) {
        bestRssi = avgRssi;
        bestRoom = room;
      }
    }

    return bestRoom;
  }

  /// Alternative Methode: Gewichtete Raumerkennung
  /// Berücksichtigt Anzahl der Beacons und deren Signalstärke
  RoomModel? detectWithWeighting({
    required List<BeaconModel> scannedBeacons,
    int minRssiThreshold = -90,
  }) {
    final validBeacons = scannedBeacons
        .where((beacon) => beacon.rssi >= minRssiThreshold)
        .toList();

    if (validBeacons.isEmpty) {
      return null;
    }

    final Map<RoomModel, double> roomScores = {};

    for (var beacon in validBeacons) {
      final room = _repository.findRoomByBeaconUuid(beacon.uuid);
      if (room != null) {
        // Score basiert auf RSSI und Entfernung
        final distance = beacon.getEstimatedDistance();
        final score = distance > 0 ? 1 / distance : 0.0;

        roomScores[room] = (roomScores[room] ?? 0.0) + score;
      }
    }

    if (roomScores.isEmpty) {
      return null;
    }

    // Finde Raum mit höchstem Score
    var bestRoom = roomScores.entries.first.key;
    var bestScore = roomScores.entries.first.value;

    for (var entry in roomScores.entries) {
      if (entry.value > bestScore) {
        bestScore = entry.value;
        bestRoom = entry.key;
      }
    }

    return bestRoom;
  }

  /// Gibt Konfidenz-Level für Raumerkennung zurück (0.0 - 1.0)
  double getConfidence({
    required List<BeaconModel> scannedBeacons,
    required RoomModel? detectedRoom,
  }) {
    if (detectedRoom == null) return 0.0;

    final roomBeacons = scannedBeacons
        .where((b) => detectedRoom.beaconUuids.contains(b.uuid))
        .toList();

    if (roomBeacons.isEmpty) return 0.0;

    // Berechne Konfidenz basierend auf:
    // - Anzahl der erkannten Beacons
    // - Durchschnittliche Signalstärke
    // CRITICAL FIX: This is already protected by isEmpty check above, but add safety
    if (roomBeacons.length == 1) {
      // If only one beacon, use its RSSI directly
      final avgRssi = roomBeacons.first.rssi.toDouble();
      final rssiConfidence = ((avgRssi + 90) / 50).clamp(0.0, 1.0);
      return rssiConfidence;
    }

    final avgRssi = roomBeacons.map((b) => b.rssi).reduce((a, b) => a + b) /
        roomBeacons.length;

    // Normalisiere RSSI auf 0-1 Skala (-90 = 0, -40 = 1)
    final rssiConfidence = ((avgRssi + 90) / 50).clamp(0.0, 1.0);

    // Bonus für mehrere Beacons
    final beaconCountBonus = (roomBeacons.length / 3).clamp(0.0, 0.3);

    return (rssiConfidence + beaconCountBonus).clamp(0.0, 1.0);
  }
}

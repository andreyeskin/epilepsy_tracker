import 'package:flutter/material.dart';
import '../models/beacon_model.dart';
import '../models/room_model.dart';
import '../models/risk_zone_model.dart';

/// Repository für Beacon- und Raumdaten
/// Verwaltet die Konfiguration von Räumen, Beacons und Risikozonen
class BeaconRepository {
  // Singleton-Pattern
  static final BeaconRepository _instance = BeaconRepository._internal();
  factory BeaconRepository() => _instance;
  BeaconRepository._internal();

  // Gespeicherte Daten
  final List<RoomModel> _rooms = [];
  final List<BeaconModel> _beacons = [];
  final Map<String, RiskZoneModel> _riskZones = {};

  /// Initialisiert das Repository mit Mock-Daten
  void initializeMockData() {
    _rooms.clear();
    _beacons.clear();
    _riskZones.clear();

    // Mock-Räume erstellen
    final livingRoom = RoomModel(
      id: 'room_living',
      name: 'Wohnzimmer',
      riskLevel: RiskLevel.low,
      beaconUuids: ['beacon_uuid_1'],
      icon: Icons.weekend,
      description: 'Entspannungsbereich mit niedrigem Risiko',
    );

    final bedroom = RoomModel(
      id: 'room_bedroom',
      name: 'Schlafzimmer',
      riskLevel: RiskLevel.low,
      beaconUuids: ['beacon_uuid_2'],
      icon: Icons.bed,
      description: 'Ruhebereich mit niedrigem Risiko',
    );

    final kitchen = RoomModel(
      id: 'room_kitchen',
      name: 'Küche',
      riskLevel: RiskLevel.medium,
      beaconUuids: ['beacon_uuid_3'],
      icon: Icons.kitchen,
      description: 'Mittleres Risiko durch heiße Oberflächen',
    );

    final bathroom = RoomModel(
      id: 'room_bathroom',
      name: 'Badezimmer',
      riskLevel: RiskLevel.high,
      beaconUuids: ['beacon_uuid_4'],
      icon: Icons.bathtub,
      description: 'Hohes Risiko durch Rutschgefahr',
    );

    _rooms.addAll([livingRoom, bedroom, kitchen, bathroom]);

    // Mock-Beacons erstellen
    _beacons.addAll([
      BeaconModel(
        uuid: 'beacon_uuid_1',
        name: 'Beacon Wohnzimmer',
        roomId: 'room_living',
        rssi: -65,
        lastSeen: DateTime.now(),
      ),
      BeaconModel(
        uuid: 'beacon_uuid_2',
        name: 'Beacon Schlafzimmer',
        roomId: 'room_bedroom',
        rssi: -75,
        lastSeen: DateTime.now(),
      ),
      BeaconModel(
        uuid: 'beacon_uuid_3',
        name: 'Beacon Küche',
        roomId: 'room_kitchen',
        rssi: -70,
        lastSeen: DateTime.now(),
      ),
      BeaconModel(
        uuid: 'beacon_uuid_4',
        name: 'Beacon Badezimmer',
        roomId: 'room_bathroom',
        rssi: -80,
        lastSeen: DateTime.now(),
      ),
    ]);

    // Risikozonen für jeden Raum erstellen
    for (var room in _rooms) {
      _riskZones[room.id] = RiskZoneModel.fromRoomModel(room);
    }
  }

  /// Gibt alle konfigurierten Räume zurück
  List<RoomModel> getRooms() => List.unmodifiable(_rooms);

  /// Gibt einen Raum anhand seiner ID zurück
  RoomModel? getRoomById(String id) {
    try {
      return _rooms.firstWhere((room) => room.id == id);
    } catch (e) {
      return null;
    }
  }

  /// Gibt alle konfigurierten Beacons zurück
  List<BeaconModel> getBeacons() => List.unmodifiable(_beacons);

  /// Gibt einen Beacon anhand seiner UUID zurück
  BeaconModel? getBeaconByUuid(String uuid) {
    try {
      return _beacons.firstWhere((beacon) => beacon.uuid == uuid);
    } catch (e) {
      return null;
    }
  }

  /// Gibt die Risikozone für einen Raum zurück
  RiskZoneModel? getRiskZoneForRoom(String roomId) {
    return _riskZones[roomId];
  }

  /// Fügt einen neuen Beacon hinzu oder aktualisiert einen bestehenden
  void saveBeacon(BeaconModel beacon) {
    final index = _beacons.indexWhere((b) => b.uuid == beacon.uuid);
    if (index >= 0) {
      _beacons[index] = beacon;
    } else {
      _beacons.add(beacon);
    }
  }

  /// Entfernt einen Beacon
  void removeBeacon(String uuid) {
    _beacons.removeWhere((beacon) => beacon.uuid == uuid);
  }

  /// Fügt einen neuen Raum hinzu oder aktualisiert einen bestehenden
  void saveRoom(RoomModel room) {
    final index = _rooms.indexWhere((r) => r.id == room.id);
    if (index >= 0) {
      _rooms[index] = room;
    } else {
      _rooms.add(room);
    }

    // Risikozone für den Raum aktualisieren
    if (!_riskZones.containsKey(room.id)) {
      _riskZones[room.id] = RiskZoneModel.fromRoomModel(room);
    }
  }

  /// Entfernt einen Raum
  void removeRoom(String id) {
    _rooms.removeWhere((room) => room.id == id);
    _riskZones.remove(id);

    // Beacons, die diesem Raum zugeordnet waren, auf null setzen
    for (var i = 0; i < _beacons.length; i++) {
      if (_beacons[i].roomId == id) {
        _beacons[i] = _beacons[i].copyWith(roomId: null);
      }
    }
  }

  /// Findet einen Raum basierend auf Beacon-UUID
  RoomModel? findRoomByBeaconUuid(String uuid) {
    try {
      return _rooms.firstWhere(
        (room) => room.beaconUuids.contains(uuid),
      );
    } catch (e) {
      return null;
    }
  }

  /// Löscht alle Daten
  void clear() {
    _rooms.clear();
    _beacons.clear();
    _riskZones.clear();
  }
}

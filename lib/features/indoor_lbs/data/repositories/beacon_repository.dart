import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/beacon_model.dart';
import '../models/room_model.dart';
import '../models/risk_zone_model.dart';

/// Repository für Beacon- und Raumdaten
/// Verwaltet die Konfiguration von Räumen, Beacons und Risikozonen
class BeaconRepository {
  // Singleton-Pattern
  static final BeaconRepository _instance = BeaconRepository._internal();
  factory BeaconRepository() => _instance;
  BeaconRepository._internal() {
    // CRITICAL FIX: Load persisted data on initialization
    _loadPersistedData();
  }

  // Gespeicherte Daten
  final List<RoomModel> _rooms = [];
  final List<BeaconModel> _beacons = [];
  final Map<String, RiskZoneModel> _riskZones = {};

  // Keys for SharedPreferences
  static const String _keyBeacons = 'indoor_lbs_beacons';
  static const String _keyRooms = 'indoor_lbs_rooms';

  /// Initialisiert das Repository mit Mock-Daten
  void initializeMockData() {
    _rooms.clear();
    _beacons.clear();
    _riskZones.clear();

    // Mock-Räume erstellen (ohne vorkonfigurierte Beacons)
    final livingRoom = RoomModel(
      id: 'room_living',
      name: 'Wohnzimmer',
      riskLevel: RiskLevel.low,
      beaconUuids: [], // Leer - Benutzer fügt Beacons manuell hinzu
      icon: Icons.weekend,
      description: 'Entspannungsbereich mit niedrigem Risiko',
    );

    final bedroom = RoomModel(
      id: 'room_bedroom',
      name: 'Schlafzimmer',
      riskLevel: RiskLevel.low,
      beaconUuids: [], // Leer - Benutzer fügt Beacons manuell hinzu
      icon: Icons.bed,
      description: 'Ruhebereich mit niedrigem Risiko',
    );

    final kitchen = RoomModel(
      id: 'room_kitchen',
      name: 'Küche',
      riskLevel: RiskLevel.medium,
      beaconUuids: [], // Leer - Benutzer fügt Beacons manuell hinzu
      icon: Icons.kitchen,
      description: 'Mittleres Risiko durch heiße Oberflächen',
    );

    final bathroom = RoomModel(
      id: 'room_bathroom',
      name: 'Badezimmer',
      riskLevel: RiskLevel.high,
      beaconUuids: [], // Leer - Benutzer fügt Beacons manuell hinzu
      icon: Icons.bathtub,
      description: 'Hohes Risiko durch Rutschgefahr',
    );

    _rooms.addAll([livingRoom, bedroom, kitchen, bathroom]);

    // Beacons sind initial LEER - Benutzer muss sie manuell hinzufügen
    // Die Mock-Beacons wurden deaktiviert, damit die App ohne vorkonfigurierte
    // Beacons startet und der Benutzer sie selbst konfigurieren muss.

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

    // Wenn Beacon bereits existiert, entferne UUID aus altem Raum
    if (index >= 0) {
      final oldBeacon = _beacons[index];
      if (oldBeacon.roomId != null && oldBeacon.roomId != beacon.roomId) {
        _removeBeaconUuidFromRoom(oldBeacon.uuid, oldBeacon.roomId!);
      }
      _beacons[index] = beacon;
    } else {
      _beacons.add(beacon);
    }

    // Füge UUID zum neuen Raum hinzu
    if (beacon.roomId != null) {
      _addBeaconUuidToRoom(beacon.uuid, beacon.roomId!);
    }

    // CRITICAL FIX: Persist data after save
    _persistData();
  }

  /// Entfernt einen Beacon
  void removeBeacon(String uuid) {
    final beacon = getBeaconByUuid(uuid);
    if (beacon != null && beacon.roomId != null) {
      _removeBeaconUuidFromRoom(uuid, beacon.roomId!);
    }
    _beacons.removeWhere((beacon) => beacon.uuid == uuid);

    // CRITICAL FIX: Persist data after removal
    _persistData();
  }

  /// Hilfsmethode: Fügt Beacon-UUID zu einem Raum hinzu
  void _addBeaconUuidToRoom(String uuid, String roomId) {
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex >= 0) {
      final room = _rooms[roomIndex];
      if (!room.beaconUuids.contains(uuid)) {
        final updatedUuids = List<String>.from(room.beaconUuids)..add(uuid);
        _rooms[roomIndex] = room.copyWith(beaconUuids: updatedUuids);
      }
    }
  }

  /// Hilfsmethode: Entfernt Beacon-UUID aus einem Raum
  void _removeBeaconUuidFromRoom(String uuid, String roomId) {
    final roomIndex = _rooms.indexWhere((r) => r.id == roomId);
    if (roomIndex >= 0) {
      final room = _rooms[roomIndex];
      if (room.beaconUuids.contains(uuid)) {
        final updatedUuids = List<String>.from(room.beaconUuids)..remove(uuid);
        _rooms[roomIndex] = room.copyWith(beaconUuids: updatedUuids);
      }
    }
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

    // CRITICAL FIX: Persist data after save
    _persistData();
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

    // CRITICAL FIX: Persist data after removal
    _persistData();
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
    _persistData(); // Persist the cleared state
  }

  // ========== PERSISTENCE METHODS (CRITICAL FIX) ==========

  /// Loads persisted beacon and room data from SharedPreferences
  Future<void> _loadPersistedData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Load beacons
      final beaconsJson = prefs.getString(_keyBeacons);
      if (beaconsJson != null) {
        final beaconsList = jsonDecode(beaconsJson) as List;
        _beacons.clear();
        _beacons.addAll(
          beaconsList.map((json) => BeaconModel.fromJson(json)).toList(),
        );
      }

      // Load rooms
      final roomsJson = prefs.getString(_keyRooms);
      if (roomsJson != null) {
        final roomsList = jsonDecode(roomsJson) as List;
        _rooms.clear();
        _rooms.addAll(
          roomsList.map((json) => RoomModel.fromJson(json)).toList(),
        );

        // Rebuild risk zones
        _riskZones.clear();
        for (var room in _rooms) {
          _riskZones[room.id] = RiskZoneModel.fromRoomModel(room);
        }
      }
    } catch (e) {
      debugPrint('Fehler beim Laden der Beacon-Daten: $e');
    }
  }

  /// Persists current beacon and room data to SharedPreferences
  Future<void> _persistData() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      // Save beacons
      final beaconsJson = jsonEncode(
        _beacons.map((beacon) => beacon.toJson()).toList(),
      );
      await prefs.setString(_keyBeacons, beaconsJson);

      // Save rooms
      final roomsJson = jsonEncode(
        _rooms.map((room) => room.toJson()).toList(),
      );
      await prefs.setString(_keyRooms, roomsJson);
    } catch (e) {
      debugPrint('Fehler beim Speichern der Beacon-Daten: $e');
    }
  }
}

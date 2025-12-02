import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import '../models/beacon_model.dart';

/// Service für BLE-Scanning
/// Scannt nach BLE-Beacons und gibt deren RSSI-Werte zurück
/// Unterstützt Mock-Modus für Tests ohne echte Hardware
class BleScannerService {
  // Singleton-Pattern
  static final BleScannerService _instance = BleScannerService._internal();
  factory BleScannerService() => _instance;
  BleScannerService._internal();

  // Scanning-Status
  bool _isScanning = false;
  bool _useMockMode = false; // Standard: Echter Bluetooth-Modus
  Timer? _mockTimer;
  final Random _random = Random();

  // Stream-Controller für Scan-Ergebnisse
  final _scanResultsController = StreamController<List<BeaconModel>>.broadcast();
  Stream<List<BeaconModel>> get scanResults => _scanResultsController.stream;

  // Aktuell erkannte Beacons
  final Map<String, BeaconModel> _detectedBeacons = {};

  /// Prüft ob Bluetooth verfügbar ist
  Future<bool> isBluetoothAvailable() async {
    if (_useMockMode) return true;

    try {
      final adapterState = await FlutterBluePlus.adapterState.first;
      return adapterState == BluetoothAdapterState.on;
    } catch (e) {
      debugPrint('Fehler beim Prüfen der Bluetooth-Verfügbarkeit: $e');
      return false;
    }
  }

  /// Aktiviert oder deaktiviert den Mock-Modus
  void setMockMode(bool enabled) {
    if (_isScanning) {
      throw StateError('Kann Mock-Modus nicht ändern während gescannt wird');
    }
    _useMockMode = enabled;
  }

  /// Startet das BLE-Scanning
  /// [scanInterval] - Intervall zwischen Scans in Sekunden (Standard: 5)
  /// [scanDuration] - Dauer eines einzelnen Scans in Sekunden (Standard: 3)
  Future<void> startScanning({
    int scanInterval = 5,
    int scanDuration = 3,
  }) async {
    if (_isScanning) {
      debugPrint('Scanning läuft bereits');
      return;
    }

    _isScanning = true;
    debugPrint('Starte BLE-Scanning (Mock-Modus: $_useMockMode)');

    if (_useMockMode) {
      _startMockScanning(scanInterval);
    } else {
      await _startRealScanning(scanInterval, scanDuration);
    }
  }

  /// Startet Mock-Scanning für Tests ohne echte Hardware
  void _startMockScanning(int interval) {
    // Mock-Beacons mit variierenden RSSI-Werten
    final mockBeacons = [
      'beacon_uuid_1',
      'beacon_uuid_2',
      'beacon_uuid_3',
      'beacon_uuid_4',
    ];

    _mockTimer = Timer.periodic(Duration(seconds: interval), (timer) {
      final beacons = <BeaconModel>[];

      for (var uuid in mockBeacons) {
        // Simuliere verschiedene Szenarien
        final shouldDetect = _random.nextDouble() > 0.2; // 80% Erkennungsrate

        if (shouldDetect) {
          // RSSI variiert zwischen -50 (sehr nah) und -90 (weit weg)
          final baseRssi = _getBaseRssiForBeacon(uuid);
          final rssi = baseRssi + _random.nextInt(10) - 5; // ±5 dBm Variation

          beacons.add(BeaconModel(
            uuid: uuid,
            name: 'Mock Beacon ${uuid.split('_').last}',
            roomId: _getRoomIdForBeacon(uuid),
            rssi: rssi,
            lastSeen: DateTime.now(),
          ));

          _detectedBeacons[uuid] = beacons.last;
        }
      }

      _scanResultsController.add(beacons);
    });
  }

  /// Gibt den Basis-RSSI für einen Mock-Beacon zurück
  /// Simuliert unterschiedliche Entfernungen
  int _getBaseRssiForBeacon(String uuid) {
    switch (uuid) {
      case 'beacon_uuid_1':
        return -60; // Nah (Wohnzimmer)
      case 'beacon_uuid_2':
        return -75; // Mittel (Schlafzimmer)
      case 'beacon_uuid_3':
        return -70; // Mittel-Nah (Küche)
      case 'beacon_uuid_4':
        return -85; // Weit (Badezimmer)
      default:
        return -70;
    }
  }

  /// Gibt die Raum-ID für einen Beacon zurück (nur für Mock)
  String? _getRoomIdForBeacon(String uuid) {
    switch (uuid) {
      case 'beacon_uuid_1':
        return 'room_living';
      case 'beacon_uuid_2':
        return 'room_bedroom';
      case 'beacon_uuid_3':
        return 'room_kitchen';
      case 'beacon_uuid_4':
        return 'room_bathroom';
      default:
        return null;
    }
  }

  /// Startet echtes BLE-Scanning mit flutter_blue_plus
  Future<void> _startRealScanning(int interval, int duration) async {
    StreamSubscription? subscription;

    try {
      // Prüfe ob Bluetooth eingeschaltet ist
      final isAvailable = await isBluetoothAvailable();
      if (!isAvailable) {
        throw Exception('Bluetooth ist nicht verfügbar');
      }

      // Periodisches Scanning
      Timer.periodic(Duration(seconds: interval), (timer) async {
        if (!_isScanning) {
          timer.cancel();
          return;
        }

        try {
          _detectedBeacons.clear();

          // Starte Scan
          await FlutterBluePlus.startScan(
            timeout: Duration(seconds: duration),
          );

          // Höre auf Scan-Ergebnisse
          // CRITICAL FIX: Wrapped callback in try/catch to prevent unhandled exceptions
          subscription = FlutterBluePlus.scanResults.listen((results) {
            try {
              debugPrint('📡 BLE Scan: ${results.length} Geräte gefunden');

              for (var result in results) {
                final device = result.device;
                final rssi = result.rssi;
                final advData = result.advertisementData;

                // Debug-Log für jedes gefundene Gerät
                debugPrint('  🔹 Gerät gefunden:');
                debugPrint('     ID: ${device.remoteId}');
                debugPrint('     Name: ${device.platformName.isEmpty ? "(leer)" : device.platformName}');
                debugPrint('     RSSI: $rssi dBm');
                debugPrint('     ServiceUUIDs: ${advData.serviceUuids}');
                debugPrint('     ManufacturerData: ${advData.manufacturerData}');

                // Versuche iBeacon UUID zu extrahieren
                String uuid = device.remoteId.toString();
                String name = device.platformName.isNotEmpty
                    ? device.platformName
                    : 'BLE Device ${device.remoteId.toString().substring(0, 8)}';

                // Check für iBeacon Format (Apple Company ID: 0x004C)
                if (advData.manufacturerData.containsKey(76)) { // 76 = 0x004C = Apple
                  final data = advData.manufacturerData[76]!;
                  if (data.length >= 23 && data[0] == 0x02 && data[1] == 0x15) {
                    // iBeacon Format erkannt!
                    // UUID ist bei Bytes 2-17 (16 bytes)
                    final uuidBytes = data.sublist(2, 18);
                    uuid = _bytesToUuid(uuidBytes);
                    name = 'iBeacon ${uuid.substring(0, 8)}';
                    debugPrint('     ✅ iBeacon erkannt! UUID: $uuid');
                  }
                }

                // Erstelle BeaconModel
                final beacon = BeaconModel(
                  uuid: uuid,
                  name: name,
                  roomId: null, // Wird später zugeordnet
                  rssi: rssi,
                  lastSeen: DateTime.now(),
                );

                _detectedBeacons[beacon.uuid] = beacon;
                debugPrint('     ➡️ Als Beacon gespeichert: $uuid');
              }

              debugPrint('📊 Total ${_detectedBeacons.length} Beacons im Cache');
            } catch (callbackError) {
              // CRITICAL FIX: Catch exceptions in callback to prevent scan stopping
              debugPrint('Fehler im Scan-Callback: $callbackError');
            }
          });

          // Warte bis Scan fertig ist
          await Future.delayed(Duration(seconds: duration));

          // Stoppe Scan
          await FlutterBluePlus.stopScan();
          await subscription?.cancel();

          // Sende Ergebnisse
          _scanResultsController.add(_detectedBeacons.values.toList());
        } catch (e) {
          debugPrint('Fehler beim BLE-Scanning: $e');
          // CRITICAL FIX: Cancel subscription on error to prevent memory leak
          await subscription?.cancel();
        }
      });
    } catch (e) {
      debugPrint('Fehler beim Starten des BLE-Scannings: $e');
      // CRITICAL FIX: Cancel subscription on error to prevent memory leak
      await subscription?.cancel();
      _isScanning = false;
    }
  }

  /// Stoppt das BLE-Scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    _isScanning = false;

    if (_useMockMode) {
      _mockTimer?.cancel();
      _mockTimer = null;
    } else {
      try {
        await FlutterBluePlus.stopScan();
      } catch (e) {
        debugPrint('Fehler beim Stoppen des BLE-Scans: $e');
      }
    }

    _detectedBeacons.clear();
    debugPrint('BLE-Scanning gestoppt');
  }

  /// Gibt zurück ob gerade gescannt wird
  bool get isScanning => _isScanning;

  /// Gibt zurück ob Mock-Modus aktiv ist
  bool get isMockMode => _useMockMode;

  /// Konvertiert Byte-Array zu UUID-String
  String _bytesToUuid(List<int> bytes) {
    if (bytes.length != 16) return bytes.toString();

    String toHex(int byte) => byte.toRadixString(16).padLeft(2, '0');

    return '${bytes.sublist(0, 4).map(toHex).join()}-'
        '${bytes.sublist(4, 6).map(toHex).join()}-'
        '${bytes.sublist(6, 8).map(toHex).join()}-'
        '${bytes.sublist(8, 10).map(toHex).join()}-'
        '${bytes.sublist(10, 16).map(toHex).join()}';
  }

  /// Aufräumen
  void dispose() {
    stopScanning();
    _scanResultsController.close();
  }
}

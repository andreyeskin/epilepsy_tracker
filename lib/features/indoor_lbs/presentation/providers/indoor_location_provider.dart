import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../data/models/beacon_model.dart';
import '../../data/models/room_model.dart';
import '../../data/repositories/beacon_repository.dart';
import '../../data/services/ble_scanner_service.dart';
import '../../domain/usecases/detect_current_room.dart';
import '../../domain/usecases/evaluate_risk_level.dart';

/// Provider für Indoor-Location State Management
/// Verwaltet den aktuellen Standort, Risikobewertung und Scanning-Status
class IndoorLocationProvider with ChangeNotifier {
  final BeaconRepository _repository;
  final BleScannerService _scannerService;
  final DetectCurrentRoom _detectCurrentRoom;
  final EvaluateRiskLevel _evaluateRiskLevel;

  // State
  RoomModel? _currentRoom;
  RiskLevel _riskLevel = RiskLevel.low;
  Duration _timeInCurrentRoom = Duration.zero;
  bool _isScanning = false;
  List<BeaconModel> _configuredBeacons = [];
  List<BeaconModel> _recentlyDetectedBeacons = [];
  RiskEvaluation? _currentRiskEvaluation;

  // Timer für Verweildauer
  Timer? _dwellTimer;
  DateTime? _roomEntryTime;

  // Subscription für Scan-Ergebnisse
  StreamSubscription<List<BeaconModel>>? _scanSubscription;

  IndoorLocationProvider({
    required BeaconRepository repository,
    required BleScannerService scannerService,
    required DetectCurrentRoom detectCurrentRoom,
    required EvaluateRiskLevel evaluateRiskLevel,
  })  : _repository = repository,
        _scannerService = scannerService,
        _detectCurrentRoom = detectCurrentRoom,
        _evaluateRiskLevel = evaluateRiskLevel {
    _initialize();
  }

  // Getters
  RoomModel? get currentRoom => _currentRoom;
  RiskLevel get riskLevel => _riskLevel;
  Duration get timeInCurrentRoom => _timeInCurrentRoom;
  bool get isScanning => _isScanning;
  bool get isMockMode => _scannerService.isMockMode;
  List<BeaconModel> get configuredBeacons => List.unmodifiable(_configuredBeacons);
  List<BeaconModel> get recentlyDetectedBeacons =>
      List.unmodifiable(_recentlyDetectedBeacons);
  RiskEvaluation? get currentRiskEvaluation => _currentRiskEvaluation;
  List<RoomModel> get allRooms => _repository.getRooms();

  /// Initialisiert den Provider
  void _initialize() {
    // Lade konfigurierte Beacons
    _configuredBeacons = _repository.getBeacons();
    notifyListeners();
  }

  /// Startet das BLE-Scanning
  Future<void> startScanning() async {
    if (_isScanning) {
      debugPrint('Scanning läuft bereits');
      return;
    }

    try {
      // CRITICAL FIX: Request runtime permissions before scanning
      final permissionsGranted = await _requestPermissions();
      if (!permissionsGranted) {
        debugPrint('Berechtigungen wurden nicht erteilt');
        throw Exception('Bluetooth and Location permissions are required');
      }

      _isScanning = true;
      notifyListeners();

      // Starte Scanner Service
      await _scannerService.startScanning(
        scanInterval: 5,
        scanDuration: 3,
      );

      // Höre auf Scan-Ergebnisse
      _scanSubscription = _scannerService.scanResults.listen(_onScanResults);

      debugPrint('Indoor-Location Scanning gestartet');
    } catch (e) {
      debugPrint('Fehler beim Starten des Scannings: $e');
      _isScanning = false;
      notifyListeners();
      rethrow;
    }
  }

  /// Requests necessary permissions for BLE scanning
  Future<bool> _requestPermissions() async {
    // Skip permission check in mock mode
    if (isMockMode) return true;

    // For Android 12+ (API 31+), we need BLUETOOTH_SCAN and BLUETOOTH_CONNECT
    // For older versions, we need BLUETOOTH and LOCATION
    Map<Permission, PermissionStatus> statuses = await [
      Permission.bluetoothScan,
      Permission.bluetoothConnect,
      Permission.locationWhenInUse,
    ].request();

    // Check if all permissions are granted
    bool allGranted = statuses.values.every(
      (status) => status.isGranted || status.isLimited,
    );

    if (!allGranted) {
      debugPrint('Nicht alle Berechtigungen erteilt:');
      statuses.forEach((permission, status) {
        debugPrint('  $permission: $status');
      });
    }

    return allGranted;
  }

  /// Stoppt das BLE-Scanning
  Future<void> stopScanning() async {
    if (!_isScanning) return;

    try {
      await _scannerService.stopScanning();
      await _scanSubscription?.cancel();
      _scanSubscription = null;

      _isScanning = false;
      _stopDwellTimer();

      debugPrint('Indoor-Location Scanning gestoppt');
      notifyListeners();
    } catch (e) {
      debugPrint('Fehler beim Stoppen des Scannings: $e');
    }
  }

  /// Callback für Scan-Ergebnisse
  void _onScanResults(List<BeaconModel> beacons) {
    _recentlyDetectedBeacons = beacons;

    // Erkenne aktuellen Raum
    final detectedRoom = _detectCurrentRoom(
      scannedBeacons: beacons,
      minRssiThreshold: -90,
    );

    // Prüfe ob Raum gewechselt wurde
    if (detectedRoom?.id != _currentRoom?.id) {
      _onRoomChanged(detectedRoom);
    }

    // Bewerte Risiko
    _updateRiskEvaluation();

    notifyListeners();
  }

  /// Wird aufgerufen wenn der Raum gewechselt wurde
  void _onRoomChanged(RoomModel? newRoom) {
    debugPrint('Raumwechsel: ${_currentRoom?.name} -> ${newRoom?.name}');

    _currentRoom = newRoom;
    _roomEntryTime = newRoom != null ? DateTime.now() : null;
    _timeInCurrentRoom = Duration.zero;

    // Starte/Stoppe Verweildauer-Timer
    if (newRoom != null) {
      _startDwellTimer();
    } else {
      _stopDwellTimer();
    }
  }

  /// Startet den Verweildauer-Timer
  void _startDwellTimer() {
    _stopDwellTimer();

    _dwellTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_roomEntryTime != null) {
        _timeInCurrentRoom = DateTime.now().difference(_roomEntryTime!);
        _updateRiskEvaluation();
        notifyListeners();
      }
    });
  }

  /// Stoppt den Verweildauer-Timer
  void _stopDwellTimer() {
    _dwellTimer?.cancel();
    _dwellTimer = null;
  }

  /// Aktualisiert die Risikobewertung
  void _updateRiskEvaluation() {
    _currentRiskEvaluation = _evaluateRiskLevel(
      currentRoom: _currentRoom,
      dwellTime: _timeInCurrentRoom,
      // Hier könnten Vitaldaten von Fitbit integriert werden
      // heartRate: _fitbitData?.heartRate,
      // movementLevel: _fitbitData?.movementLevel,
    );

    _riskLevel = _currentRiskEvaluation?.riskLevel ?? RiskLevel.low;
  }

  /// Fügt einen neuen Beacon hinzu
  Future<void> configureBeacon(BeaconModel beacon) async {
    _repository.saveBeacon(beacon);
    _configuredBeacons = _repository.getBeacons();
    notifyListeners();
    debugPrint('Beacon konfiguriert: ${beacon.name}');
  }

  /// Entfernt einen Beacon
  Future<void> removeBeacon(String uuid) async {
    _repository.removeBeacon(uuid);
    _configuredBeacons = _repository.getBeacons();
    notifyListeners();
    debugPrint('Beacon entfernt: $uuid');
  }

  /// Fügt einen neuen Raum hinzu
  Future<void> addRoom(RoomModel room) async {
    _repository.saveRoom(room);
    notifyListeners();
    debugPrint('Raum hinzugefügt: ${room.name}');
  }

  /// Entfernt einen Raum
  Future<void> removeRoom(String roomId) async {
    _repository.removeRoom(roomId);
    if (_currentRoom?.id == roomId) {
      _currentRoom = null;
    }
    notifyListeners();
    debugPrint('Raum entfernt: $roomId');
  }

  /// Initialisiert Mock-Daten
  void initializeMockData() {
    _repository.initializeMockData();
    _configuredBeacons = _repository.getBeacons();
    notifyListeners();
    debugPrint('Mock-Daten initialisiert');
  }

  /// Setzt Mock-Modus für Scanner
  void setMockMode(bool enabled) {
    if (_isScanning) {
      debugPrint('Kann Mock-Modus nicht ändern während gescannt wird');
      return;
    }
    _scannerService.setMockMode(enabled);
    debugPrint('Mock-Modus: ${enabled ? "aktiviert" : "deaktiviert"}');
  }

  /// Manuelles Setzen des aktuellen Raums (für Tests/Demo)
  void setCurrentRoomManually(RoomModel? room) {
    if (_currentRoom?.id != room?.id) {
      _onRoomChanged(room);
      _updateRiskEvaluation();
      notifyListeners();
    }
  }

  @override
  void dispose() {
    stopScanning();
    _stopDwellTimer();
    _scanSubscription?.cancel();
    super.dispose();
  }
}

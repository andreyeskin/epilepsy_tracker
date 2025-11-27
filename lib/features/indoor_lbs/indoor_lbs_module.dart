/// Indoor Location-Based Service (LBS) Modul
///
/// Dieses Modul stellt alle Komponenten für Indoor-Positionierung
/// und Safe-Zone-Überwachung mit BLE-Beacons bereit.
library indoor_lbs;

// Data Layer
export 'data/models/beacon_model.dart';
export 'data/models/room_model.dart';
export 'data/models/risk_zone_model.dart';
export 'data/repositories/beacon_repository.dart';
export 'data/services/ble_scanner_service.dart';

// Domain Layer
export 'domain/usecases/detect_current_room.dart';
export 'domain/usecases/evaluate_risk_level.dart';

// Presentation Layer
export 'presentation/providers/indoor_location_provider.dart';
export 'presentation/screens/safe_zone_screen.dart';
export 'presentation/widgets/beacon_setup_widget.dart';
export 'presentation/widgets/risk_alert_widget.dart';
export 'presentation/widgets/room_indicator_widget.dart';

import 'data/repositories/beacon_repository.dart';
import 'data/services/ble_scanner_service.dart';
import 'domain/usecases/detect_current_room.dart';
import 'domain/usecases/evaluate_risk_level.dart';
import 'presentation/providers/indoor_location_provider.dart';

/// Helper-Klasse zum einfachen Setup des Indoor-LBS-Moduls
class IndoorLbsModule {
  static IndoorLocationProvider? _provider;

  /// Erstellt und konfiguriert den IndoorLocationProvider
  ///
  /// Verwendung:
  /// ```dart
  /// final provider = IndoorLbsModule.createProvider();
  ///
  /// // In main.dart:
  /// ChangeNotifierProvider(
  ///   create: (_) => provider,
  ///   child: MyApp(),
  /// )
  /// ```
  static IndoorLocationProvider createProvider({
    bool initializeMockData = true,
  }) {
    if (_provider != null) {
      return _provider!;
    }

    // Initialisiere Dependencies
    final repository = BeaconRepository();
    final scannerService = BleScannerService();
    final detectCurrentRoom = DetectCurrentRoom(repository);
    final evaluateRiskLevel = EvaluateRiskLevel(repository);

    // Erstelle Provider
    _provider = IndoorLocationProvider(
      repository: repository,
      scannerService: scannerService,
      detectCurrentRoom: detectCurrentRoom,
      evaluateRiskLevel: evaluateRiskLevel,
    );

    // Optional: Initialisiere Mock-Daten für Demo/Tests
    if (initializeMockData) {
      _provider!.initializeMockData();
    }

    return _provider!;
  }

  /// Gibt den bestehenden Provider zurück (falls vorhanden)
  static IndoorLocationProvider? get provider => _provider;

  /// Setzt den Provider zurück (nützlich für Tests)
  static void reset() {
    _provider?.dispose();
    _provider = null;
  }
}

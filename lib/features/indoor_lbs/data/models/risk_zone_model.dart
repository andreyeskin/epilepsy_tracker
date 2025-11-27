import 'room_model.dart';

/// Notfallaktion die bei erhöhtem Risiko ausgeführt werden kann
enum EmergencyAction {
  alert,           // Warnung anzeigen
  notifyContacts,  // Notfallkontakte benachrichtigen
  callEmergency,   // Notruf wählen
  activateSafeMode; // Sicherheitsmodus aktivieren

  String get displayName {
    switch (this) {
      case EmergencyAction.alert:
        return 'Warnung anzeigen';
      case EmergencyAction.notifyContacts:
        return 'Kontakte benachrichtigen';
      case EmergencyAction.callEmergency:
        return 'Notruf wählen';
      case EmergencyAction.activateSafeMode:
        return 'Sicherheitsmodus aktivieren';
    }
  }
}

/// Modell für eine Risikozone
/// Enthält Raum-Referenz, Risikofaktoren, empfohlene Verweildauer und Notfallaktionen
class RiskZoneModel {
  final String roomId;
  final List<String> riskFactors;
  final Duration? recommendedDwellTime;
  final List<EmergencyAction> emergencyActions;
  final String? warningMessage;

  RiskZoneModel({
    required this.roomId,
    required this.riskFactors,
    this.recommendedDwellTime,
    required this.emergencyActions,
    this.warningMessage,
  });

  /// Erstellt ein RiskZoneModel aus JSON
  factory RiskZoneModel.fromJson(Map<String, dynamic> json) {
    return RiskZoneModel(
      roomId: json['roomId'] as String,
      riskFactors: (json['riskFactors'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      recommendedDwellTime: json['recommendedDwellTime'] != null
          ? Duration(minutes: json['recommendedDwellTime'] as int)
          : null,
      emergencyActions: (json['emergencyActions'] as List<dynamic>)
          .map((e) => EmergencyAction.values.firstWhere(
                (action) => action.name == e,
                orElse: () => EmergencyAction.alert,
              ))
          .toList(),
      warningMessage: json['warningMessage'] as String?,
    );
  }

  /// Konvertiert das RiskZoneModel zu JSON
  Map<String, dynamic> toJson() {
    return {
      'roomId': roomId,
      'riskFactors': riskFactors,
      'recommendedDwellTime': recommendedDwellTime?.inMinutes,
      'emergencyActions': emergencyActions.map((e) => e.name).toList(),
      'warningMessage': warningMessage,
    };
  }

  /// Kopiert das RiskZoneModel mit optionalen Änderungen
  RiskZoneModel copyWith({
    String? roomId,
    List<String>? riskFactors,
    Duration? recommendedDwellTime,
    List<EmergencyAction>? emergencyActions,
    String? warningMessage,
  }) {
    return RiskZoneModel(
      roomId: roomId ?? this.roomId,
      riskFactors: riskFactors ?? this.riskFactors,
      recommendedDwellTime: recommendedDwellTime ?? this.recommendedDwellTime,
      emergencyActions: emergencyActions ?? this.emergencyActions,
      warningMessage: warningMessage ?? this.warningMessage,
    );
  }

  /// Prüft ob die Verweildauer überschritten wurde
  bool isDwellTimeExceeded(Duration currentDwellTime) {
    if (recommendedDwellTime == null) return false;
    return currentDwellTime > recommendedDwellTime!;
  }

  /// Erstellt eine Standard-Risikozone basierend auf dem RiskLevel
  factory RiskZoneModel.fromRoomModel(RoomModel room) {
    List<String> factors = [];
    Duration? dwellTime;
    List<EmergencyAction> actions = [EmergencyAction.alert];
    String? message;

    switch (room.riskLevel) {
      case RiskLevel.high:
        factors = ['Sturzgefahr', 'Rutschgefahr', 'Harte Oberflächen'];
        dwellTime = const Duration(minutes: 15);
        actions = [
          EmergencyAction.alert,
          EmergencyAction.notifyContacts,
        ];
        message =
            'Sie befinden sich in einem Hochrisikobereich. Bitte seien Sie vorsichtig.';
        break;
      case RiskLevel.medium:
        factors = ['Heiße Oberflächen', 'Scharfe Gegenstände'];
        dwellTime = const Duration(minutes: 30);
        actions = [EmergencyAction.alert];
        message = 'Achtung: Erhöhtes Risiko in diesem Bereich.';
        break;
      case RiskLevel.low:
        factors = ['Minimales Risiko'];
        dwellTime = null;
        actions = [];
        message = null;
        break;
    }

    return RiskZoneModel(
      roomId: room.id,
      riskFactors: factors,
      recommendedDwellTime: dwellTime,
      emergencyActions: actions,
      warningMessage: message,
    );
  }

  @override
  String toString() {
    return 'RiskZoneModel(roomId: $roomId, factors: ${riskFactors.length}, dwellTime: ${recommendedDwellTime?.inMinutes ?? 0}min)';
  }
}

import '../../data/models/room_model.dart';
import '../../data/models/risk_zone_model.dart';
import '../../data/repositories/beacon_repository.dart';

/// Ergebnis der Risikobewertung
class RiskEvaluation {
  final int riskScore; // 0-100
  final RiskLevel riskLevel;
  final String message;
  final List<String> recommendations;
  final bool shouldAlert;
  final Duration? timeUntilWarning;

  RiskEvaluation({
    required this.riskScore,
    required this.riskLevel,
    required this.message,
    required this.recommendations,
    required this.shouldAlert,
    this.timeUntilWarning,
  });
}

/// Use Case: Bewertet das Risiko basierend auf aktuellem Raum und Kontext
///
/// Berücksichtigt:
/// - Risikolevel des Raums
/// - Verweildauer im Raum
/// - Optionale Smartwatch-Daten (Herzfrequenz, Bewegung)
class EvaluateRiskLevel {
  final BeaconRepository _repository;

  EvaluateRiskLevel(this._repository);

  /// Führt die Risikobewertung aus
  ///
  /// [currentRoom] - Der aktuelle Raum
  /// [dwellTime] - Wie lange sich der Nutzer bereits im Raum befindet
  /// [heartRate] - Optional: Aktuelle Herzfrequenz (bpm)
  /// [movementLevel] - Optional: Bewegungslevel (0.0 - 1.0)
  ///
  /// Gibt eine RiskEvaluation mit Score und Empfehlungen zurück
  RiskEvaluation call({
    required RoomModel? currentRoom,
    required Duration dwellTime,
    int? heartRate,
    double? movementLevel,
  }) {
    // Kein Raum erkannt = kein Risiko
    if (currentRoom == null) {
      return RiskEvaluation(
        riskScore: 0,
        riskLevel: RiskLevel.low,
        message: 'Aktueller Standort unbekannt',
        recommendations: ['Überprüfen Sie die Beacon-Konfiguration'],
        shouldAlert: false,
      );
    }

    // Hole Risikozone für Raum
    final riskZone = _repository.getRiskZoneForRoom(currentRoom.id);

    // Berechne Basis-Risiko basierend auf Raum
    int riskScore = _calculateBaseRisk(currentRoom.riskLevel);

    // Erhöhe Risiko basierend auf Verweildauer
    riskScore += _calculateDwellTimeRisk(dwellTime, riskZone);

    // Berücksichtige Vitaldaten falls verfügbar
    if (heartRate != null) {
      riskScore += _calculateHeartRateRisk(heartRate);
    }

    if (movementLevel != null) {
      riskScore += _calculateMovementRisk(movementLevel, currentRoom);
    }

    // Begrenze Score auf 0-100
    riskScore = riskScore.clamp(0, 100);

    // Bestimme effektives Risikolevel
    final effectiveRiskLevel = _determineRiskLevel(riskScore);

    // Erstelle Nachricht und Empfehlungen
    final message = _createMessage(currentRoom, riskScore, dwellTime, riskZone);
    final recommendations = _createRecommendations(
      currentRoom,
      riskScore,
      dwellTime,
      riskZone,
      heartRate,
      movementLevel,
    );

    // Prüfe ob Warnung nötig
    final shouldAlert = _shouldAlert(riskScore, currentRoom, dwellTime, riskZone);
    final timeUntilWarning = _calculateTimeUntilWarning(dwellTime, riskZone);

    return RiskEvaluation(
      riskScore: riskScore,
      riskLevel: effectiveRiskLevel,
      message: message,
      recommendations: recommendations,
      shouldAlert: shouldAlert,
      timeUntilWarning: timeUntilWarning,
    );
  }

  /// Berechnet Basis-Risiko basierend auf Raum-Risikolevel
  int _calculateBaseRisk(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return 10;
      case RiskLevel.medium:
        return 35;
      case RiskLevel.high:
        return 60;
    }
  }

  /// Berechnet Risiko basierend auf Verweildauer
  int _calculateDwellTimeRisk(Duration dwellTime, RiskZoneModel? riskZone) {
    if (riskZone?.recommendedDwellTime == null) return 0;

    final recommended = riskZone!.recommendedDwellTime!;
    if (dwellTime <= recommended) return 0;

    // +10 Punkte pro 5 Minuten Überschreitung
    final excessMinutes = dwellTime.inMinutes - recommended.inMinutes;
    return (excessMinutes / 5 * 10).round().clamp(0, 30);
  }

  /// Berechnet Risiko basierend auf Herzfrequenz
  int _calculateHeartRateRisk(int heartRate) {
    // Normale Ruheherzfrequenz: 60-100 bpm
    if (heartRate >= 60 && heartRate <= 100) return 0;

    // Zu niedrig (< 60) oder zu hoch (> 100)
    if (heartRate < 60) {
      return ((60 - heartRate) / 10 * 5).round().clamp(0, 15);
    } else {
      return ((heartRate - 100) / 10 * 5).round().clamp(0, 15);
    }
  }

  /// Berechnet Risiko basierend auf Bewegungslevel
  int _calculateMovementRisk(double movementLevel, RoomModel room) {
    // In Hochrisiko-Räumen ist hohe Bewegung riskant
    if (room.riskLevel == RiskLevel.high && movementLevel > 0.7) {
      return 10;
    }
    // In sicheren Räumen ist wenig Bewegung normal
    return 0;
  }

  /// Bestimmt Risikolevel basierend auf Score
  RiskLevel _determineRiskLevel(int score) {
    if (score < 30) return RiskLevel.low;
    if (score < 60) return RiskLevel.medium;
    return RiskLevel.high;
  }

  /// Erstellt aussagekräftige Nachricht
  String _createMessage(
    RoomModel room,
    int score,
    Duration dwellTime,
    RiskZoneModel? riskZone,
  ) {
    if (score < 30) {
      return 'Alles in Ordnung. Sie befinden sich im ${room.name}.';
    } else if (score < 60) {
      return 'Erhöhte Aufmerksamkeit empfohlen im ${room.name}.';
    } else {
      if (riskZone?.isDwellTimeExceeded(dwellTime) == true) {
        return 'Warnung: Sie sind bereits ${dwellTime.inMinutes} Minuten im ${room.name}.';
      }
      return 'Achtung: Hochrisiko-Bereich ${room.name}!';
    }
  }

  /// Erstellt Handlungsempfehlungen
  List<String> _createRecommendations(
    RoomModel room,
    int score,
    Duration dwellTime,
    RiskZoneModel? riskZone,
    int? heartRate,
    double? movementLevel,
  ) {
    final recommendations = <String>[];

    // Raum-spezifische Empfehlungen
    if (room.riskLevel == RiskLevel.high) {
      recommendations.add('Seien Sie besonders vorsichtig');
      if (room.name.toLowerCase().contains('bad')) {
        recommendations.add('Verwenden Sie Anti-Rutsch-Matten');
      }
    }

    // Verweildauer-Empfehlungen
    if (riskZone?.isDwellTimeExceeded(dwellTime) == true) {
      recommendations.add('Erwägen Sie, den Raum zu verlassen');
    }

    // Vitaldaten-Empfehlungen
    if (heartRate != null && (heartRate < 60 || heartRate > 100)) {
      recommendations.add('Ungewöhnliche Herzfrequenz erkannt');
    }

    // Score-basierte Empfehlungen
    if (score >= 70) {
      recommendations.add('Erwägen Sie, in einen sichereren Bereich zu gehen');
      recommendations.add('Benachrichtigen Sie ggf. eine Vertrauensperson');
    }

    return recommendations;
  }

  /// Prüft ob eine Warnung ausgegeben werden sollte
  bool _shouldAlert(
    int score,
    RoomModel room,
    Duration dwellTime,
    RiskZoneModel? riskZone,
  ) {
    // Hoher Score = immer warnen
    if (score >= 70) return true;

    // Hochrisiko-Raum mit überschrittener Verweildauer
    if (room.riskLevel == RiskLevel.high &&
        riskZone?.isDwellTimeExceeded(dwellTime) == true) {
      return true;
    }

    return false;
  }

  /// Berechnet verbleibende Zeit bis zur Warnung
  Duration? _calculateTimeUntilWarning(
    Duration dwellTime,
    RiskZoneModel? riskZone,
  ) {
    if (riskZone?.recommendedDwellTime == null) return null;

    final remaining =
        riskZone!.recommendedDwellTime!.inSeconds - dwellTime.inSeconds;
    if (remaining <= 0) return Duration.zero;

    return Duration(seconds: remaining);
  }
}

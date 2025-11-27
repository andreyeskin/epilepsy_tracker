import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/room_model.dart';
import '../providers/indoor_location_provider.dart';

/// Widget das den aktuellen Raum kompakt anzeigt
/// Kann in anderen Screens eingebunden werden (z.B. Start-Screen)
class RoomIndicatorWidget extends StatelessWidget {
  final bool showDetails;
  final VoidCallback? onTap;

  const RoomIndicatorWidget({
    super.key,
    this.showDetails = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorLocationProvider>(
      builder: (context, provider, child) {
        final room = provider.currentRoom;
        final riskLevel = provider.riskLevel;
        final timeInRoom = provider.timeInCurrentRoom;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: _getBackgroundColor(room, riskLevel),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: riskLevel.color.withOpacity(0.5),
                width: 2,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Icon
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    room?.icon ?? Icons.location_off,
                    color: riskLevel.color,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),

                // Text-Info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        room?.name ?? 'Unbekannt',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      if (showDetails && room != null) ...[
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            Icon(
                              Icons.timer,
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              _formatDuration(timeInRoom),
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Icon(
                              _getRiskIcon(riskLevel),
                              size: 14,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              riskLevel.displayName,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ],
                  ),
                ),

                // Status-Indikator
                if (provider.isScanning)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),

                // Pfeil für Tap-Aktion
                if (onTap != null)
                  const Padding(
                    padding: EdgeInsets.only(left: 8),
                    child: Icon(
                      Icons.chevron_right,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Gibt die Hintergrundfarbe basierend auf Raum und Risiko zurück
  Color _getBackgroundColor(RoomModel? room, RiskLevel riskLevel) {
    if (room == null) {
      return Colors.grey;
    }
    return riskLevel.color;
  }

  /// Gibt das Icon für das Risikolevel zurück
  IconData _getRiskIcon(RiskLevel level) {
    switch (level) {
      case RiskLevel.low:
        return Icons.check_circle;
      case RiskLevel.medium:
        return Icons.warning_amber;
      case RiskLevel.high:
        return Icons.error;
    }
  }

  /// Formatiert die Verweildauer
  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m';
    } else {
      return '${minutes}m';
    }
  }
}

/// Kompakte Version für kleine Spaces
class RoomIndicatorCompact extends StatelessWidget {
  final VoidCallback? onTap;

  const RoomIndicatorCompact({super.key, this.onTap});

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorLocationProvider>(
      builder: (context, provider, child) {
        final room = provider.currentRoom;
        final riskLevel = provider.riskLevel;

        return GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: riskLevel.color,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  room?.icon ?? Icons.location_off,
                  color: Colors.white,
                  size: 16,
                ),
                const SizedBox(width: 6),
                Text(
                  room?.name ?? 'Unbekannt',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

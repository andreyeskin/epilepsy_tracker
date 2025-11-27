import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/indoor_location_provider.dart';

/// Widget das eine Risiko-Warnung anzeigt
/// Erscheint bei erhöhtem Risiko und bietet Aktionen an
class RiskAlertWidget extends StatelessWidget {
  final VoidCallback? onDismiss;
  final VoidCallback? onCallHelp;

  const RiskAlertWidget({
    super.key,
    this.onDismiss,
    this.onCallHelp,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorLocationProvider>(
      builder: (context, provider, child) {
        final evaluation = provider.currentRiskEvaluation;

        // Zeige nur bei tatsächlicher Warnung an
        if (evaluation == null || !evaluation.shouldAlert) {
          return const SizedBox.shrink();
        }

        return Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: Colors.red,
              width: 2,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(10),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.warning_rounded,
                      color: Colors.white,
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Sicherheitswarnung',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Risiko-Level: ${evaluation.riskLevel.displayName}',
                            style: const TextStyle(
                              color: Colors.white70,
                              fontSize: 14,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Risk Score Badge
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${evaluation.riskScore}',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Content
              Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Hauptnachricht
                    Text(
                      evaluation.message,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 12),

                    // Timer falls vorhanden
                    if (evaluation.timeUntilWarning != null &&
                        evaluation.timeUntilWarning!.inSeconds > 0) ...[
                      _TimerDisplay(
                        timeRemaining: evaluation.timeUntilWarning!,
                      ),
                      const SizedBox(height: 12),
                    ],

                    // Empfehlungen
                    if (evaluation.recommendations.isNotEmpty) ...[
                      const Text(
                        'Empfehlungen:',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 8),
                      ...evaluation.recommendations.map((recommendation) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 4),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.check_circle_outline,
                                size: 16,
                                color: Colors.red,
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  recommendation,
                                  style: const TextStyle(fontSize: 14),
                                ),
                              ),
                            ],
                          ),
                        );
                      }),
                      const SizedBox(height: 16),
                    ],

                    // Aktions-Buttons
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              onDismiss?.call();
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Warnung bestätigt'),
                                  duration: Duration(seconds: 2),
                                ),
                              );
                            },
                            icon: const Icon(Icons.check),
                            label: const Text('Mir geht es gut'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.green,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: ElevatedButton.icon(
                            onPressed: () {
                              onCallHelp?.call();
                              _showHelpDialog(context);
                            },
                            icon: const Icon(Icons.phone),
                            label: const Text('Hilfe rufen'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  /// Zeigt Dialog mit Hilfe-Optionen
  void _showHelpDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hilfe rufen'),
        content: const Text(
          'Wählen Sie eine Option:\n\n'
          '• Notfallkontakte werden benachrichtigt\n'
          '• Bei schwerwiegenden Symptomen: 112 wählen',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Abbrechen'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Notfallkontakte werden benachrichtigt...'),
                ),
              );
            },
            child: const Text('Kontakte benachrichtigen'),
          ),
        ],
      ),
    );
  }
}

/// Widget das verbleibende Zeit bis zur Warnung anzeigt
class _TimerDisplay extends StatelessWidget {
  final Duration timeRemaining;

  const _TimerDisplay({required this.timeRemaining});

  @override
  Widget build(BuildContext context) {
    final minutes = timeRemaining.inMinutes;
    final seconds = timeRemaining.inSeconds.remainder(60);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.orange.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.orange),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.timer,
            color: Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            timeRemaining.inSeconds > 0
                ? 'Empfohlene Verweildauer endet in ${minutes}:${seconds.toString().padLeft(2, '0')} min'
                : 'Empfohlene Verweildauer überschritten',
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: Colors.orange,
            ),
          ),
        ],
      ),
    );
  }
}

/// Kompakte Risiko-Anzeige für permanente Anzeige
class RiskLevelIndicator extends StatelessWidget {
  const RiskLevelIndicator({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IndoorLocationProvider>(
      builder: (context, provider, child) {
        final evaluation = provider.currentRiskEvaluation;
        if (evaluation == null) {
          return const SizedBox.shrink();
        }

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: evaluation.riskLevel.color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: evaluation.riskLevel.color,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getIconForScore(evaluation.riskScore),
                size: 16,
                color: evaluation.riskLevel.color,
              ),
              const SizedBox(width: 6),
              Text(
                'Risiko: ${evaluation.riskLevel.displayName}',
                style: TextStyle(
                  color: evaluation.riskLevel.color,
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  IconData _getIconForScore(int score) {
    if (score < 30) return Icons.check_circle;
    if (score < 60) return Icons.warning_amber;
    return Icons.error;
  }
}

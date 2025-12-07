import 'package:flutter/material.dart';
import '../../../widgets/quick_action_card.dart';

/// 4 Action Cards Grid
/// Schnellzugriff auf wichtige Funktionen
class QuickActionsGrid extends StatelessWidget {
  final VoidCallback onSeizureLog;
  final VoidCallback onMedication;
  final VoidCallback onRelaxation;
  final VoidCallback onInsights;

  const QuickActionsGrid({
    super.key,
    required this.onSeizureLog,
    required this.onMedication,
    required this.onRelaxation,
    required this.onInsights,
  });

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      mainAxisSpacing: 12,
      crossAxisSpacing: 12,
      childAspectRatio: 1.1,
      children: [
        QuickActionCard(
          icon: Icons.add_circle_outline,
          title: 'Anfall protokollieren',
          description: 'Schnelle Dokumentation',
          color: const Color(0xFF8FD1B7),
          onTap: onSeizureLog,
        ),
        QuickActionCard(
          icon: Icons.medication,
          title: 'Medikamente',
          description: 'Einnahme bestätigen',
          color: const Color(0xFFA6D5C4),
          onTap: onMedication,
        ),
        QuickActionCard(
          icon: Icons.self_improvement,
          title: 'Ruheraum',
          description: 'Entspannung & Atmung',
          color: const Color(0xFF3A8C78),
          onTap: onRelaxation,
        ),
        QuickActionCard(
          icon: Icons.notifications_active,
          title: 'Einblicke',
          description: 'Deine Fortschritte',
          color: const Color(0xFF4CAF93),
          onTap: onInsights,
        ),
      ],
    );
  }
}

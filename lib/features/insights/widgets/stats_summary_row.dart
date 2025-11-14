import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Stats Summary Row - Zeigt 3 wichtige Metriken
/// Gesamt, Veränderung %, Durchschnitt
class StatsSummaryRow extends StatelessWidget {
  final int totalSeizures;
  final double changePercentage; // Kann positiv oder negativ sein
  final double averagePerWeek;

  const StatsSummaryRow({
    super.key,
    required this.totalSeizures,
    required this.changePercentage,
    required this.averagePerWeek,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Gesamt',
            value: totalSeizures.toString(),
            icon: Icons.event_note,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _StatCard(
            label: 'Veränderung',
            value: '${changePercentage >= 0 ? '+' : ''}${changePercentage.toInt()}%',
            icon: changePercentage >= 0 ? Icons.trending_up : Icons.trending_down,
            color: changePercentage >= 0 ? AppColors.error : AppColors.success,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _StatCard(
            label: 'Ø pro Woche',
            value: averagePerWeek.toStringAsFixed(1),
            icon: Icons.bar_chart,
            color: AppColors.info,
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: Icon(
              icon,
              color: color,
              size: 20,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            value,
            style: AppTextStyles.h3.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            label,
            style: AppTextStyles.labelSmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

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
            icon: Icons.event_note_rounded,
            color: AppColors.primary,
            gradient: AppColors.primaryGradient,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _StatCard(
            label: 'Veränderung',
            value: '${changePercentage >= 0 ? '+' : ''}${changePercentage.toInt()}%',
            icon: changePercentage >= 0 ? Icons.trending_up_rounded : Icons.trending_down_rounded,
            color: changePercentage >= 0 ? AppColors.error : AppColors.success,
            gradient: LinearGradient(
              colors: changePercentage >= 0
                  ? [AppColors.error, AppColors.errorLight]
                  : [AppColors.success, AppColors.successLight],
            ),
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: _StatCard(
            label: 'Ø pro Woche',
            value: averagePerWeek.toStringAsFixed(1),
            icon: Icons.bar_chart_rounded,
            color: AppColors.info,
            gradient: AppColors.accentGradient,
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
  final Gradient gradient;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingMd),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        boxShadow: [AppColors.elevation1],
      ),
      child: Column(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: color.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Icon(
              icon,
              color: AppColors.textOnPrimary,
              size: 24,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          Text(
            value,
            style: AppTextStyles.h4.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingXs),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

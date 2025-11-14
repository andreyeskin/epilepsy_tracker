import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Donut Chart für Auslöser-Verteilung
/// Zeigt die prozentuale Verteilung der Anfalls-Auslöser
class TriggerDonutChart extends StatelessWidget {
  final Map<String, double> triggerData;

  const TriggerDonutChart({
    super.key,
    required this.triggerData,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 1.3,
          child: PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: _buildSections(),
              pieTouchData: PieTouchData(
                touchCallback: (FlTouchEvent event, pieTouchResponse) {},
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        _buildLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colors = [
      AppColors.primary,
      AppColors.primaryMedium,
      AppColors.warning,
      AppColors.info,
      AppColors.primaryLight,
    ];

    int colorIndex = 0;
    return triggerData.entries.map((entry) {
      final color = colors[colorIndex % colors.length];
      colorIndex++;

      return PieChartSectionData(
        color: color,
        value: entry.value,
        title: '${entry.value.toInt()}%',
        radius: 50,
        titleStyle: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      );
    }).toList();
  }

  Widget _buildLegend() {
    final colors = [
      AppColors.primary,
      AppColors.primaryMedium,
      AppColors.warning,
      AppColors.info,
      AppColors.primaryLight,
    ];

    int colorIndex = 0;
    return Wrap(
      spacing: AppDimensions.spacingMd,
      runSpacing: AppDimensions.spacingSm,
      children: triggerData.entries.map((entry) {
        final color = colors[colorIndex % colors.length];
        colorIndex++;

        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Text(
              entry.key,
              style: AppTextStyles.bodySmall.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ],
        );
      }).toList(),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';

/// Bar Chart für Anfallshäufigkeit pro Woche
/// Zeigt die Anzahl der Anfälle für die letzten 4 Wochen mit verbesserter UI
class SeizureFrequencyChart extends StatelessWidget {
  final List<int> weeklyData;

  const SeizureFrequencyChart({
    super.key,
    required this.weeklyData,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: _getMaxY(),
          barTouchData: BarTouchData(
            enabled: true,
            touchTooltipData: BarTouchTooltipData(
              tooltipBgColor: AppColors.primaryDark.withOpacity(0.85),
              tooltipBorder: const BorderSide(color: AppColors.primaryLight, width: 1),
              tooltipRoundedRadius: AppDimensions.radiusMd,
              getTooltipItem: (group, groupIndex, rod, rodIndex) {
                return BarTooltipItem(
                  '${rod.toY.toInt()} Anfälle',
                  AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textOnPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                );
              },
            ),
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, meta) {
                  const weeks = ['Woche 1', 'Woche 2', 'Woche 3', 'Woche 4'];
                  if (value.toInt() >= 0 && value.toInt() < weeks.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
                      child: Text(
                        weeks[value.toInt()],
                        style: AppTextStyles.bodyXSmall.copyWith(
                          color: AppColors.textTertiary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
            leftTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                interval: 1,
                getTitlesWidget: (value, meta) {
                  if (value % 1 == 0 && value <= _getMaxY()) {
                    return Text(
                      value.toInt().toString(),
                      style: AppTextStyles.bodyXSmall.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    );
                  }
                  return const Text('');
                },
              ),
            ),
          ),
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.outlineVariant.withOpacity(0.7),
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 1.5),
              left: BorderSide(color: AppColors.outlineVariant, width: 1.5),
            ),
          ),
          barGroups: _buildBarGroups(),
        ),
        swapAnimationDuration: const Duration(milliseconds: 450),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  List<BarChartGroupData> _buildBarGroups() {
    return List.generate(weeklyData.length, (index) {
      final isZero = weeklyData[index] == 0;
      return BarChartGroupData(
        x: index,
        barRods: [
          BarChartRodData(
            toY: weeklyData[index].toDouble(),
            gradient: isZero ? _zeroStateGradient() : AppColors.accentGradient,
            width: 22,
            borderRadius: const BorderRadius.all(Radius.circular(AppDimensions.radiusSm)),
            borderSide: isZero ? BorderSide(color: AppColors.outline, width: 1.5) : BorderSide.none,
          ),
        ],
      );
    });
  }

  LinearGradient _zeroStateGradient() {
    return LinearGradient(
      colors: [
        AppColors.surfaceContainer,
        AppColors.surfaceVariant,
      ],
      begin: Alignment.bottomCenter,
      end: Alignment.topCenter,
    );
  }

  double _getMaxY() {
    final maxValue = weeklyData.isEmpty ? 0 : weeklyData.reduce((a, b) => a > b ? a : b);
    return (maxValue < 4 ? 4 : maxValue + 1).toDouble();
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_text_styles.dart';
import '../../../core/constants/app_dimensions.dart';

/// Line Chart für Medikamenten-Adhärenz
/// Zeigt den Verlauf der Medikamenten-Einnahme über eine Woche mit verbesserter UI
class AdherenceLineChart extends StatelessWidget {
  final List<double> dailyAdherence; // 7 Tage, Werte 0-100

  const AdherenceLineChart({
    super.key,
    required this.dailyAdherence,
  });

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.8,
      child: LineChart(
        LineChartData(
          gridData: FlGridData(
            show: true,
            drawVerticalLine: false,
            horizontalInterval: 25,
            getDrawingHorizontalLine: (value) {
              return FlLine(
                color: AppColors.outlineVariant.withOpacity(0.7),
                strokeWidth: 1,
                dashArray: [4, 4],
              );
            },
          ),
          titlesData: FlTitlesData(
            show: true,
            topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                reservedSize: 32,
                getTitlesWidget: (value, meta) {
                  const days = ['Mo', 'Di', 'Mi', 'Do', 'Fr', 'Sa', 'So'];
                  if (value.toInt() >= 0 && value.toInt() < days.length) {
                    return Padding(
                      padding: const EdgeInsets.only(top: AppDimensions.spacingSm),
                      child: Text(
                        days[value.toInt()],
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
                reservedSize: 40,
                interval: 25,
                getTitlesWidget: (value, meta) {
                  return Text(
                    '${value.toInt()}%',
                    style: AppTextStyles.bodyXSmall.copyWith(
                      color: AppColors.textTertiary,
                    ),
                  );
                },
              ),
            ),
          ),
          borderData: FlBorderData(
            show: true,
            border: Border(
              bottom: BorderSide(color: AppColors.outlineVariant, width: 1.5),
              left: BorderSide(color: AppColors.outlineVariant, width: 1.5),
            ),
          ),
          minX: 0,
          maxX: 6,
          minY: 0,
          maxY: 100,
          lineBarsData: [
            LineChartBarData(
              spots: _buildSpots(),
              isCurved: true,
              curveSmoothness: 0.35,
              gradient: AppColors.accentGradient,
              barWidth: 4,
              isStrokeCapRound: true,
              dotData: FlDotData(
                show: true,
                getDotPainter: (spot, percent, barData, index) {
                  return FlDotCirclePainter(
                    radius: 5,
                    color: AppColors.accentGradient.colors.first,
                    strokeWidth: 2,
                    strokeColor: AppColors.cardBackground,
                  );
                },
              ),
              belowBarData: BarAreaData(
                show: true,
                gradient: LinearGradient(
                  colors: AppColors.accentGradient.colors
                      .map((color) => color.withOpacity(0.2))
                      .toList(),
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
              ),
            ),
          ],
          lineTouchData: LineTouchData(
            handleBuiltInTouches: true,
            touchTooltipData: LineTouchTooltipData(
              tooltipBgColor: AppColors.primaryDark.withOpacity(0.85),
              tooltipBorder: const BorderSide(color: AppColors.primaryLight, width: 1),
              tooltipRoundedRadius: AppDimensions.radiusMd,
              getTooltipItems: (List<LineBarSpot> touchedBarSpots) {
                return touchedBarSpots.map((barSpot) {
                  return LineTooltipItem(
                    '${barSpot.y.toInt()}% Adhärenz',
                    AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textOnPrimary,
                      fontWeight: FontWeight.w700,
                    ),
                  );
                }).toList();
              },
            ),
          ),
        ),
        swapAnimationDuration: const Duration(milliseconds: 450),
        swapAnimationCurve: Curves.easeOutCubic,
      ),
    );
  }

  List<FlSpot> _buildSpots() {
    return List.generate(
      dailyAdherence.length,
      (index) => FlSpot(index.toDouble(), dailyAdherence[index]),
    );
  }
}

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_text_styles.dart';

/// Donut Chart für Auslöser-Verteilung
/// Modern Material Design 3 styled mit Gradients und Animation
class TriggerDonutChart extends StatefulWidget {
  final Map<String, double> triggerData;

  const TriggerDonutChart({
    super.key,
    required this.triggerData,
  });

  @override
  State<TriggerDonutChart> createState() => _TriggerDonutChartState();
}

class _TriggerDonutChartState extends State<TriggerDonutChart> {
  int touchedIndex = -1;

  // Define colors from AppColors
  final List<List<Color>> _colorPairs = [
    [AppColors.primary, AppColors.primaryLight],
    [AppColors.secondary, AppColors.secondaryLight],
    [AppColors.tertiary, AppColors.tertiaryLight],
    [AppColors.warning, AppColors.warningLight],
    [AppColors.info, AppColors.infoLight],
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Title
        Text(
          'Auslöser',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        // Chart - Clean and minimalist
        SizedBox(
          height: 260,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Chart
              PieChart(
                PieChartData(
                  sectionsSpace: 3,
                  centerSpaceRadius: 75,
                  startDegreeOffset: -90,
                  sections: _buildSections(),
                  pieTouchData: PieTouchData(
                    touchCallback: (FlTouchEvent event, pieTouchResponse) {
                      setState(() {
                        if (!event.isInterestedForInteractions ||
                            pieTouchResponse == null ||
                            pieTouchResponse.touchedSection == null) {
                          touchedIndex = -1;
                          return;
                        }
                        touchedIndex = pieTouchResponse.touchedSection!.touchedSectionIndex;
                      });
                    },
                  ),
                ),
              ),
              // Center content - Minimal icon only
              Container(
                width: 130,
                height: 130,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.surface,
                  border: Border.all(
                    color: AppColors.outlineVariant,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Icon(
                    Icons.insights_rounded,
                    size: 36,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: AppDimensions.spacingLg),
        // Legend below - More compact
        _buildModernLegend(),
      ],
    );
  }

  List<PieChartSectionData> _buildSections() {
    final colorPairs = [
      [const Color(0xFF26A69A), const Color(0xFF4DB6AC)], // Teal
      [const Color(0xFF5E35B1), const Color(0xFF7E57C2)], // Purple (more distinct from teal)
      [const Color(0xFFFF7043), const Color(0xFFFF8A65)], // Coral (warm contrast)
      [const Color(0xFF42A5F5), const Color(0xFF64B5F6)], // Blue
      [const Color(0xFFFFA726), const Color(0xFFFFB74D)], // Orange
    ];

    int colorIndex = 0;
    return widget.triggerData.entries.map((entry) {
      final colors = colorPairs[colorIndex % colorPairs.length];
      final isTouched = widget.triggerData.keys.toList().indexOf(entry.key) == touchedIndex;
      final radius = isTouched ? 58.0 : 52.0;
      colorIndex++;

      return PieChartSectionData(
        color: colors[0],
        value: entry.value,
        title: isTouched ? '${entry.value.toInt()}%' : '',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          color: Colors.white,
          shadows: [
            Shadow(
              color: Colors.black.withValues(alpha: 0.3),
              blurRadius: 3,
            ),
          ],
        ),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderSide: BorderSide(
          color: Colors.white,
          width: isTouched ? 3 : 0,
        ),
      );
    }).toList();
  }

  Widget _buildModernLegend() {
    final colorPairs = [
      [const Color(0xFF26A69A), const Color(0xFF4DB6AC)],
      [const Color(0xFF5E35B1), const Color(0xFF7E57C2)],
      [const Color(0xFFFF7043), const Color(0xFFFF8A65)],
      [const Color(0xFF42A5F5), const Color(0xFF64B5F6)],
      [const Color(0xFFFFA726), const Color(0xFFFFB74D)],
    ];

    int colorIndex = 0;
    final entries = widget.triggerData.entries.toList();

    return Column(
      children: entries.asMap().entries.map((mapEntry) {
        final index = mapEntry.key;
        final entry = mapEntry.value;
        final colors = colorPairs[colorIndex % colorPairs.length];
        colorIndex++;

        return Padding(
          padding: EdgeInsets.only(
            bottom: index < entries.length - 1 ? AppDimensions.spacingSm : 0,
          ),
          child: Row(
            children: [
              // Color indicator - Simplified
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: colors,
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              // Trigger name
              Expanded(
                child: Text(
                  entry.key,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w500,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              // Percentage - More prominent
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.spacingMd,
                  vertical: AppDimensions.spacingXs,
                ),
                decoration: BoxDecoration(
                  color: colors[0].withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Text(
                  '${entry.value.toInt()}%',
                  style: AppTextStyles.labelMedium.copyWith(
                    color: colors[0],
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              const SizedBox(width: AppDimensions.spacingSm),
              // Icon
              Icon(
                _getIconForTrigger(entry.key),
                size: 18,
                color: colors[0],
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  IconData _getIconForTrigger(String trigger) {
    if (trigger.toLowerCase().contains('stress')) {
      return Icons.psychology_rounded;
    } else if (trigger.toLowerCase().contains('schlaf')) {
      return Icons.bedtime_rounded;
    } else if (trigger.toLowerCase().contains('medikament')) {
      return Icons.medication_rounded;
    } else {
      return Icons.help_outline_rounded;
    }
  }
}

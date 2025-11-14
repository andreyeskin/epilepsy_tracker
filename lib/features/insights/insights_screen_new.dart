import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import 'widgets/month_selector.dart';
import 'widgets/seizure_frequency_chart.dart';
import 'widgets/stats_summary_row.dart';
import 'widgets/trigger_donut_chart.dart';
import 'widgets/adherence_line_chart.dart';
import 'widgets/achievement_badge.dart';

/// Insights Screen - Analytics Dashboard
/// Zeigt umfassende Statistiken über Anfälle und Medikamenten-Adhärenz
class InsightsScreenNew extends StatefulWidget {
  const InsightsScreenNew({super.key});

  @override
  State<InsightsScreenNew> createState() => _InsightsScreenNewState();
}

class _InsightsScreenNewState extends State<InsightsScreenNew> {
  DateTime _selectedMonth = DateTime.now();
  bool _isLoading = false;

  // Demo Daten
  final List<int> _weeklySeizures = [2, 1, 0, 0]; // 4 Wochen
  final Map<String, double> _triggers = {
    'Stress': 40,
    'Schlafmangel': 30,
    'Auslassen Medikamente': 20,
    'Sonstiges': 10,
  };
  final List<double> _dailyAdherence = [100, 100, 100, 100, 100, 100, 100]; // 7 Tage

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
                padding: const EdgeInsets.all(AppDimensions.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Text(
                      AppStrings.insightsTitle,
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Month Selector
                    MonthSelector(
                      selectedMonth: _selectedMonth,
                      onPrevious: _previousMonth,
                      onNext: _nextMonth,
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Seizure Frequency Chart
                    _buildSection(
                      title: AppStrings.insightsSeizuresTitle,
                      child: SeizureFrequencyChart(
                        weeklyData: _weeklySeizures,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingLg),

                    // Stats Summary
                    StatsSummaryRow(
                      totalSeizures: _calculateTotal(),
                      changePercentage: _calculateChange(),
                      averagePerWeek: _calculateAverage(),
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Trigger Distribution
                    _buildSection(
                      title: AppStrings.insightsTriggersTitle,
                      child: TriggerDonutChart(
                        triggerData: _triggers,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Medication Adherence
                    _buildSection(
                      title: '${AppStrings.insightsAdherenceTitle} (${_calculateAdherence()}%)',
                      child: AdherenceLineChart(
                        dailyAdherence: _dailyAdherence,
                      ),
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Achievement Badge
                    AchievementBadge(
                      title: AppStrings.insightsAchievement,
                      subtitle: 'Weiter so! Du machst das großartig.',
                      icon: Icons.emoji_events,
                      color: AppColors.warning,
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Action Buttons
                    _buildActionButtons(),
                    const SizedBox(height: AppDimensions.spacing4Xl),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildSection({required String title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTextStyles.h4,
          ),
          const SizedBox(height: AppDimensions.spacingMd),
          child,
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        // Export Button
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLg,
          child: ElevatedButton.icon(
            onPressed: _exportReport,
            icon: const Icon(Icons.file_download),
            label: Text(
              AppStrings.insightsExport,
              style: AppTextStyles.button,
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ),
        const SizedBox(height: AppDimensions.spacingMd),

        // Share with Doctor Button
        SizedBox(
          width: double.infinity,
          height: AppDimensions.buttonHeightLg,
          child: OutlinedButton.icon(
            onPressed: _shareWithDoctor,
            icon: const Icon(Icons.share),
            label: Text(
              AppStrings.insightsShare,
              style: AppTextStyles.button.copyWith(
                color: AppColors.primary,
              ),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.primary, width: 2),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month - 1,
      );
    });
    // TODO: Load data for previous month
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(
        _selectedMonth.year,
        _selectedMonth.month + 1,
      );
    });
    // TODO: Load data for next month
  }

  int _calculateTotal() {
    return _weeklySeizures.reduce((a, b) => a + b);
  }

  double _calculateChange() {
    // Simuliert Veränderung zum Vormonat
    return -20.0; // -20% = Verbesserung
  }

  double _calculateAverage() {
    final total = _calculateTotal();
    return total / _weeklySeizures.length;
  }

  int _calculateAdherence() {
    final sum = _dailyAdherence.reduce((a, b) => a + b);
    return (sum / _dailyAdherence.length).round();
  }

  void _exportReport() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Bericht wird exportiert...'),
        backgroundColor: AppColors.success,
      ),
    );
    // TODO: Implement PDF export
  }

  void _shareWithDoctor() {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Teilen-Funktion wird vorbereitet...'),
        backgroundColor: AppColors.info,
      ),
    );
    // TODO: Implement share functionality
  }
}

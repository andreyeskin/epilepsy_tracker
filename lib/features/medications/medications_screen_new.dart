import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/models/medication.dart';

/// Medications Screen - Medikamentenverwaltung
/// Zeigt heutige und morgige Medikamente mit Einnahmestatus
class MedicationsScreenNew extends StatefulWidget {
  const MedicationsScreenNew({super.key});

  @override
  State<MedicationsScreenNew> createState() => _MedicationsScreenNewState();
}

class _MedicationsScreenNewState extends State<MedicationsScreenNew> {
  // Demo-Daten
  List<Medication> _medications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadMedications();
  }

  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    // Simuliere Laden von Daten
    await Future.delayed(const Duration(milliseconds: 500));

    final now = DateTime.now();
    final tomorrow = now.add(const Duration(days: 1));

    setState(() {
      _medications = [
        // Heute
        Medication(
          id: '1',
          name: 'Lamotrigin',
          dosage: '150mg',
          quantity: 2,
          scheduledDate: now,
          scheduledTime: const TimeOfDay(hour: 8, minute: 0),
          timeOfDay: AppStrings.medsMorning,
          status: MedicationStatus.taken,
          actualIntakeTime: DateTime(now.year, now.month, now.day, 8, 15),
        ),
        Medication(
          id: '2',
          name: 'Lamotrigin',
          dosage: '150mg',
          quantity: 2,
          scheduledDate: now,
          scheduledTime: const TimeOfDay(hour: 20, minute: 0),
          timeOfDay: AppStrings.medsEvening,
          status: MedicationStatus.pending,
        ),
        // Morgen
        Medication(
          id: '3',
          name: 'Lamotrigin',
          dosage: '150mg',
          quantity: 2,
          scheduledDate: tomorrow,
          scheduledTime: const TimeOfDay(hour: 8, minute: 0),
          timeOfDay: AppStrings.medsMorning,
          status: MedicationStatus.pending,
        ),
        Medication(
          id: '4',
          name: 'Lamotrigin',
          dosage: '150mg',
          quantity: 2,
          scheduledDate: tomorrow,
          scheduledTime: const TimeOfDay(hour: 20, minute: 0),
          timeOfDay: AppStrings.medsEvening,
          status: MedicationStatus.pending,
        ),
      ];
      _isLoading = false;
    });
  }

  List<Medication> get _todayMedications {
    return _medications.where((med) => med.isDueToday).toList()
      ..sort((a, b) => a.scheduledTime.hour.compareTo(b.scheduledTime.hour));
  }

  List<Medication> get _tomorrowMedications {
    final tomorrow = DateTime.now().add(const Duration(days: 1));
    return _medications.where((med) {
      return med.scheduledDate.year == tomorrow.year &&
          med.scheduledDate.month == tomorrow.month &&
          med.scheduledDate.day == tomorrow.day;
    }).toList()
      ..sort((a, b) => a.scheduledTime.hour.compareTo(b.scheduledTime.hour));
  }

  Future<void> _markAsTaken(String id) async {
    setState(() {
      final index = _medications.indexWhere((m) => m.id == id);
      if (index != -1) {
        _medications[index] = _medications[index].copyWith(
          status: MedicationStatus.taken,
          actualIntakeTime: DateTime.now(),
        );
      }
    });

    // Zeige Bestätigung
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Medikament als genommen markiert'),
        backgroundColor: AppColors.success,
        duration: Duration(seconds: 2),
      ),
    );
  }

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
                      AppStrings.medsTitle,
                      style: AppTextStyles.h1,
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Heute Section
                    _buildDaySection(
                      AppStrings.medsToday,
                      _todayMedications,
                      true,
                    ),
                    const SizedBox(height: AppDimensions.spacingXxl),

                    // Morgen Section
                    _buildDaySection(
                      AppStrings.medsTomorrow,
                      _tomorrowMedications,
                      false,
                    ),
                    const SizedBox(height: AppDimensions.spacing3Xl),

                    // Add Medication Button
                    _buildAddButton(),
                    const SizedBox(height: AppDimensions.spacing4Xl),
                  ],
                ),
              ),
      ),
    );
  }

  Widget _buildDaySection(String title, List<Medication> medications, bool isToday) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title with Icon
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  color: AppColors.primary.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                ),
                child: Icon(
                  isToday ? Icons.today : Icons.event,
                  color: AppColors.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                title,
                style: AppTextStyles.h3,
              ),
            ],
          ),
        ),

        // Medications List
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.divider),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: medications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: medications.length,
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                    color: AppColors.divider,
                    indent: AppDimensions.spacingLg,
                    endIndent: AppDimensions.spacingLg,
                  ),
                  itemBuilder: (context, index) {
                    return _buildMedicationItem(
                      medications[index],
                      isToday,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildMedicationItem(Medication medication, bool isToday) {
    final isTaken = medication.status == MedicationStatus.taken;

    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      child: Row(
        children: [
          // Medication Icon with gradient
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: isTaken
                  ? LinearGradient(
                      colors: [
                        AppColors.success,
                        AppColors.success.withOpacity(0.7),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : LinearGradient(
                      colors: [
                        AppColors.primary,
                        AppColors.primaryLight,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              boxShadow: [
                BoxShadow(
                  color: (isTaken ? AppColors.success : AppColors.primary)
                      .withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              Icons.medication,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),

          // Medication Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        '${medication.name} ${medication.dosage}',
                        style: AppTextStyles.cardTitle.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (isTaken)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppDimensions.spacingSm,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                          border: Border.all(
                            color: AppColors.success.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.check_circle,
                              color: AppColors.success,
                              size: 12,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              'Genommen',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.success,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Row(
                  children: [
                    Icon(
                      Icons.pills,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      '${medication.quantity} ${AppStrings.medsTablets}',
                      style: AppTextStyles.cardSubtitle,
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Icon(
                      medication.timeOfDay == AppStrings.medsMorning
                          ? Icons.wb_sunny
                          : Icons.nightlight,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      medication.timeOfDay,
                      style: AppTextStyles.cardSubtitle,
                    ),
                    const SizedBox(width: AppDimensions.spacingMd),
                    Icon(
                      Icons.schedule,
                      size: 14,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      medication.formattedTime,
                      style: AppTextStyles.cardSubtitle.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Action Button
          if (isToday && !isTaken) ...[
            const SizedBox(width: AppDimensions.spacingMd),
            _buildStatusButton(medication),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton(Medication medication) {
    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryMedium],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: () => _markAsTaken(medication.id),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          foregroundColor: AppColors.textOnPrimary,
          shadowColor: Colors.transparent,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.check_circle_outline, size: 18),
            const SizedBox(width: AppDimensions.spacingXs),
            Text(
              AppStrings.medsTake,
              style: AppTextStyles.buttonSmall.copyWith(
                fontSize: 13,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.all(AppDimensions.spacing3Xl),
      child: Center(
        child: Column(
          children: [
            Icon(
              Icons.medication_outlined,
              size: 48,
              color: AppColors.textSecondary.withOpacity(0.5),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Keine Medikamente geplant',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddButton() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
        boxShadow: [
          BoxShadow(
            color: AppColors.primary.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: AppDimensions.buttonHeightLg,
        child: OutlinedButton.icon(
          onPressed: () {
            // TODO: Navigate to Add Medication Screen
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Add Medication Screen wird noch implementiert'),
              ),
            );
          },
          icon: Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
            ),
            child: const Icon(Icons.add, size: 20),
          ),
          label: Text(
            AppStrings.medsAddNew,
            style: AppTextStyles.button.copyWith(
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
            ),
          ),
          style: OutlinedButton.styleFrom(
            side: BorderSide(color: AppColors.primary.withOpacity(0.3), width: 1.5),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            backgroundColor: AppColors.primary.withOpacity(0.03),
          ),
        ),
      ),
    );
  }
}

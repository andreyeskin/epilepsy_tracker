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
        // Section Title
        Padding(
          padding: const EdgeInsets.only(bottom: AppDimensions.spacingMd),
          child: Text(
            title,
            style: AppTextStyles.h3,
          ),
        ),

        // Medications List
        Container(
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
            border: Border.all(color: AppColors.divider),
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
          // Medication Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: isTaken
                  ? AppColors.success.withValues(alpha: 0.2)
                  : AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
            ),
            child: Icon(
              Icons.medication,
              color: isTaken ? AppColors.success : AppColors.primary,
              size: 24,
            ),
          ),
          const SizedBox(width: AppDimensions.spacingMd),

          // Medication Info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${medication.name} ${medication.dosage}',
                  style: AppTextStyles.cardTitle,
                ),
                const SizedBox(height: AppDimensions.spacingXs),
                Text(
                  '${medication.quantity} ${AppStrings.medsTablets} • ${medication.timeOfDay} • ${medication.formattedTime}',
                  style: AppTextStyles.cardSubtitle,
                ),
              ],
            ),
          ),

          // Action Button
          if (isToday) _buildStatusButton(medication),
        ],
      ),
    );
  }

  Widget _buildStatusButton(Medication medication) {
    final isTaken = medication.status == MedicationStatus.taken;

    if (isTaken) {
      return Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppColors.success,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.check_circle,
              color: AppColors.textOnPrimary,
              size: 16,
            ),
            const SizedBox(width: AppDimensions.spacingXs),
            Text(
              AppStrings.medsTaken,
              style: AppTextStyles.buttonSmall.copyWith(
                fontSize: 12,
              ),
            ),
          ],
        ),
      );
    }

    return ElevatedButton(
      onPressed: () => _markAsTaken(medication.id),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingMd,
          vertical: AppDimensions.spacingSm,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
        ),
        elevation: 0,
      ),
      child: Text(
        AppStrings.medsTake,
        style: AppTextStyles.buttonSmall.copyWith(
          fontSize: 12,
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
            const Icon(
              Icons.medication_outlined,
              size: 48,
              color: AppColors.textSecondary,
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
    return SizedBox(
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
        icon: const Icon(Icons.add),
        label: Text(
          AppStrings.medsAddNew,
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
    );
  }
}

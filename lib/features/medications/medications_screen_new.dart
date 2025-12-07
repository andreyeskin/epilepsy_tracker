import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/models/medication.dart';
import 'add_medication_screen.dart';

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
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(AppStrings.medsTitle),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(AppDimensions.spacingLg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Heute Section
                  _buildDaySection(
                    AppStrings.medsToday,
                    _todayMedications,
                    true,
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Morgen Section
                  _buildDaySection(
                    AppStrings.medsTomorrow,
                    _tomorrowMedications,
                    false,
                  ),
                  const SizedBox(height: AppDimensions.spacingXl),

                  // Add Medication Button
                  _buildAddButton(),
                  const SizedBox(height: AppDimensions.spacingXl),
                ],
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
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppDimensions.spacingSm),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [AppColors.primary, AppColors.primaryMedium],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  isToday ? Icons.today : Icons.event,
                  size: AppDimensions.iconSm,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingMd),
              Text(
                title,
                style: AppTextStyles.titleLarge,
              ),
            ],
          ),
        ),

        // Medications List
        Container(
          decoration: BoxDecoration(
            color: AppColors.surface,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXxl),
            boxShadow: [
              AppColors.elevation2,
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: medications.isEmpty
              ? _buildEmptyState()
              : ListView.separated(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: medications.length,
                  separatorBuilder: (context, index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: AppDimensions.spacingLg),
                    child: Divider(
                      height: 1,
                      color: AppColors.outlineVariant,
                    ),
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Medication Icon
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isTaken
                        ? [AppColors.success, AppColors.successLight]
                        : [AppColors.primary, AppColors.primaryMedium],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
                  boxShadow: [
                    BoxShadow(
                      color: (isTaken ? AppColors.success : AppColors.primary)
                          .withValues(alpha: 0.3),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Icon(
                  Icons.medication_rounded,
                  color: Colors.white,
                  size: AppDimensions.iconMd,
                ),
              ),
              const SizedBox(width: AppDimensions.spacingLg),

              // Medication Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${medication.name} ${medication.dosage}',
                      style: AppTextStyles.titleMedium,
                    ),
                    const SizedBox(height: AppDimensions.spacingXs),
                    Wrap(
                      spacing: AppDimensions.spacingSm,
                      runSpacing: AppDimensions.spacingXs,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.schedule_rounded,
                              size: 14,
                              color: AppColors.textSecondary,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              medication.formattedTime,
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textSecondary,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: BoxDecoration(
                            color: AppColors.textTertiary,
                            shape: BoxShape.circle,
                          ),
                        ),
                        Text(
                          '${medication.quantity} ${AppStrings.medsTablets}',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),

          // Action Button - Moved below to avoid overlap
          if (isToday) ...[
            const SizedBox(height: AppDimensions.spacingMd),
            _buildStatusButton(medication),
          ],
        ],
      ),
    );
  }

  Widget _buildStatusButton(Medication medication) {
    final isTaken = medication.status == MedicationStatus.taken;

    if (isTaken) {
      return Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(
          horizontal: AppDimensions.spacingLg,
          vertical: AppDimensions.spacingMd,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.success, AppColors.successLight],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          boxShadow: [
            BoxShadow(
              color: AppColors.success.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.check_circle_rounded,
              color: Colors.white,
              size: 20,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              AppStrings.medsTaken,
              style: AppTextStyles.labelLarge.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      );
    }

    return SizedBox(
      width: double.infinity,
      child: ElevatedButton.icon(
        onPressed: () => _markAsTaken(medication.id),
        icon: const Icon(Icons.check_circle_outline_rounded, size: 20),
        label: Text(
          AppStrings.medsTake,
          style: AppTextStyles.labelLarge.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: AppDimensions.spacingLg,
            vertical: AppDimensions.spacingMd,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: AppDimensions.elevation2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
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
      child: ElevatedButton.icon(
        onPressed: () async {
          final newMedication = await Navigator.push<Medication>(
            context,
            MaterialPageRoute(
              builder: (context) => const AddMedicationScreen(),
            ),
          );

          if (newMedication != null) {
            setState(() {
              _medications.add(newMedication);
            });

            if (!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Medikament erfolgreich hinzugefügt'),
                backgroundColor: AppColors.success,
                duration: Duration(seconds: 2),
              ),
            );
          }
        },
        icon: const Icon(Icons.add_rounded, size: AppDimensions.iconMd),
        label: Text(
          AppStrings.medsAddNew,
          style: AppTextStyles.buttonLarge,
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          ),
          elevation: AppDimensions.elevation2,
          shadowColor: AppColors.primary.withValues(alpha: 0.4),
        ),
      ),
    );
  }
}

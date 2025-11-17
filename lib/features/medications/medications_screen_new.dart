import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/models/medication.dart';
import '../../services/medication_database_service.dart';
import '../../services/notification_service.dart';

/// Medications Screen - Medikamentenverwaltung
/// Zeigt heutige und morgige Medikamente mit Einnahmestatus
class MedicationsScreenNew extends StatefulWidget {
  const MedicationsScreenNew({super.key});

  @override
  State<MedicationsScreenNew> createState() => _MedicationsScreenNewState();
}

class _MedicationsScreenNewState extends State<MedicationsScreenNew> {
  final _dbService = MedicationDatabaseService();
  final _notificationService = NotificationService();

  List<Medication> _medications = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeServices();
    _loadMedications();
  }

  /// Initialisiert Services (Datenbank und Benachrichtigungen)
  Future<void> _initializeServices() async {
    await _notificationService.initialize();
    await _notificationService.requestPermissions();
  }

  /// Lädt Medikamente aus der Datenbank
  Future<void> _loadMedications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      // Holt heutige und morgige Medikamente aus der Datenbank
      final today = await _dbService.getTodayMedications();
      final tomorrow = await _dbService.getTomorrowMedications();

      setState(() {
        _medications = [...today, ...tomorrow];
        _isLoading = false;
      });
    } catch (e) {
      print('Fehler beim Laden der Medikamente: $e');
      setState(() {
        _isLoading = false;
      });
    }
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

  /// Markiert ein Medikament als genommen
  Future<void> _markAsTaken(String id) async {
    try {
      // Aktualisiert in der Datenbank
      await _dbService.markAsTaken(id);

      // Storniert die geplante Benachrichtigung
      await _notificationService.cancelMedicationNotification(id);

      // Lädt die Liste neu
      await _loadMedications();

      // Zeige Bestätigung
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Medikament als genommen markiert'),
          backgroundColor: AppColors.success,
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      print('Fehler beim Markieren des Medikaments: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Fehler beim Speichern'),
          backgroundColor: AppColors.error,
          duration: Duration(seconds: 2),
        ),
      );
    }
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
                  ? AppColors.success.withOpacity(0.2)
                  : AppColors.primary.withOpacity(0.2),
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
          if (isToday)
            _buildStatusButton(medication)
          else
            Text(
              medication.formattedTime,
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
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
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightLg,
      child: OutlinedButton.icon(
        onPressed: _showAddMedicationDialog,
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

  /// Zeigt Dialog zum Hinzufügen eines neuen Medikaments
  Future<void> _showAddMedicationDialog() async {
    final nameController = TextEditingController();
    final dosageController = TextEditingController();
    final quantityController = TextEditingController(text: '1');

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedTimeOfDay = AppStrings.medsMorning;

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Neues Medikament'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Medikamentenname
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: 'Name',
                    hintText: 'z.B. Lamotrigin',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Dosierung
                TextField(
                  controller: dosageController,
                  decoration: const InputDecoration(
                    labelText: 'Dosierung',
                    hintText: 'z.B. 150mg',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Anzahl
                TextField(
                  controller: quantityController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Anzahl',
                    hintText: '1',
                    border: OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),

                // Datum
                ListTile(
                  title: const Text('Datum'),
                  subtitle: Text(
                    '${selectedDate.day}.${selectedDate.month}.${selectedDate.year}',
                  ),
                  trailing: const Icon(Icons.calendar_today),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: selectedDate,
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (date != null) {
                      setDialogState(() {
                        selectedDate = date;
                      });
                    }
                  },
                ),

                // Uhrzeit
                ListTile(
                  title: const Text('Uhrzeit'),
                  subtitle: Text(
                    '${selectedTime.hour.toString().padLeft(2, '0')}:${selectedTime.minute.toString().padLeft(2, '0')}',
                  ),
                  trailing: const Icon(Icons.access_time),
                  onTap: () async {
                    final time = await showTimePicker(
                      context: context,
                      initialTime: selectedTime,
                    );
                    if (time != null) {
                      setDialogState(() {
                        selectedTime = time;
                        // Aktualisiert automatisch die Tageszeit basierend auf Uhrzeit
                        if (time.hour >= 5 && time.hour < 12) {
                          selectedTimeOfDay = AppStrings.medsMorning;
                        } else if (time.hour >= 12 && time.hour < 18) {
                          selectedTimeOfDay = 'Mittags';
                        } else if (time.hour >= 18 && time.hour < 22) {
                          selectedTimeOfDay = AppStrings.medsEvening;
                        } else {
                          selectedTimeOfDay = 'Nachts';
                        }
                      });
                    }
                  },
                ),

                // Tageszeit
                DropdownButtonFormField<String>(
                  value: selectedTimeOfDay,
                  decoration: const InputDecoration(
                    labelText: 'Tageszeit',
                    border: OutlineInputBorder(),
                  ),
                  items: [
                    AppStrings.medsMorning,
                    'Mittags',
                    AppStrings.medsEvening,
                    'Nachts',
                  ].map((timeOfDay) {
                    return DropdownMenuItem(
                      value: timeOfDay,
                      child: Text(timeOfDay),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      setDialogState(() {
                        selectedTimeOfDay = value;
                      });
                    }
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Abbrechen'),
            ),
            ElevatedButton(
              onPressed: () {
                if (nameController.text.trim().isEmpty ||
                    dosageController.text.trim().isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Bitte Name und Dosierung eingeben'),
                      backgroundColor: AppColors.error,
                    ),
                  );
                  return;
                }
                Navigator.pop(context, true);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
              ),
              child: const Text('Hinzufügen'),
            ),
          ],
        ),
      ),
    );

    if (result == true && mounted) {
      // Erstellt neues Medikament
      final medication = Medication(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        name: nameController.text.trim(),
        dosage: dosageController.text.trim(),
        quantity: int.tryParse(quantityController.text) ?? 1,
        scheduledDate: selectedDate,
        scheduledTime: selectedTime,
        timeOfDay: selectedTimeOfDay,
        status: MedicationStatus.pending,
      );

      try {
        // Speichert in Datenbank
        await _dbService.insertMedication(medication);

        // Plant Benachrichtigung
        await _notificationService.scheduleMedicationNotification(medication);

        // Lädt Liste neu
        await _loadMedications();

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Medikament erfolgreich hinzugefügt'),
            backgroundColor: AppColors.success,
          ),
        );
      } catch (e) {
        print('Fehler beim Hinzufügen des Medikaments: $e');
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Fehler beim Speichern'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }
}

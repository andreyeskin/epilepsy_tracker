import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/seizure.dart';
import '../services/seizure_database_service.dart';
import '../core/constants/app_colors.dart';

class SeizureLogScreen extends StatefulWidget {
  const SeizureLogScreen({super.key});

  @override
  State<SeizureLogScreen> createState() => _SeizureLogScreenState();
}

class _SeizureLogScreenState extends State<SeizureLogScreen> {
  final _formKey = GlobalKey<FormState>();
  final _dbService = SeizureDatabaseService();

  // Form fields
  DateTime _selectedDateTime = DateTime.now();
  SeizureType _selectedType = SeizureType.unknown;
  int _durationMinutes = 0;
  int _durationSeconds = 0;
  int _severity = 3;
  String? _auraSymptoms;
  final List<String> _selectedSymptomsDuring = [];
  final List<String> _selectedSymptomsAfter = [];
  final List<String> _selectedTriggers = [];
  String? _location;
  String? _activity;
  bool _medicationTaken = false;
  String? _medicationName;
  final TextEditingController _notesController = TextEditingController();

  bool _isLoading = false;

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _selectDateTime() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateTime,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (date == null) return;

    if (!mounted) return;

    final time = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_selectedDateTime),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppColors.primary,
            ),
          ),
          child: child!,
        );
      },
    );

    if (time == null) return;

    setState(() {
      _selectedDateTime = DateTime(
        date.year,
        date.month,
        date.day,
        time.hour,
        time.minute,
      );
    });
  }

  Future<void> _saveSeizure() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      final duration = Duration(
        minutes: _durationMinutes,
        seconds: _durationSeconds,
      );

      final seizure = Seizure(
        id: DateTime.now().millisecondsSinceEpoch.toString(),
        dateTime: _selectedDateTime,
        type: _selectedType,
        duration: duration,
        severity: _severity,
        auraSymptoms: _auraSymptoms?.isEmpty == true ? null : _auraSymptoms,
        symptomsDuring: _selectedSymptomsDuring,
        symptomsAfter: _selectedSymptomsAfter,
        triggers: _selectedTriggers,
        location: _location?.isEmpty == true ? null : _location,
        activity: _activity?.isEmpty == true ? null : _activity,
        medicationTaken: _medicationTaken,
        medicationName: _medicationName?.isEmpty == true ? null : _medicationName,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      await _dbService.insertSeizure(seizure);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Anfall erfolgreich gespeichert'),
          backgroundColor: AppColors.success,
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Fehler beim Speichern: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Anfall protokollieren'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Datum und Zeit
            _buildSection(
              title: 'Wann ist der Anfall aufgetreten?',
              icon: Icons.calendar_today,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: const Icon(Icons.access_time, color: AppColors.primary),
                  title: const Text('Datum und Uhrzeit'),
                  subtitle: Text(
                    DateFormat('dd.MM.yyyy - HH:mm').format(_selectedDateTime),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  trailing: const Icon(Icons.edit),
                  onTap: _selectDateTime,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Typ des Anfalls
            _buildSection(
              title: 'Art des Anfalls',
              icon: Icons.analytics,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: SeizureType.values.map((type) {
                      return RadioListTile<SeizureType>(
                        title: Text(type.displayName),
                        subtitle: Text(
                          type.description,
                          style: const TextStyle(fontSize: 12),
                        ),
                        value: type,
                        groupValue: _selectedType,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _selectedType = value!;
                          });
                        },
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Dauer
            _buildSection(
              title: 'Dauer des Anfalls',
              icon: Icons.timer,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Minuten'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _durationMinutes,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: List.generate(61, (index) {
                                return DropdownMenuItem(
                                  value: index,
                                  child: Text('$index min'),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _durationMinutes = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sekunden'),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<int>(
                              value: _durationSeconds,
                              decoration: InputDecoration(
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 8,
                                ),
                              ),
                              items: List.generate(60, (index) {
                                return DropdownMenuItem(
                                  value: index,
                                  child: Text('$index sek'),
                                );
                              }),
                              onChanged: (value) {
                                setState(() {
                                  _durationSeconds = value!;
                                });
                              },
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Schweregrad
            _buildSection(
              title: 'Schweregrad (1 = leicht, 5 = sehr schwer)',
              icon: Icons.warning_amber,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: List.generate(5, (index) {
                          final severity = index + 1;
                          return Text(
                            '$severity',
                            style: TextStyle(
                              fontWeight: _severity == severity
                                  ? FontWeight.bold
                                  : FontWeight.normal,
                              color: _severity == severity
                                  ? AppColors.primary
                                  : Colors.grey,
                            ),
                          );
                        }),
                      ),
                      Slider(
                        value: _severity.toDouble(),
                        min: 1,
                        max: 5,
                        divisions: 4,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _severity = value.toInt();
                          });
                        },
                      ),
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: _getSeverityColor(_severity).withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              _getSeverityIcon(_severity),
                              color: _getSeverityColor(_severity),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _getSeverityText(_severity),
                              style: TextStyle(
                                color: _getSeverityColor(_severity),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Aura-Symptome
            _buildSection(
              title: 'Warnsignale vor dem Anfall (Aura)',
              icon: Icons.lightbulb_outline,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    maxLines: 2,
                    decoration: InputDecoration(
                      hintText: 'z.B. Sehstörungen, Kribbeln, seltsamer Geruch...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    onChanged: (value) {
                      _auraSymptoms = value;
                    },
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Symptome während
            _buildSection(
              title: 'Symptome während des Anfalls',
              icon: Icons.health_and_safety,
              child: _buildMultiSelectChips(
                items: SeizureSymptoms.duringSymptoms,
                selectedItems: _selectedSymptomsDuring,
              ),
            ),

            const SizedBox(height: 24),

            // Symptome danach
            _buildSection(
              title: 'Symptome nach dem Anfall',
              icon: Icons.healing,
              child: _buildMultiSelectChips(
                items: SeizureSymptoms.afterSymptoms,
                selectedItems: _selectedSymptomsAfter,
              ),
            ),

            const SizedBox(height: 24),

            // Mögliche Auslöser
            _buildSection(
              title: 'Mögliche Auslöser/Trigger',
              icon: Icons.flash_on,
              child: _buildMultiSelectChips(
                items: SeizureSymptoms.commonTriggers,
                selectedItems: _selectedTriggers,
              ),
            ),

            const SizedBox(height: 24),

            // Ort und Aktivität
            _buildSection(
              title: 'Zusätzliche Informationen',
              icon: Icons.info_outline,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Wo ist der Anfall passiert?',
                          hintText: 'z.B. Zuhause, Arbeit, Supermarkt',
                          prefixIcon: const Icon(Icons.location_on),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          _location = value;
                        },
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        decoration: InputDecoration(
                          labelText: 'Was haben Sie gerade gemacht?',
                          hintText: 'z.B. Schlafen, Sport, Fernsehen',
                          prefixIcon: const Icon(Icons.directions_run),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                        onChanged: (value) {
                          _activity = value;
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notfallmedikation
            _buildSection(
              title: 'Notfallmedikation',
              icon: Icons.medication,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    children: [
                      SwitchListTile(
                        title: const Text('Notfallmedikation genommen?'),
                        value: _medicationTaken,
                        activeColor: AppColors.primary,
                        onChanged: (value) {
                          setState(() {
                            _medicationTaken = value;
                          });
                        },
                      ),
                      if (_medicationTaken) ...[
                        const SizedBox(height: 16),
                        TextFormField(
                          decoration: InputDecoration(
                            labelText: 'Welches Medikament?',
                            hintText: 'z.B. Lorazepam, Diazepam',
                            prefixIcon: const Icon(Icons.medical_services),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                          ),
                          onChanged: (value) {
                            _medicationName = value;
                          },
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Notizen
            _buildSection(
              title: 'Notizen',
              icon: Icons.note_alt,
              child: Card(
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: TextFormField(
                    controller: _notesController,
                    maxLines: 4,
                    decoration: InputDecoration(
                      hintText: 'Weitere Beobachtungen oder Details...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 32),

            // Speichern Button
            ElevatedButton(
              onPressed: _isLoading ? null : _saveSeizure,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text(
                      'Speichern',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildSection({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, color: AppColors.primary, size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        child,
      ],
    );
  }

  Widget _buildMultiSelectChips({
    required List<String> items,
    required List<String> selectedItems,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: items.map((item) {
            final isSelected = selectedItems.contains(item);
            return FilterChip(
              label: Text(item),
              selected: isSelected,
              selectedColor: AppColors.primary.withOpacity(0.2),
              checkmarkColor: AppColors.primary,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    selectedItems.add(item);
                  } else {
                    selectedItems.remove(item);
                  }
                });
              },
            );
          }).toList(),
        ),
      ),
    );
  }

  Color _getSeverityColor(int severity) {
    switch (severity) {
      case 1:
        return Colors.green;
      case 2:
        return Colors.lightGreen;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.deepOrange;
      case 5:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getSeverityIcon(int severity) {
    switch (severity) {
      case 1:
        return Icons.sentiment_satisfied;
      case 2:
        return Icons.sentiment_neutral;
      case 3:
        return Icons.sentiment_dissatisfied;
      case 4:
        return Icons.warning;
      case 5:
        return Icons.emergency;
      default:
        return Icons.help_outline;
    }
  }

  String _getSeverityText(int severity) {
    switch (severity) {
      case 1:
        return 'Sehr leicht';
      case 2:
        return 'Leicht';
      case 3:
        return 'Mittel';
      case 4:
        return 'Schwer';
      case 5:
        return 'Sehr schwer';
      default:
        return '';
    }
  }
}
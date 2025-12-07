import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';

/// Wellbeing Screen - Tagesform dokumentieren
/// Ermöglicht dem Benutzer, täglich sein Wohlbefinden zu erfassen
class WellbeingScreen extends StatefulWidget {
  const WellbeingScreen({super.key});

  @override
  State<WellbeingScreen> createState() => _WellbeingScreenState();
}

class _WellbeingScreenState extends State<WellbeingScreen> {
  // State
  DateTime _selectedDate = DateTime.now();
  double _sleepQuality = 3.0;
  double _stressLevel = 5.0;
  String? _selectedMood;
  final TextEditingController _notesController = TextEditingController();
  bool _isLoading = false;

  // Mood Options
  final List<Map<String, String>> _moods = [
    {'emoji': '😊', 'label': 'Sehr gut'},
    {'emoji': '🙂', 'label': 'Gut'},
    {'emoji': '😐', 'label': 'OK'},
    {'emoji': '🙁', 'label': 'Nicht gut'},
    {'emoji': '😢', 'label': 'Schlecht'},
  ];

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _saveWellbeing() async {
    setState(() {
      _isLoading = true;
    });

    // Simulate saving
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(AppStrings.wellbeingSaved),
        backgroundColor: AppColors.success,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.cardBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Text(
                AppStrings.wellbeingTitle,
                style: AppTextStyles.h1,
              ),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Datum Auswahl
              _buildDateSelector(),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Allgemeinbefinden
              _buildMoodSelector(),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Schlafqualität
              _buildSleepQualitySlider(),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Stress Level
              _buildStressLevelSlider(),
              const SizedBox(height: AppDimensions.spacingXxl),

              // Besondere Ereignisse
              _buildNotesField(),
              const SizedBox(height: AppDimensions.spacing3Xl),

              // Save Button
              _buildSaveButton(),
              const SizedBox(height: AppDimensions.spacing4Xl),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDateSelector() {
    return Container(
      padding: const EdgeInsets.all(AppDimensions.spacingLg),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
        border: Border.all(color: AppColors.divider),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppStrings.wellbeingDate,
                style: AppTextStyles.labelSmall,
              ),
              const SizedBox(height: AppDimensions.spacingXs),
              Text(
                '${_selectedDate.day}.${_selectedDate.month}.${_selectedDate.year}',
                style: AppTextStyles.h3,
              ),
            ],
          ),
          IconButton(
            onPressed: () async {
              final date = await showDatePicker(
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime.now().subtract(const Duration(days: 365)),
                lastDate: DateTime.now(),
              );
              if (date != null) {
                setState(() {
                  _selectedDate = date;
                });
              }
            },
            icon: const Icon(Icons.calendar_today, color: AppColors.primary),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelector() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.wellbeingMood,
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: _moods.map((mood) {
            final isSelected = _selectedMood == mood['emoji'];
            return InkWell(
              onTap: () {
                setState(() {
                  _selectedMood = mood['emoji'];
                });
              },
              child: Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: isSelected ? AppColors.primaryLight : AppColors.background,
                  borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
                  border: Border.all(
                    color: isSelected ? AppColors.primary : AppColors.divider,
                    width: 2,
                  ),
                ),
                child: Center(
                  child: Text(
                    mood['emoji']!,
                    style: const TextStyle(fontSize: 32),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildSleepQualitySlider() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.wellbeingSleep,
              style: AppTextStyles.h4,
            ),
            Row(
              children: List.generate(5, (index) {
                return Icon(
                  index < _sleepQuality ? Icons.star : Icons.star_border,
                  color: AppColors.warning,
                  size: 20,
                );
              }),
            ),
          ],
        ),
        Slider(
          value: _sleepQuality,
          min: 1,
          max: 5,
          divisions: 4,
          activeColor: AppColors.primary,
          onChanged: (value) {
            setState(() {
              _sleepQuality = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildStressLevelSlider() {
    Color getStressColor() {
      if (_stressLevel <= 3) return AppColors.success;
      if (_stressLevel <= 7) return AppColors.warning;
      return AppColors.error;
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.wellbeingStress,
              style: AppTextStyles.h4,
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppDimensions.spacingMd,
                vertical: AppDimensions.spacingXs,
              ),
              decoration: BoxDecoration(
                color: getStressColor().withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppDimensions.radiusSm),
              ),
              child: Text(
                '${_stressLevel.toInt()}/10',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: getStressColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
        Slider(
          value: _stressLevel,
          min: 1,
          max: 10,
          divisions: 9,
          activeColor: getStressColor(),
          onChanged: (value) {
            setState(() {
              _stressLevel = value;
            });
          },
        ),
      ],
    );
  }

  Widget _buildNotesField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppStrings.wellbeingNotes,
          style: AppTextStyles.h4,
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        TextField(
          controller: _notesController,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Beschreibe besondere Ereignisse oder Beobachtungen...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.divider),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
              borderSide: const BorderSide(color: AppColors.primary, width: 2),
            ),
            filled: true,
            fillColor: AppColors.background,
          ),
        ),
      ],
    );
  }

  Widget _buildSaveButton() {
    return SizedBox(
      width: double.infinity,
      height: AppDimensions.buttonHeightLg,
      child: ElevatedButton(
        onPressed: _isLoading ? null : _saveWellbeing,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textOnPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: 2,
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
            : Text(
                AppStrings.wellbeingSave,
                style: AppTextStyles.button,
              ),
      ),
    );
  }
}

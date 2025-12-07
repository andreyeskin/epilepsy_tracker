import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../core/constants/app_dimensions.dart';
import '../../core/constants/app_animations.dart';

/// Relaxation Screen - Ruheraum
/// Ermöglicht Auswahl von Meditation-Szenen und Dauer
class RelaxationScreenNew extends StatefulWidget {
  const RelaxationScreenNew({super.key});

  @override
  State<RelaxationScreenNew> createState() => _RelaxationScreenNewState();
}

class _RelaxationScreenNewState extends State<RelaxationScreenNew> {
  String? _selectedScene;
  int? _selectedDuration; // in Minuten, null = Frei

  final List<Map<String, dynamic>> _scenes = [
    {
      'id': 'forest',
      'name': 'Wald',
      'gradient': LinearGradient(
        colors: [Color(0xFF1B4D3E), Color(0xFF2E7D5E), Color(0xFF4CAF50)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.forest,
    },
    {
      'id': 'beach',
      'name': 'Strand',
      'gradient': LinearGradient(
        colors: [Color(0xFF006994), Color(0xFF0097D3), Color(0xFF87CEEB)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.beach_access,
    },
    {
      'id': 'mountain',
      'name': 'Bergwiese',
      'gradient': LinearGradient(
        colors: [Color(0xFF5D8C7B), Color(0xFF7FA99B), Color(0xFFA8C5BA)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.terrain,
    },
    {
      'id': 'aurora',
      'name': 'Polarlichter',
      'gradient': LinearGradient(
        colors: [Color(0xFF1A237E), Color(0xFF4A148C), Color(0xFF00BFA5)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      'icon': Icons.nightlight_round,
    },
  ];

  final List<int?> _durations = [5, 10, 15, null]; // null = Frei

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Ruheraum'),
        backgroundColor: const Color(0xFF4CAF93),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.spacingLg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Scene Selection
            Text(
              'Szene wählen',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _buildSceneGrid(),
            const SizedBox(height: AppDimensions.spacingXxl),

            // Duration Selection
            Text(
              'Dauer wählen',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            _buildDurationChips(),
            const SizedBox(height: AppDimensions.spacingXxl),

            // Breathing Guide
            _buildBreathingGuide(),
            const SizedBox(height: AppDimensions.spacingMd),

            // Meditation Image
            _buildMeditationImage(),
            const SizedBox(height: AppDimensions.spacing3Xl),

            // Start Button
            _buildStartButton(),
            const SizedBox(height: AppDimensions.spacing4Xl),
          ],
        ),
      ),
    );
  }

  Widget _buildSceneGrid() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: AppDimensions.spacingMd,
        mainAxisSpacing: AppDimensions.spacingMd,
        childAspectRatio: 1.3,
      ),
      itemCount: _scenes.length,
      itemBuilder: (context, index) {
        final scene = _scenes[index];
        final isSelected = _selectedScene == scene['id'];

        return InkWell(
          onTap: () {
            setState(() {
              _selectedScene = scene['id'];
            });
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            decoration: BoxDecoration(
              gradient: scene['gradient'],
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
                width: 3,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CAF93).withValues(alpha: 0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.1),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
            ),
            child: Stack(
              children: [
                Center(
                  child: Icon(
                    scene['icon'],
                    size: 48,
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
                Positioned(
                  bottom: 12,
                  left: 0,
                  right: 0,
                  child: Text(
                    scene['name'],
                    textAlign: TextAlign.center,
                    style: AppTextStyles.h4.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.5),
                          blurRadius: 4,
                        ),
                      ],
                    ),
                  ),
                ),
                if (isSelected)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.white,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check,
                        color: Color(0xFF4CAF93),
                        size: 16,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildDurationChips() {
    return Wrap(
      spacing: AppDimensions.spacingMd,
      runSpacing: AppDimensions.spacingMd,
      children: _durations.map((duration) {
        final isSelected = _selectedDuration == duration;
        final label = duration == null ? 'Frei' : '$duration Min.';

        return InkWell(
          onTap: () {
            setState(() {
              _selectedDuration = duration;
            });
          },
          borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
          child: AnimatedContainer(
            duration: AppAnimations.durationShort,
            curve: AppAnimations.curveEmphasized,
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.spacingXl,
              vertical: AppDimensions.spacingMd,
            ),
            decoration: BoxDecoration(
              gradient: isSelected
                  ? const LinearGradient(
                      colors: [Color(0xFF4CAF93), Color(0xFF66BB9A)],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
              color: isSelected ? null : AppColors.surfaceVariant,
              borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
              border: Border.all(
                color: isSelected ? Colors.transparent : AppColors.outline,
                width: 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: const Color(0xFF4CAF93).withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (isSelected)
                  Padding(
                    padding: const EdgeInsets.only(right: AppDimensions.spacingSm),
                    child: Icon(
                      Icons.check_circle_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                Text(
                  label,
                  style: AppTextStyles.labelLarge.copyWith(
                    color: isSelected ? Colors.white : AppColors.textPrimary,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBreathingGuide() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.air,
              color: Color(0xFF4CAF93),
              size: 24,
            ),
            const SizedBox(width: AppDimensions.spacingSm),
            Text(
              'Geführte Atmung',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
                color: Color(0xFF4CAF93),
              ),
            ),
          ],
        ),
        const SizedBox(height: AppDimensions.spacingMd),
        Text(
          'Die 4-7-8 Atemtechnik hilft, den Körper zu beruhigen und Stress zu reduzieren. Atme 4 Sekunden ein, halte 7 Sekunden, und atme 8 Sekunden aus.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }


  Widget _buildMeditationImage() {
    return Container(
      width: double.infinity,
      height: 200,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF667EEA), Color(0xFF764BA2), Color(0xFFF093FB)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusLg),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.self_improvement,
              size: 80,
              color: Colors.white.withValues(alpha: 0.9),
            ),
            const SizedBox(height: AppDimensions.spacingMd),
            Text(
              'Finde deine innere Ruhe',
              style: AppTextStyles.h3.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStartButton() {
    final canStart = _selectedScene != null && _selectedDuration != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      width: double.infinity,
      height: AppDimensions.buttonHeightLg,
      child: ElevatedButton.icon(
        onPressed: canStart ? _startSession : null,
        icon: const Icon(Icons.play_arrow, size: 24),
        label: const Text(
          'Starten',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: canStart ? const Color(0xFF4CAF93) : const Color(0xFFE8E8E8),
          foregroundColor: canStart ? Colors.white : AppColors.textSecondary,
          disabledBackgroundColor: const Color(0xFFE8E8E8),
          disabledForegroundColor: AppColors.textSecondary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimensions.radiusMd),
          ),
          elevation: canStart ? 4 : 0,
          shadowColor: canStart ? const Color(0xFF4CAF93).withValues(alpha: 0.4) : null,
        ),
      ),
    );
  }

  void _startSession() {
    final sceneName = _scenes
        .firstWhere((s) => s['id'] == _selectedScene)['name'];
    final durationText = _selectedDuration == null
        ? 'Freie Dauer'
        : '$_selectedDuration Minuten';

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Starte $sceneName Session ($durationText)'),
        backgroundColor: AppColors.success,
      ),
    );

    // TODO: Navigate to VR Session Screen
  }
}

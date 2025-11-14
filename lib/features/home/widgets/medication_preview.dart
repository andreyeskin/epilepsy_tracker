import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// "Nächste Medikamente" Section auf dem Startbildschirm
/// Zeigt maximal 2 Medikamente mit:
/// - Name und Dosierung
/// - Einnahmezeit
/// - Icon für Uhrzeit
class MedicationPreview extends StatelessWidget {
  final VoidCallback onViewAll;

  const MedicationPreview({
    super.key,
    required this.onViewAll,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppStrings.homeNextMeds,
              style: AppTextStyles.h4,
            ),
            TextButton(
              onPressed: onViewAll,
              child: Text(
                AppStrings.homeViewAll,
                style: const TextStyle(
                  color: AppColors.primary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),

        // Medications List
        Container(
          padding: const EdgeInsets.all(AppDimensions.spacingLg),
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.03),
                blurRadius: 10,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildMedicationItem(
                'Lamotrigin 150mg',
                '2 Tabletten',
                '08:00',
              ),
              const Divider(height: 24, color: AppColors.divider),
              _buildMedicationItem(
                'Levetiracetam 500mg',
                '1 Tablette',
                '20:00',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMedicationItem(String name, String dosage, String time) {
    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppColors.primaryDark,
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Icon(
            Icons.access_time,
            color: Colors.white,
            size: 20,
          ),
        ),
        const SizedBox(width: AppDimensions.spacingMd),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                name,
                style: AppTextStyles.cardTitle,
              ),
              Text(
                dosage,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// "Letzte Anfälle" Section auf dem Startbildschirm
/// Zeigt maximal 2 der letzten Anfälle mit:
/// - Typ (Fokal, Generalisiert)
/// - Dauer und Schweregrad
/// - Zeitpunkt
class SeizurePreview extends StatelessWidget {
  final VoidCallback onViewAll;

  const SeizurePreview({
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
              AppStrings.homeRecentSeizures,
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

        // Seizures List
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
              _buildSeizureItem(
                'Fokal',
                '45 Sekunden, Schweregrad 3',
                'Heute, 09:15',
              ),
              const Divider(height: 24, color: AppColors.divider),
              _buildSeizureItem(
                'Generalisiert',
                '90 Sekunden, Schweregrad 4',
                '15.10.2025',
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSeizureItem(String type, String details, String time) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                type,
                style: AppTextStyles.cardTitle,
              ),
              Text(
                details,
                style: AppTextStyles.cardSubtitle,
              ),
            ],
          ),
        ),
        Text(
          time,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}

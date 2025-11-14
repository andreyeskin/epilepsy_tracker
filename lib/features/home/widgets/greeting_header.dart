import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_dimensions.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/constants/app_text_styles.dart';

/// Gradient Header mit "Hallo!" Begrüßung
/// Zeigt personalisierte Begrüßung am oberen Bildschirmrand
class GreetingHeader extends StatelessWidget {
  final String? userName;

  const GreetingHeader({
    super.key,
    this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppDimensions.spacingXxl),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF5AB49A), Color(0xFF8FD1B7)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppDimensions.radiusXl),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Hallo!',
            style: AppTextStyles.h1.copyWith(
              color: Colors.white,
              fontSize: 28,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppDimensions.spacingSm),
          Text(
            'Wie geht es dir heute?',
            style: AppTextStyles.bodyMedium.copyWith(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}

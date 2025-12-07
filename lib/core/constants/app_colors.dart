import 'package:flutter/material.dart';

/// Farbpalette für die Epilepsie-Management-App
/// Basiert auf Material Design 3 (2025) - Expressive & Modern
class AppColors {
  AppColors._(); // Private constructor für Utility-Klasse

  // Primärfarben - Teal/Grün (Material Design 3)
  static const Color primary = Color(0xFF26A69A);           // Vibrant Teal
  static const Color primaryLight = Color(0xFF64D8CB);      // Light Teal
  static const Color primaryMedium = Color(0xFF4DB6AC);     // Medium Teal
  static const Color primaryDark = Color(0xFF00796B);       // Deep Teal
  static const Color primaryContainer = Color(0xFFB2DFDB);  // Container Teal

  // Sekundärfarben - Akzent
  static const Color secondary = Color(0xFF42A5F5);         // Blue
  static const Color secondaryLight = Color(0xFF80D6FF);    // Light Blue
  static const Color secondaryDark = Color(0xFF0077C2);     // Deep Blue

  // Tertiärfarben - Warmer Akzent
  static const Color tertiary = Color(0xFFFF7043);          // Coral
  static const Color tertiaryLight = Color(0xFFFFAB91);     // Light Coral
  static const Color tertiaryDark = Color(0xFFC63F17);      // Deep Coral

  // Surface & Background (Material Design 3 Elevation Tint)
  static const Color surface = Color(0xFFFFFFFF);           // Surface Level 0
  static const Color surfaceVariant = Color(0xFFF5F5F5);    // Surface Level 1
  static const Color surfaceContainer = Color(0xFFECEFF1);  // Surface Level 2
  static const Color surfaceContainerHigh = Color(0xFFE0E0E0); // Surface Level 3

  static const Color background = Color(0xFFFAFDFC);        // Soft mint background
  static const Color cardBackground = Color(0xFFFFFFFF);    // Pure white cards

  // Outline & Divider
  static const Color outline = Color(0xFFBDBDBD);           // Medium gray
  static const Color outlineVariant = Color(0xFFE0E0E0);    // Light gray
  static const Color divider = Color(0xFFEEEEEE);           // Very light divider

  // Textfarben (Material Design 3 - Higher contrast)
  static const Color textPrimary = Color(0xFF1A1C1E);       // Nearly black
  static const Color textSecondary = Color(0xFF43474E);     // Medium gray
  static const Color textTertiary = Color(0xFF73777F);      // Light gray
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // White on primary
  static const Color textOnSurface = Color(0xFF1A1C1E);     // Black on surface
  static const Color textDisabled = Color(0xFF9E9E9E);      // Disabled text

  // Statusfarben (Semantic colors)
  static const Color success = Color(0xFF4CAF50);           // Green
  static const Color successLight = Color(0xFF81C784);      // Light Green
  static const Color successDark = Color(0xFF388E3C);       // Dark Green

  static const Color error = Color(0xFFEF5350);             // Red
  static const Color errorLight = Color(0xFFE57373);        // Light Red
  static const Color errorDark = Color(0xFFC62828);         // Dark Red

  static const Color warning = Color(0xFFFFA726);           // Orange
  static const Color warningLight = Color(0xFFFFB74D);      // Light Orange
  static const Color warningDark = Color(0xFFF57C00);       // Dark Orange

  static const Color info = Color(0xFF29B6F6);              // Light Blue
  static const Color infoLight = Color(0xFF4FC3F7);         // Lighter Blue
  static const Color infoDark = Color(0xFF0288D1);          // Deep Blue

  // Gradients - More vibrant and expressive
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF26A69A), Color(0xFF4DB6AC), Color(0xFF80CBC4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF00796B), Color(0xFF26A69A)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF42A5F5), Color(0xFF64B5F6), Color(0xFF90CAF9)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient warmGradient = LinearGradient(
    colors: [Color(0xFFFF7043), Color(0xFFFFAB91)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Overlay colors para estados interactivos
  static const Color hoverOverlay = Color(0x0A000000);      // 4% black
  static const Color focusOverlay = Color(0x1F000000);      // 12% black
  static const Color pressedOverlay = Color(0x1F000000);    // 12% black

  // Elevation shadows (Material Design 3)
  static BoxShadow elevation1 = BoxShadow(
    color: const Color(0xFF26A69A).withValues(alpha: 0.08),
    blurRadius: 2,
    offset: const Offset(0, 1),
  );

  static BoxShadow elevation2 = BoxShadow(
    color: const Color(0xFF26A69A).withValues(alpha: 0.12),
    blurRadius: 4,
    offset: const Offset(0, 2),
  );

  static BoxShadow elevation3 = BoxShadow(
    color: const Color(0xFF26A69A).withValues(alpha: 0.16),
    blurRadius: 8,
    offset: const Offset(0, 4),
  );

  static BoxShadow elevation4 = BoxShadow(
    color: const Color(0xFF26A69A).withValues(alpha: 0.20),
    blurRadius: 12,
    offset: const Offset(0, 6),
  );
}

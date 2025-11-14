import 'package:flutter/material.dart';

/// Farbpalette für die Epilepsie-Management-App
/// Alle Farben basieren auf dem UI-Design vom November 2025
class AppColors {
  AppColors._(); // Private constructor für Utility-Klasse

  // Primärfarben - Teal/Grün
  static const Color primary = Color(0xFF4CAF93);           // Haupt-Teal
  static const Color primaryLight = Color(0xFFA6D5C4);      // Heller Teal
  static const Color primaryMedium = Color(0xFF8FD1B7);     // Mittleres Teal
  static const Color primaryDark = Color(0xFF3A8C78);       // Dunkles Teal

  // Hintergrundfarben
  static const Color background = Color(0xFFF7FAF9);        // Sehr helles Grau-Grün
  static const Color cardBackground = Color(0xFFFFFFFF);    // Weiß
  static const Color divider = Color(0xFFE8F2EE);           // Helles Grün-Grau

  // Textfarben
  static const Color textPrimary = Color(0xFF1F2937);       // Fast Schwarz
  static const Color textSecondary = Color(0xFF4B5563);     // Grau
  static const Color textOnPrimary = Color(0xFFFFFFFF);     // Weiß auf Teal

  // Statusfarben
  static const Color success = Color(0xFF4CAF93);           // Grün - "Genommen"
  static const Color error = Color(0xFFD9534F);             // Rot - Emergency Button
  static const Color warning = Color(0xFFFF9800);           // Orange - Warnungen
  static const Color info = Color(0xFF2196F3);              // Blau - Info

  // Gradients für Cards
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF4CAF93), Color(0xFFA6D5C4)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient darkGradient = LinearGradient(
    colors: [Color(0xFF3A8C78), Color(0xFF4CAF93)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

import 'package:flutter/animation.dart';

/// Animationskonstanten für die App
/// Basiert auf Material Design 3 Motion (2025)
/// Provides consistent, expressive motion throughout the app
class AppAnimations {
  AppAnimations._(); // Private constructor für Utility-Klasse

  // Duration (Material Design 3 - Expressive)
  static const Duration durationInstant = Duration(milliseconds: 0);
  static const Duration durationQuick = Duration(milliseconds: 100);
  static const Duration durationShort = Duration(milliseconds: 200);
  static const Duration durationMedium = Duration(milliseconds: 300);
  static const Duration durationLong = Duration(milliseconds: 400);
  static const Duration durationExtraLong = Duration(milliseconds: 500);
  static const Duration durationSlow = Duration(milliseconds: 600);

  // Curves (Material Design 3 - Natural motion)
  static const Curve curveStandard = Curves.easeInOutCubicEmphasized;
  static const Curve curveDecelerate = Curves.easeOut;
  static const Curve curveAccelerate = Curves.easeIn;
  static const Curve curveLinear = Curves.linear;

  // Material Design 3 specific curves
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;
  static const Curve curveEmphasizedDecelerate = Curves.easeOutCubic;
  static const Curve curveEmphasizedAccelerate = Curves.easeInCubic;

  // Bouncy animations for playful elements
  static const Curve curveBounce = Curves.elasticOut;
  static const Curve curveSpring = Curves.bounceOut;

  // Page transitions
  static const Duration pageTransitionDuration = durationMedium;
  static const Curve pageTransitionCurve = curveStandard;

  // Button animations
  static const Duration buttonPressDuration = durationQuick;
  static const Duration buttonReleaseDuration = durationShort;
  static const Curve buttonCurve = curveEmphasized;

  // Card animations
  static const Duration cardExpandDuration = durationMedium;
  static const Duration cardCollapseDuration = durationShort;
  static const Curve cardCurve = curveEmphasized;

  // List item animations
  static const Duration listItemDuration = durationShort;
  static const Curve listItemCurve = curveDecelerate;

  // Fade animations
  static const Duration fadeDuration = durationMedium;
  static const Curve fadeCurve = curveLinear;

  // Scale animations (for micro-interactions)
  static const Duration scaleDuration = durationQuick;
  static const Curve scaleCurve = curveEmphasized;
  static const double scaleMin = 0.95;
  static const double scaleMax = 1.05;

  // Slide animations
  static const Duration slideDuration = durationMedium;
  static const Curve slideCurve = curveEmphasized;

  // Rotation animations
  static const Duration rotationDuration = durationMedium;
  static const Curve rotationCurve = curveStandard;

  // Shimmer loading (for skeleton screens)
  static const Duration shimmerDuration = Duration(milliseconds: 1500);
  static const Curve shimmerCurve = curveLinear;

  // Ripple effect
  static const Duration rippleDuration = Duration(milliseconds: 300);

  // Dialog animations
  static const Duration dialogDuration = durationMedium;
  static const Curve dialogCurve = curveEmphasized;

  // Bottom sheet animations
  static const Duration bottomSheetDuration = durationMedium;
  static const Curve bottomSheetCurve = curveEmphasizedDecelerate;

  // Snackbar animations
  static const Duration snackbarDuration = durationShort;
  static const Curve snackbarCurve = curveEmphasizedDecelerate;

  // FAB animations
  static const Duration fabDuration = durationMedium;
  static const Curve fabCurve = curveEmphasized;

  // Stagger animations (for lists)
  static const Duration staggerDelay = Duration(milliseconds: 50);
  static const int maxStaggerItems = 10;
}

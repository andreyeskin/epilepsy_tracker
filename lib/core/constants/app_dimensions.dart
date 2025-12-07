/// Spacing und Dimensionen für konsistentes Layout
/// Basiert auf Material Design 3 (8dp grid system)
class AppDimensions {
  AppDimensions._(); // Private constructor für Utility-Klasse

  // Spacing (8dp grid system - Material Design 3)
  static const double spacingXs = 4.0;    // 0.5x
  static const double spacingSm = 8.0;    // 1x - Base unit
  static const double spacingMd = 12.0;   // 1.5x
  static const double spacingLg = 16.0;   // 2x
  static const double spacingXl = 24.0;   // 3x
  static const double spacingXxl = 32.0;  // 4x
  static const double spacing3Xl = 40.0;  // 5x
  static const double spacing4Xl = 48.0;  // 6x
  static const double spacing5Xl = 64.0;  // 8x

  // Border Radius (Material Design 3 - More rounded)
  static const double radiusXs = 4.0;     // Extra small
  static const double radiusSm = 8.0;     // Small
  static const double radiusMd = 12.0;    // Medium
  static const double radiusLg = 16.0;    // Large
  static const double radiusXl = 20.0;    // Extra large
  static const double radiusXxl = 28.0;   // Extra extra large
  static const double radius3Xl = 32.0;   // Full rounded cards
  static const double radiusCircle = 999.0; // Fully circular

  // Icon Sizes (Material Design 3)
  static const double iconXs = 16.0;
  static const double iconSm = 20.0;
  static const double iconMd = 24.0;
  static const double iconLg = 32.0;
  static const double iconXl = 40.0;
  static const double iconXxl = 48.0;
  static const double icon3Xl = 64.0;

  // Button Heights (Material Design 3 - Larger touch targets)
  static const double buttonHeightSm = 40.0;
  static const double buttonHeightMd = 48.0;  // Minimum touch target 48dp
  static const double buttonHeightLg = 56.0;
  static const double buttonHeightXl = 64.0;

  // Button Padding
  static const double buttonPaddingHorizontal = 24.0;
  static const double buttonPaddingVertical = 12.0;

  // App Bar
  static const double appBarHeight = 64.0;  // Material 3 default

  // Bottom Nav
  static const double bottomNavHeight = 80.0;

  // FAB (Floating Action Button)
  static const double fabSize = 56.0;
  static const double fabSizeLarge = 96.0;
  static const double fabIconSize = 24.0;

  // Card (Material Design 3)
  static const double cardElevation = 1.0;  // Subtle elevation
  static const double cardPadding = 16.0;
  static const double cardPaddingLarge = 24.0;
  static const double cardMinHeight = 80.0;

  // Elevation levels (Material Design 3)
  static const double elevation0 = 0.0;
  static const double elevation1 = 1.0;
  static const double elevation2 = 3.0;
  static const double elevation3 = 6.0;
  static const double elevation4 = 8.0;
  static const double elevation5 = 12.0;

  // Divider & Borders
  static const double dividerThickness = 1.0;
  static const double borderWidth = 1.0;
  static const double borderWidthThick = 2.0;

  // Container Max Width (für Tablets)
  static const double maxContentWidth = 600.0;
  static const double maxContentWidthLarge = 840.0;

  // List Items
  static const double listItemHeight = 64.0;
  static const double listItemHeightLarge = 72.0;
  static const double listItemHeightCompact = 48.0;

  // Chip sizes
  static const double chipHeight = 32.0;
  static const double chipPaddingHorizontal = 12.0;

  // Avatar sizes
  static const double avatarSm = 32.0;
  static const double avatarMd = 40.0;
  static const double avatarLg = 56.0;
  static const double avatarXl = 72.0;

  // Minimum touch target size (Accessibility)
  static const double minTouchTarget = 48.0;
}

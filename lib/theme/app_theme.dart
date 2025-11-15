import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// A class that contains all theme configurations for the application.
/// Implements Contemporary Educational Minimalism design system with
/// Focused Learning Palette optimized for Vietnamese educational mobile apps.
class AppTheme {
  AppTheme._();

  // Design System Colors - Focused Learning Palette
  static const Color primary = Color(
    0xFF6C63FF,
  ); // Core brand color for CTAs and progress indicators
  static const Color secondary = Color(
    0xFFFF6584,
  ); // Accent color for achievements and positive feedback
  static const Color success = Color(
    0xFF4CAF50,
  ); // Correct answers and completion states
  static const Color warning = Color(
    0xFFFFC107,
  ); // Attention states and moderate difficulty indicators
  static const Color error = Color(
    0xFFF44336,
  ); // Incorrect answers and validation errors
  static const Color background = Color(
    0xFFF5F7FA,
  ); // Primary surface color reducing eye strain
  static const Color surface = Color(
    0xFFFFFFFF,
  ); // Card backgrounds and modal surfaces
  static const Color textPrimary = Color(
    0xFF1A1A1A,
  ); // High contrast for body text
  static const Color textSecondary = Color(
    0xFF6B7280,
  ); // Supporting text and metadata
  static const Color border = Color(0xFFE5E7EB); // Subtle element separation

  // Dark theme variations
  static const Color primaryDark = Color(0xFF8B82FF);
  static const Color secondaryDark = Color(0xFFFF7A96);
  static const Color successDark = Color(0xFF66BB6A);
  static const Color warningDark = Color(0xFFFFD54F);
  static const Color errorDark = Color(0xFFEF5350);
  static const Color backgroundDark = Color(0xFF0F1419);
  static const Color surfaceDark = Color(0xFF1A1F2E);
  static const Color textPrimaryDark = Color(0xFFE8EAED);
  static const Color textSecondaryDark = Color(0xFF9AA0A6);
  static const Color borderDark = Color(0xFF2D3748);

  // Shadow and elevation colors
  static const Color shadowLight = Color(
    0x14000000,
  ); // 2-4dp blur radius, 20% opacity
  static const Color shadowDark = Color(0x1FFFFFFF);

  /// Light theme - Contemporary Educational Minimalism
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.light,
      primary: primary,
      onPrimary: surface,
      primaryContainer: primary.withAlpha(26),
      onPrimaryContainer: primary,
      secondary: secondary,
      onSecondary: surface,
      secondaryContainer: secondary.withAlpha(26),
      onSecondaryContainer: secondary,
      tertiary: success,
      onTertiary: surface,
      tertiaryContainer: success.withAlpha(26),
      onTertiaryContainer: success,
      error: error,
      onError: surface,
      errorContainer: error.withAlpha(26),
      onErrorContainer: error,
      surface: surface,
      onSurface: textPrimary,
      onSurfaceVariant: textSecondary,
      outline: border,
      outlineVariant: border.withAlpha(128),
      shadow: shadowLight,
      scrim: textPrimary.withAlpha(128),
      inverseSurface: textPrimary,
      onInverseSurface: surface,
      inversePrimary: primaryDark,
      surfaceTint: primary,
    ),
    scaffoldBackgroundColor: background,

    // Typography - Inter font family for Vietnamese character support
    textTheme: _buildTextTheme(isLight: true),

    // AppBar Theme - Clean, content-focused
    appBarTheme: AppBarTheme(
      backgroundColor: surface,
      foregroundColor: textPrimary,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: shadowLight,
      surfaceTintColor: surface,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: textPrimary, size: 24),
      actionsIconTheme: const IconThemeData(color: textPrimary, size: 24),
      centerTitle: true,
      toolbarHeight: 56,
    ),

    // Card Theme - Clean content separation
    cardTheme: CardThemeData(
      color: surface,
      elevation: 2,
      shadowColor: shadowLight,
      surfaceTintColor: surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation - Adaptive navigation for core sections
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surface,
      selectedItemColor: primary,
      unselectedItemColor: textSecondary,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      selectedIconTheme: const IconThemeData(size: 24),
      unselectedIconTheme: const IconThemeData(size: 24),
    ),

    // Tab Bar Theme - Clean tab navigation
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textSecondary,
      indicatorColor: primary,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      overlayColor: WidgetStateProperty.all(primary.withAlpha(26)),
    ),

    // Floating Action Button - Strategic FAB placement
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primary,
      foregroundColor: surface,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Button Themes - Micro-feedback animations
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: surface,
        elevation: 2,
        shadowColor: shadowLight,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primary,
        side: const BorderSide(color: primary, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    // Input Decoration - Clear visual feedback
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surface,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: border, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: error, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary,
        letterSpacing: 0.15,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondary.withAlpha(153),
        letterSpacing: 0.15,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: error,
        letterSpacing: 0.4,
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primary,
      linearTrackColor: Color(0xFFE8EAED),
      circularTrackColor: Color(0xFFE8EAED),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return textSecondary;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return primary.withAlpha(128);
        return border;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(surface),
      side: const BorderSide(color: border, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primary;
        return border;
      }),
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primary,
      inactiveTrackColor: border,
      thumbColor: primary,
      overlayColor: primary.withAlpha(51),
      valueIndicatorColor: primary,
      valueIndicatorTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: surface,
      ),
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimary.withAlpha(230),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: surface,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: surface,
      ),
      actionTextColor: primary,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
    ),

    // Dialog Theme
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      elevation: 8,
      shadowColor: shadowLight,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimary,
        letterSpacing: 0.15,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimary,
        letterSpacing: 0.5,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surface,
      elevation: 8,
      modalElevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Expansion Tile Theme - Progressive disclosure
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: surface,
      collapsedBackgroundColor: surface,
      textColor: textPrimary,
      collapsedTextColor: textPrimary,
      iconColor: textSecondary,
      collapsedIconColor: textSecondary,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(color: border, thickness: 1, space: 1),
  );

  /// Dark theme - Contemporary Educational Minimalism (Dark Mode)
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    useMaterial3: true,
    colorScheme: ColorScheme(
      brightness: Brightness.dark,
      primary: primaryDark,
      onPrimary: backgroundDark,
      primaryContainer: primaryDark.withAlpha(51),
      onPrimaryContainer: primaryDark,
      secondary: secondaryDark,
      onSecondary: backgroundDark,
      secondaryContainer: secondaryDark.withAlpha(51),
      onSecondaryContainer: secondaryDark,
      tertiary: successDark,
      onTertiary: backgroundDark,
      tertiaryContainer: successDark.withAlpha(51),
      onTertiaryContainer: successDark,
      error: errorDark,
      onError: backgroundDark,
      errorContainer: errorDark.withAlpha(51),
      onErrorContainer: errorDark,
      surface: surfaceDark,
      onSurface: textPrimaryDark,
      onSurfaceVariant: textSecondaryDark,
      outline: borderDark,
      outlineVariant: borderDark.withAlpha(128),
      shadow: shadowDark,
      scrim: textPrimaryDark.withAlpha(128),
      inverseSurface: textPrimaryDark,
      onInverseSurface: surfaceDark,
      inversePrimary: primary,
      surfaceTint: primaryDark,
    ),
    scaffoldBackgroundColor: backgroundDark,

    // Typography - Inter font family for Vietnamese character support
    textTheme: _buildTextTheme(isLight: false),

    // AppBar Theme - Clean, content-focused
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceDark,
      foregroundColor: textPrimaryDark,
      elevation: 0,
      scrolledUnderElevation: 2,
      shadowColor: shadowDark,
      surfaceTintColor: surfaceDark,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
      ),
      iconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
      actionsIconTheme: const IconThemeData(color: textPrimaryDark, size: 24),
      centerTitle: true,
      toolbarHeight: 56,
    ),

    // Card Theme - Clean content separation (Dark theme section)
    cardTheme: CardThemeData(
      color: surfaceDark,
      elevation: 2,
      shadowColor: shadowDark,
      surfaceTintColor: surfaceDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Bottom Navigation - Adaptive navigation for core sections (Dark theme section)
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: surfaceDark,
      selectedItemColor: primaryDark,
      unselectedItemColor: textSecondaryDark,
      type: BottomNavigationBarType.fixed,
      elevation: 8,
      selectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        letterSpacing: 0.4,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.4,
      ),
      selectedIconTheme: const IconThemeData(size: 24),
      unselectedIconTheme: const IconThemeData(size: 24),
    ),

    // Tab Bar Theme - Clean tab navigation (Dark theme section)
    tabBarTheme: TabBarThemeData(
      labelColor: primaryDark,
      unselectedLabelColor: textSecondaryDark,
      indicatorColor: primaryDark,
      indicatorSize: TabBarIndicatorSize.label,
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.1,
      ),
      unselectedLabelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        letterSpacing: 0.1,
      ),
      overlayColor: WidgetStateProperty.all(primaryDark.withAlpha(26)),
    ),

    // Floating Action Button - Strategic FAB placement
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: primaryDark,
      foregroundColor: backgroundDark,
      elevation: 6,
      focusElevation: 8,
      hoverElevation: 8,
      highlightElevation: 12,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),

    // Button Themes - Micro-feedback animations
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primaryDark,
        foregroundColor: backgroundDark,
        elevation: 2,
        shadowColor: shadowDark,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: primaryDark,
        side: const BorderSide(color: primaryDark, width: 1),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        minimumSize: const Size(88, 48),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primaryDark,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        minimumSize: const Size(64, 40),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        textStyle: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          letterSpacing: 0.1,
        ),
        animationDuration: const Duration(milliseconds: 200),
      ),
    ),

    // Input Decoration - Clear visual feedback
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceDark,
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: borderDark, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: primaryDark, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorDark, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: errorDark, width: 2),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark,
        letterSpacing: 0.15,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textSecondaryDark.withAlpha(153),
        letterSpacing: 0.15,
      ),
      errorStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: errorDark,
        letterSpacing: 0.4,
      ),
    ),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: primaryDark,
      linearTrackColor: Color(0xFF2D3748),
      circularTrackColor: Color(0xFF2D3748),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryDark;
        return textSecondaryDark;
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected))
          return primaryDark.withAlpha(128);
        return borderDark;
      }),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryDark;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(backgroundDark),
      side: const BorderSide(color: borderDark, width: 2),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return primaryDark;
        return borderDark;
      }),
    ),

    // Slider Theme
    sliderTheme: SliderThemeData(
      activeTrackColor: primaryDark,
      inactiveTrackColor: borderDark,
      thumbColor: primaryDark,
      overlayColor: primaryDark.withAlpha(51),
      valueIndicatorColor: primaryDark,
      valueIndicatorTextStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: backgroundDark,
      ),
    ),

    // Tooltip Theme
    tooltipTheme: TooltipThemeData(
      decoration: BoxDecoration(
        color: textPrimaryDark.withAlpha(230),
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: backgroundDark,
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // SnackBar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimaryDark,
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: backgroundDark,
      ),
      actionTextColor: primaryDark,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 6,
    ),

    // Dialog Theme (Dark theme section)
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceDark,
      elevation: 8,
      shadowColor: shadowDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: textPrimaryDark,
        letterSpacing: 0.15,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textPrimaryDark,
        letterSpacing: 0.5,
      ),
    ),

    // Bottom Sheet Theme
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: surfaceDark,
      elevation: 8,
      modalElevation: 16,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
    ),

    // Expansion Tile Theme - Progressive disclosure
    expansionTileTheme: ExpansionTileThemeData(
      backgroundColor: surfaceDark,
      collapsedBackgroundColor: surfaceDark,
      textColor: textPrimaryDark,
      collapsedTextColor: textPrimaryDark,
      iconColor: textSecondaryDark,
      collapsedIconColor: textSecondaryDark,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      collapsedShape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
    ),

    // Divider Theme
    dividerTheme: const DividerThemeData(
      color: borderDark,
      thickness: 1,
      space: 1,
    ),
  );

  /// Helper method to build text theme based on brightness
  /// Uses Inter font family for excellent Vietnamese character support
  static TextTheme _buildTextTheme({required bool isLight}) {
    final Color textHigh = isLight ? textPrimary : textPrimaryDark;
    final Color textMedium = isLight ? textSecondary : textSecondaryDark;
    final Color textDisabled =
    isLight
        ? textSecondary.withAlpha(153)
        : textSecondaryDark.withAlpha(153);

    return TextTheme(
      // Display styles - Inter w700 for strong mobile readability
      displayLarge: GoogleFonts.inter(
        fontSize: 57,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: -0.25,
        height: 1.12,
      ),
      displayMedium: GoogleFonts.inter(
        fontSize: 45,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: 0,
        height: 1.16,
      ),
      displaySmall: GoogleFonts.inter(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: textHigh,
        letterSpacing: 0,
        height: 1.22,
      ),

      // Headline styles - Inter w600 for headings
      headlineLarge: GoogleFonts.inter(
        fontSize: 32,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.25,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 28,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.29,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.33,
      ),

      // Title styles - Inter w500/w600 for section titles
      titleLarge: GoogleFonts.inter(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: textHigh,
        letterSpacing: 0,
        height: 1.27,
      ),
      titleMedium: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.15,
        height: 1.50,
      ),
      titleSmall: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.1,
        height: 1.43,
      ),

      // Body styles - Inter w400/w500 optimized for extended reading
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.5,
        height: 1.50,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: textHigh,
        letterSpacing: 0.25,
        height: 1.43,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: textMedium,
        letterSpacing: 0.4,
        height: 1.33,
      ),

      // Label styles - Inter w400/w500 for captions and metadata
      labelLarge: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: textHigh,
        letterSpacing: 0.1,
        height: 1.43,
      ),
      labelMedium: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: textMedium,
        letterSpacing: 0.5,
        height: 1.33,
      ),
      labelSmall: GoogleFonts.inter(
        fontSize: 11,
        fontWeight: FontWeight.w400,
        color: textDisabled,
        letterSpacing: 0.5,
        height: 1.45,
      ),
    );
  }

  /// Data text style using JetBrains Mono for scores and statistics
  static TextStyle dataTextStyle({
    required bool isLight,
    double fontSize = 16,
    FontWeight fontWeight = FontWeight.w400,
  }) {
    return GoogleFonts.jetBrainsMono(
      fontSize: fontSize,
      fontWeight: fontWeight,
      color: isLight ? textPrimary : textPrimaryDark,
      letterSpacing: 0,
      height: 1.5,
    );
  }

  /// Helper method to get theme-aware colors
  static Color getTextColor(BuildContext context, {bool secondary = false}) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (secondary) {
      return isDark ? textSecondaryDark : textSecondary;
    }
    return isDark ? textPrimaryDark : textPrimary;
  }

  /// Helper method to get surface color
  static Color getSurfaceColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? surfaceDark : surface;
  }

  /// Helper method to get background color
  static Color getBackgroundColor(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? backgroundDark : background;
  }
}

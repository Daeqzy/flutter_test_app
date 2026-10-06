import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ==========================================================
  // BRAND
  // ==========================================================

  static const Color primary = Color(0xFF2563EB);
  static const Color primaryDark = Color(0xFF1D4ED8);
  static const Color primarySoft = Color(0xFFDBEAFE);

  // ==========================================================
  // LIGHT
  // ==========================================================

  static const Color background = Color(0xFFF7F9FC);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF64748B);

  static const Color border = Color(0xFFE7EAF0);

  // ==========================================================
  // DARK
  // ==========================================================

  static const Color darkBackground = Color(0xFF0B101B);
  static const Color darkSurface = Color(0xFF111827);
  static const Color darkSurfaceElevated = Color(0xFF172033);
  static const Color darkBorder = Color(0xFF202A3A);

  static const Color darkTextPrimary = Color(0xFFF8FAFC);
  static const Color darkTextSecondary = Color(0xFF94A3B8);

  // ==========================================================
  // STATUS
  // ==========================================================

  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFDC2626);
}

class AppTheme {
  AppTheme._();

  // ============================================================
  // LIGHT THEME
  // ============================================================

  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.light,
      surface: AppColors.surface,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.background,

      // ========================================================
      // TYPOGRAPHY
      // ========================================================
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: AppColors.textPrimary,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
          color: AppColors.textPrimary,
        ),

        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
          color: AppColors.textPrimary,
        ),

        bodyLarge: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.textPrimary,
        ),

        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppColors.textSecondary,
        ),

        bodySmall: TextStyle(
          fontSize: 11,
          height: 1.35,
          color: AppColors.textSecondary,
        ),
      ),

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        foregroundColor: AppColors.textPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,

        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),

        iconTheme: IconThemeData(color: AppColors.textPrimary, size: 22),
      ),

      // ========================================================
      // CARDS
      // ========================================================
      cardTheme: CardThemeData(
        color: AppColors.surface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),

          side: const BorderSide(color: AppColors.border, width: 0.8),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.surface,

        hintStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        labelStyle: const TextStyle(
          color: AppColors.textSecondary,
          fontSize: 13,
        ),

        prefixIconColor: AppColors.textSecondary,

        suffixIconColor: AppColors.textSecondary,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.border),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.border),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.primary, width: 1.4),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),

      // ========================================================
      // FILLED BUTTON
      // ========================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          minimumSize: const Size(double.infinity, 50),

          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.textPrimary,

          minimumSize: const Size(double.infinity, 50),

          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),

          side: const BorderSide(color: AppColors.border),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,

          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      // ========================================================
      // DRAWER
      // ========================================================
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.border,
        thickness: 0.8,
        space: 1,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: AppColors.textPrimary,

        contentTextStyle: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.surface,

        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }

  // ============================================================
  // DARK THEME
  // ============================================================

  static ThemeData get dark {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.primary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
    );

    return ThemeData(
      useMaterial3: true,

      colorScheme: colorScheme,

      scaffoldBackgroundColor: AppColors.darkBackground,

      // ========================================================
      // TYPOGRAPHY
      // ========================================================
      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          fontSize: 22,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.6,
          color: AppColors.darkTextPrimary,
        ),

        titleLarge: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.35,
          color: AppColors.darkTextPrimary,
        ),

        titleMedium: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.15,
          color: AppColors.darkTextPrimary,
        ),

        bodyLarge: TextStyle(
          fontSize: 14,
          height: 1.45,
          color: AppColors.darkTextPrimary,
        ),

        bodyMedium: TextStyle(
          fontSize: 13,
          height: 1.4,
          color: AppColors.darkTextSecondary,
        ),

        bodySmall: TextStyle(
          fontSize: 11,
          height: 1.35,
          color: AppColors.darkTextSecondary,
        ),
      ),

      // ========================================================
      // APP BAR
      // ========================================================
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.darkBackground,
        foregroundColor: AppColors.darkTextPrimary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,

        titleTextStyle: TextStyle(
          color: AppColors.darkTextPrimary,
          fontSize: 19,
          fontWeight: FontWeight.w800,
          letterSpacing: -0.4,
        ),

        iconTheme: IconThemeData(color: AppColors.darkTextPrimary, size: 22),
      ),

      // ========================================================
      // CARDS
      // ========================================================
      cardTheme: CardThemeData(
        color: AppColors.darkSurface,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        margin: EdgeInsets.zero,

        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),

          side: const BorderSide(color: AppColors.darkBorder, width: 0.8),
        ),
      ),

      // ========================================================
      // INPUTS
      // ========================================================
      inputDecorationTheme: InputDecorationTheme(
        filled: true,

        fillColor: AppColors.darkSurface,

        hintStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 14,
          fontWeight: FontWeight.w400,
        ),

        labelStyle: const TextStyle(
          color: AppColors.darkTextSecondary,
          fontSize: 13,
        ),

        prefixIconColor: AppColors.darkTextSecondary,

        suffixIconColor: AppColors.darkTextSecondary,

        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),

        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.darkBorder),
        ),

        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: Color(0xFF3B82F6), width: 1.4),
        ),

        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.error),
        ),

        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),

          borderSide: const BorderSide(color: AppColors.error, width: 1.4),
        ),
      ),

      // ========================================================
      // FILLED BUTTON
      // ========================================================
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.primary,

          foregroundColor: Colors.white,

          minimumSize: const Size(double.infinity, 50),

          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),

          elevation: 0,

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700),
        ),
      ),

      // ========================================================
      // OUTLINED BUTTON
      // ========================================================
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.darkTextPrimary,

          minimumSize: const Size(double.infinity, 50),

          padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 14),

          side: const BorderSide(color: AppColors.darkBorder),

          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),

          textStyle: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
        ),
      ),

      // ========================================================
      // TEXT BUTTON
      // ========================================================
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xFF60A5FA),

          textStyle: const TextStyle(fontWeight: FontWeight.w700),
        ),
      ),

      // ========================================================
      // CHECKBOX
      // ========================================================
      checkboxTheme: CheckboxThemeData(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
      ),

      // ========================================================
      // DRAWER
      // ========================================================
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.darkSurface,
        surfaceTintColor: Colors.transparent,
      ),

      // ========================================================
      // DIVIDERS
      // ========================================================
      dividerTheme: const DividerThemeData(
        color: AppColors.darkBorder,
        thickness: 0.8,
        space: 1,
      ),

      // ========================================================
      // SNACKBAR
      // ========================================================
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,

        backgroundColor: const Color(0xFFF8FAFC),

        contentTextStyle: const TextStyle(
          color: Color(0xFF111827),
          fontWeight: FontWeight.w500,
        ),

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),

      // ========================================================
      // DIALOG
      // ========================================================
      dialogTheme: DialogThemeData(
        backgroundColor: AppColors.darkSurface,

        surfaceTintColor: Colors.transparent,

        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(22)),
      ),
    );
  }
}

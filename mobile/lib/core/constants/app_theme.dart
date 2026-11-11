import 'package:flutter/material.dart';
import 'app_borders_and_shadows.dart';
import 'app_colors.dart';
import 'app_dimensions.dart';
import 'app_text_styles.dart';

/// App theme configuration (Material 3 Light & Dark themes wired to Design System tokens).
class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: const ColorScheme.light(
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainerLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainerLight,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainerLight,
        surface: AppColors.surfaceLight,
        onSurface: AppColors.textPrimaryLight,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.borderDefaultLight,
        outlineVariant: AppColors.borderSubtleLight,
      ),
      scaffoldBackgroundColor: AppColors.backgroundLight,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.textPrimaryLight,
        elevation: AppShadows.elevation0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.white,
          minimumSize: const Size(double.infinity, AppSizing.buttonHeightLg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          minimumSize: const Size(double.infinity, AppSizing.buttonHeightLg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          side: const BorderSide(color: AppColors.primary),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey100,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: AppBorders.focusSideLight,
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: AppBorders.errorSideLight,
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.textDisabledLight,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.white,
        elevation: AppShadows.elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.white,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.grey400,
        type: BottomNavigationBarType.fixed,
        elevation: AppShadows.elevation3,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.white,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.dividerLight,
        thickness: AppBorders.dividerThickness,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primaryLight,
        onPrimary: AppColors.black,
        primaryContainer: AppColors.primaryDark,
        secondary: AppColors.secondaryLight,
        onSecondary: AppColors.black,
        secondaryContainer: AppColors.secondaryDark,
        tertiary: AppColors.tertiaryLight,
        tertiaryContainer: AppColors.tertiaryContainerDark,
        surface: AppColors.surfaceDark,
        onSurface: AppColors.grey100,
        error: AppColors.error,
        onError: AppColors.white,
        outline: AppColors.borderDefaultDark,
        outlineVariant: AppColors.borderSubtleDark,
      ),
      scaffoldBackgroundColor: AppColors.backgroundDark,
      textTheme: _textTheme,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.surfaceDark,
        foregroundColor: AppColors.white,
        elevation: AppShadows.elevation0,
        centerTitle: true,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryLight,
          foregroundColor: AppColors.black,
          minimumSize: const Size(double.infinity, AppSizing.buttonHeightLg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          textStyle: AppTextStyles.button,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          minimumSize: const Size(double.infinity, AppSizing.buttonHeightLg),
          shape: const RoundedRectangleBorder(
            borderRadius: AppRadius.borderRadiusMd,
          ),
          side: const BorderSide(color: AppColors.primaryLight),
          textStyle: AppTextStyles.button,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primaryLight,
          textStyle: AppTextStyles.button,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.grey800,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        border: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        enabledBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide.none,
        ),
        focusedBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: AppBorders.focusSideDark,
        ),
        errorBorder: const OutlineInputBorder(
          borderRadius: AppRadius.borderRadiusMd,
          borderSide: BorderSide(color: AppColors.error, width: 2),
        ),
        hintStyle: AppTextStyles.bodyMedium.copyWith(
          color: AppColors.grey500,
        ),
      ),
      cardTheme: const CardThemeData(
        color: AppColors.surfaceDark,
        elevation: AppShadows.elevation1,
        shape: RoundedRectangleBorder(
          borderRadius: AppRadius.borderRadiusLg,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surfaceDark,
        selectedItemColor: AppColors.primaryLight,
        unselectedItemColor: AppColors.grey500,
        type: BottomNavigationBarType.fixed,
        elevation: AppShadows.elevation3,
      ),
      floatingActionButtonTheme: const FloatingActionButtonThemeData(
        backgroundColor: AppColors.primaryLight,
        foregroundColor: AppColors.black,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.grey700,
        thickness: AppBorders.dividerThickness,
      ),
    );
  }

  static TextTheme get _textTheme {
    return const TextTheme(
      displayLarge: AppTextStyles.displayLarge,
      displayMedium: AppTextStyles.displayMedium,
      displaySmall: AppTextStyles.displaySmall,
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      titleLarge: AppTextStyles.titleLarge,
      titleMedium: AppTextStyles.titleMedium,
      titleSmall: AppTextStyles.titleSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    );
  }
}

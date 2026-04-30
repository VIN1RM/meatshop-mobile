import 'package:flutter/material.dart';
import 'app_colors.dart';

abstract class AppTheme {
  static ThemeData get client => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.white,
    colorScheme: const ColorScheme.light(
      primary: AppColors.red500,
      onPrimary: AppColors.white,
      secondary: AppColors.red700,
      onSecondary: AppColors.white,
      surface: AppColors.white,
      onSurface: AppColors.grey400,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.grey400,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.grey400,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.red500,
        foregroundColor: AppColors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.red500,
        side: const BorderSide(color: AppColors.red500, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.redSurface,
      labelStyle: TextStyle(color: AppColors.red500, fontSize: 11),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.grey400),
      bodyMedium: TextStyle(color: AppColors.grey400),
      bodySmall: TextStyle(color: AppColors.grey200),
      labelSmall: TextStyle(color: AppColors.grey200, letterSpacing: 0.06),
    ),
  );

  static ThemeData get driver => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: AppColors.grey300,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.white,
      onPrimary: AppColors.red500,
      secondary: AppColors.red500,
      onSecondary: AppColors.white,
      surface: AppColors.grey300,
      onSurface: AppColors.white,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.grey400,
      foregroundColor: AppColors.white,
      elevation: 0,
      surfaceTintColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: AppColors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.white,
        foregroundColor: AppColors.red500,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.white,
        side: const BorderSide(color: AppColors.white, width: 1.5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    ),
    chipTheme: const ChipThemeData(
      backgroundColor: AppColors.grey400,
      labelStyle: TextStyle(color: AppColors.white, fontSize: 11),
    ),
    textTheme: const TextTheme(
      bodyLarge: TextStyle(color: AppColors.white),
      bodyMedium: TextStyle(color: AppColors.white),
      bodySmall: TextStyle(color: AppColors.grey100),
      labelSmall: TextStyle(color: AppColors.grey100, letterSpacing: 0.06),
    ),
  );
}

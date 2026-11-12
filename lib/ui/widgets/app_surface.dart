import 'package:flutter/material.dart';
import 'buttons_widget.dart';

ThemeData appSurfaceTheme(BuildContext context) => Theme.of(context).copyWith(
  colorScheme: ColorScheme.fromSeed(
    seedColor: AppColors.redPrimary,
    brightness: Brightness.light,
  ),
  textTheme: Theme.of(
    context,
  ).textTheme.apply(bodyColor: AppColors.dark, displayColor: AppColors.dark),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFFDDDDDD)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: AppColors.redPrimary, width: 2),
    ),
    labelStyle: const TextStyle(color: Color(0xFF555555)),
  ),
);

ThemeData appDarkSurfaceTheme(BuildContext context) =>
    Theme.of(context).copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppColors.redPrimary,
        onPrimary: Colors.white,
        secondary: AppColors.redBright,
        surface: Color(0xFF383838),
        onSurface: Colors.white,
        error: Color(0xFFFFA99F),
      ),
      textTheme: Theme.of(
        context,
      ).textTheme.apply(bodyColor: Colors.white, displayColor: Colors.white),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF383838),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 18,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Colors.white12),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.redPrimary, width: 1.5),
        ),
        labelStyle: const TextStyle(color: Colors.white70),
        hintStyle: const TextStyle(color: Colors.white38),
        prefixIconColor: const Color(0xFFCB7770),
        counterStyle: const TextStyle(color: Colors.white38),
        errorStyle: const TextStyle(color: Color(0xFFFFA99F), height: 1.4),
      ),
    );

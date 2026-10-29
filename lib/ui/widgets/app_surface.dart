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

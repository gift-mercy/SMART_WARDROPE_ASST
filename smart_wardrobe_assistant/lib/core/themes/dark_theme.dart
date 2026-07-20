import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

abstract class DarkTheme {
  static ThemeData get theme => ThemeData.dark(useMaterial3: true).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: AppColors.primaryLight,
          secondary: AppColors.secondaryLight,
          surface: Color(0xFF1E293B),
          error: AppColors.error,
        ),
        scaffoldBackgroundColor: const Color(0xFF0F172A),
        cardColor: const Color(0xFF1E293B),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF1E293B),
          foregroundColor: Colors.white,
        ),
      );
}

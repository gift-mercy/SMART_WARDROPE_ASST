import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Centralised typography for Smart Wardrobe Assistant.
/// Uses Google Fonts Poppins via the theme's textTheme — these styles
/// carry the correct sizes/weights; the fontFamily is applied by AppTheme.
abstract class AppTextStyles {
  // ── Headings ─────────────────────────────────────────────────────────────
  static const TextStyle heading = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
    letterSpacing: -0.3,
  );

  static const TextStyle subheading = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
    letterSpacing: -0.2,
  );

  // ── Body ─────────────────────────────────────────────────────────────────
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: AppColors.textPrimary,
  );

  static const TextStyle bodySecondary = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  // ── Small ────────────────────────────────────────────────────────────────
  static const TextStyle small = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.normal,
    color: AppColors.textSecondary,
  );

  static const TextStyle smallBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.normal,
    color: AppColors.textHint,
  );

  // ── Buttons ──────────────────────────────────────────────────────────────
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  static const TextStyle buttonSmall = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: 0.2,
  );

  // ── AppBar ───────────────────────────────────────────────────────────────
  static const TextStyle appBarTitle = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: AppColors.textOnPrimary,
    letterSpacing: -0.2,
  );

  // ── Labels ───────────────────────────────────────────────────────────────
  static const TextStyle label = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: AppColors.textSecondary,
  );

  static const TextStyle labelBold = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.textPrimary,
  );

  // ── Helpers ──────────────────────────────────────────────────────────────

  /// Returns a copy of [base] coloured with [AppColors.primary].
  static TextStyle primary(TextStyle base) =>
      base.copyWith(color: AppColors.primary);

  /// Returns a copy of [base] coloured with [AppColors.secondary].
  static TextStyle secondary(TextStyle base) =>
      base.copyWith(color: AppColors.secondary);

  /// Returns a copy of [base] coloured with [AppColors.error].
  static TextStyle error(TextStyle base) =>
      base.copyWith(color: AppColors.error);
}

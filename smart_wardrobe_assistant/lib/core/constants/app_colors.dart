import 'package:flutter/material.dart';

/// Central color palette for Smart Wardrobe Assistant.
/// All screens and widgets must reference these constants — never hard-code hex values.
abstract class AppColors {
  // ── Primary ──────────────────────────────────────────────────────────────
  /// Buttons, AppBar, active icons, navigation, important actions.
  static const Color primary = Color(0xFF4F46E5);
  static const Color primaryLight = Color(0xFF818CF8);
  static const Color primaryDark = Color(0xFF3730A3);

  // ── Secondary ────────────────────────────────────────────────────────────
  /// Recommendation cards, weather card, highlights, AI sections.
  static const Color secondary = Color(0xFF14B8A6);
  static const Color secondaryLight = Color(0xFF5EEAD4);
  static const Color secondaryDark = Color(0xFF0F766E);

  // ── Background ───────────────────────────────────────────────────────────
  static const Color background = Color(0xFFF8FAFC);
  static const Color card = Color(0xFFFFFFFF);

  // ── Status ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF22C55E);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);

  // ── Text ─────────────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textHint = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // ── Border / Divider ─────────────────────────────────────────────────────
  static const Color border = Color(0xFFE5E7EB);
  static const Color divider = Color(0xFFF3F4F6);

  // ── Overlay / Shadow ─────────────────────────────────────────────────────
  static const Color overlay = Color(0x80000000);
  static const Color shadow = Color(0x1A000000);

  // ── Camera-specific ──────────────────────────────────────────────────────
  static const Color cameraOverlay = Color(0xCC000000);
  static const Color cameraControl = Color(0xFFFFFFFF);
}

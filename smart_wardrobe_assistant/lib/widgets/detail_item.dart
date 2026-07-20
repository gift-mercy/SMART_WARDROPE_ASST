// ============================================
// DETAIL_ITEM.DART
// ============================================
// Reusable widget for displaying detail rows
// in the clothing details screen
//
// Purpose:
// - Display icon, label, and value in a row
// - Maintain consistent styling
// - Reusable across detail screens
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/constants/app_colors.dart';

/// DetailItem widget
/// Displays a single detail row with icon, label, and value
class DetailItem extends StatelessWidget {
  /// Icon to display on the left
  final IconData icon;

  /// Label text (e.g., "Category", "Color")
  final String label;

  /// Value text (e.g., "Shirts", "Blue")
  final String value;

  /// Optional icon color (defaults to primary color)
  final Color? iconColor;

  const DetailItem({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Icon
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: (iconColor ?? AppColors.primary).withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            size: 20,
            color: iconColor ?? AppColors.primary,
          ),
        ),

        const SizedBox(width: 12),

        // Label and Value
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Label
              Text(
                label,
                style: GoogleFonts.poppins(
                  fontSize: 12,
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),

              const SizedBox(height: 2),

              // Value
              Text(
                value,
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  color: AppColors.textPrimary,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

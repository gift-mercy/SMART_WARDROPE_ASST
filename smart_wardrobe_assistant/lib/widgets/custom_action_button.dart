// ============================================
// CUSTOM_ACTION_BUTTON.DART
// ============================================
// Reusable action button widget
//
// Purpose:
// - Provide consistent button styling
// - Display icon and label
// - Support custom colors
// - Reusable across the app
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// CustomActionButton widget
/// A reusable button with icon and label
class CustomActionButton extends StatelessWidget {
  /// Button label text
  final String label;

  /// Icon to display
  final IconData icon;

  /// Background color
  final Color backgroundColor;

  /// Callback function when button is pressed
  final VoidCallback onPressed;

  /// Optional foreground color (defaults to white)
  final Color? foregroundColor;

  const CustomActionButton({
    super.key,
    required this.label,
    required this.icon,
    required this.backgroundColor,
    required this.onPressed,
    this.foregroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: backgroundColor,
        foregroundColor: foregroundColor ?? Colors.white,
        elevation: 2,
        shadowColor: backgroundColor.withValues(alpha: 0.3),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 16,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Icon(
            icon,
            size: 20,
          ),

          const SizedBox(width: 8),

          // Label
          Flexible(
            child: Text(
              label,
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

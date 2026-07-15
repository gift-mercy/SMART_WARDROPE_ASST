// ============================================
// LOADING_WIDGET.DART
// ============================================
// Reusable loading indicator widget
//
// Purpose:
// - Display loading state
// - Consistent loading animation
// - Optional message
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// LoadingWidget
/// Displays a loading indicator with optional message
class LoadingWidget extends StatelessWidget {
  /// Optional loading message
  final String? message;

  const LoadingWidget({
    super.key,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Loading Indicator
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xFF4F46E5)),
            strokeWidth: 3,
          ),

          if (message != null) ...[
            const SizedBox(height: 24),

            // Loading Message
            Text(
              message!,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }
}

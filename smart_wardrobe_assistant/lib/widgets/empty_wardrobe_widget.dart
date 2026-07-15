// ============================================
// EMPTY_WARDROBE_WIDGET.DART
// ============================================
// Widget displayed when wardrobe is empty
//
// Purpose:
// - Show empty state message
// - Encourage user to add clothing
// - Provide visual feedback
// ============================================

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// EmptyWardrobeWidget
/// Displays when there are no clothing items in the wardrobe
class EmptyWardrobeWidget extends StatelessWidget {
  /// Optional custom message
  final String? message;

  /// Optional custom subtitle
  final String? subtitle;

  const EmptyWardrobeWidget({
    super.key,
    this.message,
    this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Wardrobe Icon
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: const Color(0xFFF8FAFC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.checkroom_outlined,
                size: 64,
                color: const Color(0xFFCBD5E1),
              ),
            ),

            const SizedBox(height: 24),

            // Message
            Text(
              message ?? 'Your wardrobe is empty.',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: const Color(0xFF1E293B),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              subtitle ?? 'Start by adding your first clothing item.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: const Color(0xFF64748B),
              ),
              textAlign: TextAlign.center,
            ),

            const SizedBox(height: 32),

            // Add Button Icon
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.add,
                size: 32,
                color: const Color(0xFF4F46E5),
              ),
            ),

            const SizedBox(height: 12),

            // Hint Text
            Text(
              'Tap the + button below to add clothes',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: const Color(0xFF94A3B8),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

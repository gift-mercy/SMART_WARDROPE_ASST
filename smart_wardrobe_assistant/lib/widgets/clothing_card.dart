// ============================================
// CLOTHING_CARD.DART
// ============================================
// Reusable widget for displaying a clothing item card
//
// Purpose:
// - Display clothing item in a grid
// - Show image, name, category, and color
// - Handle tap to view details
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../models/clothing_item.dart';

/// ClothingCard widget
/// Displays a single clothing item in a card format
class ClothingCard extends StatelessWidget {
  /// The clothing item to display
  final ClothingItem item;

  /// Callback when the card is tapped
  final VoidCallback? onTap;

  /// Callback for favorite button (optional)
  final VoidCallback? onFavorite;

  /// Whether this item is favorited
  final bool isFavorite;

  const ClothingCard({
    super.key,
    required this.item,
    this.onTap,
    this.onFavorite,
    this.isFavorite = false,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      color: Colors.white,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ============================================
            // IMAGE SECTION
            // ============================================
            Expanded(
              flex: 3,
              child: Stack(
                children: [
                  // Clothing Image with Hero Animation
                  Hero(
                    tag: 'clothing_${item.clothingId}',
                    child: Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        color: const Color(0xFFF8FAFC),
                      ),
                      child: ClipRRect(
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(12),
                          topRight: Radius.circular(12),
                        ),
                        child: _buildImage(),
                      ),
                    ),
                  ),

                  // Favorite Icon (Optional)
                  if (onFavorite != null)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.9),
                          shape: BoxShape.circle,
                        ),
                        child: IconButton(
                          icon: Icon(
                            isFavorite ? Icons.favorite : Icons.favorite_border,
                            color: isFavorite
                                ? const Color(0xFFEF4444)
                                : const Color(0xFF64748B),
                            size: 20,
                          ),
                          onPressed: onFavorite,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints(
                            minWidth: 32,
                            minHeight: 32,
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),

            // ============================================
            // INFORMATION SECTION
            // ============================================
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    // Clothing Name
                    Text(
                      item.clothingName,
                      style: GoogleFonts.poppins(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF1E293B),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),

                    const SizedBox(height: 4),

                    // Category
                    if (item.categoryName != null)
                      Row(
                        children: [
                          Icon(
                            Icons.category_outlined,
                            size: 12,
                            color: const Color(0xFF64748B),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.categoryName!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 2),

                    // Color
                    if (item.colorName != null)
                      Row(
                        children: [
                          Container(
                            width: 12,
                            height: 12,
                            decoration: BoxDecoration(
                              color: _getColorFromName(item.colorName!),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: const Color(0xFFE5E7EB),
                                width: 1,
                              ),
                            ),
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.colorName!,
                              style: GoogleFonts.poppins(
                                fontSize: 12,
                                color: const Color(0xFF64748B),
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the image widget based on the image path
  Widget _buildImage() {
    // Check if the image path is a valid file
    final file = File(item.imagePath);

    if (file.existsSync()) {
      return Image.file(
        file,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholder();
        },
      );
    } else {
      // Check if it's an asset
      if (item.imagePath.startsWith('assets/')) {
        return Image.asset(
          item.imagePath,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return _buildPlaceholder();
          },
        );
      } else {
        return _buildPlaceholder();
      }
    }
  }

  /// Builds a placeholder when image cannot be loaded
  Widget _buildPlaceholder() {
    return Container(
      color: const Color(0xFFF8FAFC),
      child: Center(
        child: Icon(
          Icons.checkroom,
          size: 48,
          color: const Color(0xFFCBD5E1),
        ),
      ),
    );
  }

  /// Converts color name to Color object
  /// This is a simple implementation - you can expand it with more colors
  Color _getColorFromName(String colorName) {
    final color = colorName.toLowerCase();
    
    switch (color) {
      case 'black':
        return Colors.black;
      case 'white':
        return Colors.white;
      case 'red':
        return Colors.red;
      case 'blue':
        return Colors.blue;
      case 'green':
        return Colors.green;
      case 'yellow':
        return Colors.yellow;
      case 'orange':
        return Colors.orange;
      case 'purple':
        return Colors.purple;
      case 'pink':
        return Colors.pink;
      case 'brown':
        return Colors.brown;
      case 'grey':
      case 'gray':
        return Colors.grey;
      case 'navy':
        return const Color(0xFF001F3F);
      case 'beige':
        return const Color(0xFFF5F5DC);
      case 'maroon':
        return const Color(0xFF800000);
      case 'teal':
        return Colors.teal;
      default:
        return const Color(0xFF64748B);
    }
  }
}

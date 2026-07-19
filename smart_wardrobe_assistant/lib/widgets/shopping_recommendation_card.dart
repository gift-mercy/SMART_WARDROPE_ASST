// ============================================
// SHOPPING_RECOMMENDATION_CARD.DART
// ============================================
// Reusable widget for displaying shopping recommendations
//
// Purpose:
// - Display recommendation information in a card
// - Show priority indicator
// - Handle tap interactions
// ============================================

import 'package:flutter/material.dart';
import '../models/shopping_recommendation_model.dart';
import '../core/constants/app_colors.dart';

/// ShoppingRecommendationCard widget
/// Displays a single shopping recommendation in a card format
class ShoppingRecommendationCard extends StatelessWidget {
  /// The recommendation to display
  final ShoppingRecommendation recommendation;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  const ShoppingRecommendationCard({
    super.key,
    required this.recommendation,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              // Icon
              _buildIcon(),
              
              const SizedBox(width: 16),
              
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Item name
                    Text(
                      recommendation.name,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    
                    const SizedBox(height: 4),
                    
                    // Category
                    Text(
                      recommendation.category,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    
                    const SizedBox(height: 8),
                    
                    // Description
                    Text(
                      recommendation.description,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    
                    const SizedBox(height: 12),
                    
                    // Priority chip
                    _buildPriorityChip(),
                  ],
                ),
              ),
              
              const SizedBox(width: 8),
              
              // Arrow icon
              const Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppColors.textHint,
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the icon widget
  Widget _buildIcon() {
    IconData iconData;
    
    // Map category to appropriate icon
    switch (recommendation.category.toLowerCase()) {
      case 'footwear':
        iconData = Icons.format_shapes; // Shoe icon alternative
        break;
      case 'tops':
        iconData = Icons.checkroom;
        break;
      case 'bottoms':
        iconData = Icons.sports;
        break;
      case 'outerwear':
        iconData = Icons.dry_cleaning;
        break;
      case 'accessories':
        iconData = Icons.watch;
        break;
      default:
        iconData = Icons.shopping_bag;
    }

    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: AppColors.secondary.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        iconData,
        size: 28,
        color: AppColors.secondary,
      ),
    );
  }

  /// Builds the priority chip
  Widget _buildPriorityChip() {
    Color backgroundColor;
    Color textColor;

    switch (recommendation.priority) {
      case RecommendationPriority.high:
        backgroundColor = const Color(0xFFEF4444).withValues(alpha: 0.1);
        textColor = const Color(0xFFEF4444);
        break;
      case RecommendationPriority.recommended:
        backgroundColor = const Color(0xFFF59E0B).withValues(alpha: 0.1);
        textColor = const Color(0xFFF59E0B);
        break;
      case RecommendationPriority.optional:
        backgroundColor = const Color(0xFF10B981).withValues(alpha: 0.1);
        textColor = const Color(0xFF10B981);
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        recommendation.priorityText,
        style: TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
    );
  }
}

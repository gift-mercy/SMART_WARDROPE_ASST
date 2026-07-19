// ============================================
// SHOPPING_RECOMMENDATION_SERVICE.DART
// ============================================
// Service for analyzing wardrobe and generating shopping recommendations
//
// Purpose:
// - Analyze user's existing wardrobe
// - Identify missing clothing categories
// - Generate recommendations with priorities
// - Provide clean abstraction for future AI integration
// ============================================

import '../models/clothing_item.dart';
import '../models/shopping_recommendation_model.dart';

/// ShoppingRecommendationService class
/// Singleton service for wardrobe analysis and recommendation generation
class ShoppingRecommendationService {
  // ============================================
  // SINGLETON PATTERN
  // ============================================

  ShoppingRecommendationService._privateConstructor();
  static final ShoppingRecommendationService instance =
      ShoppingRecommendationService._privateConstructor();

  // ============================================
  // MAIN ANALYSIS METHOD
  // ============================================

  /// Analyzes the user's wardrobe and generates shopping recommendations
  /// Returns a list of missing items that the user should consider purchasing
  List<ShoppingRecommendation> analyzeWardrobe(
    List<ClothingItem> wardrobeItems,
  ) {
    // Get category counts from wardrobe
    final categoryCounts = _analyzeCategoryCounts(wardrobeItems);

    // Get occasion coverage
    final occasionCoverage = _analyzeOccasionCoverage(wardrobeItems);

    // Generate recommendations based on analysis
    final recommendations = _generateRecommendations(
      categoryCounts,
      occasionCoverage,
      wardrobeItems,
    );

    // Sort by priority (high -> recommended -> optional)
    recommendations.sort((a, b) {
      if (a.priority != b.priority) {
        return a.priority.index.compareTo(b.priority.index);
      }
      return a.name.compareTo(b.name);
    });

    return recommendations;
  }

  // ============================================
  // ANALYSIS HELPERS
  // ============================================

  /// Counts clothing items by category
  Map<String, int> _analyzeCategoryCounts(List<ClothingItem> items) {
    final counts = <String, int>{};

    for (var item in items) {
      final category = item.categoryName ?? 'Unknown';
      counts[category] = (counts[category] ?? 0) + 1;
    }

    return counts;
  }

  /// Analyzes occasion coverage (formal, casual, etc.)
  Map<String, int> _analyzeOccasionCoverage(List<ClothingItem> items) {
    final coverage = <String, int>{};

    for (var item in items) {
      if (item.occasionName != null && item.occasionName!.isNotEmpty) {
        final occasion = item.occasionName!;
        coverage[occasion] = (coverage[occasion] ?? 0) + 1;
      }
    }

    return coverage;
  }

  /// Checks if wardrobe has any item matching a category
  bool _hasItemInCategory(
    List<ClothingItem> items,
    String categoryPattern,
  ) {
    return items.any((item) =>
        item.categoryName
            ?.toLowerCase()
            .contains(categoryPattern.toLowerCase()) ??
        false);
  }

  /// Checks if wardrobe has any item for an occasion
  bool _hasItemForOccasion(
    List<ClothingItem> items,
    String occasionPattern,
  ) {
    return items.any((item) =>
        item.occasionName
            ?.toLowerCase()
            .contains(occasionPattern.toLowerCase()) ??
        false);
  }

  // ============================================
  // RECOMMENDATION GENERATION
  // ============================================

  /// Generates specific recommendations based on wardrobe analysis
  List<ShoppingRecommendation> _generateRecommendations(
    Map<String, int> categoryCounts,
    Map<String, int> occasionCoverage,
    List<ClothingItem> wardrobeItems,
  ) {
    final recommendations = <ShoppingRecommendation>[];

    // Check for missing footwear
    if (!_hasItemInCategory(wardrobeItems, 'shoe') &&
        !_hasItemInCategory(wardrobeItems, 'footwear') &&
        !_hasItemInCategory(wardrobeItems, 'sneaker')) {
      recommendations.add(ShoppingRecommendation(
        name: 'Casual Sneakers',
        category: 'Footwear',
        description:
            'Essential for everyday wear and casual activities. Versatile and comfortable for daily use.',
        priority: RecommendationPriority.high,
        suggestedColors: ['White', 'Black', 'Grey', 'Navy'],
        suggestedOccasions: ['Casual', 'Sport', 'Outdoor'],
        iconName: 'sneaker',
      ));

      recommendations.add(ShoppingRecommendation(
        name: 'Formal Shoes',
        category: 'Footwear',
        description:
            'Necessary for formal occasions, job interviews, and professional settings.',
        priority: RecommendationPriority.high,
        suggestedColors: ['Black', 'Brown'],
        suggestedOccasions: ['Formal', 'Work', 'Interview'],
        iconName: 'formal_shoe',
      ));
    }

    // Check for missing formal wear
    if (!_hasItemForOccasion(wardrobeItems, 'formal') &&
        !_hasItemForOccasion(wardrobeItems, 'work')) {
      if (!_hasItemInCategory(wardrobeItems, 'shirt')) {
        recommendations.add(ShoppingRecommendation(
          name: 'White Formal Shirt',
          category: 'Tops',
          description:
              'A wardrobe staple for formal events, interviews, and professional environments.',
          priority: RecommendationPriority.high,
          suggestedColors: ['White', 'Light Blue', 'Cream'],
          suggestedOccasions: ['Formal', 'Work', 'Interview'],
          iconName: 'shirt',
        ));
      }

      if (!_hasItemInCategory(wardrobeItems, 'trouser') &&
          !_hasItemInCategory(wardrobeItems, 'pant')) {
        recommendations.add(ShoppingRecommendation(
          name: 'Black Formal Trousers',
          category: 'Bottoms',
          description:
              'Essential for creating professional outfits and formal occasions.',
          priority: RecommendationPriority.high,
          suggestedColors: ['Black', 'Navy', 'Charcoal Grey'],
          suggestedOccasions: ['Formal', 'Work', 'Interview'],
          iconName: 'trousers',
        ));
      }

      if (!_hasItemInCategory(wardrobeItems, 'jacket') &&
          !_hasItemInCategory(wardrobeItems, 'blazer')) {
        recommendations.add(ShoppingRecommendation(
          name: 'Formal Blazer',
          category: 'Outerwear',
          description:
              'Complete your formal wardrobe with a versatile blazer for professional settings.',
          priority: RecommendationPriority.recommended,
          suggestedColors: ['Black', 'Navy', 'Grey'],
          suggestedOccasions: ['Formal', 'Work', 'Business'],
          iconName: 'blazer',
        ));
      }
    }

    // Check for casual basics
    if (!_hasItemInCategory(wardrobeItems, 'jeans') &&
        !_hasItemInCategory(wardrobeItems, 'denim')) {
      recommendations.add(ShoppingRecommendation(
        name: 'Blue Jeans',
        category: 'Bottoms',
        description:
            'A timeless wardrobe essential. Perfect for casual everyday wear and versatile styling.',
        priority: RecommendationPriority.recommended,
        suggestedColors: ['Blue', 'Dark Blue', 'Black'],
        suggestedOccasions: ['Casual', 'Everyday', 'Outdoor'],
        iconName: 'jeans',
      ));
    }

    if (!_hasItemInCategory(wardrobeItems, 't-shirt') &&
        !_hasItemInCategory(wardrobeItems, 'tee')) {
      recommendations.add(ShoppingRecommendation(
        name: 'Basic T-Shirts',
        category: 'Tops',
        description:
            'Essential casual wear items. Build a collection in different colors for everyday use.',
        priority: RecommendationPriority.recommended,
        suggestedColors: ['White', 'Black', 'Grey', 'Navy'],
        suggestedOccasions: ['Casual', 'Everyday', 'Sport'],
        iconName: 't_shirt',
      ));
    }

    // Check for semi-formal options
    if (!_hasItemInCategory(wardrobeItems, 'polo') &&
        categoryCounts['Tops'] != null &&
        categoryCounts['Tops']! < 3) {
      recommendations.add(ShoppingRecommendation(
        name: 'Polo Shirt',
        category: 'Tops',
        description:
            'Perfect for semi-formal occasions. More polished than a t-shirt, more casual than formal wear.',
        priority: RecommendationPriority.optional,
        suggestedColors: ['White', 'Navy', 'Black', 'Grey'],
        suggestedOccasions: ['Casual', 'Semi-Formal', 'Outdoor'],
        iconName: 'polo',
      ));
    }

    // Check for outerwear
    if (!_hasItemInCategory(wardrobeItems, 'jacket') &&
        !_hasItemInCategory(wardrobeItems, 'hoodie') &&
        !_hasItemInCategory(wardrobeItems, 'sweater')) {
      recommendations.add(ShoppingRecommendation(
        name: 'Casual Jacket',
        category: 'Outerwear',
        description:
            'Essential for layering and adapting to weather changes. Adds style to any outfit.',
        priority: RecommendationPriority.recommended,
        suggestedColors: ['Black', 'Navy', 'Grey', 'Khaki'],
        suggestedOccasions: ['Casual', 'Outdoor', 'Travel'],
        iconName: 'jacket',
      ));
    }

    // Check for sport/athletic wear
    if (!_hasItemForOccasion(wardrobeItems, 'sport') &&
        !_hasItemForOccasion(wardrobeItems, 'gym')) {
      recommendations.add(ShoppingRecommendation(
        name: 'Athletic Wear',
        category: 'Tops',
        description:
            'Important for exercise, sports activities, and maintaining an active lifestyle.',
        priority: RecommendationPriority.optional,
        suggestedColors: ['Black', 'Grey', 'Navy', 'Red'],
        suggestedOccasions: ['Sport', 'Gym', 'Outdoor'],
        iconName: 'athletic',
      ));
    }

    // Check for shorts (seasonal)
    if (!_hasItemInCategory(wardrobeItems, 'shorts')) {
      recommendations.add(ShoppingRecommendation(
        name: 'Casual Shorts',
        category: 'Bottoms',
        description:
            'Essential for warm weather and casual summer activities. Great for comfort and versatility.',
        priority: RecommendationPriority.optional,
        suggestedColors: ['Khaki', 'Navy', 'Black', 'Grey'],
        suggestedOccasions: ['Casual', 'Beach', 'Sport'],
        iconName: 'shorts',
      ));
    }

    // Limit recommendations to avoid overwhelming the user
    // Return maximum 10 recommendations
    if (recommendations.length > 10) {
      return recommendations.sublist(0, 10);
    }

    return recommendations;
  }

  // ============================================
  // FUTURE AI INTEGRATION PLACEHOLDER
  // ============================================

  /// Placeholder method for future AI model integration
  /// This method can be replaced with actual AI model calls
  ///
  /// Usage (future):
  /// ```dart
  /// final aiRecommendations = await ShoppingRecommendationService.instance
  ///     .generateAIRecommendations(wardrobeItems);
  /// ```
  Future<List<ShoppingRecommendation>> generateAIRecommendations(
    List<ClothingItem> wardrobeItems,
  ) async {
    // TODO: Replace with actual AI model integration
    // For now, return rule-based recommendations
    return analyzeWardrobe(wardrobeItems);

    // Future implementation example:
    // 1. Prepare wardrobe data as features
    // 2. Call AI model API
    // 3. Parse AI response
    // 4. Convert to ShoppingRecommendation objects with confidence scores
    // 5. Set recommendationSource = 'ai-model'
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Gets a summary of the wardrobe analysis
  Map<String, dynamic> getWardrobeSummary(List<ClothingItem> items) {
    final categoryCounts = _analyzeCategoryCounts(items);
    final occasionCoverage = _analyzeOccasionCoverage(items);

    return {
      'total_items': items.length,
      'category_counts': categoryCounts,
      'occasion_coverage': occasionCoverage,
      'has_formal_wear': _hasItemForOccasion(items, 'formal'),
      'has_casual_wear': _hasItemForOccasion(items, 'casual'),
      'has_footwear': _hasItemInCategory(items, 'shoe') ||
          _hasItemInCategory(items, 'footwear'),
    };
  }
}

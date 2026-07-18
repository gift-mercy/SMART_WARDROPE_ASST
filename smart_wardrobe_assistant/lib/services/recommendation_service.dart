// ============================================
// RECOMMENDATION_SERVICE.DART
// ============================================
// Service class for generating outfit recommendations
//
// Purpose:
// - Implement recommendation algorithm
// - Match clothing to weather conditions
// - Prepare for future AI model integration
// ============================================

import '../models/clothing_item.dart';
import '../models/weather_model.dart';
import '../models/recommendation_model.dart';

/// RecommendationService
/// Generates outfit recommendations based on weather and available clothing
class RecommendationService {
  // Singleton pattern
  static final RecommendationService _instance = RecommendationService._internal();
  factory RecommendationService() => _instance;
  RecommendationService._internal();

  /// Generate outfit recommendation based on weather and wardrobe
  RecommendationModel generateRecommendation({
    required WeatherModel weather,
    required List<ClothingItem> availableClothing,
  }) {
    // If no clothing available, return empty recommendation
    if (availableClothing.isEmpty) {
      return RecommendationModel(
        outfitItems: [],
        explanation: 'Your wardrobe is empty. Add some clothing items to receive recommendations.',
        weatherCondition: weather.condition,
        temperature: weather.temperature,
        recommendationSource: 'rule-based',
      );
    }

    // Filter and select clothing based on weather
    final selectedItems = _selectClothingForWeather(
      weather: weather,
      availableClothing: availableClothing,
    );

    // Generate explanation
    final explanation = _generateExplanation(
      weather: weather,
      selectedItems: selectedItems,
    );

    return RecommendationModel(
      outfitItems: selectedItems,
      explanation: explanation,
      weatherCondition: weather.condition,
      temperature: weather.temperature,
      recommendationSource: 'rule-based',
      confidenceScore: _calculateConfidenceScore(selectedItems),
    );
  }

  /// Select clothing items suitable for current weather
  List<ClothingItem> _selectClothingForWeather({
    required WeatherModel weather,
    required List<ClothingItem> availableClothing,
  }) {
    final List<ClothingItem> selected = [];
    final temp = weather.temperature;
    final condition = weather.condition.toLowerCase();

    // Determine weather category
    final isHot = temp > 28;
    final isWarm = temp > 20 && temp <= 28;
    final isCool = temp > 10 && temp <= 20;
    final isCold = temp <= 10;
    final isRainy = condition.contains('rain') || condition.contains('drizzle');
    final isSunny = condition.contains('clear') || condition.contains('sun');

    // Define preferred seasons based on temperature
    List<String> preferredSeasons = [];
    if (isHot || isWarm) {
      preferredSeasons = ['Summer', 'Spring'];
    } else if (isCool) {
      preferredSeasons = ['Spring', 'Fall', 'Autumn'];
    } else if (isCold) {
      preferredSeasons = ['Winter', 'Fall', 'Autumn'];
    }

    // Define preferred occasions based on weather
    List<String> preferredOccasions = [];
    if (isRainy) {
      preferredOccasions = ['Casual', 'Outdoor'];
    } else if (isSunny && (isHot || isWarm)) {
      preferredOccasions = ['Casual', 'Beach', 'Outdoor', 'Sport'];
    } else {
      preferredOccasions = ['Casual', 'Work', 'Formal'];
    }

    // Score each clothing item based on suitability
    final scoredItems = availableClothing.map((item) {
      int score = 0;

      // Season matching (highest priority)
      if (item.seasonName != null && preferredSeasons.any(
          (season) => item.seasonName!.toLowerCase().contains(season.toLowerCase()))) {
        score += 100;
      }

      // Occasion matching
      if (item.occasionName != null && preferredOccasions.any(
          (occasion) => item.occasionName!.toLowerCase().contains(occasion.toLowerCase()))) {
        score += 50;
      }

      // Category-based scoring for hot weather
      if (isHot && item.categoryName != null) {
        final category = item.categoryName!.toLowerCase();
        if (category.contains('t-shirt') || category.contains('shorts') ||
            category.contains('sandal') || category.contains('dress')) {
          score += 30;
        }
      }

      // Category-based scoring for cold weather
      if (isCold && item.categoryName != null) {
        final category = item.categoryName!.toLowerCase();
        if (category.contains('jacket') || category.contains('sweater') ||
            category.contains('coat') || category.contains('boot')) {
          score += 30;
        }
      }

      // Light colors for sunny/hot weather
      if ((isSunny || isHot) && item.colorName != null) {
        final color = item.colorName!.toLowerCase();
        if (color.contains('white') || color.contains('light') ||
            color.contains('beige') || color.contains('yellow')) {
          score += 20;
        }
      }

      // Dark colors for cold weather
      if (isCold && item.colorName != null) {
        final color = item.colorName!.toLowerCase();
        if (color.contains('black') || color.contains('dark') ||
            color.contains('navy') || color.contains('grey')) {
          score += 20;
        }
      }

      return {'item': item, 'score': score};
    }).toList();

    // Sort by score (descending)
    scoredItems.sort((a, b) => (b['score'] as int).compareTo(a['score'] as int));

    // Select diverse items (try to get different categories)
    final Set<String> selectedCategories = {};
    for (final scored in scoredItems) {
      final item = scored['item'] as ClothingItem;
      final category = item.categoryName?.toLowerCase() ?? 'unknown';

      // Add item if we don't have this category yet, or if we have less than 3 items
      if (!selectedCategories.contains(category) || selected.length < 3) {
        selected.add(item);
        selectedCategories.add(category);

        // Limit to maximum 5 items for a complete outfit
        if (selected.length >= 5) break;
      }
    }

    // If we still don't have enough items, add any remaining high-scoring items
    if (selected.length < 3) {
      for (final scored in scoredItems) {
        final item = scored['item'] as ClothingItem;
        if (!selected.contains(item)) {
          selected.add(item);
          if (selected.length >= 3) break;
        }
      }
    }

    return selected;
  }

  /// Generate human-readable explanation for the recommendation
  String _generateExplanation({
    required WeatherModel weather,
    required List<ClothingItem> selectedItems,
  }) {
    if (selectedItems.isEmpty) {
      return 'Add clothing items to your wardrobe to get outfit recommendations.';
    }

    final temp = weather.temperature;
    final condition = weather.condition.toLowerCase();

    // Build explanation based on weather
    StringBuffer explanation = StringBuffer();

    // Weather-based intro
    if (temp > 28) {
      explanation.write('It\'s hot outside (${temp.round()}°C). ');
      explanation.write('This outfit features light and breathable items ');
    } else if (temp > 20) {
      explanation.write('The weather is warm (${temp.round()}°C). ');
      explanation.write('This outfit combines comfort with style ');
    } else if (temp > 10) {
      explanation.write('It\'s cool outside (${temp.round()}°C). ');
      explanation.write('This outfit provides moderate warmth ');
    } else {
      explanation.write('It\'s cold outside (${temp.round()}°C). ');
      explanation.write('This outfit will keep you warm ');
    }

    // Condition-based addition
    if (condition.contains('rain')) {
      explanation.write('suitable for rainy conditions. ');
    } else if (condition.contains('clear') || condition.contains('sun')) {
      explanation.write('perfect for sunny weather. ');
    } else if (condition.contains('cloud')) {
      explanation.write('ideal for cloudy conditions. ');
    } else {
      explanation.write('appropriate for today\'s conditions. ');
    }

    // Add item-specific details if available
    if (selectedItems.length > 1) {
      explanation.write('The combination of ');
      for (int i = 0; i < selectedItems.length && i < 3; i++) {
        if (i > 0 && i == selectedItems.length - 1) {
          explanation.write(' and ');
        } else if (i > 0) {
          explanation.write(', ');
        }
        explanation.write(selectedItems[i].categoryName?.toLowerCase() ?? 'clothing');
      }
      explanation.write(' works well together.');
    }

    return explanation.toString();
  }

  /// Calculate confidence score for the recommendation
  double _calculateConfidenceScore(List<ClothingItem> selectedItems) {
    if (selectedItems.isEmpty) return 0.0;

    // Base confidence on number and diversity of items
    double score = 0.5; // Base score

    // More items = higher confidence (up to 5 items)
    score += (selectedItems.length.clamp(0, 5) / 5) * 0.3;

    // Diversity bonus (different categories)
    final categories = selectedItems.map((item) => item.categoryName).toSet();
    score += (categories.length / selectedItems.length) * 0.2;

    return score.clamp(0.0, 1.0);
  }

  /// Future method: Generate recommendation using AI model
  /// This is a placeholder for future AI integration
  Future<RecommendationModel> generateAIRecommendation({
    required WeatherModel weather,
    required List<ClothingItem> availableClothing,
  }) async {
    // TODO: Integrate with pre-trained AI model
    // For now, fallback to rule-based recommendation
    return generateRecommendation(
      weather: weather,
      availableClothing: availableClothing,
    );
  }
}

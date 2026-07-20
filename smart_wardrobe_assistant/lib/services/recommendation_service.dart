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
import '../models/calendar_event_model.dart';

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
    CalendarEventModel? calendarEvent,
    RecommendationPreference preference = RecommendationPreference.balanced,
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
      calendarEvent: calendarEvent,
      preference: preference,
    );

    if (calendarEvent != null &&
        calendarEvent.category != EventCategory.unknown &&
        !selectedItems.any((item) => _matchesEventCategory(item, calendarEvent.category))) {
      return RecommendationModel(
        outfitItems: const [],
        explanation: 'We could not find a perfect outfit from your current wardrobe. Add more clothing items and try again.',
        weatherCondition: weather.condition,
        temperature: weather.temperature,
        eventCategory: calendarEvent.category,
        recommendationSource: 'rule-based',
        confidenceScore: 0,
      );
    }

    // Generate explanation
    final explanation = _generateExplanation(
      weather: weather,
      selectedItems: selectedItems,
      calendarEvent: calendarEvent,
    );

    return RecommendationModel(
      outfitItems: selectedItems,
      explanation: explanation,
      weatherCondition: weather.condition,
      temperature: weather.temperature,
      eventCategory: calendarEvent?.category,
      recommendationSource: 'rule-based',
      confidenceScore: _calculateMatchScore(selectedItems, weather, calendarEvent),
    );
  }

  /// Select clothing items suitable for current weather
  List<ClothingItem> _selectClothingForWeather({
    required WeatherModel weather,
    required List<ClothingItem> availableClothing,
    CalendarEventModel? calendarEvent,
    required RecommendationPreference preference,
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
    // A selected event is the strongest intent signal; preferences guide days
    // without an event instead of overriding an athletic or formal event.
    preferredOccasions = _eventOccasions(calendarEvent) ??
        _preferenceOccasions(preference) ??
        preferredOccasions;

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

      // Calendar context deliberately affects only local rule-based scoring.
      if (calendarEvent != null && _matchesEventCategory(item, calendarEvent.category)) {
        score += 80;
      }
      if (_matchesPreference(item, preference)) score += 25;

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
    CalendarEventModel? calendarEvent,
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

    if (calendarEvent != null && calendarEvent.category != EventCategory.unknown) {
      explanation.write('It also prioritizes ${calendarEvent.categoryName.toLowerCase()} pieces for your upcoming event. ');
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
  double _calculateMatchScore(
    List<ClothingItem> selectedItems,
    WeatherModel weather,
    CalendarEventModel? event,
  ) {
    if (selectedItems.isEmpty) return 0.0;
    // Transparent 100-point match: event 50, weather 30, colours 20.
    final eventScore = event == null || event.category == EventCategory.unknown
        ? 25.0
        : (selectedItems.any((item) => _matchesEventCategory(item, event.category)) ? 50.0 : 20.0);
    final weatherText = '${weather.condition} ${weather.temperature}'.toLowerCase();
    final weatherScore = selectedItems.any((item) => _isWeatherAppropriate(item, weatherText)) ? 30.0 : 15.0;
    final colors = selectedItems.map((item) => item.colorName?.toLowerCase()).whereType<String>().toSet();
    final colorScore = colors.length <= 1 || !colors.contains('blue') || colors.length > 2 ? 20.0 : 12.0;
    return ((eventScore + weatherScore + colorScore) / 100).clamp(0.0, 1.0);
  }

  bool _isWeatherAppropriate(ClothingItem item, String weatherText) {
    final text = '${item.categoryName ?? ''} ${item.seasonName ?? ''} ${item.colorName ?? ''}'.toLowerCase();
    if (weatherText.contains('rain')) return !text.contains('sandal');
    if (weatherText.contains('30') || weatherText.contains('29') || weatherText.contains('28')) {
      return _containsAny(text, const ['summer', 'spring', 'shirt', 't-shirt', 'short']);
    }
    return true;
  }

  List<String>? _eventOccasions(CalendarEventModel? event) {
    if (event == null) return null;
    return switch (event.category) {
      EventCategory.formal => const ['Formal', 'Work', 'Business'],
      EventCategory.professional => const ['Work', 'Business', 'Formal'],
      EventCategory.athletic => const ['Sport', 'Sports', 'Gym', 'Athletic'],
      EventCategory.casual => const ['Casual', 'Social', 'Outdoor'],
      EventCategory.unknown => null,
    };
  }

  List<String>? _preferenceOccasions(RecommendationPreference preference) => switch (preference) {
        RecommendationPreference.balanced => null,
        RecommendationPreference.formal => const ['Formal', 'Work', 'Business'],
        RecommendationPreference.casual => const ['Casual', 'Social'],
        RecommendationPreference.comfortable => const ['Casual', 'Sport', 'Outdoor'],
      };

  bool _matchesPreference(ClothingItem item, RecommendationPreference preference) {
    final text = '${item.occasionName ?? ''} ${item.categoryName ?? ''}'.toLowerCase();
    return switch (preference) {
      RecommendationPreference.balanced => false,
      RecommendationPreference.formal => _containsAny(text, const ['formal', 'work', 'business']),
      RecommendationPreference.casual => _containsAny(text, const ['casual', 'jean', 't-shirt']),
      RecommendationPreference.comfortable => _containsAny(text, const ['casual', 'sport', 'sneaker', 'track']),
    };
  }

  bool _matchesEventCategory(ClothingItem item, EventCategory category) {
    final text = '${item.occasionName ?? ''} ${item.categoryName ?? ''}'.toLowerCase();
    return switch (category) {
      EventCategory.formal => _containsAny(text, const ['formal', 'shirt', 'trouser', 'blazer', 'dress shoe']),
      EventCategory.professional => _containsAny(text, const ['work', 'business', 'formal', 'shirt', 'trouser']),
      EventCategory.athletic => _containsAny(text, const ['sport', 'gym', 'athletic', 'track', 'trainer']),
      EventCategory.casual => _containsAny(text, const ['casual', 't-shirt', 'jean', 'sneaker']),
      EventCategory.unknown => false,
    };
  }

  bool _containsAny(String text, List<String> values) => values.any(text.contains);

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

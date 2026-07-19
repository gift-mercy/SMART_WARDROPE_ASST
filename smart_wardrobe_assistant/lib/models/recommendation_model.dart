// ============================================
// RECOMMENDATION_MODEL.DART
// ============================================
// Model class for outfit recommendations
//
// Purpose:
// - Represent a recommended outfit
// - Include explanation for the recommendation
// - Support calendar event context integration
// - Support future AI model integration
// ============================================

import 'clothing_item.dart';
import 'calendar_event_model.dart';

enum RecommendationPreference { balanced, formal, casual, comfortable }

/// RecommendationModel class
/// Represents a recommended outfit with explanation
class RecommendationModel {
  /// List of recommended clothing items for the outfit
  final List<ClothingItem> outfitItems;

  /// Explanation for why this outfit was recommended
  final String explanation;

  /// Weather condition this outfit is suitable for
  final String weatherCondition;

  /// Temperature range (in Celsius)
  final double temperature;

  /// Derived category only. Calendar titles and locations are never persisted.
  final EventCategory? eventCategory;

  /// Timestamp when recommendation was generated
  final DateTime timestamp;

  /// Optional: Confidence score (0.0 to 1.0) for AI integration
  final double? confidenceScore;

  /// Optional: Source of recommendation (e.g., "rule-based", "ai-model")
  final String? recommendationSource;

  /// Raw event label returned by the pretrained BART-MNLI backend.
  final String? aiEventType;

  /// Human-readable weather summary returned by the AI backend.
  final String? aiWeatherSummary;

  /// Constructor
  RecommendationModel({
    required this.outfitItems,
    required this.explanation,
    required this.weatherCondition,
    required this.temperature,
    this.eventCategory,
    DateTime? timestamp,
    this.confidenceScore,
    this.recommendationSource,
    this.aiEventType,
    this.aiWeatherSummary,
  }) : timestamp = timestamp ?? DateTime.now();

  /// Check if the recommendation is still fresh (less than 3 hours old)
  bool get isFresh {
    final age = DateTime.now().difference(timestamp);
    return age.inHours < 3;
  }

  /// Get display text for weather condition
  String get weatherDisplay {
    return '$weatherCondition, ${temperature.round()}°C';
  }

  /// Get number of items in the outfit
  int get itemCount => outfitItems.length;

  /// Check if outfit is valid (has at least one item)
  bool get isValid => outfitItems.isNotEmpty;

  int get matchPercentage => ((confidenceScore ?? 0) * 100).round();

  /// Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'outfit_items': outfitItems.map((item) => item.toMap()).toList(),
      'explanation': explanation,
      'weather_condition': weatherCondition,
      'temperature': temperature,
      'event_category': eventCategory?.name,
      'timestamp': timestamp.toIso8601String(),
      'confidence_score': confidenceScore,
      'recommendation_source': recommendationSource ?? 'rule-based',
      'ai_event_type': aiEventType,
      'ai_weather_summary': aiWeatherSummary,
    };
  }

  /// Create from Map (for deserialization)
  factory RecommendationModel.fromMap(Map<String, dynamic> map) {
    return RecommendationModel(
      outfitItems: (map['outfit_items'] as List)
          .map((item) => ClothingItem.fromMap(item as Map<String, dynamic>))
          .toList(),
      explanation: map['explanation'] as String,
      weatherCondition: map['weather_condition'] as String,
      temperature: (map['temperature'] as num).toDouble(),
      eventCategory: map['event_category'] == null
          ? null
          : EventCategory.values.firstWhere(
              (value) => value.name == map['event_category'],
              orElse: () => EventCategory.unknown,
            ),
      timestamp: DateTime.parse(map['timestamp'] as String),
      confidenceScore: map['confidence_score'] as double?,
      recommendationSource: map['recommendation_source'] as String?,
      aiEventType: map['ai_event_type'] as String?,
      aiWeatherSummary: map['ai_weather_summary'] as String?,
    );
  }

  /// Copy with modifications
  RecommendationModel copyWith({
    List<ClothingItem>? outfitItems,
    String? explanation,
    String? weatherCondition,
    double? temperature,
    EventCategory? eventCategory,
    DateTime? timestamp,
    double? confidenceScore,
    String? recommendationSource,
    String? aiEventType,
    String? aiWeatherSummary,
  }) {
    return RecommendationModel(
      outfitItems: outfitItems ?? this.outfitItems,
      explanation: explanation ?? this.explanation,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
      eventCategory: eventCategory ?? this.eventCategory,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      recommendationSource: recommendationSource ?? this.recommendationSource,
      aiEventType: aiEventType ?? this.aiEventType,
      aiWeatherSummary: aiWeatherSummary ?? this.aiWeatherSummary,
    );
  }

  @override
  String toString() {
    return 'RecommendationModel(items: $itemCount, weather: $weatherDisplay, source: ${recommendationSource ?? "rule-based"})';
  }
}

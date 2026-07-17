// ============================================
// RECOMMENDATION_MODEL.DART
// ============================================
// Model class for outfit recommendations
//
// Purpose:
// - Represent a recommended outfit
// - Include explanation for the recommendation
// - Support future AI model integration
// ============================================

import 'clothing_item.dart';

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

  /// Timestamp when recommendation was generated
  final DateTime timestamp;

  /// Optional: Confidence score (0.0 to 1.0) for AI integration
  final double? confidenceScore;

  /// Optional: Source of recommendation (e.g., "rule-based", "ai-model")
  final String? recommendationSource;

  /// Constructor
  RecommendationModel({
    required this.outfitItems,
    required this.explanation,
    required this.weatherCondition,
    required this.temperature,
    DateTime? timestamp,
    this.confidenceScore,
    this.recommendationSource,
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

  /// Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'outfit_items': outfitItems.map((item) => item.toMap()).toList(),
      'explanation': explanation,
      'weather_condition': weatherCondition,
      'temperature': temperature,
      'timestamp': timestamp.toIso8601String(),
      'confidence_score': confidenceScore,
      'recommendation_source': recommendationSource ?? 'rule-based',
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
      timestamp: DateTime.parse(map['timestamp'] as String),
      confidenceScore: map['confidence_score'] as double?,
      recommendationSource: map['recommendation_source'] as String?,
    );
  }

  /// Copy with modifications
  RecommendationModel copyWith({
    List<ClothingItem>? outfitItems,
    String? explanation,
    String? weatherCondition,
    double? temperature,
    DateTime? timestamp,
    double? confidenceScore,
    String? recommendationSource,
  }) {
    return RecommendationModel(
      outfitItems: outfitItems ?? this.outfitItems,
      explanation: explanation ?? this.explanation,
      weatherCondition: weatherCondition ?? this.weatherCondition,
      temperature: temperature ?? this.temperature,
      timestamp: timestamp ?? this.timestamp,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      recommendationSource: recommendationSource ?? this.recommendationSource,
    );
  }

  @override
  String toString() {
    return 'RecommendationModel(items: ${itemCount}, weather: $weatherDisplay, source: ${recommendationSource ?? "rule-based"})';
  }
}

// ============================================
// SHOPPING_RECOMMENDATION_MODEL.DART
// ============================================
// Model class for shopping recommendations
//
// Purpose:
// - Represent missing wardrobe items to recommend
// - Include priority and reasoning
// - Support future AI model integration
// ============================================

/// Priority levels for shopping recommendations
enum RecommendationPriority {
  high,
  recommended,
  optional,
}

/// ShoppingRecommendation class
/// Represents a clothing item that may be missing from the user's wardrobe
class ShoppingRecommendation {
  /// Name of the recommended item
  final String name;

  /// Category (e.g., "Footwear", "Tops", "Bottoms")
  final String category;

  /// Description/reason for recommendation
  final String description;

  /// Priority level
  final RecommendationPriority priority;

  /// Suggested colors for this item
  final List<String> suggestedColors;

  /// Suggested occasions where this item would be useful
  final List<String> suggestedOccasions;

  /// Optional: Icon name for display
  final String? iconName;

  /// Optional: Confidence score (0.0 to 1.0) for AI integration
  final double? confidenceScore;

  /// Optional: Source of recommendation (e.g., "rule-based", "ai-model")
  final String? recommendationSource;

  /// Constructor
  ShoppingRecommendation({
    required this.name,
    required this.category,
    required this.description,
    required this.priority,
    this.suggestedColors = const [],
    this.suggestedOccasions = const [],
    this.iconName,
    this.confidenceScore,
    this.recommendationSource,
  });

  /// Get priority display text
  String get priorityText {
    switch (priority) {
      case RecommendationPriority.high:
        return 'High Priority';
      case RecommendationPriority.recommended:
        return 'Recommended';
      case RecommendationPriority.optional:
        return 'Optional';
    }
  }

  /// Get priority color code (for UI)
  int get priorityColorValue {
    switch (priority) {
      case RecommendationPriority.high:
        return 0xFFEF4444; // Red
      case RecommendationPriority.recommended:
        return 0xFFF59E0B; // Amber
      case RecommendationPriority.optional:
        return 0xFF10B981; // Green
    }
  }

  /// Convert to Map for storage/serialization
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'category': category,
      'description': description,
      'priority': priority.name,
      'suggested_colors': suggestedColors,
      'suggested_occasions': suggestedOccasions,
      'icon_name': iconName,
      'confidence_score': confidenceScore,
      'recommendation_source': recommendationSource ?? 'rule-based',
    };
  }

  /// Create from Map (for deserialization)
  factory ShoppingRecommendation.fromMap(Map<String, dynamic> map) {
    return ShoppingRecommendation(
      name: map['name'] as String,
      category: map['category'] as String,
      description: map['description'] as String,
      priority: RecommendationPriority.values.firstWhere(
        (e) => e.name == map['priority'],
        orElse: () => RecommendationPriority.recommended,
      ),
      suggestedColors: List<String>.from(map['suggested_colors'] ?? []),
      suggestedOccasions: List<String>.from(map['suggested_occasions'] ?? []),
      iconName: map['icon_name'] as String?,
      confidenceScore: map['confidence_score'] as double?,
      recommendationSource: map['recommendation_source'] as String?,
    );
  }

  /// Copy with modifications
  ShoppingRecommendation copyWith({
    String? name,
    String? category,
    String? description,
    RecommendationPriority? priority,
    List<String>? suggestedColors,
    List<String>? suggestedOccasions,
    String? iconName,
    double? confidenceScore,
    String? recommendationSource,
  }) {
    return ShoppingRecommendation(
      name: name ?? this.name,
      category: category ?? this.category,
      description: description ?? this.description,
      priority: priority ?? this.priority,
      suggestedColors: suggestedColors ?? this.suggestedColors,
      suggestedOccasions: suggestedOccasions ?? this.suggestedOccasions,
      iconName: iconName ?? this.iconName,
      confidenceScore: confidenceScore ?? this.confidenceScore,
      recommendationSource: recommendationSource ?? this.recommendationSource,
    );
  }

  @override
  String toString() {
    return 'ShoppingRecommendation(name: $name, category: $category, priority: ${priority.name})';
  }
}

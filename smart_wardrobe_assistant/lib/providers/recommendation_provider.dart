// ============================================
// RECOMMENDATION_PROVIDER.DART
// ============================================
// Provider class for recommendation state management
//
// Purpose:
// - Manage recommendation state
// - Coordinate weather and wardrobe data
// - Generate and cache recommendations
// ============================================

import 'package:flutter/material.dart';
import '../models/recommendation_model.dart';
import '../models/weather_model.dart';
import '../models/clothing_item.dart';
import '../services/recommendation_service.dart';

/// Recommendation state enum
enum RecommendationState {
  initial,      // No recommendation generated yet
  loading,      // Currently generating recommendation
  loaded,       // Recommendation successfully generated
  error,        // Error occurred
  emptyWardrobe, // User has no clothing items
}

/// RecommendationProvider
/// Manages state for outfit recommendations
class RecommendationProvider with ChangeNotifier {
  // ============================================
  // STATE VARIABLES
  // ============================================

  RecommendationState _state = RecommendationState.initial;
  RecommendationModel? _recommendation;
  String? _errorMessage;
  final RecommendationService _recommendationService = RecommendationService();

  // ============================================
  // GETTERS
  // ============================================

  RecommendationState get state => _state;
  RecommendationModel? get recommendation => _recommendation;
  String? get errorMessage => _errorMessage;
  bool get isLoading => _state == RecommendationState.loading;
  bool get hasError => _state == RecommendationState.error;
  bool get hasRecommendation => _state == RecommendationState.loaded && _recommendation != null;
  bool get isEmptyWardrobe => _state == RecommendationState.emptyWardrobe;

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Generate recommendation based on weather and wardrobe
  Future<void> generateRecommendation({
    required WeatherModel weather,
    required List<ClothingItem> clothingItems,
  }) async {
    try {
      _setState(RecommendationState.loading);
      _errorMessage = null;

      // Check if wardrobe is empty
      if (clothingItems.isEmpty) {
        _recommendation = RecommendationModel(
          outfitItems: [],
          explanation: 'Your wardrobe is empty. Add some clothing items to receive outfit recommendations.',
          weatherCondition: weather.condition,
          temperature: weather.temperature,
        );
        _setState(RecommendationState.emptyWardrobe);
        return;
      }

      // Generate recommendation using the service
      _recommendation = _recommendationService.generateRecommendation(
        weather: weather,
        availableClothing: clothingItems,
      );

      // Check if recommendation is valid
      if (_recommendation == null || !_recommendation!.isValid) {
        _errorMessage = 'Unable to generate a suitable outfit recommendation.';
        _setState(RecommendationState.error);
        return;
      }

      _setState(RecommendationState.loaded);
      print('Recommendation generated: ${_recommendation!.itemCount} items');
    } catch (e) {
      print('Error generating recommendation: $e');
      _errorMessage = 'Failed to generate recommendation: ${e.toString()}';
      _setState(RecommendationState.error);
    }
  }

  /// Refresh recommendation (regenerate with current data)
  Future<void> refreshRecommendation({
    required WeatherModel weather,
    required List<ClothingItem> clothingItems,
  }) async {
    await generateRecommendation(
      weather: weather,
      clothingItems: clothingItems,
    );
  }

  /// Clear current recommendation
  void clearRecommendation() {
    _recommendation = null;
    _errorMessage = null;
    _setState(RecommendationState.initial);
  }

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    if (_state == RecommendationState.error) {
      _setState(RecommendationState.initial);
    }
  }

  // ============================================
  // FUTURE AI INTEGRATION
  // ============================================

  /// Generate recommendation using AI model
  /// This is prepared for future AI integration
  Future<void> generateAIRecommendation({
    required WeatherModel weather,
    required List<ClothingItem> clothingItems,
  }) async {
    try {
      _setState(RecommendationState.loading);
      _errorMessage = null;

      // Check if wardrobe is empty
      if (clothingItems.isEmpty) {
        _recommendation = RecommendationModel(
          outfitItems: [],
          explanation: 'Your wardrobe is empty. Add some clothing items to receive outfit recommendations.',
          weatherCondition: weather.condition,
          temperature: weather.temperature,
        );
        _setState(RecommendationState.emptyWardrobe);
        return;
      }

      // TODO: Replace with actual AI model call
      // For now, use rule-based recommendation
      _recommendation = await _recommendationService.generateAIRecommendation(
        weather: weather,
        availableClothing: clothingItems,
      );

      _setState(RecommendationState.loaded);
      print('AI Recommendation generated: ${_recommendation!.itemCount} items');
    } catch (e) {
      print('Error generating AI recommendation: $e');
      _errorMessage = 'Failed to generate AI recommendation: ${e.toString()}';
      _setState(RecommendationState.error);
    }
  }

  // ============================================
  // PRIVATE METHODS
  // ============================================

  /// Update state and notify listeners
  void _setState(RecommendationState newState) {
    _state = newState;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _state = RecommendationState.initial;
    _recommendation = null;
    _errorMessage = null;
    notifyListeners();
  }
}

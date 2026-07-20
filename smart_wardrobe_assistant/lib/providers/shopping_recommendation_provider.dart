// ============================================
// SHOPPING_RECOMMENDATION_PROVIDER.DART
// ============================================
// State management for shopping recommendations
//
// Purpose:
// - Load wardrobe data
// - Analyze and generate recommendations
// - Manage loading, error, and data states
// - Notify UI of changes
// ============================================

import 'package:flutter/material.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';
import '../models/clothing_item.dart';
import '../models/shopping_recommendation_model.dart';
import '../services/shopping_recommendation_service.dart';

/// ShoppingRecommendationProvider class
/// Manages the state of shopping recommendations
class ShoppingRecommendationProvider with ChangeNotifier {
  // ============================================
  // STATE VARIABLES
  // ============================================

  /// List of shopping recommendations
  List<ShoppingRecommendation> _recommendations = [];

  /// User's wardrobe items count
  int _wardrobeItemCount = 0;

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Current user ID
  int? _userId;

  /// Wardrobe summary data
  Map<String, dynamic>? _wardrobeSummary;

  // ============================================
  // GETTERS
  // ============================================

  /// Returns the list of recommendations
  List<ShoppingRecommendation> get recommendations => _recommendations;

  /// Returns wardrobe item count
  int get wardrobeItemCount => _wardrobeItemCount;

  /// Returns loading state
  bool get isLoading => _isLoading;

  /// Returns error message
  String? get errorMessage => _errorMessage;

  /// Returns if recommendations are available
  bool get hasRecommendations => _recommendations.isNotEmpty;

  /// Returns if wardrobe is empty
  bool get isWardrobeEmpty => _wardrobeItemCount == 0;

  /// Returns wardrobe summary
  Map<String, dynamic>? get wardrobeSummary => _wardrobeSummary;

  /// Returns high priority recommendations count
  int get highPriorityCount => _recommendations
      .where((r) => r.priority == RecommendationPriority.high)
      .length;

  /// Returns recommended priority recommendations count
  int get recommendedCount => _recommendations
      .where((r) => r.priority == RecommendationPriority.recommended)
      .length;

  /// Returns optional priority recommendations count
  int get optionalCount => _recommendations
      .where((r) => r.priority == RecommendationPriority.optional)
      .length;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Sets the current user ID and generates recommendations
  Future<void> setUserId(int userId) async {
    _userId = userId;
    await generateRecommendations();
  }

  // ============================================
  // GENERATE RECOMMENDATIONS
  // ============================================

  /// Generates shopping recommendations by analyzing the user's wardrobe
  Future<void> generateRecommendations() async {
    if (_userId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load wardrobe items from database
      final wardrobeItems = await _loadWardrobeItems();
      _wardrobeItemCount = wardrobeItems.length;

      // If wardrobe is empty, set empty state
      if (wardrobeItems.isEmpty) {
        _recommendations = [];
        _wardrobeSummary = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Analyze wardrobe and generate recommendations
      final service = ShoppingRecommendationService.instance;
      _recommendations = service.analyzeWardrobe(wardrobeItems);
      _wardrobeSummary = service.getWardrobeSummary(wardrobeItems);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to generate recommendations: ${e.toString()}';
      print('Error generating recommendations: $e');
      notifyListeners();
    }
  }

  // ============================================
  // LOAD WARDROBE DATA
  // ============================================

  /// Loads wardrobe items from the database
  Future<List<ClothingItem>> _loadWardrobeItems() async {
    try {
      // Get database instance
      final db = await DatabaseHelper.instance.database;

      // Query clothing items with JOINs to get category, color, season, and occasion names
      final List<Map<String, dynamic>> maps = await db.rawQuery('''
        SELECT 
          ci.clothing_id,
          ci.user_id,
          ci.category_id,
          cat.category_name,
          ci.color_id,
          col.color_name,
          ci.season_id,
          s.season_name,
          ci.occasion_id,
          o.occasion_name,
          ci.clothing_name,
          ci.image_path,
          ci.notes,
          ci.date_added
        FROM ${TableNames.clothingItems} ci
        LEFT JOIN ${TableNames.categories} cat ON ci.category_id = cat.category_id
        LEFT JOIN ${TableNames.colors} col ON ci.color_id = col.color_id
        LEFT JOIN ${TableNames.seasons} s ON ci.season_id = s.season_id
        LEFT JOIN ${TableNames.occasions} o ON ci.occasion_id = o.occasion_id
        WHERE ci.user_id = ?
        ORDER BY ci.date_added DESC
      ''', [_userId]);

      // Convert maps to ClothingItem objects
      return maps.map((map) => ClothingItem.fromMap(map)).toList();
    } catch (e) {
      print('Error loading wardrobe items: $e');
      throw Exception('Failed to load wardrobe data');
    }
  }

  // ============================================
  // REFRESH
  // ============================================

  /// Refreshes recommendations by reloading wardrobe and regenerating
  Future<void> refreshRecommendations() async {
    await generateRecommendations();
  }

  // ============================================
  // FILTER RECOMMENDATIONS
  // ============================================

  /// Gets recommendations by priority
  List<ShoppingRecommendation> getRecommendationsByPriority(
    RecommendationPriority priority,
  ) {
    return _recommendations.where((r) => r.priority == priority).toList();
  }

  /// Gets recommendations by category
  List<ShoppingRecommendation> getRecommendationsByCategory(
    String category,
  ) {
    return _recommendations
        .where((r) => r.category.toLowerCase() == category.toLowerCase())
        .toList();
  }

  // ============================================
  // FUTURE AI INTEGRATION
  // ============================================

  /// Placeholder method for generating AI-based recommendations
  /// This will be implemented when AI model is integrated
  Future<void> generateAIRecommendations() async {
    if (_userId == null) {
      _errorMessage = 'User not logged in';
      notifyListeners();
      return;
    }

    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // Load wardrobe items from database
      final wardrobeItems = await _loadWardrobeItems();
      _wardrobeItemCount = wardrobeItems.length;

      // If wardrobe is empty, set empty state
      if (wardrobeItems.isEmpty) {
        _recommendations = [];
        _wardrobeSummary = null;
        _isLoading = false;
        notifyListeners();
        return;
      }

      // TODO: Replace with actual AI model call
      // For now, use rule-based recommendations
      final service = ShoppingRecommendationService.instance;
      _recommendations = await service.generateAIRecommendations(wardrobeItems);
      _wardrobeSummary = service.getWardrobeSummary(wardrobeItems);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to generate AI recommendations: ${e.toString()}';
      print('Error generating AI recommendations: $e');
      notifyListeners();
    }
  }

  // ============================================
  // CLEAR ERROR
  // ============================================

  /// Clears the error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // ============================================
  // RESET
  // ============================================

  /// Resets all state
  void reset() {
    _recommendations = [];
    _wardrobeItemCount = 0;
    _wardrobeSummary = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }
}

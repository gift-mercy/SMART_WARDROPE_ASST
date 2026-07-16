// ============================================
// ONBOARDING_SERVICE.DART
// ============================================
// Service class for managing onboarding state
// Handles first-time user experience flow
// ============================================

import 'package:shared_preferences/shared_preferences.dart';

/// Service to manage onboarding completion status
/// Uses SharedPreferences to persist onboarding state
class OnboardingService {
  // ============================================
  // SINGLETON PATTERN
  // ============================================

  /// Private constructor prevents external instantiation
  OnboardingService._privateConstructor();

  /// Single instance of OnboardingService (Singleton)
  static final OnboardingService instance = OnboardingService._privateConstructor();

  // ============================================
  // CONSTANTS
  // ============================================

  /// SharedPreferences key for onboarding completion status
  /// Do NOT hardcode this value in other files
  static const String _keyHasCompletedOnboarding = 'has_completed_onboarding';

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Check if user has completed onboarding
  /// Returns true if onboarding has been completed before
  /// Returns false for first-time users
  ///
  /// Usage:
  /// ```dart
  /// final hasCompleted = await OnboardingService.instance.hasCompletedOnboarding();
  /// if (hasCompleted) {
  ///   // Skip to login
  /// } else {
  ///   // Show onboarding
  /// }
  /// ```
  Future<bool> hasCompletedOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // Returns false by default for first-time users
      return prefs.getBool(_keyHasCompletedOnboarding) ?? false;
    } catch (e) {
      print('Error checking onboarding status: $e');
      // Return false on error to show onboarding as a safe fallback
      return false;
    }
  }

  /// Mark onboarding as completed
  /// Call this when user finishes the onboarding screens
  ///
  /// Usage:
  /// ```dart
  /// await OnboardingService.instance.completeOnboarding();
  /// ```
  Future<void> completeOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasCompletedOnboarding, true);
      print('Onboarding marked as completed');
    } catch (e) {
      print('Error saving onboarding status: $e');
      // Re-throw to let caller handle the error
      throw Exception('Failed to save onboarding status: $e');
    }
  }

  /// Reset onboarding status (for testing purposes)
  /// WARNING: Only use this for debugging/testing
  /// In production, users should not be able to reset onboarding
  ///
  /// Usage:
  /// ```dart
  /// await OnboardingService.instance.resetOnboarding();
  /// ```
  Future<void> resetOnboarding() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_keyHasCompletedOnboarding, false);
      print('Onboarding status reset to incomplete');
    } catch (e) {
      print('Error resetting onboarding status: $e');
      throw Exception('Failed to reset onboarding status: $e');
    }
  }

  /// Clear all onboarding data
  /// Use this when user logs out or resets the app
  ///
  /// Usage:
  /// ```dart
  /// await OnboardingService.instance.clearOnboardingData();
  /// ```
  Future<void> clearOnboardingData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_keyHasCompletedOnboarding);
      print('Onboarding data cleared');
    } catch (e) {
      print('Error clearing onboarding data: $e');
      throw Exception('Failed to clear onboarding data: $e');
    }
  }
}

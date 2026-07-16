// ============================================
// APP_INITIALIZATION_SERVICE.DART
// ============================================
// Service class for app initialization and navigation logic
// Determines which screen to show on app startup
// ============================================

import 'onboarding_service.dart';
import 'auth_service.dart';

/// Enum representing the initial destination for the app
enum InitialRoute {
  onboarding, // Show onboarding screens (first-time user)
  login,      // Show login screen (returning user, not logged in)
  home,       // Show home screen (user is already logged in)
}

/// Service to determine app initialization flow
/// Handles the logic for deciding which screen to show on startup
class AppInitializationService {
  // ============================================
  // SINGLETON PATTERN
  // ============================================

  /// Private constructor prevents external instantiation
  AppInitializationService._privateConstructor();

  /// Single instance of AppInitializationService (Singleton)
  static final AppInitializationService instance = 
      AppInitializationService._privateConstructor();

  // ============================================
  // SERVICE DEPENDENCIES
  // ============================================

  final OnboardingService _onboardingService = OnboardingService.instance;
  final AuthService _authService = AuthService.instance;

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Determine which screen to show on app startup
  /// 
  /// Logic flow:
  /// 1. Check if user is already logged in
  ///    - If YES → navigate to Home
  /// 2. Check if user has completed onboarding
  ///    - If YES → navigate to Login
  ///    - If NO → navigate to Onboarding
  ///
  /// Returns InitialRoute enum indicating destination
  ///
  /// Usage:
  /// ```dart
  /// final route = await AppInitializationService.instance.determineInitialRoute();
  /// switch (route) {
  ///   case InitialRoute.onboarding:
  ///     Navigator.pushReplacementNamed(context, '/onboarding');
  ///     break;
  ///   case InitialRoute.login:
  ///     Navigator.pushReplacementNamed(context, '/login');
  ///     break;
  ///   case InitialRoute.home:
  ///     Navigator.pushReplacementNamed(context, '/home');
  ///     break;
  /// }
  /// ```
  Future<InitialRoute> determineInitialRoute() async {
    try {
      print('Determining initial route...');

      // Step 1: Check if user is already logged in
      // This has highest priority - logged-in users go straight to home
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        print('User is logged in → navigating to Home');
        return InitialRoute.home;
      }

      // Step 2: User is not logged in, check onboarding status
      final hasCompletedOnboarding = await _onboardingService.hasCompletedOnboarding();
      
      if (hasCompletedOnboarding) {
        print('Onboarding completed → navigating to Login');
        return InitialRoute.login;
      } else {
        print('First-time user → navigating to Onboarding');
        return InitialRoute.onboarding;
      }

    } catch (e) {
      // If any error occurs, default to onboarding as safest option
      print('Error determining initial route: $e');
      print('Defaulting to onboarding screen');
      return InitialRoute.onboarding;
    }
  }

  /// Get the route name as a string for navigation
  /// Converts InitialRoute enum to Flutter route string
  ///
  /// Usage:
  /// ```dart
  /// final routeName = AppInitializationService.instance.getRouteNameFromInitialRoute(route);
  /// Navigator.pushReplacementNamed(context, routeName);
  /// ```
  String getRouteNameFromInitialRoute(InitialRoute route) {
    switch (route) {
      case InitialRoute.onboarding:
        return '/onboarding';
      case InitialRoute.login:
        return '/login';
      case InitialRoute.home:
        return '/home';
    }
  }

  /// Complete initialization and return route name directly
  /// This is a convenience method that combines determineInitialRoute
  /// and getRouteNameFromInitialRoute
  ///
  /// Usage:
  /// ```dart
  /// final routeName = await AppInitializationService.instance.getInitialRouteName();
  /// Navigator.pushReplacementNamed(context, routeName);
  /// ```
  Future<String> getInitialRouteName() async {
    final route = await determineInitialRoute();
    return getRouteNameFromInitialRoute(route);
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Check app initialization status
  /// Returns a map with detailed status information
  /// Useful for debugging and testing
  ///
  /// Usage:
  /// ```dart
  /// final status = await AppInitializationService.instance.getInitializationStatus();
  /// print('Is Logged In: ${status['isLoggedIn']}');
  /// print('Has Completed Onboarding: ${status['hasCompletedOnboarding']}');
  /// print('Initial Route: ${status['initialRoute']}');
  /// ```
  Future<Map<String, dynamic>> getInitializationStatus() async {
    final isLoggedIn = await _authService.isLoggedIn();
    final hasCompletedOnboarding = await _onboardingService.hasCompletedOnboarding();
    final initialRoute = await determineInitialRoute();

    return {
      'isLoggedIn': isLoggedIn,
      'hasCompletedOnboarding': hasCompletedOnboarding,
      'initialRoute': initialRoute.toString(),
      'routeName': getRouteNameFromInitialRoute(initialRoute),
    };
  }
}

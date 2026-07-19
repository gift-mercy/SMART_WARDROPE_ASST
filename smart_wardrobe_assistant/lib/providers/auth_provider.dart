// ============================================
// AUTH_PROVIDER.DART
// ============================================
// Provider class for authentication state management
// Manages logged-in user state across the app
// ============================================

import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

enum AuthState {
  initial,      // App just started
  authenticated, // User is logged in
  unauthenticated, // User is not logged in
  loading,      // Processing authentication
}

class AuthProvider extends ChangeNotifier {
  // ============================================
  // STATE VARIABLES
  // ============================================

  AuthState _state = AuthState.initial;
  UserModel? _currentUser;
  String? _errorMessage;
  final AuthService _authService = AuthService.instance;

  // ============================================
  // GETTERS
  // ============================================

  AuthState get state => _state;
  UserModel? get currentUser => _currentUser;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated && _currentUser != null;
  bool get isLoading => _state == AuthState.loading;
  bool get hasError => _errorMessage != null;

  // Get user's first name (or 'Guest' if not logged in)
  String get userFirstName => _currentUser?.firstName ?? 'Guest';
  
  // Get user's full name (or 'Guest' if not logged in)
  String get userFullName => _currentUser?.fullName ?? 'Guest';

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Initialize auth state (check if user is already logged in)
  Future<void> initialize() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      final isLoggedIn = await _authService.isLoggedIn();
      
      if (isLoggedIn) {
        final user = await _authService.getCurrentUser();
        if (user != null) {
          _currentUser = user;
          _state = AuthState.authenticated;
        } else {
          _state = AuthState.unauthenticated;
        }
      } else {
        _state = AuthState.unauthenticated;
      }
    } catch (e) {
      print('Error initializing auth: $e');
      _state = AuthState.unauthenticated;
    }

    notifyListeners();
  }

  // ============================================
  // AUTHENTICATION METHODS
  // ============================================

  /// Register a new user
  Future<bool> register({
    required String fullName,
    required String email,
    required String password,
    String? gender,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        fullName: fullName,
        email: email,
        password: password,
        gender: gender,
      );

      // Don't auto-login after registration
      // User should login manually with their credentials
      _state = AuthState.unauthenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Login with email and password
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _state = AuthState.loading;
    _errorMessage = null;
    notifyListeners();

    try {
      final user = await _authService.login(
        email: email,
        password: password,
      );

      _currentUser = user;
      _state = AuthState.authenticated;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      _state = AuthState.unauthenticated;
      notifyListeners();
      return false;
    }
  }

  /// Logout current user
  Future<void> logout() async {
    _state = AuthState.loading;
    notifyListeners();

    try {
      await _authService.logout();
      _currentUser = null;
      _state = AuthState.unauthenticated;
    } catch (e) {
      print('Error during logout: $e');
      _errorMessage = 'Failed to logout. Please try again.';
    }

    notifyListeners();
  }

  // ============================================
  // USER OPERATIONS
  // ============================================

  /// Update user profile
  Future<bool> updateProfile({
    String? fullName,
    String? gender,
    String? profilePicture,
  }) async {
    if (_currentUser == null) return false;

    try {
      final updatedUser = await _authService.updateProfile(
        userId: _currentUser!.userId,
        fullName: fullName,
        gender: gender,
        profilePicture: profilePicture,
      );

      _currentUser = updatedUser;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = e.toString().replaceAll('Exception: ', '');
      notifyListeners();
      return false;
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    if (_currentUser == null) return;

    try {
      final user = await _authService.getCurrentUser();
      if (user != null) {
        _currentUser = user;
        notifyListeners();
      }
    } catch (e) {
      print('Error refreshing user: $e');
    }
  }

  // ============================================
  // UTILITY METHODS
  // ============================================

  /// Clear error message
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  /// Reset provider state
  void reset() {
    _state = AuthState.initial;
    _currentUser = null;
    _errorMessage = null;
    notifyListeners();
  }
}

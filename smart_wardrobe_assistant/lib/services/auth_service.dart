// ============================================
// AUTH_SERVICE.DART
// ============================================
// Service class for authentication operations
// Handles login, registration, and session management
// ============================================

import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';

class AuthService {
  /// Singleton pattern
  AuthService._privateConstructor();
  static final AuthService instance = AuthService._privateConstructor();

  // SharedPreferences keys
  static const String _keyUserId = 'user_id';
  static const String _keyIsLoggedIn = 'is_logged_in';

  // ============================================
  // REGISTRATION
  // ============================================

  /// Register a new user
  Future<UserModel> register({
    required String fullName,
    required String email,
    required String password,
    String? gender,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Check if email already exists
    final existing = await db.query(
      TableNames.users,
      where: 'email = ?',
      whereArgs: [email],
    );

    if (existing.isNotEmpty) {
      throw Exception('Email already registered. Please login instead.');
    }

    // Insert new user
    final userId = await db.insert(
      TableNames.users,
      {
        'full_name': fullName,
        'email': email,
        'password': password, // In production, hash this with bcrypt!
        'gender': gender,
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    // Retrieve the created user
    final userMaps = await db.query(
      TableNames.users,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return UserModel.fromMap(userMaps.first);
  }

  // ============================================
  // LOGIN
  // ============================================

  /// Login with email and password
  Future<UserModel> login({
    required String email,
    required String password,
  }) async {
    final db = await DatabaseHelper.instance.database;

    // Query user by email and password
    final results = await db.query(
      TableNames.users,
      where: 'email = ? AND password = ?',
      whereArgs: [email, password], // In production, hash password first!
    );

    if (results.isEmpty) {
      throw Exception('Invalid email or password. Please try again.');
    }

    final user = UserModel.fromMap(results.first);

    // Save session
    await _saveSession(user.userId);

    return user;
  }

  // ============================================
  // LOGOUT
  // ============================================

  /// Logout current user
  Future<void> logout() async {
    await _clearSession();
  }

  // ============================================
  // SESSION MANAGEMENT
  // ============================================

  /// Save user session to SharedPreferences
  Future<void> _saveSession(int userId) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_keyUserId, userId);
    await prefs.setBool(_keyIsLoggedIn, true);
  }

  /// Clear user session
  Future<void> _clearSession() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUserId);
    await prefs.setBool(_keyIsLoggedIn, false);
  }

  /// Check if user is logged in
  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyIsLoggedIn) ?? false;
  }

  /// Get current logged-in user ID
  Future<int?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_keyUserId);
  }

  /// Get current logged-in user
  Future<UserModel?> getCurrentUser() async {
    final userId = await getCurrentUserId();
    if (userId == null) return null;

    final db = await DatabaseHelper.instance.database;
    final results = await db.query(
      TableNames.users,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    if (results.isEmpty) return null;

    return UserModel.fromMap(results.first);
  }

  // ============================================
  // USER OPERATIONS
  // ============================================

  /// Update user profile
  Future<UserModel> updateProfile({
    required int userId,
    String? fullName,
    String? gender,
    String? profilePicture,
  }) async {
    final db = await DatabaseHelper.instance.database;

    final Map<String, dynamic> updates = {};
    if (fullName != null) updates['full_name'] = fullName;
    if (gender != null) updates['gender'] = gender;
    if (profilePicture != null) updates['profile_picture'] = profilePicture;

    if (updates.isNotEmpty) {
      await db.update(
        TableNames.users,
        updates,
        where: 'user_id = ?',
        whereArgs: [userId],
      );
    }

    // Retrieve updated user
    final userMaps = await db.query(
      TableNames.users,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    return UserModel.fromMap(userMaps.first);
  }

  /// Delete user account
  Future<void> deleteAccount(int userId) async {
    final db = await DatabaseHelper.instance.database;

    await db.delete(
      TableNames.users,
      where: 'user_id = ?',
      whereArgs: [userId],
    );

    await _clearSession();
  }
}

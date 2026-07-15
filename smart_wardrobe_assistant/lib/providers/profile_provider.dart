// ============================================
// PROFILE_PROVIDER.DART
// ============================================
// State management for user profile picture
//
// Purpose:
// - Manage profile picture state
// - Handle image picking from camera/gallery
// - Save and load profile pictures
// - Update user record in database
// ============================================

import 'package:flutter/material.dart';
import '../services/image_service.dart';
import '../database/database_helper.dart';
import '../database/tables.dart';

/// ProfileProvider class
/// Manages user profile picture state and operations
class ProfileProvider with ChangeNotifier {
  // ============================================
  // STATE VARIABLES
  // ============================================

  /// Current profile picture path
  String? _profilePicturePath;

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Image service instance
  final ImageService _imageService = ImageService();

  /// Current user ID
  int? _userId;

  // ============================================
  // GETTERS
  // ============================================

  /// Returns the current profile picture path
  String? get profilePicturePath => _profilePicturePath;

  /// Returns loading state
  bool get isLoading => _isLoading;

  /// Returns error message
  String? get errorMessage => _errorMessage;

  /// Returns whether a profile picture is set
  bool get hasProfilePicture =>
      _profilePicturePath != null && _profilePicturePath!.isNotEmpty;

  // ============================================
  // INITIALIZATION
  // ============================================

  /// Sets the current user ID and loads their profile picture
  Future<void> setUserId(int userId) async {
    _userId = userId;
    await loadProfileImage();
  }

  // ============================================
  // PICK IMAGE FROM GALLERY
  // ============================================

  /// Picks an image from the device gallery
  /// Returns true if successful, false otherwise
  Future<bool> pickImageFromGallery() async {
    try {
      _setLoading(true);
      _clearError();

      // Pick image using image service
      final String? imagePath = await _imageService.pickImageFromGallery();

      if (imagePath != null) {
        // Save the new profile picture
        final success = await saveProfileImage(imagePath);
        _setLoading(false);
        return success;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to pick image from gallery');
      print('Error picking image from gallery: $e');
      return false;
    }
  }

  // ============================================
  // PICK IMAGE FROM CAMERA
  // ============================================

  /// Picks an image from the device camera
  /// Returns true if successful, false otherwise
  Future<bool> pickImageFromCamera() async {
    try {
      _setLoading(true);
      _clearError();

      // Pick image using image service
      final String? imagePath = await _imageService.pickImageFromCamera();

      if (imagePath != null) {
        // Save the new profile picture
        final success = await saveProfileImage(imagePath);
        _setLoading(false);
        return success;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to take photo');
      print('Error picking image from camera: $e');
      return false;
    }
  }

  // ============================================
  // SAVE PROFILE IMAGE
  // ============================================

  /// Saves the profile picture path to the database
  /// Updates the current user's profile_picture field
  Future<bool> saveProfileImage(String imagePath) async {
    if (_userId == null) {
      _setError('No user logged in');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Delete old profile picture if it exists
      if (_profilePicturePath != null && _profilePicturePath!.isNotEmpty) {
        await _imageService.deleteImage(_profilePicturePath);
      }

      // Update database with new profile picture path
      final db = await DatabaseHelper.instance.database;
      final result = await db.update(
        TableNames.users,
        {'profile_picture': imagePath},
        where: 'user_id = ?',
        whereArgs: [_userId],
      );

      if (result > 0) {
        // Update local state
        _profilePicturePath = imagePath;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      _setError('Failed to save profile picture');
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to save profile picture');
      print('Error saving profile image: $e');
      return false;
    }
  }

  // ============================================
  // LOAD PROFILE IMAGE
  // ============================================

  /// Loads the profile picture from the database
  /// Called when the app starts or user logs in
  Future<void> loadProfileImage() async {
    if (_userId == null) {
      return;
    }

    try {
      _setLoading(true);
      _clearError();

      // Query database for user's profile picture
      final db = await DatabaseHelper.instance.database;
      final List<Map<String, dynamic>> result = await db.query(
        TableNames.users,
        columns: ['profile_picture'],
        where: 'user_id = ?',
        whereArgs: [_userId],
      );

      if (result.isNotEmpty) {
        final String? imagePath = result.first['profile_picture'] as String?;

        // Verify that the image file still exists
        if (imagePath != null && imagePath.isNotEmpty) {
          final exists = await _imageService.imageExists(imagePath);
          if (exists) {
            _profilePicturePath = imagePath;
          } else {
            // Image file doesn't exist, clear from database
            await removeProfileImage();
          }
        }
      }

      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _setLoading(false);
      _setError('Unable to load profile picture. Please try again.');
      print('Error loading profile image: $e');
      notifyListeners();
    }
  }

  // ============================================
  // REMOVE PROFILE IMAGE
  // ============================================

  /// Removes the profile picture
  /// Deletes the image file and clears the database field
  Future<bool> removeProfileImage() async {
    if (_userId == null) {
      _setError('No user logged in');
      return false;
    }

    try {
      _setLoading(true);
      _clearError();

      // Delete image file
      if (_profilePicturePath != null && _profilePicturePath!.isNotEmpty) {
        await _imageService.deleteImage(_profilePicturePath);
      }

      // Clear profile picture in database
      final db = await DatabaseHelper.instance.database;
      final result = await db.update(
        TableNames.users,
        {'profile_picture': null},
        where: 'user_id = ?',
        whereArgs: [_userId],
      );

      if (result > 0) {
        _profilePicturePath = null;
        _setLoading(false);
        notifyListeners();
        return true;
      }

      _setLoading(false);
      return false;
    } catch (e) {
      _setLoading(false);
      _setError('Failed to remove profile picture');
      print('Error removing profile image: $e');
      return false;
    }
  }

  // ============================================
  // HELPER METHODS
  // ============================================

  /// Sets loading state
  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  /// Sets error message
  void _setError(String message) {
    _errorMessage = message;
    notifyListeners();
  }

  /// Clears error message
  void _clearError() {
    _errorMessage = null;
  }

  /// Clears all state (for logout)
  void clear() {
    _profilePicturePath = null;
    _userId = null;
    _errorMessage = null;
    _isLoading = false;
    notifyListeners();
  }

  // ============================================
  // CHECK PERMISSIONS
  // ============================================

  /// Checks if camera permission is granted
  Future<bool> checkCameraPermission() async {
    return await _imageService.checkCameraPermission();
  }

  /// Checks if gallery permission is granted
  Future<bool> checkGalleryPermission() async {
    return await _imageService.checkGalleryPermission();
  }
}

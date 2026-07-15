// ============================================
// IMAGE_SERVICE.DART
// ============================================
// Service for handling image picking and file operations
//
// Purpose:
// - Pick images from camera or gallery
// - Handle permissions
// - Save images to local storage
// - Provide error handling
// ============================================

import 'dart:io';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// ImageService class
/// Handles all image-related operations
class ImageService {
  /// Image picker instance
  final ImagePicker _picker = ImagePicker();

  // ============================================
  // PICK IMAGE FROM GALLERY
  // ============================================

  /// Picks an image from the device gallery
  /// Returns the file path if successful, null otherwise
  Future<String?> pickImageFromGallery() async {
    try {
      // Check and request gallery permission
      final hasPermission = await _requestGalleryPermission();
      if (!hasPermission) {
        return null;
      }

      // Pick image from gallery
      final XFile? image = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Save image to app directory and return path
        return await _saveImageToAppDirectory(image);
      }

      return null;
    } catch (e) {
      print('Error picking image from gallery: $e');
      return null;
    }
  }

  // ============================================
  // PICK IMAGE FROM CAMERA
  // ============================================

  /// Picks an image from the device camera
  /// Returns the file path if successful, null otherwise
  Future<String?> pickImageFromCamera() async {
    try {
      // Check and request camera permission
      final hasPermission = await _requestCameraPermission();
      if (!hasPermission) {
        return null;
      }

      // Take photo with camera
      final XFile? image = await _picker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1024,
        maxHeight: 1024,
        imageQuality: 85,
      );

      if (image != null) {
        // Save image to app directory and return path
        return await _saveImageToAppDirectory(image);
      }

      return null;
    } catch (e) {
      print('Error picking image from camera: $e');
      return null;
    }
  }

  // ============================================
  // PERMISSION HANDLING
  // ============================================

  /// Requests gallery permission
  /// Returns true if permission granted, false otherwise
  Future<bool> _requestGalleryPermission() async {
    try {
      // For Android 13+, we need photos permission instead of storage
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          // Android 13+ uses photos permission
          final status = await Permission.photos.request();
          return status.isGranted;
        } else {
          // Older Android versions use storage permission
          final status = await Permission.storage.request();
          return status.isGranted;
        }
      }

      // For iOS
      if (Platform.isIOS) {
        final status = await Permission.photos.request();
        return status.isGranted;
      }

      return true;
    } catch (e) {
      print('Error requesting gallery permission: $e');
      return false;
    }
  }

  /// Requests camera permission
  /// Returns true if permission granted, false otherwise
  Future<bool> _requestCameraPermission() async {
    try {
      final status = await Permission.camera.request();
      return status.isGranted;
    } catch (e) {
      print('Error requesting camera permission: $e');
      return false;
    }
  }

  /// Gets Android SDK version
  Future<int> _getAndroidVersion() async {
    if (Platform.isAndroid) {
      // This is a simplified version
      // In production, you'd use device_info_plus package
      return 33; // Assume Android 13+
    }
    return 0;
  }

  /// Checks if gallery permission is granted
  Future<bool> checkGalleryPermission() async {
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _getAndroidVersion();
        if (androidInfo >= 33) {
          final status = await Permission.photos.status;
          return status.isGranted;
        } else {
          final status = await Permission.storage.status;
          return status.isGranted;
        }
      }

      if (Platform.isIOS) {
        final status = await Permission.photos.status;
        return status.isGranted;
      }

      return true;
    } catch (e) {
      print('Error checking gallery permission: $e');
      return false;
    }
  }

  /// Checks if camera permission is granted
  Future<bool> checkCameraPermission() async {
    try {
      final status = await Permission.camera.status;
      return status.isGranted;
    } catch (e) {
      print('Error checking camera permission: $e');
      return false;
    }
  }

  // ============================================
  // FILE OPERATIONS
  // ============================================

  /// Saves the picked image to app's permanent directory
  /// Returns the new file path
  Future<String> _saveImageToAppDirectory(XFile image) async {
    try {
      // Get the application documents directory
      final Directory appDir = await getApplicationDocumentsDirectory();

      // Create profile_pictures directory if it doesn't exist
      final Directory profilePicsDir =
          Directory('${appDir.path}/profile_pictures');
      if (!await profilePicsDir.exists()) {
        await profilePicsDir.create(recursive: true);
      }

      // Generate unique filename using timestamp
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String extension = path.extension(image.path);
      final String fileName = 'profile_$timestamp$extension';
      final String newPath = '${profilePicsDir.path}/$fileName';

      // Copy image to new location
      final File imageFile = File(image.path);
      await imageFile.copy(newPath);

      print('Image saved to: $newPath');
      return newPath;
    } catch (e) {
      print('Error saving image to app directory: $e');
      rethrow;
    }
  }

  /// Deletes an image file from storage
  /// Returns true if successful, false otherwise
  Future<bool> deleteImage(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        await file.delete();
        print('Image deleted: $imagePath');
        return true;
      }
      return false;
    } catch (e) {
      print('Error deleting image: $e');
      return false;
    }
  }

  /// Checks if an image file exists
  Future<bool> imageExists(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return false;
    }

    try {
      final File file = File(imagePath);
      return await file.exists();
    } catch (e) {
      print('Error checking if image exists: $e');
      return false;
    }
  }

  /// Gets the size of an image file in bytes
  Future<int?> getImageSize(String? imagePath) async {
    if (imagePath == null || imagePath.isEmpty) {
      return null;
    }

    try {
      final File file = File(imagePath);
      if (await file.exists()) {
        return await file.length();
      }
      return null;
    } catch (e) {
      print('Error getting image size: $e');
      return null;
    }
  }
}

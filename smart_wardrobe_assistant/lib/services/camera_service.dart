import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Result object returned by [CameraService] operations.
class CameraResult {
  final bool success;
  final String? imagePath;
  final String? errorMessage;

  const CameraResult._({
    required this.success,
    this.imagePath,
    this.errorMessage,
  });

  factory CameraResult.ok(String imagePath) =>
      CameraResult._(success: true, imagePath: imagePath);

  factory CameraResult.err(String message) =>
      CameraResult._(success: false, errorMessage: message);
}

/// Handles all camera and gallery interactions for the app.
///
/// Usage:
/// ```dart
/// final service = CameraService();
/// final granted = await service.requestCameraPermission();
/// final result  = await service.pickFromGallery();
/// ```
class CameraService {
  final ImagePicker _picker = ImagePicker();

  // ── Permissions ───────────────────────────────────────────────────────────

  /// Returns true if camera permission is already granted.
  Future<bool> hasCameraPermission() async {
    final status = await Permission.camera.status;
    return status.isGranted;
  }

  /// Requests camera permission. Returns true if granted.
  Future<bool> requestCameraPermission() async {
    final status = await Permission.camera.request();
    return status.isGranted;
  }

  /// Returns true if storage / photos permission is already granted.
  Future<bool> hasStoragePermission() async {
    if (Platform.isAndroid) {
      // Android 13+ uses READ_MEDIA_IMAGES; older versions use READ_EXTERNAL_STORAGE
      final photos = await Permission.photos.status;
      if (photos.isGranted) return true;
      final storage = await Permission.storage.status;
      return storage.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.status;
      return status.isGranted;
    }
    return true;
  }

  /// Requests storage / photos permission. Returns true if granted.
  Future<bool> requestStoragePermission() async {
    if (Platform.isAndroid) {
      final photos = await Permission.photos.request();
      if (photos.isGranted) return true;
      final storage = await Permission.storage.request();
      return storage.isGranted;
    } else if (Platform.isIOS) {
      final status = await Permission.photos.request();
      return status.isGranted;
    }
    return true;
  }

  /// Requests both camera and storage permissions.
  /// Returns a map: `{'camera': bool, 'storage': bool}`.
  Future<Map<String, bool>> requestAllPermissions() async {
    final results = await [
      Permission.camera,
      Permission.photos,
    ].request();

    final cameraGranted =
        results[Permission.camera]?.isGranted ?? false;

    bool storageGranted = results[Permission.photos]?.isGranted ?? false;
    if (!storageGranted && Platform.isAndroid) {
      final storageResult = await Permission.storage.request();
      storageGranted = storageResult.isGranted;
    }

    return {'camera': cameraGranted, 'storage': storageGranted};
  }

  // ── Gallery ───────────────────────────────────────────────────────────────

  /// Opens the system image picker and returns the selected image path,
  /// or null if the user cancelled.
  Future<CameraResult> pickFromGallery({
    double? maxWidth = 1920,
    double? maxHeight = 1920,
    int? imageQuality = 90,
  }) async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) {
        return CameraResult.err(
          'Gallery permission denied. Please allow photo access in Settings.',
        );
      }

      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      if (picked == null) {
        return CameraResult.err('No image selected.');
      }

      return CameraResult.ok(picked.path);
    } catch (e) {
      debugPrint('CameraService.pickFromGallery error: $e');
      return CameraResult.err('Failed to pick image: $e');
    }
  }

  /// Picks multiple images from the gallery.
  /// Returns a list of file paths, or an empty list on cancel / error.
  Future<List<String>> pickMultipleFromGallery({
    int? imageQuality = 90,
  }) async {
    try {
      final granted = await requestStoragePermission();
      if (!granted) return [];

      final List<XFile> files = await _picker.pickMultiImage(
        imageQuality: imageQuality,
      );
      return files.map((f) => f.path).toList();
    } catch (e) {
      debugPrint('CameraService.pickMultipleFromGallery error: $e');
      return [];
    }
  }

  // ── Save ─────────────────────────────────────────────────────────────────

  /// Saves an image from [sourcePath] to the app's documents directory
  /// under the `wardrobe/` sub-folder. Returns the saved file path.
  Future<String?> saveImageToApp(String sourcePath) async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final wardrobeDir = Directory(path.join(appDir.path, 'wardrobe'));
      if (!await wardrobeDir.exists()) {
        await wardrobeDir.create(recursive: true);
      }

      final fileName =
          '${DateTime.now().millisecondsSinceEpoch}${path.extension(sourcePath)}';
      final destPath = path.join(wardrobeDir.path, fileName);

      await File(sourcePath).copy(destPath);
      return destPath;
    } catch (e) {
      debugPrint('CameraService.saveImageToApp error: $e');
      return null;
    }
  }

  // ── Camera controller helpers ─────────────────────────────────────────────

  /// Creates and initialises a [CameraController] for [camera].
  /// The caller is responsible for calling [controller.dispose()].
  Future<CameraController?> initController(
    CameraDescription camera, {
    ResolutionPreset resolution = ResolutionPreset.high,
  }) async {
    try {
      final controller = CameraController(
        camera,
        resolution,
        enableAudio: false,
        imageFormatGroup: ImageFormatGroup.jpeg,
      );
      await controller.initialize();
      return controller;
    } catch (e) {
      debugPrint('CameraService.initController error: $e');
      return null;
    }
  }

  /// Captures a photo using [controller] and returns the file path.
  Future<CameraResult> capturePhoto(CameraController controller) async {
    try {
      if (!controller.value.isInitialized) {
        return CameraResult.err('Camera is not ready.');
      }
      final XFile file = await controller.takePicture();
      return CameraResult.ok(file.path);
    } catch (e) {
      debugPrint('CameraService.capturePhoto error: $e');
      return CameraResult.err('Failed to capture photo: $e');
    }
  }
}

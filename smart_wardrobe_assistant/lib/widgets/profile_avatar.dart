// ============================================
// PROFILE_AVATAR.DART
// ============================================
// Reusable profile avatar widget with image picker
//
// Purpose:
// - Display user profile picture
// - Handle tap to change picture
// - Show bottom sheet with options
// - Smooth animations when changing image
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';

/// ProfileAvatar widget
/// Displays user profile picture with click-to-change functionality
class ProfileAvatar extends StatelessWidget {
  /// Avatar radius
  final double radius;

  /// User initials to display when no image
  final String initials;

  /// Whether to show camera icon overlay
  final bool showCameraIcon;

  /// Background color when no image is set
  final Color? backgroundColor;

  const ProfileAvatar({
    super.key,
    this.radius = 28,
    required this.initials,
    this.showCameraIcon = false,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _showImageSourceBottomSheet(context),
      child: Consumer<ProfileProvider>(
        builder: (context, profileProvider, child) {
          return Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.1),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                // Profile Picture with Animation
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return FadeTransition(
                      opacity: animation,
                      child: child,
                    );
                  },
                  child: Container(
                    key: ValueKey(profileProvider.profilePicturePath),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 3,
                      ),
                    ),
                    child: CircleAvatar(
                      radius: radius,
                      backgroundColor:
                          backgroundColor ?? const Color(0xFF2563EB),
                      child: profileProvider.hasProfilePicture
                          ? ClipOval(
                              child: Image.file(
                                File(profileProvider.profilePicturePath!),
                                width: radius * 2,
                                height: radius * 2,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Show initials if image fails to load
                                  return _buildInitials();
                                },
                              ),
                            )
                          : _buildInitials(),
                    ),
                  ),
                ),

                // Camera Icon Overlay (Optional)
                if (showCameraIcon)
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: const Color(0xFF2563EB),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: 2,
                        ),
                      ),
                      child: Icon(
                        Icons.camera_alt,
                        size: radius * 0.4,
                        color: Colors.white,
                      ),
                    ),
                  ),

                // Loading Overlay
                if (profileProvider.isLoading)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.black.withOpacity(0.5),
                      ),
                      child: const Center(
                        child: CircularProgressIndicator(
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                          strokeWidth: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  /// Builds the initials widget
  Widget _buildInitials() {
    return Text(
      initials,
      style: TextStyle(
        fontSize: radius * 0.7,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    );
  }

  /// Shows bottom sheet with image source options
  void _showImageSourceBottomSheet(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _ImageSourceBottomSheet(),
    );
  }
}

/// Bottom sheet for selecting image source
class _ImageSourceBottomSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final profileProvider = Provider.of<ProfileProvider>(context, listen: false);

    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            const SizedBox(height: 20),

            // Title
            const Text(
              'Choose Profile Picture',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
            ),

            const SizedBox(height: 20),

            // Take Photo Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF2563EB).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Color(0xFF2563EB),
                  size: 24,
                ),
              ),
              title: const Text(
                'Take Photo',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final success = await profileProvider.pickImageFromCamera();
                if (!success && context.mounted) {
                  _showErrorSnackBar(
                    context,
                    profileProvider.errorMessage ??
                        'Camera permission is required to take photos',
                  );
                }
              },
            ),

            // Choose from Gallery Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF14B8A6).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.photo_library,
                  color: Color(0xFF14B8A6),
                  size: 24,
                ),
              ),
              title: const Text(
                'Choose from Gallery',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF111827),
                ),
              ),
              onTap: () async {
                Navigator.pop(context);
                final success = await profileProvider.pickImageFromGallery();
                if (!success && context.mounted) {
                  _showErrorSnackBar(
                    context,
                    profileProvider.errorMessage ??
                        'Gallery permission is required to select photos',
                  );
                }
              },
            ),

            // Remove Photo Option (if picture exists)
            Consumer<ProfileProvider>(
              builder: (context, provider, child) {
                if (provider.hasProfilePicture) {
                  return ListTile(
                    leading: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFFEF4444).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Color(0xFFEF4444),
                        size: 24,
                      ),
                    ),
                    title: const Text(
                      'Remove Photo',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFFEF4444),
                      ),
                    ),
                    onTap: () async {
                      Navigator.pop(context);
                      await provider.removeProfileImage();
                    },
                  );
                }
                return const SizedBox.shrink();
              },
            ),

            // Cancel Option
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFF6B7280).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.close,
                  color: Color(0xFF6B7280),
                  size: 24,
                ),
              ),
              title: const Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
              ),
              onTap: () {
                Navigator.pop(context);
              },
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  /// Shows error snackbar
  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFEF4444),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {},
        ),
      ),
    );
  }
}

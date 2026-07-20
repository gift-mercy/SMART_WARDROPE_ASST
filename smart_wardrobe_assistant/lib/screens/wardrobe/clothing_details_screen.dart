// ============================================
// CLOTHING_DETAILS_SCREEN.DART
// ============================================
// Professional clothing details screen
//
// Purpose:
// - Display complete information about a clothing item
// - Provide Edit and Delete actions
// - Show beautiful Material Design cards
// - Use Hero animations for images
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../models/clothing_item.dart';
import '../../providers/wardrobe_provider.dart';
import '../../core/constants/app_colors.dart';
import '../../widgets/detail_item.dart';
import '../../widgets/custom_action_button.dart';

/// ClothingDetailsScreen
/// Displays detailed information about a selected clothing item
class ClothingDetailsScreen extends StatefulWidget {
  final ClothingItem clothingItem;

  const ClothingDetailsScreen({
    super.key,
    required this.clothingItem,
  });

  @override
  State<ClothingDetailsScreen> createState() => _ClothingDetailsScreenState();
}

class _ClothingDetailsScreenState extends State<ClothingDetailsScreen> {
  late ClothingItem _clothingItem;

  @override
  void initState() {
    super.initState();
    _clothingItem = widget.clothingItem;
  }

  /// Format date to readable string
  String _formatDate(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return 'Unknown';
    }

    try {
      final date = DateTime.parse(dateString);
      return DateFormat('dd MMMM yyyy').format(date);
    } catch (e) {
      return dateString;
    }
  }

  /// Show delete confirmation dialog
  Future<void> _showDeleteConfirmationDialog() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Clothing Item?',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this clothing item? This action cannot be undone.',
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
        actions: [
          // Cancel Button
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(
              'Cancel',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: AppColors.textSecondary,
              ),
            ),
          ),

          // Delete Button
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
            ),
            child: Text(
              'Delete',
              style: GoogleFonts.poppins(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await _deleteClothing();
    }
  }

  /// Delete clothing item
  Future<void> _deleteClothing() async {
    if (_clothingItem.clothingId == null) return;

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Center(
        child: Card(
          margin: const EdgeInsets.all(32),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircularProgressIndicator(
                  color: AppColors.primary,
                ),
                const SizedBox(height: 16),
                Text(
                  'Deleting...',
                  style: GoogleFonts.poppins(
                    fontSize: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    // Delete from database
    final wardrobeProvider = Provider.of<WardrobeProvider>(
      context,
      listen: false,
    );

    final success = await wardrobeProvider.deleteClothingItem(
      _clothingItem.clothingId!,
    );

    // Close loading dialog
    if (mounted) {
      Navigator.of(context).pop();
    }

    if (success) {
      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Clothing deleted successfully',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );

        // Navigate back to wardrobe
        Navigator.of(context).pop();
      }
    } else {
      // Show error message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Failed to delete clothing',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            backgroundColor: AppColors.error,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: const EdgeInsets.all(16),
          ),
        );
      }
    }
  }

  /// Navigate to edit screen
  void _navigateToEditScreen() {
    // Navigate to edit clothing screen
    Navigator.pushNamed(
      context,
      '/edit-clothing',
      arguments: _clothingItem,
    ).then((result) {
      // Refresh if clothing was updated
      if (result != null && result is ClothingItem) {
        setState(() {
          _clothingItem = result;
        });
      }
    });
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      // ============================================
      // APP BAR
      // ============================================
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppColors.textPrimary,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Clothing Details',
          style: GoogleFonts.poppins(
            fontSize: 20,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

      ),

      // ============================================
      // BODY
      // ============================================
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ============================================
            // IMAGE SECTION
            // ============================================
            _buildImageSection(),

            const SizedBox(height: 24),

            // ============================================
            // CLOTHING NAME CARD
            // ============================================
            _buildNameCard(),

            const SizedBox(height: 16),

            // ============================================
            // DETAILS CARD
            // ============================================
            _buildDetailsCard(),

            const SizedBox(height: 16),

            const SizedBox(height: 24),

            // ============================================
            // ACTION BUTTONS
            // ============================================
            _buildActionButtons(),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  /// Build image section with Hero animation
  Widget _buildImageSection() {
    return Hero(
      tag: 'clothing_${_clothingItem.clothingId}',
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: const BoxDecoration(
          color: Colors.white,
        ),
        child: ClipRRect(
          borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(24),
            bottomRight: Radius.circular(24),
          ),
          child: _buildImage(),
        ),
      ),
    );
  }

  /// Build image widget
  Widget _buildImage() {
    // Check if image file exists
    final imageFile = File(_clothingItem.imagePath);

    if (imageFile.existsSync()) {
      return Image.file(
        imageFile,
        fit: BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return _buildPlaceholderImage();
        },
      );
    } else {
      return _buildPlaceholderImage();
    }
  }

  /// Build placeholder image
  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.background,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.checkroom,
              size: 80,
              color: AppColors.primary.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 16),
            Text(
              'No Image Available',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build clothing name card
  Widget _buildNameCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Text(
            _clothingItem.clothingName,
            style: GoogleFonts.poppins(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ),
    );
  }

  /// Build details card
  Widget _buildDetailsCard() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Details title
              Text(
                'Details',
                style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),

              const SizedBox(height: 16),

              // Category
              DetailItem(
                icon: Icons.checkroom,
                label: 'Category',
                value: _clothingItem.categoryName ?? 'Unknown',
              ),

              const SizedBox(height: 12),

              // Color
              DetailItem(
                icon: Icons.palette,
                label: 'Color',
                value: _clothingItem.colorName ?? 'Unknown',
              ),

              const SizedBox(height: 12),

              // Date Added
              DetailItem(
                icon: Icons.calendar_today,
                label: 'Date Added',
                value: _formatDate(_clothingItem.dateAdded),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          // Edit Button
          Expanded(
            child: CustomActionButton(
              label: 'Edit Clothing',
              icon: Icons.edit,
              backgroundColor: AppColors.primary,
              onPressed: _navigateToEditScreen,
            ),
          ),

          const SizedBox(width: 16),

          // Delete Button
          Expanded(
            child: CustomActionButton(
              label: 'Delete Clothing',
              icon: Icons.delete,
              backgroundColor: AppColors.error,
              onPressed: _showDeleteConfirmationDialog,
            ),
          ),
        ],
      ),
    );
  }
}

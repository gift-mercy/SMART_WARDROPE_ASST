import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/camera_service.dart';
import '../../widgets/custom_appbar.dart';
import '../../widgets/empty_state.dart';
import '../../widgets/loading_widget.dart';
import 'image_preview_screen.dart';

/// Gallery screen â€” lets the user pick one or multiple photos from the
/// device library and preview / use them in the app.
///
/// â€¢ Grid view of recently picked images (session-level history)
/// â€¢ Single pick â†’ opens [ImagePreviewScreen]
/// â€¢ Multi-select mode â†’ confirms selection and returns paths to caller
/// â€¢ Permission handling via [CameraService]
class GalleryScreen extends StatefulWidget {
  const GalleryScreen({super.key});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  final CameraService _cameraService = CameraService();

  bool _isLoading = false;
  bool _isMultiSelectMode = false;
  final List<String> _pickedImages = [];
  final Set<int> _selectedIndices = {};

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _pickSingleImage() async {
    setState(() => _isLoading = true);

    final result = await _cameraService.pickFromGallery();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result.success && result.imagePath != null) {
      // Add to session list (avoid duplicates)
      if (!_pickedImages.contains(result.imagePath)) {
        setState(() => _pickedImages.insert(0, result.imagePath!));
      }
      // Navigate to preview
      if (mounted) {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ImagePreviewScreen(imagePath: result.imagePath!),
          ),
        );
      }
    } else if (result.errorMessage != null &&
        result.errorMessage != 'No image selected.') {
      _showError(result.errorMessage!);
    }
  }

  Future<void> _pickMultipleImages() async {
    setState(() => _isLoading = true);

    final paths = await _cameraService.pickMultipleFromGallery();

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (paths.isEmpty) return;

    // Merge into session list
    for (final p in paths) {
      if (!_pickedImages.contains(p)) {
        _pickedImages.insert(0, p);
      }
    }
    setState(() {});
  }

  void _toggleMultiSelect() {
    setState(() {
      _isMultiSelectMode = !_isMultiSelectMode;
      _selectedIndices.clear();
    });
  }

  void _toggleSelection(int index) {
    setState(() {
      if (_selectedIndices.contains(index)) {
        _selectedIndices.remove(index);
      } else {
        _selectedIndices.add(index);
      }
    });
  }

  void _confirmSelection() {
    final selected =
        _selectedIndices.map((i) => _pickedImages[i]).toList();
    Navigator.of(context).pop(selected);
  }

  void _openPreview(String imagePath) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ImagePreviewScreen(imagePath: imagePath),
      ),
    );
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message,
            style: AppTextStyles.small.copyWith(color: Colors.white)),
        backgroundColor: AppColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: CustomAppBar(
        title: _isMultiSelectMode
            ? '${_selectedIndices.length} selected'
            : 'Gallery',
        actions: [
          if (_pickedImages.isNotEmpty) ...[
            // Multi-select toggle
            IconButton(
              icon: Icon(
                _isMultiSelectMode
                    ? Icons.close_rounded
                    : Icons.checklist_rounded,
                color: AppColors.textOnPrimary,
              ),
              tooltip: _isMultiSelectMode ? 'Cancel' : 'Select multiple',
              onPressed: _toggleMultiSelect,
            ),
            // Add more photos
            if (!_isMultiSelectMode)
              IconButton(
                icon: const Icon(Icons.add_photo_alternate_outlined,
                    color: AppColors.textOnPrimary),
                tooltip: 'Add photos',
                onPressed: _pickMultipleImages,
              ),
          ],
        ],
      ),
      body: LoadingOverlay(
        isLoading: _isLoading,
        message: 'Loading imagesâ€¦',
        child: _pickedImages.isEmpty
            ? _buildEmptyState()
            : _buildImageGrid(),
      ),
      bottomNavigationBar: _isMultiSelectMode && _selectedIndices.isNotEmpty
          ? _buildSelectionBar()
          : null,
      floatingActionButton: !_isMultiSelectMode
          ? FloatingActionButton.extended(
              onPressed: _pickSingleImage,
              backgroundColor: AppColors.primary,
              foregroundColor: AppColors.textOnPrimary,
              icon: const Icon(Icons.add_photo_alternate_outlined),
              label: Text('Pick Photo', style: AppTextStyles.button),
              elevation: 2,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            )
          : null,
    );
  }

  Widget _buildEmptyState() {
    return EmptyState(
      icon: Icons.photo_library_outlined,
      title: 'No Photos Yet',
      subtitle: 'Pick an image from your gallery to start building your wardrobe.',
      actionLabel: 'Open Gallery',
      onAction: _pickSingleImage,
      iconColor: AppColors.secondary,
    );
  }

  Widget _buildImageGrid() {
    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemCount: _pickedImages.length,
      itemBuilder: (context, index) {
        return _ImageGridTile(
          imagePath: _pickedImages[index],
          isMultiSelectMode: _isMultiSelectMode,
          isSelected: _selectedIndices.contains(index),
          onTap: () => _isMultiSelectMode
              ? _toggleSelection(index)
              : _openPreview(_pickedImages[index]),
          onLongPress: () {
            if (!_isMultiSelectMode) {
              _toggleMultiSelect();
              _toggleSelection(index);
            }
          },
        );
      },
    );
  }

  Widget _buildSelectionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
        boxShadow: [
          BoxShadow(color: AppColors.shadow, blurRadius: 8, offset: Offset(0, -2)),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: _toggleMultiSelect,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppColors.textSecondary,
                side: const BorderSide(color: AppColors.border),
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text('Cancel', style: AppTextStyles.button.copyWith(color: AppColors.textSecondary)),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: _confirmSelection,
              icon: const Icon(Icons.check_circle_outline_rounded),
              label: Text(
                'Use ${_selectedIndices.length} Photo${_selectedIndices.length == 1 ? '' : 's'}',
                style: AppTextStyles.button,
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                minimumSize: const Size(0, 48),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Image grid tile â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ImageGridTile extends StatelessWidget {
  final String imagePath;
  final bool isMultiSelectMode;
  final bool isSelected;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _ImageGridTile({
    required this.imagePath,
    required this.isMultiSelectMode,
    required this.isSelected,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          border: isSelected
              ? Border.all(color: AppColors.primary, width: 3)
              : Border.all(color: Colors.transparent),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(isSelected ? 9 : 12),
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Thumbnail
              Image.file(
                File(imagePath),
                fit: BoxFit.cover,
                errorBuilder: (context, error, stack) => Container(
                  color: AppColors.border,
                  child: const Icon(Icons.broken_image_outlined,
                      color: AppColors.textHint),
                ),
              ),

              // Selection overlay
              if (isMultiSelectMode)
                Positioned(
                  top: 6,
                  right: 6,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: isSelected ? AppColors.primary : Colors.white,
                      border: Border.all(
                        color: isSelected ? AppColors.primary : AppColors.border,
                        width: 2,
                      ),
                      boxShadow: const [
                        BoxShadow(color: AppColors.shadow, blurRadius: 4),
                      ],
                    ),
                    child: isSelected
                        ? const Icon(Icons.check_rounded,
                            size: 14, color: Colors.white)
                        : null,
                  ),
                ),

              // Dark overlay on selected
              if (isSelected)
                Container(
                  color: AppColors.primary.withValues(alpha: 0.15),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

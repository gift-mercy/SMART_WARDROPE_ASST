import 'dart:io';
import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/camera_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

/// Full-screen image preview shown after capture or gallery pick.
///
/// Actions available:
/// â€¢ Retake / Back  â€” pops back to the camera or gallery
/// â€¢ Save           â€” persists image to app documents via [CameraService]
/// â€¢ Use Photo      â€” returns [imagePath] to the calling screen via [Navigator.pop]
class ImagePreviewScreen extends StatefulWidget {
  final String imagePath;

  /// Optional label shown below the image (e.g. 'Captured photo').
  final String? label;

  const ImagePreviewScreen({
    super.key,
    required this.imagePath,
    this.label,
  });

  @override
  State<ImagePreviewScreen> createState() => _ImagePreviewScreenState();
}

class _ImagePreviewScreenState extends State<ImagePreviewScreen>
    with SingleTickerProviderStateMixin {
  final CameraService _cameraService = CameraService();

  bool _isSaving = false;
  bool _isSaved = false;
  String? _savedPath;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeIn,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // â”€â”€ Actions â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  Future<void> _saveImage() async {
    if (_isSaving || _isSaved) return;

    setState(() => _isSaving = true);

    final saved = await _cameraService.saveImageToApp(widget.imagePath);

    if (!mounted) return;
    setState(() {
      _isSaving = false;
      if (saved != null) {
        _isSaved = true;
        _savedPath = saved;
      }
    });

    if (saved != null) {
      _showSnackBar(
        'âœ“  Photo saved to your wardrobe.',
        AppColors.success,
      );
    } else {
      _showSnackBar('Failed to save photo. Please try again.', AppColors.error);
    }
  }

  void _usePhoto() {
    // Return the saved path (if saved) or the original path to the caller
    Navigator.of(context).pop(_savedPath ?? widget.imagePath);
  }

  void _retake() => Navigator.of(context).pop();

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: AppTextStyles.small.copyWith(color: Colors.white),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 3),
      ),
    );
  }

  // â”€â”€ Build â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: _buildAppBar(),
      body: _buildBody(),
      bottomNavigationBar: _buildActionBar(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios_new_rounded,
            color: AppColors.cameraControl),
        onPressed: _retake,
        tooltip: 'Back',
      ),
      title: Text(
        widget.label ?? 'Preview',
        style: AppTextStyles.appBarTitle
            .copyWith(color: AppColors.cameraControl),
      ),
      actions: [
        // Save icon shortcut
        if (!_isSaved)
          IconButton(
            icon: const Icon(Icons.save_alt_rounded,
                color: AppColors.cameraControl),
            tooltip: 'Save photo',
            onPressed: _isSaving ? null : _saveImage,
          )
        else
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.check_circle_rounded,
                    color: AppColors.success, size: 18),
                const SizedBox(width: 4),
                Text('Saved',
                    style: AppTextStyles.small
                        .copyWith(color: AppColors.success)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBody() {
    return LoadingOverlay(
      isLoading: _isSaving,
      message: 'Savingâ€¦',
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // â”€â”€ Full-screen image â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            InteractiveViewer(
              minScale: 0.8,
              maxScale: 4.0,
              child: Image.file(
                File(widget.imagePath),
                fit: BoxFit.contain,
                errorBuilder: (context, error, stack) => const Center(
                  child: Icon(Icons.broken_image_outlined,
                      size: 64, color: AppColors.textHint),
                ),
              ),
            ),

            // â”€â”€ Top gradient â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: 100,
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [Color(0xBB000000), Colors.transparent],
                  ),
                ),
              ),
            ),

            // â”€â”€ Zoom hint â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
            Positioned(
              top: MediaQuery.of(context).padding.top + 64,
              left: 0,
              right: 0,
              child: Center(
                child: _ZoomHintBadge(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
      decoration: const BoxDecoration(
        color: Color(0xF2111827),
        border: Border(top: BorderSide(color: Color(0x33FFFFFF))),
      ),
      child: Row(
        children: [
          // Retake / Back
          Expanded(
            child: CustomButton(
              label: 'Retake',
              onPressed: _retake,
              variant: ButtonVariant.outlined,
              icon: Icons.refresh_rounded,
              color: AppColors.cameraControl,
            ),
          ),

          const SizedBox(width: 12),

          // Save
          if (!_isSaved)
            Expanded(
              child: CustomButton(
                label: 'Save',
                onPressed: _saveImage,
                variant: ButtonVariant.filled,
                icon: Icons.save_alt_rounded,
                isLoading: _isSaving,
                color: AppColors.secondary,
              ),
            )
          else
            Expanded(
              child: Container(
                height: 52,
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.check_rounded,
                        color: AppColors.success, size: 18),
                    const SizedBox(width: 6),
                    Text('Saved',
                        style: AppTextStyles.button
                            .copyWith(color: AppColors.success)),
                  ],
                ),
              ),
            ),

          const SizedBox(width: 12),

          // Use Photo
          Expanded(
            child: CustomButton(
              label: 'Use Photo',
              onPressed: _usePhoto,
              variant: ButtonVariant.filled,
              icon: Icons.check_circle_outline_rounded,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

// â”€â”€ Zoom hint â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

class _ZoomHintBadge extends StatefulWidget {
  @override
  State<_ZoomHintBadge> createState() => _ZoomHintBadgeState();
}

class _ZoomHintBadgeState extends State<_ZoomHintBadge>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _opacity;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _opacity = CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut);

    // Show briefly then fade
    Future.delayed(const Duration(milliseconds: 800), () {
      if (mounted) _ctrl.forward();
    });
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) _ctrl.reverse();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _opacity,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: AppColors.cameraOverlay,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.zoom_in_rounded,
                color: AppColors.cameraControl, size: 16),
            const SizedBox(width: 6),
            Text(
              'Pinch to zoom',
              style: AppTextStyles.caption
                  .copyWith(color: AppColors.cameraControl),
            ),
          ],
        ),
      ),
    );
  }
}

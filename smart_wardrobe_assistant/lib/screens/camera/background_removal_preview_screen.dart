import 'dart:io';

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import '../../core/constants/app_text_styles.dart';
import '../../services/ai_service.dart';
import '../../widgets/custom_button.dart';
import '../../widgets/loading_widget.dart';

/// Shows the AI background-removal result and lets the user confirm or retake.
/// The original image is kept until a processed image is successfully created.
class BackgroundRemovalPreviewScreen extends StatefulWidget {
  const BackgroundRemovalPreviewScreen({
    super.key,
    required this.originalImagePath,
  });

  final String originalImagePath;

  @override
  State<BackgroundRemovalPreviewScreen> createState() =>
      _BackgroundRemovalPreviewScreenState();
}

class _BackgroundRemovalPreviewScreenState
    extends State<BackgroundRemovalPreviewScreen> {
  final AiService _aiService = AiService();

  String? _processedImagePath;
  String? _errorMessage;
  bool _isProcessing = true;
  bool _showOriginal = false;

  @override
  void initState() {
    super.initState();
    _processImage();
  }

  Future<void> _processImage() async {
    setState(() {
      _isProcessing = true;
      _errorMessage = null;
      _processedImagePath = null;
    });

    try {
      final processed = await _aiService.removeBackground(widget.originalImagePath);
      if (!mounted) return;
      setState(() {
        _processedImagePath = processed;
        _isProcessing = false;
      });
    } on AiServiceException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorMessage = error.message;
        _isProcessing = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Background removal failed. Please try again.';
        _isProcessing = false;
      });
    }
  }

  void _confirm() {
    final path = _processedImagePath;
    if (path == null) return;
    Navigator.of(context).pop(path);
  }

  void _retake() {
    Navigator.of(context).pop('__retake__');
  }

  void _cancel() {
    Navigator.of(context).pop();
  }

  String? get _displayPath {
    if (_showOriginal || _processedImagePath == null) {
      return widget.originalImagePath;
    }
    return _processedImagePath;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: AppColors.cameraControl),
          onPressed: _cancel,
        ),
        title: Text(
          'Background Removal',
          style: AppTextStyles.appBarTitle.copyWith(color: AppColors.cameraControl),
        ),
      ),
      body: _isProcessing
          ? const LoadingWidget(
              message: 'Removing background with AI…',
              color: AppColors.cameraControl,
            )
          : _errorMessage != null
              ? _buildErrorState()
              : _buildPreviewState(),
      bottomNavigationBar: _processedImagePath == null || _isProcessing
          ? null
          : _buildActionBar(),
    );
  }

  Widget _buildErrorState() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, color: AppColors.error, size: 56),
          const SizedBox(height: 16),
          Text(
            _errorMessage ?? 'Background removal failed.',
            style: AppTextStyles.bodyMedium.copyWith(color: AppColors.cameraControl),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          CustomButton(
            label: 'Retry',
            icon: Icons.refresh_rounded,
            onPressed: _processImage,
            color: AppColors.primary,
          ),
          const SizedBox(height: 12),
          CustomButton(
            label: 'Retake Photo',
            icon: Icons.camera_alt_outlined,
            variant: ButtonVariant.outlined,
            onPressed: _retake,
            color: AppColors.cameraControl,
          ),
        ],
      ),
    );
  }

  Widget _buildPreviewState() {
    final path = _displayPath;
    return Column(
      children: [
        Expanded(
          child: Stack(
            fit: StackFit.expand,
            children: [
              if (path != null)
                InteractiveViewer(
                  child: Image.file(
                    File(path),
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) => const Center(
                      child: Icon(Icons.broken_image_outlined,
                          color: AppColors.textHint, size: 64),
                    ),
                  ),
                ),
              Positioned(
                top: 16,
                left: 16,
                right: 16,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: AppColors.cameraOverlay,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _showOriginal
                        ? 'Original photo (background not removed)'
                        : 'AI removed the background. Review the result before saving.',
                    style: AppTextStyles.small.copyWith(color: AppColors.cameraControl),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (_processedImagePath != null)
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ChoiceChip(
                  label: const Text('Processed'),
                  selected: !_showOriginal,
                  onSelected: (_) => setState(() => _showOriginal = false),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Original'),
                  selected: _showOriginal,
                  onSelected: (_) => setState(() => _showOriginal = true),
                ),
              ],
            ),
          ),
      ],
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
          Expanded(
            child: CustomButton(
              label: 'Retake',
              icon: Icons.refresh_rounded,
              variant: ButtonVariant.outlined,
              onPressed: _retake,
              color: AppColors.cameraControl,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: CustomButton(
              label: 'Confirm',
              icon: Icons.check_circle_outline_rounded,
              onPressed: _confirm,
              color: AppColors.primary,
            ),
          ),
        ],
      ),
    );
  }
}

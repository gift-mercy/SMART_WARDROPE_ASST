import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Full-screen or inline loading indicator.
///
/// ```dart
/// // Full-screen overlay
/// LoadingWidget()
///
/// // Inline with custom message
/// LoadingWidget(message: 'Processing image…', fullScreen: false)
/// ```
class LoadingWidget extends StatelessWidget {
  final String? message;
  final bool fullScreen;
  final Color? color;

  const LoadingWidget({
    super.key,
    this.message,
    this.fullScreen = true,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final indicator = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(
            color ?? AppColors.primary,
          ),
          strokeWidth: 3,
        ),
        if (message != null) ...[
          const SizedBox(height: 16),
          Text(
            message!,
            style: AppTextStyles.small,
            textAlign: TextAlign.center,
          ),
        ],
      ],
    );

    if (!fullScreen) {
      return Center(child: Padding(padding: const EdgeInsets.all(24), child: indicator));
    }

    return Container(
      color: AppColors.background,
      child: Center(child: indicator),
    );
  }
}

/// Transparent overlay spinner — useful over camera preview or images.
class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;
  final String? message;

  const LoadingOverlay({
    super.key,
    required this.isLoading,
    required this.child,
    this.message,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: AppColors.overlay,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(AppColors.cameraControl),
                    strokeWidth: 3,
                  ),
                  if (message != null) ...[
                    const SizedBox(height: 16),
                    Text(
                      message!,
                      style: AppTextStyles.small.copyWith(
                        color: AppColors.cameraControl,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
      ],
    );
  }
}

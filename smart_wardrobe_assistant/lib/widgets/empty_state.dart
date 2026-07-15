import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';
import 'custom_button.dart';

/// Generic empty / error state widget used across lists and screens.
///
/// ```dart
/// EmptyState(
///   icon: Icons.photo_library_outlined,
///   title: 'No photos yet',
///   subtitle: 'Pick an image from your gallery to get started.',
///   actionLabel: 'Open Gallery',
///   onAction: _openGallery,
/// )
/// ```
class EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Color? iconColor;

  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    this.subtitle,
    this.actionLabel,
    this.onAction,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Icon container
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: (iconColor ?? AppColors.primary).withValues(alpha: 0.08),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                size: 40,
                color: iconColor ?? AppColors.primary,
              ),
            ),

            const SizedBox(height: 20),

            Text(
              title,
              style: AppTextStyles.subheading,
              textAlign: TextAlign.center,
            ),

            if (subtitle != null) ...[
              const SizedBox(height: 8),
              Text(
                subtitle!,
                style: AppTextStyles.bodySecondary,
                textAlign: TextAlign.center,
              ),
            ],

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 28),
              CustomButton(
                label: actionLabel!,
                onPressed: onAction,
                fullWidth: false,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

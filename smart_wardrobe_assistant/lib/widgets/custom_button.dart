import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Variant controls the visual style of [CustomButton].
enum ButtonVariant { filled, outlined, text }

/// A themed button used throughout the app.
///
/// ```dart
/// CustomButton(label: 'Save', onPressed: _save)
/// CustomButton(label: 'Cancel', variant: ButtonVariant.outlined, onPressed: _cancel)
/// ```
class CustomButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final ButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final Color? color;
  final double? height;

  const CustomButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.variant = ButtonVariant.filled,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.color,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveColor = color ?? AppColors.primary;
    final effectiveHeight = height ?? 52.0;

    Widget child = isLoading
        ? const SizedBox(
            width: 22,
            height: 22,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(AppColors.textOnPrimary),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (icon != null) ...[
                Icon(icon, size: 18),
                const SizedBox(width: 8),
              ],
              Text(label, style: AppTextStyles.button),
            ],
          );

    Widget button;
    switch (variant) {
      case ButtonVariant.filled:
        button = ElevatedButton(
          onPressed: isLoading ? null : onPressed,
          style: ElevatedButton.styleFrom(
            backgroundColor: effectiveColor,
            foregroundColor: AppColors.textOnPrimary,
            disabledBackgroundColor: effectiveColor.withValues(alpha: 0.5),
            minimumSize: Size(fullWidth ? double.infinity : 0, effectiveHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            elevation: 0,
          ),
          child: child,
        );
        break;

      case ButtonVariant.outlined:
        button = OutlinedButton(
          onPressed: isLoading ? null : onPressed,
          style: OutlinedButton.styleFrom(
            foregroundColor: effectiveColor,
            side: BorderSide(color: effectiveColor, width: 1.5),
            minimumSize: Size(fullWidth ? double.infinity : 0, effectiveHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: DefaultTextStyle(
            style: AppTextStyles.button.copyWith(color: effectiveColor),
            child: child,
          ),
        );
        break;

      case ButtonVariant.text:
        button = TextButton(
          onPressed: isLoading ? null : onPressed,
          style: TextButton.styleFrom(
            foregroundColor: effectiveColor,
            minimumSize: Size(fullWidth ? double.infinity : 0, effectiveHeight),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: DefaultTextStyle(
            style: AppTextStyles.button.copyWith(color: effectiveColor),
            child: child,
          ),
        );
        break;
    }

    return button;
  }
}

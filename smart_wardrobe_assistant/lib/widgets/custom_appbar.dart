import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_text_styles.dart';

/// Themed [AppBar] used on every screen.
///
/// ```dart
/// CustomAppBar(title: 'Camera')
/// CustomAppBar(title: 'Preview', actions: [IconButton(...)])
/// ```
class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool showBack;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final double elevation;
  final VoidCallback? onBack;
  final PreferredSizeWidget? bottom;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.showBack = true,
    this.backgroundColor,
    this.foregroundColor,
    this.elevation = 0,
    this.onBack,
    this.bottom,
  });

  @override
  Size get preferredSize => Size.fromHeight(
        kToolbarHeight + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final bgColor = backgroundColor ?? AppColors.primary;
    final fgColor = foregroundColor ?? AppColors.textOnPrimary;

    return AppBar(
      title: Text(title, style: AppTextStyles.appBarTitle.copyWith(color: fgColor)),
      centerTitle: false,
      backgroundColor: bgColor,
      foregroundColor: fgColor,
      elevation: elevation,
      scrolledUnderElevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: bgColor,
        statusBarIconBrightness:
            bgColor == AppColors.primary ? Brightness.light : Brightness.dark,
      ),
      leading: leading ??
          (showBack && Navigator.of(context).canPop()
              ? IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20),
                  onPressed: onBack ?? () => Navigator.of(context).pop(),
                  tooltip: 'Back',
                )
              : null),
      actions: actions,
      bottom: bottom,
    );
  }
}

import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';

/// A themed destination used until its feature receives persisted content.
class FeaturePlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;
  final String message;

  const FeaturePlaceholderScreen({super.key, required this.title, required this.icon, required this.message});

  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(title: Text(title)),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              Icon(icon, size: 56, color: AppColors.primary),
              const SizedBox(height: 18),
              Text(message, textAlign: TextAlign.center, style: Theme.of(context).textTheme.bodyLarge),
            ]),
          ),
        ),
      );
}

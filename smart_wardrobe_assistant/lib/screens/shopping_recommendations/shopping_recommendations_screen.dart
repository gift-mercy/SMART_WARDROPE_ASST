// ============================================
// SHOPPING_RECOMMENDATIONS_SCREEN.DART
// ============================================
// Main screen for shopping recommendations feature
//
// Purpose:
// - Display wardrobe analysis summary
// - Show missing clothing item recommendations
// - Handle loading, error, and empty states
// - Allow detail view of recommendations
// ============================================

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/shopping_recommendation_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/shopping_recommendation_model.dart';
import '../../widgets/shopping_recommendation_card.dart';
import '../../core/constants/app_colors.dart';

class ShoppingRecommendationsScreen extends StatefulWidget {
  const ShoppingRecommendationsScreen({super.key});

  @override
  State<ShoppingRecommendationsScreen> createState() =>
      _ShoppingRecommendationsScreenState();
}

class _ShoppingRecommendationsScreenState
    extends State<ShoppingRecommendationsScreen> {
  @override
  void initState() {
    super.initState();
    // Initialize recommendations when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = context.read<AuthProvider>();
      if (authProvider.isAuthenticated && authProvider.currentUser != null) {
        context
            .read<ShoppingRecommendationProvider>()
            .setUserId(authProvider.currentUser!.userId);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Shopping Recommendations'),
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textOnPrimary,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              context
                  .read<ShoppingRecommendationProvider>()
                  .refreshRecommendations();
            },
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Consumer<ShoppingRecommendationProvider>(
        builder: (context, provider, child) {
          // Loading state
          if (provider.isLoading) {
            return _buildLoadingState();
          }

          // Error state
          if (provider.errorMessage != null) {
            return _buildErrorState(provider.errorMessage!, provider);
          }

          // Empty wardrobe state
          if (provider.isWardrobeEmpty) {
            return _buildEmptyWardrobeState();
          }

          // Success state with recommendations
          return RefreshIndicator(
            onRefresh: () => provider.refreshRecommendations(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Summary card
                  _buildSummaryCard(provider),

                  const SizedBox(height: 24),

                  // Recommendations header
                  _buildRecommendationsHeader(provider),

                  const SizedBox(height: 16),

                  // Recommendations list
                  if (provider.hasRecommendations)
                    _buildRecommendationsList(provider)
                  else
                    _buildNoRecommendationsState(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  // ============================================
  // STATE WIDGETS
  // ============================================

  /// Loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppColors.primary),
          ),
          SizedBox(height: 16),
          Text(
            'Analyzing your wardrobe...',
            style: TextStyle(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Error state
  Widget _buildErrorState(
      String errorMessage, ShoppingRecommendationProvider provider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: AppColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Unable to generate shopping recommendations',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              errorMessage,
              style: const TextStyle(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                provider.refreshRecommendations();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Empty wardrobe state
  Widget _buildEmptyWardrobeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.checkroom_outlined,
              size: 80,
              color: AppColors.textHint,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your wardrobe is empty',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'Add some clothing items first so we can identify what your wardrobe may be missing.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pushNamed('/wardrobe');
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: AppColors.textOnPrimary,
                padding:
                    const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              ),
              child: const Text(
                'Go to Wardrobe',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// No recommendations state (wardrobe is complete)
  Widget _buildNoRecommendationsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          children: [
            Icon(
              Icons.check_circle_outline,
              size: 80,
              color: AppColors.success,
            ),
            const SizedBox(height: 24),
            const Text(
              'Your wardrobe looks complete!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            const Text(
              'We couldn\'t find any essential items missing from your wardrobe.',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================
  // CONTENT WIDGETS
  // ============================================

  /// Summary card
  Widget _buildSummaryCard(ShoppingRecommendationProvider provider) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: AppColors.border),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20.0),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.secondary.withOpacity(0.1),
              AppColors.secondary.withOpacity(0.05),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.secondary,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.shopping_bag,
                    size: 28,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Complete Your Wardrobe',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Based on ${provider.wardrobeItemCount} items',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            const Divider(color: AppColors.divider),
            const SizedBox(height: 16),
            const Text(
              'Here are some items that could make your wardrobe more complete:',
              style: TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            if (provider.hasRecommendations) ...[
              const SizedBox(height: 16),
              Row(
                children: [
                  _buildPriorityBadge(
                    'High Priority',
                    provider.highPriorityCount,
                    const Color(0xFFEF4444),
                  ),
                  const SizedBox(width: 12),
                  _buildPriorityBadge(
                    'Recommended',
                    provider.recommendedCount,
                    const Color(0xFFF59E0B),
                  ),
                  const SizedBox(width: 12),
                  _buildPriorityBadge(
                    'Optional',
                    provider.optionalCount,
                    const Color(0xFF10B981),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Priority badge
  Widget _buildPriorityBadge(String label, int count, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            count.toString(),
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  /// Recommendations header
  Widget _buildRecommendationsHeader(ShoppingRecommendationProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        const Text(
          'Recommended Items',
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        Text(
          '${provider.recommendations.length} items',
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Recommendations list
  Widget _buildRecommendationsList(ShoppingRecommendationProvider provider) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: provider.recommendations.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final recommendation = provider.recommendations[index];
        return ShoppingRecommendationCard(
          recommendation: recommendation,
          onTap: () {
            _showRecommendationDetail(context, recommendation);
          },
        );
      },
    );
  }

  // ============================================
  // DETAIL VIEW
  // ============================================

  /// Shows detailed information about a recommendation
  void _showRecommendationDetail(
    BuildContext context,
    ShoppingRecommendation recommendation,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                // Handle bar
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppColors.divider,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Item name
                Text(
                  recommendation.name,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 8),

                // Category
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    recommendation.category,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.secondary,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Why useful section
                const Text(
                  'Why this item?',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  recommendation.description,
                  style: const TextStyle(
                    fontSize: 15,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),

                // Suggested colors
                if (recommendation.suggestedColors.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Suggested Colors',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recommendation.suggestedColors
                        .map((color) => Chip(
                              label: Text(color),
                              backgroundColor:
                                  AppColors.primary.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.primary,
                              ),
                            ))
                        .toList(),
                  ),
                ],

                // Suggested occasions
                if (recommendation.suggestedOccasions.isNotEmpty) ...[
                  const SizedBox(height: 24),
                  const Text(
                    'Useful For',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: recommendation.suggestedOccasions
                        .map((occasion) => Chip(
                              label: Text(occasion),
                              backgroundColor:
                                  AppColors.secondary.withOpacity(0.1),
                              labelStyle: const TextStyle(
                                fontSize: 14,
                                color: AppColors.secondary,
                              ),
                            ))
                        .toList(),
                  ),
                ],

                const SizedBox(height: 32),

                // Close button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () => Navigator.pop(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: AppColors.textOnPrimary,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                    ),
                    child: const Text(
                      'Got it',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

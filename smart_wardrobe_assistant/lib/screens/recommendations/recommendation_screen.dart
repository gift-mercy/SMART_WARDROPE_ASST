// ============================================
// RECOMMENDATION_SCREEN.DART
// ============================================
// Screen for displaying outfit recommendations
//
// Purpose:
// - Show recommended outfit based on weather
// - Display weather information
// - Explain recommendation reasoning
// - Allow user to view clothing details
// ============================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../providers/recommendation_provider.dart';
import '../../providers/weather_provider.dart';
import '../../providers/wardrobe_provider.dart';
import '../../providers/auth_provider.dart';
import '../../models/clothing_item.dart';

/// RecommendationScreen
/// Displays personalized outfit recommendations based on weather
class RecommendationScreen extends StatefulWidget {
  const RecommendationScreen({super.key});

  @override
  State<RecommendationScreen> createState() => _RecommendationScreenState();
}

class _RecommendationScreenState extends State<RecommendationScreen> {
  @override
  void initState() {
    super.initState();
    _initializeRecommendation();
  }

  /// Initialize recommendation by loading weather and wardrobe data
  Future<void> _initializeRecommendation() async {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final wardrobeProvider = Provider.of<WardrobeProvider>(context, listen: false);
    final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);

    // Set user ID for wardrobe
    final userId = authProvider.currentUser?.userId;
    if (userId != null) {
      await wardrobeProvider.setUserId(userId);
    }

    // Initialize weather if not already loaded
    if (!weatherProvider.hasData) {
      await weatherProvider.initializeWeather();
    }

    // Generate recommendation
    if (weatherProvider.hasData && wardrobeProvider.clothingItems.isNotEmpty) {
      await recommendationProvider.generateRecommendation(
        weather: weatherProvider.weather!,
        clothingItems: wardrobeProvider.clothingItems,
      );
    } else if (wardrobeProvider.clothingItems.isEmpty) {
      // Handle empty wardrobe
      recommendationProvider.clearRecommendation();
    }
  }

  /// Refresh recommendation
  Future<void> _refreshRecommendation() async {
    final weatherProvider = Provider.of<WeatherProvider>(context, listen: false);
    final wardrobeProvider = Provider.of<WardrobeProvider>(context, listen: false);
    final recommendationProvider = Provider.of<RecommendationProvider>(context, listen: false);

    // Refresh weather
    await weatherProvider.refreshWeather();

    // Refresh wardrobe
    await wardrobeProvider.refreshWardrobe();

    // Generate new recommendation
    if (weatherProvider.hasData) {
      await recommendationProvider.generateRecommendation(
        weather: weatherProvider.weather!,
        clothingItems: wardrobeProvider.clothingItems,
      );
    }
  }

  /// Navigate to clothing details
  void _navigateToClothingDetails(ClothingItem item) {
    Navigator.pushNamed(
      context,
      '/clothing-details',
      arguments: item,
    );
  }

  /// Format current date
  String _formatCurrentDate() {
    return DateFormat('EEEE, d MMMM yyyy').format(DateTime.now());
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
        title: Text(
          'Recommendations',
          style: GoogleFonts.poppins(
            fontSize: 24,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),
        actions: [
          // Refresh Button
          IconButton(
            icon: const Icon(
              Icons.refresh,
              color: AppColors.primary,
            ),
            onPressed: _refreshRecommendation,
            tooltip: 'Refresh Recommendation',
          ),
          const SizedBox(width: 8),
        ],
      ),

      // ============================================
      // BODY
      // ============================================
      body: RefreshIndicator(
        onRefresh: _refreshRecommendation,
        color: AppColors.primary,
        child: Consumer3<RecommendationProvider, WeatherProvider, WardrobeProvider>(
          builder: (context, recommendationProvider, weatherProvider, wardrobeProvider, child) {
            // ============================================
            // LOADING STATE
            // ============================================
            if (recommendationProvider.isLoading || weatherProvider.isLoading) {
              return _buildLoadingState();
            }

            // ============================================
            // WEATHER ERROR STATE
            // ============================================
            if (weatherProvider.hasError) {
              return _buildWeatherErrorState(weatherProvider);
            }

            // ============================================
            // EMPTY WARDROBE STATE
            // ============================================
            if (wardrobeProvider.clothingItems.isEmpty) {
              return _buildEmptyWardrobeState();
            }

            // ============================================
            // RECOMMENDATION ERROR STATE
            // ============================================
            if (recommendationProvider.hasError) {
              return _buildRecommendationErrorState(recommendationProvider);
            }

            // ============================================
            // MAIN CONTENT
            // ============================================
            return SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Page Header
                    _buildPageHeader(),

                    const SizedBox(height: 24),

                    // Weather Section
                    if (weatherProvider.hasData)
                      _buildWeatherSection(weatherProvider.weather!),

                    const SizedBox(height: 24),

                    // Recommended Outfit Section
                    if (recommendationProvider.hasRecommendation)
                      _buildRecommendedOutfit(recommendationProvider.recommendation!),

                    const SizedBox(height: 24),

                    // Recommendation Explanation
                    if (recommendationProvider.hasRecommendation)
                      _buildRecommendationExplanation(recommendationProvider.recommendation!),

                    const SizedBox(height: 32),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  /// Build page header
  Widget _buildPageHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Today\'s Recommendation',
          style: GoogleFonts.poppins(
            fontSize: 28,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          _formatCurrentDate(),
          style: GoogleFonts.poppins(
            fontSize: 16,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build weather section
  Widget _buildWeatherSection(weather) {
    return Card(
      elevation: 2,
      shadowColor: AppColors.shadow,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.secondary,
              AppColors.secondaryDark,
            ],
          ),
        ),
        child: Row(
          children: [
            // Weather Icon
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  weather.weatherEmoji,
                  style: const TextStyle(fontSize: 40),
                ),
              ),
            ),

            const SizedBox(width: 20),

            // Weather Info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    weather.cityName,
                    style: GoogleFonts.poppins(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${weather.temperature.round()}°C',
                    style: GoogleFonts.poppins(
                      fontSize: 36,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    weather.condition,
                    style: GoogleFonts.poppins(
                      fontSize: 16,
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build recommended outfit section
  Widget _buildRecommendedOutfit(recommendation) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Title
        Text(
          'Recommended Outfit',
          style: GoogleFonts.poppins(
            fontSize: 22,
            fontWeight: FontWeight.w600,
            color: AppColors.textPrimary,
          ),
        ),

        const SizedBox(height: 16),

        // Outfit Items Grid
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.75,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
          ),
          itemCount: recommendation.outfitItems.length,
          itemBuilder: (context, index) {
            final item = recommendation.outfitItems[index];
            return _buildClothingItemCard(item);
          },
        ),
      ],
    );
  }

  /// Build clothing item card
  Widget _buildClothingItemCard(ClothingItem item) {
    return GestureDetector(
      onTap: () => _navigateToClothingDetails(item),
      child: Card(
        elevation: 2,
        shadowColor: AppColors.shadow,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Image
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                child: _buildClothingImage(item),
              ),
            ),

            // Item Info
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.clothingName,
                    style: GoogleFonts.poppins(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    item.categoryName ?? 'Clothing',
                    style: GoogleFonts.poppins(
                      fontSize: 12,
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build clothing image
  Widget _buildClothingImage(ClothingItem item) {
    final imageFile = File(item.imagePath);

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
        child: Icon(
          Icons.checkroom,
          size: 48,
          color: AppColors.primary.withOpacity(0.3),
        ),
      ),
    );
  }

  /// Build recommendation explanation
  Widget _buildRecommendationExplanation(recommendation) {
    return Card(
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
            Row(
              children: [
                Icon(
                  Icons.lightbulb_outline,
                  color: AppColors.primary,
                  size: 24,
                ),
                const SizedBox(width: 8),
                Text(
                  'Why this outfit?',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              recommendation.explanation,
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            color: AppColors.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Generating your outfit...',
            style: GoogleFonts.poppins(
              fontSize: 16,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  /// Build weather error state
  Widget _buildWeatherErrorState(WeatherProvider weatherProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.cloud_off,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to load weather',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              weatherProvider.errorMessage ?? 'Please check your connection',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshRecommendation,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty wardrobe state
  Widget _buildEmptyWardrobeState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.checkroom,
                size: 64,
                color: AppColors.primary,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Your wardrobe is empty',
              style: GoogleFonts.poppins(
                fontSize: 22,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              'Add some clothing items to receive outfit recommendations.',
              style: GoogleFonts.poppins(
                fontSize: 16,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 32),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pushNamed(context, '/wardrobe');
              },
              icon: const Icon(Icons.add),
              label: Text(
                'Go to Wardrobe',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build recommendation error state
  Widget _buildRecommendationErrorState(RecommendationProvider recommendationProvider) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Color(0xFFFEE2E2),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline,
                size: 48,
                color: AppColors.error,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Unable to generate recommendation',
              style: GoogleFonts.poppins(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              recommendationProvider.errorMessage ?? 'Please try again',
              style: GoogleFonts.poppins(
                fontSize: 14,
                color: AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _refreshRecommendation,
              icon: const Icon(Icons.refresh),
              label: Text(
                'Try Again',
                style: GoogleFonts.poppins(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================
// SEED_DATA.DART
// ============================================
// This file contains initial seed data for lookup tables.
// Seed data is inserted during the first database creation.
//
// Purpose:
// - Populate lookup tables with predefined values
// - Ensure consistent reference data across all users
// - Simplify user experience by providing ready-to-use options
// ============================================

import 'package:sqflite/sqflite.dart';
import 'tables.dart';

/// SeedData class handles insertion of initial data into lookup tables
class SeedData {
  // Prevent instantiation
  SeedData._();

  /// ============================================
  /// INSERT ALL SEED DATA
  /// ============================================
  /// Main method to insert all seed data into the database
  /// This should be called only during initial database creation
  ///
  /// Parameters:
  /// - db: Database instance
  ///
  /// Returns a `Future<void>`.
  static Future<void> insertAllSeedData(Database db) async {
    // Use a transaction to ensure all seed data is inserted atomically
    // If any insert fails, all changes will be rolled back
    await db.transaction((txn) async {
      await _insertCategories(txn);
      await _insertColors(txn);
      await _insertSeasons(txn);
      await _insertOccasions(txn);
    });
  }

  /// ============================================
  /// INSERT CATEGORIES
  /// ============================================
  /// Inserts predefined clothing categories
  /// Categories include common clothing types like T-Shirt, Jeans, etc.
  static Future<void> _insertCategories(Transaction txn) async {
    final categories = [
      'T-Shirt',
      'Shirt',
      'Trouser',
      'Jeans',
      'Dress',
      'Skirt',
      'Jacket',
      'Coat',
      'Sweater',
      'Hoodie',
      'Shorts',
      'Shoes',
      'Sneakers',
      'Sandals',
      'Boots',
      'Cap',
      'Suit',
      'Blazer',
    ];

    // Insert each category into the database
    for (String category in categories) {
      await txn.insert(
        TableNames.categories,
        {'category_name': category},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// ============================================
  /// INSERT COLORS
  /// ============================================
  /// Inserts predefined color options
  /// Colors include basic and common clothing colors
  static Future<void> _insertColors(Transaction txn) async {
    final colors = [
      'Black',
      'White',
      'Blue',
      'Red',
      'Green',
      'Yellow',
      'Brown',
      'Grey',
      'Pink',
      'Purple',
      'Orange',
      'Beige',
    ];

    // Insert each color into the database
    for (String color in colors) {
      await txn.insert(
        TableNames.colors,
        {'color_name': color},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// ============================================
  /// INSERT SEASONS
  /// ============================================
  /// Inserts predefined season options
  /// Seasons help users categorize clothing for different weather
  static Future<void> _insertSeasons(Transaction txn) async {
    final seasons = [
      'Summer',
      'Winter',
      'Rainy',
      'Spring',
      'Autumn',
      'All Seasons',
    ];

    // Insert each season into the database
    for (String season in seasons) {
      await txn.insert(
        TableNames.seasons,
        {'season_name': season},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// ============================================
  /// INSERT OCCASIONS
  /// ============================================
  /// Inserts predefined occasion types
  /// Occasions help users categorize clothing for different events
  static Future<void> _insertOccasions(Transaction txn) async {
    final occasions = [
      'Casual',
      'Office',
      'Formal',
      'Sports',
      'Wedding',
      'Party',
      'Travel',
      'Home',
    ];

    // Insert each occasion into the database
    for (String occasion in occasions) {
      await txn.insert(
        TableNames.occasions,
        {'occasion_name': occasion},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
    }
  }

  /// ============================================
  /// OPTIONAL: GET SEED DATA COUNTS
  /// ============================================
  /// Helper method to verify seed data was inserted correctly
  /// Returns a map with counts for each lookup table
  ///
  /// Usage example:
  /// ```dart
  /// final counts = await SeedData.getSeedDataCounts(db);
  /// print('Categories: ${counts['categories']}');
  /// ```
  static Future<Map<String, int>> getSeedDataCounts(Database db) async {
    final categoriesCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.categories}'),
    );
    final colorsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.colors}'),
    );
    final seasonsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.seasons}'),
    );
    final occasionsCount = Sqflite.firstIntValue(
      await db.rawQuery('SELECT COUNT(*) FROM ${TableNames.occasions}'),
    );

    return {
      'categories': categoriesCount ?? 0,
      'colors': colorsCount ?? 0,
      'seasons': seasonsCount ?? 0,
      'occasions': occasionsCount ?? 0,
    };
  }
}

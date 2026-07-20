// ============================================
// TABLES.DART
// ============================================
// This file contains all table names and SQL CREATE TABLE statements
// for the Smart Wardrobe Assistant database.
//
// Purpose:
// - Centralize all table definitions
// - Maintain consistency across the app
// - Make schema changes easier to manage
// ============================================

/// Database table names as constants
/// Using constants prevents typos and makes refactoring easier
class TableNames {
  // Prevent instantiation
  TableNames._();

  static const String users = 'users';
  static const String categories = 'categories';
  static const String colors = 'colors';
  static const String seasons = 'seasons';
  static const String occasions = 'occasions';
  static const String clothingItems = 'clothing_items';
  static const String outfitHistory = 'outfit_history';
  static const String aiRecommendations = 'ai_recommendations';
  static const String shoppingRecommendations = 'shopping_recommendations';
  static const String weatherCache = 'weather_cache';
  static const String manualCalendarEvents = 'manual_calendar_events';
}

/// Database table creation SQL statements
/// Each constant contains the CREATE TABLE statement for a specific table
class TableSchemas {
  // Prevent instantiation
  TableSchemas._();

  /// ============================================
  /// USERS TABLE
  /// ============================================
  /// Stores user account information
  /// - user_id: Primary key, auto-incremented
  /// - full_name: User's full name (required)
  /// - email: Unique email address (required)
  /// - password: Hashed password (required)
  /// - gender: Optional gender information
  /// - profile_picture: Path to profile image file
  /// - created_at: Timestamp of account creation
  static const String users = '''
    CREATE TABLE ${TableNames.users} (
      user_id INTEGER PRIMARY KEY AUTOINCREMENT,
      full_name TEXT NOT NULL,
      email TEXT UNIQUE NOT NULL,
      password TEXT NOT NULL,
      gender TEXT,
      profile_picture TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP
    )
  ''';

  /// ============================================
  /// CATEGORIES TABLE
  /// ============================================
  /// Stores clothing category types
  /// - category_id: Primary key, auto-incremented
  /// - category_name: Unique category name (e.g., 'T-Shirt', 'Jeans')
  static const String categories = '''
    CREATE TABLE ${TableNames.categories} (
      category_id INTEGER PRIMARY KEY AUTOINCREMENT,
      category_name TEXT NOT NULL UNIQUE
    )
  ''';

  /// ============================================
  /// COLORS TABLE
  /// ============================================
  /// Stores available color options
  /// - color_id: Primary key, auto-incremented
  /// - color_name: Unique color name (e.g., 'Black', 'Blue')
  static const String colors = '''
    CREATE TABLE ${TableNames.colors} (
      color_id INTEGER PRIMARY KEY AUTOINCREMENT,
      color_name TEXT NOT NULL UNIQUE
    )
  ''';

  /// ============================================
  /// SEASONS TABLE
  /// ============================================
  /// Stores season types for clothing items
  /// - season_id: Primary key, auto-incremented
  /// - season_name: Unique season name (e.g., 'Summer', 'Winter')
  static const String seasons = '''
    CREATE TABLE ${TableNames.seasons} (
      season_id INTEGER PRIMARY KEY AUTOINCREMENT,
      season_name TEXT NOT NULL UNIQUE
    )
  ''';

  /// ============================================
  /// OCCASIONS TABLE
  /// ============================================
  /// Stores occasion types for clothing items
  /// - occasion_id: Primary key, auto-incremented
  /// - occasion_name: Unique occasion name (e.g., 'Casual', 'Formal')
  static const String occasions = '''
    CREATE TABLE ${TableNames.occasions} (
      occasion_id INTEGER PRIMARY KEY AUTOINCREMENT,
      occasion_name TEXT NOT NULL UNIQUE
    )
  ''';

  /// ============================================
  /// CLOTHING ITEMS TABLE
  /// ============================================
  /// Stores individual clothing items in user's wardrobe
  /// - clothing_id: Primary key, auto-incremented
  /// - user_id: Foreign key to users table
  /// - category_id: Foreign key to categories table
  /// - color_id: Foreign key to colors table
  /// - season_id: Foreign key to seasons table (optional)
  /// - occasion_id: Foreign key to occasions table (optional)
  /// - clothing_name: Name/description of the item
  /// - image_path: Path to the clothing item image
  /// - notes: Optional notes about the item
  /// - date_added: Timestamp when item was added
  static const String clothingItems = '''
    CREATE TABLE ${TableNames.clothingItems} (
      clothing_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      category_id INTEGER NOT NULL,
      color_id INTEGER NOT NULL,
      season_id INTEGER,
      occasion_id INTEGER,
      clothing_name TEXT NOT NULL,
      image_path TEXT NOT NULL,
      notes TEXT,
      date_added TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES ${TableNames.users}(user_id),
      FOREIGN KEY(category_id) REFERENCES ${TableNames.categories}(category_id),
      FOREIGN KEY(color_id) REFERENCES ${TableNames.colors}(color_id),
      FOREIGN KEY(season_id) REFERENCES ${TableNames.seasons}(season_id),
      FOREIGN KEY(occasion_id) REFERENCES ${TableNames.occasions}(occasion_id)
    )
  ''';

  /// ============================================
  /// OUTFIT HISTORY TABLE
  /// ============================================
  /// Stores history of outfits worn by users
  /// - history_id: Primary key, auto-incremented
  /// - user_id: Foreign key to users table
  /// - outfit_description: Description of the outfit
  /// - date_worn: Date when the outfit was worn
  /// - user_rating: Optional rating given by user (1-5)
  static const String outfitHistory = '''
    CREATE TABLE ${TableNames.outfitHistory} (
      history_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      outfit_description TEXT NOT NULL,
      date_worn TEXT,
      user_rating INTEGER,
      FOREIGN KEY(user_id) REFERENCES ${TableNames.users}(user_id)
    )
  ''';

  /// ============================================
  /// AI RECOMMENDATIONS TABLE
  /// ============================================
  /// Stores AI-generated outfit recommendations
  /// - recommendation_id: Primary key, auto-incremented
  /// - user_id: Foreign key to users table
  /// - recommended_outfit: Description of recommended outfit
  /// - reason: AI explanation for the recommendation
  /// - recommendation_date: Date when recommendation was generated
  static const String aiRecommendations = '''
    CREATE TABLE ${TableNames.aiRecommendations} (
      recommendation_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      recommended_outfit TEXT NOT NULL,
      reason TEXT,
      recommendation_date TEXT,
      FOREIGN KEY(user_id) REFERENCES ${TableNames.users}(user_id)
    )
  ''';

  /// ============================================
  /// SHOPPING RECOMMENDATIONS TABLE
  /// ============================================
  /// Stores AI-generated shopping suggestions
  /// - shopping_id: Primary key, auto-incremented
  /// - user_id: Foreign key to users table
  /// - item_name: Name of recommended item to purchase
  /// - category: Category of the recommended item
  /// - reason: AI explanation for the recommendation
  /// - generated_date: Date when recommendation was generated
  static const String shoppingRecommendations = '''
    CREATE TABLE ${TableNames.shoppingRecommendations} (
      shopping_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      item_name TEXT NOT NULL,
      category TEXT,
      reason TEXT,
      generated_date TEXT,
      FOREIGN KEY(user_id) REFERENCES ${TableNames.users}(user_id)
    )
  ''';

  /// ============================================
  /// WEATHER CACHE TABLE
  /// ============================================
  /// Stores cached weather data to reduce API calls
  /// - weather_id: Primary key, auto-incremented
  /// - city: City name
  /// - temperature: Current temperature
  /// - weather_condition: Description of weather (e.g., 'Sunny', 'Rainy')
  /// - updated_at: Timestamp of last weather data update
  static const String weatherCache = '''
    CREATE TABLE ${TableNames.weatherCache} (
      weather_id INTEGER PRIMARY KEY AUTOINCREMENT,
      city TEXT,
      temperature REAL,
      weather_condition TEXT,
      updated_at TEXT
    )
  ''';

  /// Locally-created schedule items. Device calendar data is never copied into
  /// SQLite; only events explicitly created in the app are stored here.
  static const String manualCalendarEvents = '''
    CREATE TABLE ${TableNames.manualCalendarEvents} (
      event_id INTEGER PRIMARY KEY AUTOINCREMENT,
      user_id INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      start_time TEXT NOT NULL,
      end_time TEXT,
      created_at TEXT DEFAULT CURRENT_TIMESTAMP,
      FOREIGN KEY(user_id) REFERENCES ${TableNames.users}(user_id)
    )
  ''';

  /// ============================================
  /// ALL TABLES LIST
  /// ============================================
  /// Returns a list of all table creation statements
  /// Used during database initialization to create all tables
  static List<String> getAllTables() {
    return [
      users,
      categories,
      colors,
      seasons,
      occasions,
      clothingItems,
      outfitHistory,
      aiRecommendations,
      shoppingRecommendations,
      weatherCache,
      manualCalendarEvents,
    ];
  }
}

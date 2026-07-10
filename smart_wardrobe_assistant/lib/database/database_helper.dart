// ============================================
// DATABASE_HELPER.DART
// ============================================
// This is the main database helper class for the Smart Wardrobe Assistant app.
// It implements the Singleton pattern to ensure only one database connection exists.
//
// Purpose:
// - Initialize and manage SQLite database connection
// - Create database tables on first run
// - Handle database versioning and migrations
// - Provide database access throughout the app
//
// Usage:
// ```dart
// final db = await DatabaseHelper.instance.database;
// await db.insert('users', userData);
// ```
// ============================================

import 'dart:io';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'tables.dart';
import 'seed_data.dart';
import 'migrations.dart';

/// DatabaseHelper class - Singleton pattern
/// Manages the SQLite database for the entire application
class DatabaseHelper {
  // ============================================
  // SINGLETON PATTERN IMPLEMENTATION
  // ============================================

  /// Private constructor prevents external instantiation
  DatabaseHelper._privateConstructor();

  /// Single instance of DatabaseHelper (Singleton)
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  /// Database instance - only initialized once
  static Database? _database;

  /// Database file name
  static const String _databaseName = 'smart_wardrobe.db';

  /// Database version - increment this when schema changes
  static const int _databaseVersion = DatabaseMigrations.currentVersion;

  // ============================================
  // DATABASE GETTER
  // ============================================

  /// Returns the database instance
  /// Initializes the database if it doesn't exist yet
  ///
  /// Usage:
  /// ```dart
  /// final db = await DatabaseHelper.instance.database;
  /// ```
  Future<Database> get database async {
    // If database is already initialized, return it
    if (_database != null) return _database!;

    // Otherwise, initialize the database
    _database = await _initDatabase();
    return _database!;
  }

  // ============================================
  // DATABASE INITIALIZATION
  // ============================================

  /// Initializes the database
  /// - Gets the database path
  /// - Opens/creates the database
  /// - Sets up foreign key constraints
  Future<Database> _initDatabase() async {
    print('Initializing Smart Wardrobe database...');

    // Get the application documents directory
    // This is where we'll store the database file
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    print('Database path: $path');

    // Open the database
    // If it doesn't exist, onCreate will be called
    // If it exists but version is different, onUpgrade will be called
    return await openDatabase(
      path,
      version: _databaseVersion,
      onCreate: _onCreate,
      onUpgrade: _onUpgrade,
      onDowngrade: _onDowngrade,
      onOpen: _onOpen,
    );
  }

  // ============================================
  // DATABASE LIFECYCLE CALLBACKS
  // ============================================

  /// Called when database is opened
  /// Enables foreign key constraints
  Future<void> _onOpen(Database db) async {
    print('Database opened');

    // Enable foreign key constraints
    // This must be done every time the database is opened
    // SQLite disables foreign keys by default for backwards compatibility
    await db.execute('PRAGMA foreign_keys = ON');

    print('Foreign key constraints enabled');
  }

  /// Called when database is created for the first time
  /// - Creates all tables
  /// - Inserts seed data
  Future<void> _onCreate(Database db, int version) async {
    print('Creating database version $version...');

    // Enable foreign key constraints first
    await db.execute('PRAGMA foreign_keys = ON');

    // Create all tables using a transaction
    // If any table creation fails, all changes will be rolled back
    await db.transaction((txn) async {
      // Get all table creation statements
      final tables = TableSchemas.getAllTables();

      // Execute each CREATE TABLE statement
      for (String tableSchema in tables) {
        print('Creating table...');
        await txn.execute(tableSchema);
      }

      print('All tables created successfully');
    });

    // Insert seed data into lookup tables
    print('Inserting seed data...');
    await SeedData.insertAllSeedData(db);
    print('Seed data inserted successfully');

    // Verify seed data was inserted
    final counts = await SeedData.getSeedDataCounts(db);
    print('Seed data verification:');
    print('  - Categories: ${counts['categories']}');
    print('  - Colors: ${counts['colors']}');
    print('  - Seasons: ${counts['seasons']}');
    print('  - Occasions: ${counts['occasions']}');

    print('Database creation completed successfully');
  }

  /// Called when database needs to be upgraded
  /// Handles migrations between versions
  Future<void> _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');

    // Call the migration handler
    await DatabaseMigrations.migrate(db, oldVersion, newVersion);

    print('Database upgrade completed');
  }

  /// Called when database needs to be downgraded
  /// Usually not recommended - may result in data loss
  Future<void> _onDowngrade(Database db, int oldVersion, int newVersion) async {
    print('Warning: Downgrading database from version $oldVersion to $newVersion');

    // Call the downgrade handler
    await DatabaseMigrations.downgrade(db, oldVersion, newVersion);
  }

  // ============================================
  // PUBLIC METHODS
  // ============================================

  /// Initializes the database
  /// Call this method when the app starts
  ///
  /// Usage:
  /// ```dart
  /// await DatabaseHelper.instance.initDatabase();
  /// ```
  Future<Database> initDatabase() async {
    return await database;
  }

  /// Returns the database instance
  /// Alias for the database getter
  ///
  /// Usage:
  /// ```dart
  /// final db = await DatabaseHelper.instance.getDatabase();
  /// ```
  Future<Database> getDatabase() async {
    return await database;
  }

  /// Closes the database connection
  /// Call this when the app is closing (optional)
  /// The database will be automatically reopened if needed
  ///
  /// Usage:
  /// ```dart
  /// await DatabaseHelper.instance.closeDatabase();
  /// ```
  Future<void> closeDatabase() async {
    if (_database != null) {
      await _database!.close();
      _database = null;
      print('Database closed');
    }
  }

  // ============================================
  // DATABASE UTILITIES
  // ============================================

  /// Deletes the entire database file
  /// WARNING: This will erase all user data!
  /// Only use this for testing or when user requests data deletion
  ///
  /// Usage:
  /// ```dart
  /// await DatabaseHelper.instance.deleteDatabase();
  /// ```
  Future<void> deleteDatabase() async {
    print('WARNING: Deleting database...');

    // Close database connection first
    await closeDatabase();

    // Get database path
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, _databaseName);

    // Delete the database file
    await databaseFactory.deleteDatabase(path);

    print('Database deleted');
  }

  /// Gets current database version
  /// Useful for debugging
  Future<int> getDatabaseVersion() async {
    final db = await database;
    return await db.getVersion();
  }

  /// Checks if database is initialized
  bool get isDatabaseInitialized => _database != null;

  /// Gets database file path
  /// Useful for debugging or backup operations
  Future<String> getDatabasePath() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    return join(documentsDirectory.path, _databaseName);
  }

  // ============================================
  // TRANSACTION HELPERS
  // ============================================

  /// Executes multiple database operations in a transaction
  /// If any operation fails, all changes are rolled back
  ///
  /// Usage:
  /// ```dart
  /// await DatabaseHelper.instance.runInTransaction((txn) async {
  ///   await txn.insert('users', userData);
  ///   await txn.insert('clothing_items', clothingData);
  /// });
  /// ```
  Future<T> runInTransaction<T>(
    Future<T> Function(Transaction txn) action,
  ) async {
    final db = await database;
    return await db.transaction(action);
  }

  /// Executes a raw SQL query
  /// Use with caution - prefer using the typed methods when possible
  ///
  /// Usage:
  /// ```dart
  /// final results = await DatabaseHelper.instance.rawQuery(
  ///   'SELECT * FROM users WHERE email = ?',
  ///   ['user@example.com']
  /// );
  /// ```
  Future<List<Map<String, dynamic>>> rawQuery(
    String sql, [
    List<dynamic>? arguments,
  ]) async {
    final db = await database;
    return await db.rawQuery(sql, arguments);
  }

  /// Executes a raw SQL command
  /// Use for operations that don't return data (INSERT, UPDATE, DELETE)
  ///
  /// Usage:
  /// ```dart
  /// await DatabaseHelper.instance.rawExecute(
  ///   'DELETE FROM users WHERE user_id = ?',
  ///   [userId]
  /// );
  /// ```
  Future<int> rawExecute(String sql, [List<dynamic>? arguments]) async {
    final db = await database;
    return await db.rawUpdate(sql, arguments);
  }

  // ============================================
  // DEBUGGING HELPERS
  // ============================================

  /// Prints all tables in the database
  /// Useful for debugging
  Future<void> printDatabaseTables() async {
    final db = await database;
    final tables = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table'",
    );

    print('=== Database Tables ===');
    for (var table in tables) {
      print('  - ${table['name']}');
    }
  }

  /// Prints the schema of a specific table
  /// Useful for debugging
  Future<void> printTableSchema(String tableName) async {
    final db = await database;
    final schema = await db.rawQuery('PRAGMA table_info($tableName)');

    print('=== Schema for $tableName ===');
    for (var column in schema) {
      print('  - ${column['name']} (${column['type']})');
    }
  }

  /// Prints row count for all tables
  /// Useful for debugging
  Future<void> printTableCounts() async {
    final db = await database;
    final tables = [
      TableNames.users,
      TableNames.categories,
      TableNames.colors,
      TableNames.seasons,
      TableNames.occasions,
      TableNames.clothingItems,
      TableNames.outfitHistory,
      TableNames.aiRecommendations,
      TableNames.shoppingRecommendations,
      TableNames.weatherCache,
    ];

    print('=== Table Row Counts ===');
    for (String table in tables) {
      final count = Sqflite.firstIntValue(
        await db.rawQuery('SELECT COUNT(*) FROM $table'),
      );
      print('  - $table: $count');
    }
  }
}

// ============================================
// MIGRATIONS.DART
// ============================================
// This file handles database schema migrations between versions.
//
// Purpose:
// - Manage database schema changes across app updates
// - Preserve existing user data during upgrades
// - Provide a clear migration path for future schema changes
//
// How to use:
// When you need to change the database schema in a future version:
// 1. Increment the database version number
// 2. Add a new migration case in the migrate() method
// 3. Write SQL statements to alter the schema
// ============================================

import 'package:sqflite/sqflite.dart';

/// DatabaseMigrations class handles all database version migrations
class DatabaseMigrations {
  // Prevent instantiation
  DatabaseMigrations._();

  /// Current database version
  /// Increment this number whenever you make schema changes
  static const int currentVersion = 2;

  /// ============================================
  /// MIGRATE DATABASE
  /// ============================================
  /// Performs database migration from oldVersion to newVersion
  /// Called automatically by sqflite when database version changes
  ///
  /// Parameters:
  /// - db: Database instance
  /// - oldVersion: Previous database version
  /// - newVersion: New database version
  ///
  /// Example migration structure:
  /// ```dart
  /// if (oldVersion < 2) {
  ///   // Migration from v1 to v2
  ///   await _migrateToV2(db);
  /// }
  /// if (oldVersion < 3) {
  ///   // Migration from v2 to v3
  ///   await _migrateToV3(db);
  /// }
  /// ```
  static Future<void> migrate(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print('Migrating database from version $oldVersion to $newVersion');

    if (oldVersion < 2) {
      await db.execute('''
        CREATE TABLE manual_calendar_events (
          event_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          title TEXT NOT NULL,
          description TEXT,
          start_time TEXT NOT NULL,
          end_time TEXT,
          created_at TEXT DEFAULT CURRENT_TIMESTAMP,
          FOREIGN KEY(user_id) REFERENCES users(user_id)
        )
      ''');
    }

    // Example: If you need to migrate from version 2 to version 3
    /*
    if (oldVersion < 3) {
      await _migrateToV3(db);
    }
    */

    // Add more migration blocks as needed for future versions
    // Always use incremental checks (oldVersion < X) to ensure
    // users can upgrade from any previous version
  }

  /// ============================================
  /// EXAMPLE MIGRATION: V1 -> V2
  /// ============================================
  /// This is an example of how to write a migration
  /// Uncomment and modify when you need to release version 2
  ///
  /// Example scenarios:
  /// - Adding a new column to an existing table
  /// - Creating a new table
  /// - Modifying constraints
  /*
  static Future<void> _migrateToV2(Database db) async {
    print('Running migration to version 2');
    
    await db.transaction((txn) async {
      // Example: Add a new column to users table
      await txn.execute('''
        ALTER TABLE users 
        ADD COLUMN phone_number TEXT
      ''');
      
      // Example: Create a new table
      await txn.execute('''
        CREATE TABLE user_preferences (
          preference_id INTEGER PRIMARY KEY AUTOINCREMENT,
          user_id INTEGER NOT NULL,
          preference_key TEXT NOT NULL,
          preference_value TEXT,
          FOREIGN KEY(user_id) REFERENCES users(user_id)
        )
      ''');
      
      print('Migration to version 2 completed successfully');
    });
  }
  */

  /// ============================================
  /// EXAMPLE MIGRATION: V2 -> V3
  /// ============================================
  /// This is another example migration
  /// Uncomment and modify when you need to release version 3
  /*
  static Future<void> _migrateToV3(Database db) async {
    print('Running migration to version 3');
    
    await db.transaction((txn) async {
      // Example: Add an index for better query performance
      await txn.execute('''
        CREATE INDEX idx_clothing_items_user_id 
        ON clothing_items(user_id)
      ''');
      
      // Example: Add a new column with a default value
      await txn.execute('''
        ALTER TABLE clothing_items 
        ADD COLUMN is_favorite INTEGER DEFAULT 0
      ''');
      
      print('Migration to version 3 completed successfully');
    });
  }
  */

  /// ============================================
  /// DOWNGRADE DATABASE (Optional)
  /// ============================================
  /// Handles database downgrades (usually not recommended)
  /// Called when app version is lower than database version
  ///
  /// Warning: Downgrading may result in data loss
  /// It's generally better to prevent downgrades by checking
  /// the app version before allowing the user to proceed
  static Future<void> downgrade(
    Database db,
    int oldVersion,
    int newVersion,
  ) async {
    print('Warning: Attempting to downgrade database from '
        'version $oldVersion to $newVersion');

    // Option 1: Prevent downgrades
    throw Exception(
      'Database downgrade is not supported. '
      'Please update the app to the latest version.',
    );

    // Option 2: Allow downgrades (uncomment if needed)
    // Note: This may cause data loss if newer columns/tables exist
    /*
    print('Allowing database downgrade - data loss may occur');
    */
  }

  /// ============================================
  /// HELPER: CHECK IF COLUMN EXISTS
  /// ============================================
  /// Utility method to check if a column exists in a table
  /// Useful before attempting to add a column during migration
  ///
  /// Parameters:
  /// - db: Database instance
  /// - tableName: Name of the table
  /// - columnName: Name of the column to check
  ///
  /// Returns: true if column exists, false otherwise
  static Future<bool> columnExists(
    Database db,
    String tableName,
    String columnName,
  ) async {
    final result = await db.rawQuery('PRAGMA table_info($tableName)');
    return result.any((column) => column['name'] == columnName);
  }

  /// ============================================
  /// HELPER: CHECK IF TABLE EXISTS
  /// ============================================
  /// Utility method to check if a table exists in the database
  /// Useful before attempting to create a table during migration
  ///
  /// Parameters:
  /// - db: Database instance
  /// - tableName: Name of the table to check
  ///
  /// Returns: true if table exists, false otherwise
  static Future<bool> tableExists(Database db, String tableName) async {
    final result = await db.rawQuery(
      "SELECT name FROM sqlite_master WHERE type='table' AND name=?",
      [tableName],
    );
    return result.isNotEmpty;
  }

  /// ============================================
  /// HELPER: GET DATABASE VERSION
  /// ============================================
  /// Returns the current database version
  /// Useful for debugging and logging
  static Future<int> getDatabaseVersion(Database db) async {
    final version = await db.getVersion();
    return version;
  }
}

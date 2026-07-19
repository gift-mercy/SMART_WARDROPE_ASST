// ============================================
// CLOTHING_ITEM.DART
// ============================================
// Model class for clothing items stored in the wardrobe
//
// Purpose:
// - Represent clothing item data structure
// - Convert between database maps and Dart objects
// - Provide type-safe access to clothing properties
// ============================================

/// ClothingItem model class
/// Represents a single clothing item in the user's wardrobe
class ClothingItem {
  /// Unique identifier for the clothing item
  final int? clothingId;

  /// User who owns this clothing item
  final int userId;

  /// Category ID (references categories table)
  final int categoryId;

  /// Category name (for display purposes)
  final String? categoryName;

  /// Color ID (references colors table)
  final int colorId;

  /// Color name (for display purposes)
  final String? colorName;

  /// Season ID (optional, references seasons table)
  final int? seasonId;

  /// Season name (for display purposes)
  final String? seasonName;

  /// Occasion ID (optional, references occasions table)
  final int? occasionId;

  /// Occasion name (for display purposes)
  final String? occasionName;

  /// Name/description of the clothing item
  final String clothingName;

  /// Path to the clothing item image
  final String imagePath;

  /// Optional notes about the item
  final String? notes;

  /// Date when the item was added to the wardrobe
  final String? dateAdded;

  /// Constructor
  ClothingItem({
    this.clothingId,
    required this.userId,
    required this.categoryId,
    this.categoryName,
    required this.colorId,
    this.colorName,
    this.seasonId,
    this.seasonName,
    this.occasionId,
    this.occasionName,
    required this.clothingName,
    required this.imagePath,
    this.notes,
    this.dateAdded,
  });

  /// Creates a ClothingItem from a database map
  /// Used when reading from SQLite
  factory ClothingItem.fromMap(Map<String, dynamic> map) {
    return ClothingItem(
      clothingId: map['clothing_id'] as int?,
      userId: map['user_id'] as int,
      categoryId: map['category_id'] as int,
      categoryName: map['category_name'] as String?,
      colorId: map['color_id'] as int,
      colorName: map['color_name'] as String?,
      seasonId: map['season_id'] as int?,
      seasonName: map['season_name'] as String?,
      occasionId: map['occasion_id'] as int?,
      occasionName: map['occasion_name'] as String?,
      clothingName: map['clothing_name'] as String,
      imagePath: map['image_path'] as String,
      notes: map['notes'] as String?,
      dateAdded: map['date_added'] as String?,
    );
  }

  /// Converts the ClothingItem to a database map
  /// Used when writing to SQLite
  Map<String, dynamic> toMap() {
    return {
      'clothing_id': clothingId,
      'user_id': userId,
      'category_id': categoryId,
      'color_id': colorId,
      'season_id': seasonId,
      'occasion_id': occasionId,
      'clothing_name': clothingName,
      'image_path': imagePath,
      'notes': notes,
      'date_added': dateAdded,
    };
  }

  /// Creates a copy of this ClothingItem with updated fields
  ClothingItem copyWith({
    int? clothingId,
    int? userId,
    int? categoryId,
    String? categoryName,
    int? colorId,
    String? colorName,
    int? seasonId,
    String? seasonName,
    int? occasionId,
    String? occasionName,
    String? clothingName,
    String? imagePath,
    String? notes,
    String? dateAdded,
  }) {
    return ClothingItem(
      clothingId: clothingId ?? this.clothingId,
      userId: userId ?? this.userId,
      categoryId: categoryId ?? this.categoryId,
      categoryName: categoryName ?? this.categoryName,
      colorId: colorId ?? this.colorId,
      colorName: colorName ?? this.colorName,
      seasonId: seasonId ?? this.seasonId,
      seasonName: seasonName ?? this.seasonName,
      occasionId: occasionId ?? this.occasionId,
      occasionName: occasionName ?? this.occasionName,
      clothingName: clothingName ?? this.clothingName,
      imagePath: imagePath ?? this.imagePath,
      notes: notes ?? this.notes,
      dateAdded: dateAdded ?? this.dateAdded,
    );
  }

  @override
  String toString() {
    return 'ClothingItem(id: $clothingId, name: $clothingName, category: $categoryName, color: $colorName)';
  }
}

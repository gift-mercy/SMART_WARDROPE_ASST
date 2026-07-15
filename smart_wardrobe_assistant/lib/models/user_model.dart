// ============================================
// USER_MODEL.DART
// ============================================
// Model class for user data from database
// Represents a user in the system
// ============================================

class UserModel {
  final int userId;
  final String fullName;
  final String email;
  final String? gender;
  final String? profilePicture;
  final DateTime createdAt;

  UserModel({
    required this.userId,
    required this.fullName,
    required this.email,
    this.gender,
    this.profilePicture,
    required this.createdAt,
  });

  /// Factory constructor to create UserModel from database map
  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      userId: map['user_id'] as int,
      fullName: map['full_name'] as String,
      email: map['email'] as String,
      gender: map['gender'] as String?,
      profilePicture: map['profile_picture'] as String?,
      createdAt: DateTime.parse(map['created_at'] as String),
    );
  }

  /// Convert UserModel to Map for database storage
  Map<String, dynamic> toMap() {
    return {
      'user_id': userId,
      'full_name': fullName,
      'email': email,
      'gender': gender,
      'profile_picture': profilePicture,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Get first name from full name
  String get firstName {
    final parts = fullName.trim().split(' ');
    return parts.first;
  }

  /// Get last name from full name (if exists)
  String? get lastName {
    final parts = fullName.trim().split(' ');
    return parts.length > 1 ? parts.sublist(1).join(' ') : null;
  }

  /// Get initials (e.g., "John Doe" -> "JD")
  String get initials {
    final parts = fullName.trim().split(' ');
    if (parts.isEmpty) return '';
    if (parts.length == 1) return parts[0][0].toUpperCase();
    return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
  }

  /// Create a copy of UserModel with updated fields
  UserModel copyWith({
    int? userId,
    String? fullName,
    String? email,
    String? gender,
    String? profilePicture,
    DateTime? createdAt,
  }) {
    return UserModel(
      userId: userId ?? this.userId,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      gender: gender ?? this.gender,
      profilePicture: profilePicture ?? this.profilePicture,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(userId: $userId, fullName: $fullName, email: $email)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.userId == userId && other.email == email;
  }

  @override
  int get hashCode => userId.hashCode ^ email.hashCode;
}

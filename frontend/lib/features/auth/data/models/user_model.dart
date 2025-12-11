import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

/// Model class for User data from Firebase Auth.
/// 
/// Extends UserEntity and provides conversion methods for Firebase data.
class UserModel extends UserEntity {
  const UserModel({
    required super.uid,
    required super.email,
    super.displayName,
  });

  /// Creates a UserModel from Firebase User data.
  factory UserModel.fromFirebaseUser(Map<String, dynamic> data) {
    return UserModel(
      uid: data['uid'] as String,
      email: data['email'] as String,
      displayName: data['displayName'] as String?,
    );
  }

  /// Converts model to domain entity.
  UserEntity toEntity() {
    return UserEntity(
      uid: uid,
      email: email,
      displayName: displayName,
    );
  }

  /// Converts model to a map for storage.
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
    };
  }
}

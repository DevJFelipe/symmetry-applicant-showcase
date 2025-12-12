import 'dart:io';

import '../entities/user.dart';

/// Abstract repository defining authentication operations.
/// 
/// This interface belongs to the Domain layer and defines the contract
/// that must be implemented by the Data layer.
abstract class AuthRepository {
  /// Returns the currently authenticated user, or null if not authenticated.
  Future<UserEntity?> getCurrentUser();

  /// Signs in a user with email and password.
  /// Throws an exception if authentication fails.
  Future<UserEntity> signIn({
    required String email,
    required String password,
  });

  /// Creates a new user account with email and password.
  /// Throws an exception if registration fails.
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  });

  /// Signs out the current user.
  Future<void> signOut();

  /// Updates the user's profile photo.
  /// 
  /// Uploads the image to storage, deletes the previous photo if exists,
  /// and updates the user's photoURL in Firebase Auth.
  /// Returns the updated user entity with the new photoURL.
  Future<UserEntity> updateProfilePhoto({
    required File imageFile,
    required String userId,
  });

  /// Stream of authentication state changes.
  Stream<UserEntity?> get authStateChanges;
}

import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:news_app_clean_architecture/features/auth/data/data_sources/firebase_auth_service.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/repository/auth_repository.dart';

/// Implementation of [AuthRepository] using Firebase Authentication.
///
/// This class acts as a bridge between the domain layer and the data source,
/// converting Firebase-specific responses to domain entities.
class AuthRepositoryImpl implements AuthRepository {
  final FirebaseAuthService _authService;

  AuthRepositoryImpl(this._authService);

  @override
  Future<UserEntity?> getCurrentUser() async {
    try {
      final userModel = await _authService.getCurrentUser();
      return userModel?.toEntity();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? e.code);
    } catch (e) {
      throw AuthException(code: 'unknown', message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final userModel = await _authService.signIn(
        email: email,
        password: password,
      );
      return userModel.toEntity();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _mapFirebaseAuthErrorToMessage(e.code),
      );
    } catch (e) {
      throw AuthException(code: 'unknown', message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<UserEntity> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final userModel = await _authService.signUp(
        email: email,
        password: password,
        displayName: displayName,
      );
      return userModel.toEntity();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(
        code: e.code,
        message: _mapFirebaseAuthErrorToMessage(e.code),
      );
    } catch (e) {
      throw AuthException(code: 'unknown', message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _authService.signOut();
    } on fb.FirebaseAuthException catch (e) {
      throw AuthException(code: e.code, message: e.message ?? e.code);
    } catch (e) {
      throw AuthException(code: 'unknown', message: 'An unexpected error occurred: $e');
    }
  }

  @override
  Stream<UserEntity?> get authStateChanges {
    return _authService.authStateChanges.map((userModel) => userModel?.toEntity());
  }

  /// Maps Firebase Auth error codes to user-friendly messages.
  String _mapFirebaseAuthErrorToMessage(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'invalid-email':
        return 'The email address is not valid.';
      case 'weak-password':
        return 'The password is too weak. Please use a stronger password.';
      case 'operation-not-allowed':
        return 'Email/password sign-in is not enabled.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication failed: $code';
    }
  }
}

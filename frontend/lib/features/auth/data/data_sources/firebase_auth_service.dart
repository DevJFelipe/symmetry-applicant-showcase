import 'package:firebase_auth/firebase_auth.dart';
import 'package:news_app_clean_architecture/features/auth/data/models/user_model.dart';

/// Data source for Firebase Authentication operations.
/// 
/// This is the only place where Firebase Auth SDK is imported,
/// following Clean Architecture principles.
class FirebaseAuthService {
  final FirebaseAuth _firebaseAuth;

  FirebaseAuthService({FirebaseAuth? firebaseAuth})
      : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance;

  /// Returns the currently authenticated user, or null if not authenticated.
  Future<UserModel?> getCurrentUser() async {
    final user = _firebaseAuth.currentUser;
    if (user == null) return null;

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  /// Signs in with email and password.
  /// Throws [FirebaseAuthException] if authentication fails.
  Future<UserModel> signIn({
    required String email,
    required String password,
  }) async {
    final credential = await _firebaseAuth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user returned after sign in',
      );
    }

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: user.displayName,
    );
  }

  /// Creates a new user with email and password.
  /// Throws [FirebaseAuthException] if registration fails.
  Future<UserModel> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    final credential = await _firebaseAuth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    final user = credential.user;
    if (user == null) {
      throw FirebaseAuthException(
        code: 'user-not-created',
        message: 'No user returned after sign up',
      );
    }

    // Update display name if provided
    if (displayName != null && displayName.isNotEmpty) {
      await user.updateDisplayName(displayName);
      await user.reload();
    }

    return UserModel(
      uid: user.uid,
      email: user.email ?? '',
      displayName: displayName ?? user.displayName,
    );
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    await _firebaseAuth.signOut();
  }

  /// Stream of authentication state changes.
  Stream<UserModel?> get authStateChanges {
    return _firebaseAuth.authStateChanges().map((user) {
      if (user == null) return null;
      return UserModel(
        uid: user.uid,
        email: user.email ?? '',
        displayName: user.displayName,
      );
    });
  }
}

/// Custom exception for Firebase Auth errors.
class FirebaseAuthException implements Exception {
  final String code;
  final String message;

  FirebaseAuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => 'FirebaseAuthException: [$code] $message';
}

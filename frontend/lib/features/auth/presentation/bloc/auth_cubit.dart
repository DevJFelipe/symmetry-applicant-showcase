import 'dart:io';

import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/update_profile_photo.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/update_profile_photo_params.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

export 'auth_state.dart';

/// Cubit for managing authentication state.
///
/// Handles user authentication operations including sign in, sign up,
/// sign out, checking current authentication status, and profile photo updates.
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;
  final UpdateProfilePhotoUseCase _updateProfilePhotoUseCase;
  final ImagePicker _imagePicker;

  AuthCubit({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
    required UpdateProfilePhotoUseCase updateProfilePhotoUseCase,
    ImagePicker? imagePicker,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
        _updateProfilePhotoUseCase = updateProfilePhotoUseCase,
        _imagePicker = imagePicker ?? ImagePicker(),
        super(const AuthInitial());

  /// Checks the current authentication status on app startup.
  Future<void> checkAuthStatus() async {
    emit(const AuthLoading());

    try {
      final user = await _getCurrentUserUseCase();
      if (user != null) {
        emit(AuthAuthenticated(user));
      } else {
        emit(const AuthUnauthenticated());
      }
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Failed to check authentication status: $e'));
    }
  }

  /// Signs in a user with email and password.
  Future<void> signIn({
    required String email,
    required String password,
  }) async {
    emit(const AuthLoading());

    try {
      final user = await _signInUseCase(
        params: SignInParams(email: email, password: password),
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Sign in failed: $e'));
    }
  }

  /// Creates a new user account with email and password.
  Future<void> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    emit(const AuthLoading());

    try {
      final user = await _signUpUseCase(
        params: SignUpParams(
          email: email,
          password: password,
          displayName: displayName,
        ),
      );
      emit(AuthAuthenticated(user));
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Sign up failed: $e'));
    }
  }

  /// Signs out the current user.
  Future<void> signOut() async {
    emit(const AuthLoading());

    try {
      await _signOutUseCase();
      emit(const AuthUnauthenticated());
    } on AuthException catch (e) {
      emit(AuthError(e.message));
    } catch (e) {
      emit(AuthError('Sign out failed: $e'));
    }
  }

  /// Picks an image from gallery and updates the profile photo.
  Future<void> pickProfilePhotoFromGallery() async {
    await _pickAndUpdateProfilePhoto(ImageSource.gallery);
  }

  /// Picks an image from camera and updates the profile photo.
  Future<void> pickProfilePhotoFromCamera() async {
    await _pickAndUpdateProfilePhoto(ImageSource.camera);
  }

  /// Internal method to handle image picking and profile update.
  Future<void> _pickAndUpdateProfilePhoto(ImageSource source) async {
    final currentUser = state.user;
    if (currentUser == null) return;

    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 512,
        maxHeight: 512,
        imageQuality: 80,
      );

      if (pickedFile == null) return;

      emit(ProfilePhotoUpdating(currentUser));

      final imageFile = File(pickedFile.path);
      final updatedUser = await _updateProfilePhotoUseCase(
        params: UpdateProfilePhotoParams(
          imageFile: imageFile,
          userId: currentUser.uid,
        ),
      );

      emit(AuthAuthenticated(updatedUser));
    } on AuthException catch (e) {
      emit(ProfilePhotoError(currentUser, e.message));
      // Return to authenticated state after a brief moment
      emit(AuthAuthenticated(currentUser));
    } catch (e) {
      emit(ProfilePhotoError(currentUser, 'Failed to update profile photo'));
      emit(AuthAuthenticated(currentUser));
    }
  }
}

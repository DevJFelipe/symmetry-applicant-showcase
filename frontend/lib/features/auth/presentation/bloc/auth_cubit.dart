import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/auth_exception.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/get_current_user.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_in.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_out.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/sign_up.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/sign_in_params.dart';
import 'package:news_app_clean_architecture/features/auth/domain/usecases/params/sign_up_params.dart';
import 'package:news_app_clean_architecture/features/auth/presentation/bloc/auth_state.dart';

export 'auth_state.dart';

/// Cubit for managing authentication state.
///
/// Handles user authentication operations including sign in, sign up,
/// sign out, and checking current authentication status.
class AuthCubit extends Cubit<AuthState> {
  final GetCurrentUserUseCase _getCurrentUserUseCase;
  final SignInUseCase _signInUseCase;
  final SignUpUseCase _signUpUseCase;
  final SignOutUseCase _signOutUseCase;

  AuthCubit({
    required GetCurrentUserUseCase getCurrentUserUseCase,
    required SignInUseCase signInUseCase,
    required SignUpUseCase signUpUseCase,
    required SignOutUseCase signOutUseCase,
  })  : _getCurrentUserUseCase = getCurrentUserUseCase,
        _signInUseCase = signInUseCase,
        _signUpUseCase = signUpUseCase,
        _signOutUseCase = signOutUseCase,
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
}

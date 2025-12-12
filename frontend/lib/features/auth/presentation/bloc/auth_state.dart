import 'package:equatable/equatable.dart';
import 'package:news_app_clean_architecture/features/auth/domain/entities/user.dart';

/// Base class for all authentication states.
abstract class AuthState extends Equatable {
  const AuthState();

  /// Returns the user if authenticated, null otherwise.
  UserEntity? get user => null;

  /// Returns true if the user is authenticated.
  bool get isAuthenticated => user != null;

  @override
  List<Object?> get props => [];
}

/// Initial state before auth status is checked.
class AuthInitial extends AuthState {
  const AuthInitial();
}

/// State while auth operation is in progress.
class AuthLoading extends AuthState {
  const AuthLoading();
}

/// State when user is authenticated.
class AuthAuthenticated extends AuthState {
  final UserEntity _user;

  const AuthAuthenticated(this._user);

  @override
  UserEntity? get user => _user;

  @override
  List<Object?> get props => [_user];
}

/// State when user is not authenticated.
class AuthUnauthenticated extends AuthState {
  const AuthUnauthenticated();
}

/// State when an auth operation fails.
class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object?> get props => [message];
}

/// State while profile photo is being updated.
class ProfilePhotoUpdating extends AuthState {
  final UserEntity _user;

  const ProfilePhotoUpdating(this._user);

  @override
  UserEntity? get user => _user;

  @override
  List<Object?> get props => [_user];
}

/// State when profile photo update fails.
class ProfilePhotoError extends AuthState {
  final UserEntity _user;
  final String message;

  const ProfilePhotoError(this._user, this.message);

  @override
  UserEntity? get user => _user;

  @override
  List<Object?> get props => [_user, message];
}

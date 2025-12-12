import 'package:equatable/equatable.dart';

/// Entity representing an authenticated user.
/// 
/// This is a pure Dart class with no external dependencies,
/// following Clean Architecture principles for the Domain layer.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;
  final String? photoURL;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
    this.photoURL,
  });

  /// Creates a copy of this entity with the given fields replaced.
  UserEntity copyWith({
    String? uid,
    String? email,
    String? displayName,
    String? photoURL,
  }) {
    return UserEntity(
      uid: uid ?? this.uid,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
    );
  }

  @override
  List<Object?> get props => [uid, email, displayName, photoURL];
}

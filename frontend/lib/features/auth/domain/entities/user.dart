import 'package:equatable/equatable.dart';

/// Entity representing an authenticated user.
/// 
/// This is a pure Dart class with no external dependencies,
/// following Clean Architecture principles for the Domain layer.
class UserEntity extends Equatable {
  final String uid;
  final String email;
  final String? displayName;

  const UserEntity({
    required this.uid,
    required this.email,
    this.displayName,
  });

  @override
  List<Object?> get props => [uid, email, displayName];
}

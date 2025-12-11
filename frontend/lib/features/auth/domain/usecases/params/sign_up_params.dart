import 'package:equatable/equatable.dart';

/// Parameters for sign up operation.
class SignUpParams extends Equatable {
  final String email;
  final String password;
  final String? displayName;

  const SignUpParams({
    required this.email,
    required this.password,
    this.displayName,
  });

  @override
  List<Object?> get props => [email, password, displayName];
}

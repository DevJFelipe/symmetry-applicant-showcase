/// Exception class for authentication errors.
///
/// Used throughout the auth feature to represent authentication failures
/// with a specific error code and user-friendly message.
class AuthException implements Exception {
  /// Error code from the authentication provider (e.g., 'user-not-found').
  final String code;

  /// User-friendly error message.
  final String message;

  const AuthException({
    required this.code,
    required this.message,
  });

  @override
  String toString() => message;
}

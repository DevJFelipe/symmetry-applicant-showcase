import 'package:equatable/equatable.dart';

/// Base class for all application exceptions.
/// Provides a domain-level error abstraction that doesn't leak
/// implementation details (like Dio) to other layers.
sealed class AppException extends Equatable implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;
  
  const AppException({
    required this.message,
    this.code,
    this.originalError,
  });
  
  @override
  List<Object?> get props => [message, code];
  
  @override
  String toString() => 'AppException: $message${code != null ? ' (code: $code)' : ''}';
}

/// Network-related exceptions (connectivity, timeout, etc.)
final class NetworkException extends AppException {
  final int? statusCode;
  
  const NetworkException({
    required super.message,
    super.code,
    super.originalError,
    this.statusCode,
  });
  
  @override
  List<Object?> get props => [...super.props, statusCode];
  
  /// Creates a NetworkException from common HTTP status codes
  factory NetworkException.fromStatusCode(int statusCode, {String? message}) {
    switch (statusCode) {
      case 400:
        return NetworkException(
          message: message ?? 'Bad request',
          code: 'BAD_REQUEST',
          statusCode: statusCode,
        );
      case 401:
        return NetworkException(
          message: message ?? 'Unauthorized',
          code: 'UNAUTHORIZED',
          statusCode: statusCode,
        );
      case 403:
        return NetworkException(
          message: message ?? 'Forbidden',
          code: 'FORBIDDEN',
          statusCode: statusCode,
        );
      case 404:
        return NetworkException(
          message: message ?? 'Not found',
          code: 'NOT_FOUND',
          statusCode: statusCode,
        );
      case 500:
        return NetworkException(
          message: message ?? 'Internal server error',
          code: 'SERVER_ERROR',
          statusCode: statusCode,
        );
      default:
        return NetworkException(
          message: message ?? 'Network error',
          code: 'NETWORK_ERROR',
          statusCode: statusCode,
        );
    }
  }
  
  /// Creates a timeout exception
  factory NetworkException.timeout() {
    return const NetworkException(
      message: 'Connection timed out',
      code: 'TIMEOUT',
    );
  }
  
  /// Creates a no connection exception
  factory NetworkException.noConnection() {
    return const NetworkException(
      message: 'No internet connection',
      code: 'NO_CONNECTION',
    );
  }
}

/// Server-side exceptions
final class ServerException extends AppException {
  const ServerException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Cache/Local storage exceptions
final class CacheException extends AppException {
  const CacheException({
    required super.message,
    super.code,
    super.originalError,
  });
}

/// Firebase-specific exceptions
final class FirebaseAppException extends AppException {
  const FirebaseAppException({
    required super.message,
    super.code,
    super.originalError,
  });
  
  /// Creates from Firebase error code
  factory FirebaseAppException.fromCode(String code, {String? message}) {
    final errorMessage = message ?? _getMessageFromCode(code);
    return FirebaseAppException(
      message: errorMessage,
      code: code,
    );
  }
  
  static String _getMessageFromCode(String code) {
    switch (code) {
      case 'permission-denied':
        return 'You don\'t have permission to perform this action';
      case 'not-found':
        return 'The requested resource was not found';
      case 'already-exists':
        return 'This resource already exists';
      case 'resource-exhausted':
        return 'Quota exceeded. Please try again later';
      case 'failed-precondition':
        return 'Operation failed due to current state';
      case 'aborted':
        return 'Operation was aborted';
      case 'unavailable':
        return 'Service is currently unavailable';
      case 'unauthenticated':
        return 'You must be logged in to perform this action';
      default:
        return 'An error occurred';
    }
  }
}

/// Validation exceptions
final class ValidationException extends AppException {
  final Map<String, String>? fieldErrors;
  
  const ValidationException({
    required super.message,
    super.code,
    this.fieldErrors,
  });
  
  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Authentication exceptions
final class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.originalError,
  });
  
  factory AuthException.fromCode(String code) {
    return AuthException(
      message: _getMessageFromCode(code),
      code: code,
    );
  }
  
  static String _getMessageFromCode(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No user found with this email';
      case 'wrong-password':
        return 'Incorrect password';
      case 'email-already-in-use':
        return 'An account already exists with this email';
      case 'weak-password':
        return 'Password is too weak';
      case 'invalid-email':
        return 'Invalid email address';
      case 'user-disabled':
        return 'This account has been disabled';
      case 'too-many-requests':
        return 'Too many attempts. Please try again later';
      case 'operation-not-allowed':
        return 'This operation is not allowed';
      case 'invalid-credential':
        return 'Invalid credentials';
      default:
        return 'Authentication failed';
    }
  }
}

/// Unknown/Generic exceptions
final class UnknownException extends AppException {
  const UnknownException({
    super.message = 'An unexpected error occurred',
    super.code,
    super.originalError,
  });
}

/// Domain failure types for the application.
///
/// These failures are returned by repositories and use cases instead of
/// throwing exceptions. They provide user-friendly messages and can be
/// matched for specific error handling.
sealed class Failure {
  final String message;
  final String? code;

  const Failure(this.message, {this.code});

  @override
  String toString() => 'Failure($code): $message';
}

/// Network-level failures (no connection, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([String message = 'Network error'])
    : super(message, code: 'NETWORK_ERROR');
}

/// Server errors (5xx)
class ServerFailure extends Failure {
  const ServerFailure([String message = 'Server error'])
    : super(message, code: 'SERVER_ERROR');
}

/// Authentication failures (401, 403)
class AuthFailure extends Failure {
  const AuthFailure([String message = 'Authentication error'])
    : super(message, code: 'AUTH_ERROR');
}

/// Resource not found (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([String message = 'Not found'])
    : super(message, code: 'NOT_FOUND');
}

/// Validation failures (400, 422)
class ValidationFailure extends Failure {
  final Map<String, String>? fieldErrors;

  const ValidationFailure(super.message, {this.fieldErrors})
    : super(code: 'VALIDATION_ERROR');

  /// Get error for a specific field
  String? errorFor(String field) => fieldErrors?[field];
}

/// Cache/storage failures
class CacheFailure extends Failure {
  const CacheFailure([String message = 'Cache error'])
    : super(message, code: 'CACHE_ERROR');
}

/// Unknown/unhandled failures
class UnknownFailure extends Failure {
  const UnknownFailure([String message = 'An error occurred'])
    : super(message, code: 'UNKNOWN_ERROR');
}

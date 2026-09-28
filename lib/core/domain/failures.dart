/// Domain failure types for the application.
///
/// These failures are returned by repositories and use cases instead of
/// throwing exceptions. They provide user-friendly messages and can be
/// matched for specific error handling.
sealed class Failure {
  final String message;
  final String? code;
  final int? statusCode;

  const Failure(this.message, {this.code, this.statusCode});

  @override
  String toString() => 'Failure($code): $message';
}

/// Network-level failures (no connection, timeout)
class NetworkFailure extends Failure {
  const NetworkFailure([super.message = 'Network error'])
    : super(code: 'NETWORK_ERROR');
}

/// Server errors (5xx)
class ServerFailure extends Failure {
  const ServerFailure([super.message = 'Server error'])
    : super(code: 'SERVER_ERROR');
}

/// Authentication failures (401, 403)
class AuthFailure extends Failure {
  const AuthFailure([super.message = 'Authentication error'])
    : super(code: 'AUTH_ERROR');
}

/// Resource not found (404)
class NotFoundFailure extends Failure {
  const NotFoundFailure([super.message = 'Not found'])
    : super(code: 'NOT_FOUND');
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
  const CacheFailure([super.message = 'Cache error'])
    : super(code: 'CACHE_ERROR');
}

/// Unknown/unhandled failures
class UnknownFailure extends Failure {
  const UnknownFailure([super.message = 'An error occurred'])
    : super(code: 'UNKNOWN_ERROR');

  const UnknownFailure.withStatus(super.message, int statusCode)
    : super(code: 'UNKNOWN_ERROR', statusCode: statusCode);
}

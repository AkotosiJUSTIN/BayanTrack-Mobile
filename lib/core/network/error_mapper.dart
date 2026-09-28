import 'package:dio/dio.dart';
import '../domain/failures.dart';

/// Centralized error mapper that converts exceptions to domain Failure types.
///
/// This is the single source of truth for error conversion.
/// Repositories should use this in their catch blocks instead of duplicating logic.
///
/// Example:
/// ```dart
/// try {
///   final response = await dio.get('/users');
///   return Success(response.data);
/// } catch (e, stack) {
///   return Err(ErrorMapper.mapException(e, stack));
/// }
/// ```
class ErrorMapper {
  ErrorMapper._(); // Prevent instantiation

  /// Convert any exception to a domain Failure
  static Failure mapException(Object error, [StackTrace? stack]) {
    if (error is DioException) return _mapDioException(error);
    if (error is FormatException) {
      return const ValidationFailure('Invalid data format');
    }
    if (error is TypeError) {
      return UnknownFailure('Type error: ${error.toString()}');
    }
    return UnknownFailure(error.toString());
  }

  /// Best message for user-facing validation and request errors.
  static String userMessage(Failure failure) {
    if (failure case ValidationFailure(
      fieldErrors: final fieldErrors?,
    ) when fieldErrors.isNotEmpty) {
      return fieldErrors.values.first;
    }
    return failure.message;
  }

  static Failure _mapDioException(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return const NetworkFailure(
          'Connection timeout. Please check your internet.',
        );
      case DioExceptionType.connectionError:
        return const NetworkFailure(
          'Unable to connect. Check your internet connection.',
        );
      case DioExceptionType.badResponse:
        return _mapHttpResponse(e.response);
      case DioExceptionType.cancel:
        return const NetworkFailure('Request was cancelled.');
      case DioExceptionType.badCertificate:
        return const NetworkFailure('Security certificate error.');
      case DioExceptionType.unknown:
        return const NetworkFailure('Network error occurred.');
    }
  }

  static Failure _mapHttpResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final body = response?.data;

    final message = _extractMessage(body);
    final fieldErrors = _extractFieldErrors(body);

    return switch (statusCode) {
      401 => AuthFailure(message ?? 'Invalid credentials'),
      403 => AuthFailure(message ?? 'Access denied'),
      404 => NotFoundFailure(message ?? 'Resource not found'),
      400 || 422 => ValidationFailure(
        message ?? 'Invalid input',
        fieldErrors: fieldErrors,
      ),
      >= 500 => ServerFailure(
        message ?? 'Server error. Please try again later.',
      ),
      _ => UnknownFailure.withStatus(message ?? 'Request failed', statusCode),
    };
  }

  /// Extract message from backend response formats
  /// Supports: {"detail": "..."}, {"message": "..."}, {"error": "..."}
  static String? _extractMessage(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    return body['detail']?.toString() ??
        body['message']?.toString() ??
        body['error']?.toString();
  }

  /// Extract field-level validation errors
  /// Supports nested `errors`/`details` maps and DRF field arrays.
  static Map<String, String>? _extractFieldErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return null;

    // Formats: {"errors": {"field": "message"}} and
    // {"error": "...", "details": {"field": ["message"]}}.
    final nested = body['errors'] is Map ? body['errors'] : body['details'];
    if (nested is Map) {
      return nested.map((k, v) => MapEntry(k.toString(), _flattenError(v)));
    }

    // DRF format: {"field": ["error1", "error2"]} or
    // {"field": "error"}.
    final errors = <String, String>{};
    for (final entry in body.entries) {
      if (entry.key != 'detail' &&
          entry.key != 'message' &&
          entry.key != 'error' &&
          (entry.value is List || entry.value is String)) {
        errors[entry.key] = entry.value is List
            ? (entry.value as List).join(', ')
            : entry.value.toString();
      }
    }
    return errors.isNotEmpty ? errors : null;
  }

  /// Flatten error value to string
  static String _flattenError(dynamic value) {
    if (value is List) return value.join(', ');
    return value.toString();
  }
}

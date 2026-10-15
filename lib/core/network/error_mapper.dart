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
    return const UnknownFailure('Something went wrong. Please try again.');
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
          'Connecting is taking longer than expected. Please try again.',
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
        return const NetworkFailure(
          'We could not connect securely. Please try again later.',
        );
      case DioExceptionType.unknown:
        return const NetworkFailure(
          'We could not connect. Check your connection and try again.',
        );
    }
  }

  static Failure _mapHttpResponse(Response? response) {
    final statusCode = response?.statusCode ?? 0;
    final body = response?.data;

    final message = _extractMessage(body);
    final fieldErrors = _extractFieldErrors(body);

    final code = body is Map ? body['code'] : null;
    if ((statusCode == 403 && code == 'terms_acceptance_required') ||
        (statusCode == 503 && code == 'maintenance_read_only') ||
        (statusCode == 409 && code == 'terms_version_stale')) {
      return SystemRestrictionFailure(
        code as String,
        message ?? 'Review the current system notice before continuing.',
        statusCode: statusCode,
      );
    }

    return switch (statusCode) {
      401 => AuthFailure(message ?? 'Invalid credentials'),
      403 => AuthFailure(message ?? 'Access denied'),
      404 => NotFoundFailure(message ?? 'Resource not found'),
      400 || 422 => ValidationFailure(
        message ?? 'Invalid input',
        fieldErrors: fieldErrors,
      ),
      >= 500 => const ServerFailure(
        'BayanTrack is having trouble completing this request. Please try again shortly.',
      ),
      _ => UnknownFailure.withStatus(
        'We could not complete this request. Please try again.',
        statusCode,
      ),
    };
  }

  /// Extract message from backend response formats
  /// Supports: {"detail": "..."}, {"message": "..."}, {"error": "..."}
  static String? _extractMessage(dynamic body) {
    if (body is! Map<String, dynamic>) return null;
    for (final key in ['detail', 'message', 'error']) {
      final value = body[key];
      if (value is String && value.trim().isNotEmpty) return value;
    }
    return null;
  }

  /// Extract field-level validation errors
  /// Supports nested `errors`/`details` maps and DRF field arrays.
  static Map<String, String>? _extractFieldErrors(dynamic body) {
    if (body is! Map<String, dynamic>) return null;

    // Formats: {"errors": {"field": "message"}} and
    // {"error": "...", "details": {"field": ["message"]}}.
    final nested = body['errors'] is Map ? body['errors'] : body['details'];
    if (nested is Map) {
      final errors = <String, String>{};
      for (final entry in nested.entries) {
        if (entry.key == 'code') continue;
        final message = _flattenError(entry.value);
        if (message != null) errors[entry.key.toString()] = message;
      }
      return errors.isEmpty ? null : errors;
    }

    // DRF format: {"field": ["error1", "error2"]} or
    // {"field": "error"}.
    final errors = <String, String>{};
    for (final entry in body.entries) {
      if (entry.key != 'detail' &&
          entry.key != 'message' &&
          entry.key != 'error' &&
          entry.key != 'code' &&
          (entry.value is List || entry.value is String)) {
        final message = _flattenError(entry.value);
        if (message != null) errors[entry.key] = message;
      }
    }
    return errors.isNotEmpty ? errors : null;
  }

  /// Flatten error value to string
  static String? _flattenError(dynamic value) {
    if (value is String && value.trim().isNotEmpty) return value;
    if (value is List) {
      final messages = value.whereType<String>().where(
        (message) => message.trim().isNotEmpty,
      );
      if (messages.isNotEmpty) return messages.join(', ');
    }
    return null;
  }
}

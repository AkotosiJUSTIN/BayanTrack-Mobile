import '../../l10n/app_localizations.dart';

/// Centralized validation utilities for consistent form validation
/// across all screens.
///
/// Usage:
/// ```dart
/// TextFormField(
///   validator: Validators.email,
/// )
/// ```
class Validators {
  Validators._(); // Prevent instantiation

  // RFC 5322 compliant email regex
  static final _emailRegex = RegExp(
    r"^[a-zA-Z0-9.!#$%&'*+/=?^_`{|}~-]+@[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?(?:\.[a-zA-Z0-9](?:[a-zA-Z0-9-]{0,61}[a-zA-Z0-9])?)*$",
  );
  static final _registrationEmailRegex = RegExp(
    r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
  );
  static final _lettersOnlyRegex = RegExp(r"^[A-Za-z\s\-'`]+$");

  /// Validates email address using RFC 5322 compliant regex.
  static String? email(String? value, {AppLocalizations? l10n}) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return l10n == null
          ? 'Email is required'
          : l10n.fieldRequired(l10n.email);
    }
    if (cleaned.length > 255) {
      return l10n?.fieldMaxLength(l10n.email, 255) ??
          'Email must be at most 255 characters';
    }
    if (!_emailRegex.hasMatch(cleaned)) {
      return l10n?.invalidEmail ?? 'Please enter a valid email';
    }
    return null;
  }

  /// Applies stricter registration email syntax used by the backend.
  static String? registrationEmail(String? value, {AppLocalizations? l10n}) {
    final error = email(value, l10n: l10n);
    if (error != null) return error;
    if (!_registrationEmailRegex.hasMatch(value!.trim())) {
      return l10n?.invalidEmail ?? 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password with minimum length and complexity requirements.
  static String? password(
    String? value, {
    int minLength = 8,
    int maxLength = 128,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.isEmpty) {
      return l10n == null
          ? 'Password is required'
          : l10n.fieldRequired(l10n.password);
    }
    if (value.runes.length < minLength) {
      return l10n?.passwordMinLength(minLength) ??
          'Password must be at least $minLength characters';
    }
    if (value.runes.length > maxLength) {
      return l10n?.fieldMaxLength(l10n.password, maxLength) ??
          'Password must be at most $maxLength characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return l10n?.passwordUppercase ??
          'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return l10n?.passwordLowercase ??
          'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return l10n?.passwordNumber ??
          'Password must contain at least one number';
    }
    return null;
  }

  /// Validates the backend's optional international phone number format.
  static String? phoneNumber(String? value, {AppLocalizations? l10n}) {
    final cleaned = (value ?? '').replaceAll(RegExp(r'[\s\-()]'), '');
    if (cleaned.isEmpty) return null;
    if (cleaned.length < 10 ||
        cleaned.length > 15 ||
        !RegExp(r'^\+?[1-9]\d{1,14}$').hasMatch(cleaned)) {
      return l10n?.invalidPhone ??
          'Enter a valid phone number with country code';
    }
    return null;
  }

  /// Validates that the field is not empty.
  static String? required(
    String? value, [
    String fieldName = 'This field',
    AppLocalizations? l10n,
  ]) {
    if (value == null || value.trim().isEmpty) {
      return l10n?.fieldRequired(fieldName) ?? '$fieldName is required';
    }
    return null;
  }

  /// Validates a field contains letters only.
  static String? lettersOnly(
    String? value, {
    String fieldName = 'This field',
    int maxLength = 100,
    bool required = true,
    AppLocalizations? l10n,
  }) {
    if (value == null || value.trim().isEmpty) {
      if (!required) return null;
      return l10n?.fieldRequired(fieldName) ?? '$fieldName is required';
    }

    final trimmed = value.trim();
    if (trimmed.runes.length > maxLength) {
      return l10n?.fieldMaxLength(fieldName, maxLength) ??
          '$fieldName must be at most $maxLength characters';
    }

    if (!_lettersOnlyRegex.hasMatch(trimmed)) {
      return l10n?.lettersOnly(fieldName) ??
          '$fieldName must contain letters only';
    }

    return null;
  }

  /// Validates password confirmation matches original.
  static String? Function(String?) confirmPassword(
    String originalPassword, {
    AppLocalizations? l10n,
  }) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return l10n?.confirmPasswordPrompt ?? 'Please confirm your password';
      }
      if (value != originalPassword) {
        return l10n?.passwordsDoNotMatch ?? 'Passwords do not match';
      }
      return null;
    };
  }

  /// Validates minimum string length.
  static String? Function(String?) minLength(
    int min, [
    String? fieldName,
    AppLocalizations? l10n,
  ]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        final name = fieldName ?? 'This field';
        return l10n?.fieldRequired(name) ?? '$name is required';
      }
      if (value.length < min) {
        final name = fieldName ?? 'This field';
        return l10n?.passwordMinLength(min) ??
            '$name must be at least $min characters';
      }
      return null;
    };
  }

  static String? reportText(
    String? value, {
    bool isRequired = true,
    int maxLength = 5000,
    AppLocalizations? l10n,
  }) {
    final text = value?.trim() ?? '';
    if (text.isEmpty) {
      return isRequired
          ? l10n?.fieldRequired('This field') ?? 'This field is required'
          : null;
    }

    if (text.runes.length > maxLength) {
      return l10n?.fieldMaxLength('Report text', maxLength) ??
          'Text must be at most $maxLength characters';
    }
    return null;
  }
}

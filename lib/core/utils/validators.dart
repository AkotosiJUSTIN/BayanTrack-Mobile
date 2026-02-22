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
  static final _lettersOnlyRegex = RegExp(r'^[A-Za-z]+$');
  static final _specialCharRegex = RegExp(r'[!@#$%^&*(),.?":{}|<>]');

  /// Validates email address using RFC 5322 compliant regex.
  static String? email(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    }
    if (!_emailRegex.hasMatch(value)) {
      return 'Please enter a valid email';
    }
    return null;
  }

  /// Validates password with minimum length and complexity requirements.
  static String? password(String? value, {int minLength = 8}) {
    if (value == null || value.isEmpty) {
      return 'Password is required';
    }
    if (value.length < minLength) {
      return 'Password must be at least $minLength characters';
    }
    if (!value.contains(RegExp(r'[A-Z]'))) {
      return 'Password must contain at least one uppercase letter';
    }
    if (!value.contains(RegExp(r'[a-z]'))) {
      return 'Password must contain at least one lowercase letter';
    }
    if (!value.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }
    if (!_specialCharRegex.hasMatch(value)) {
      return 'Password must contain at least one special character';
    }
    return null;
  }

  /// Validates Philippine mobile phone number format.
  /// Accepts: 09XXXXXXXXX or +639XXXXXXXXX
  static String? phoneNumber(String? value) {
    if (value == null || value.isEmpty) {
      return 'Phone number is required';
    }
    if (!RegExp(r'^(09|\+639)\d{9}$').hasMatch(value)) {
      return 'Please enter a valid Philippine mobile number';
    }
    return null;
  }

  /// Validates that the field is not empty.
  static String? required(String? value, [String fieldName = 'This field']) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }
    return null;
  }

  /// Validates a field contains letters only.
  static String? lettersOnly(
    String? value, {
    String fieldName = 'This field',
    int maxLength = 100,
  }) {
    if (value == null || value.trim().isEmpty) {
      return '$fieldName is required';
    }

    final trimmed = value.trim();
    if (trimmed.length > maxLength) {
      return '$fieldName must be at most $maxLength characters';
    }

    if (!_lettersOnlyRegex.hasMatch(trimmed)) {
      return '$fieldName must contain letters only';
    }

    return null;
  }

  /// Validates password confirmation matches original.
  static String? Function(String?) confirmPassword(String originalPassword) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return 'Please confirm your password';
      }
      if (value != originalPassword) {
        return 'Passwords do not match';
      }
      return null;
    };
  }

  /// Validates minimum string length.
  static String? Function(String?) minLength(int min, [String? fieldName]) {
    return (String? value) {
      if (value == null || value.isEmpty) {
        return '${fieldName ?? 'This field'} is required';
      }
      if (value.length < min) {
        return '${fieldName ?? 'This field'} must be at least $min characters';
      }
      return null;
    };
  }
}

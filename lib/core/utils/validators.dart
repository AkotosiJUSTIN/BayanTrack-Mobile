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
  static final _lettersOnlyRegex = RegExp(r"^[A-Za-z\s\-'`]+$");
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

  /// Detects gibberish or nonsense text in report descriptions.
  /// 
  /// Checks for:
  /// - Excessive character repetition
  /// - Random keyboard mashing patterns
  /// - Too many consecutive consonants/vowels
  /// - Meaningless short text
  /// - Excessive special characters
  /// 
  /// Returns null if text is valid, error message otherwise.
  static String? reportText(String? value, {bool isRequired = true}) {
    if (value == null || value.trim().isEmpty) {
      return isRequired ? 'This field is required' : null;
    }

    final text = value.trim();

    // Check minimum meaningful length (at least 10 characters)
    if (text.length < 10) {
      // Check for common placeholder text
      final lowerText = text.toLowerCase();
      if (lowerText == 'n/a' || 
          lowerText == 'na' || 
          lowerText == 'none' ||
          lowerText == 'test' ||
          lowerText == 'tbd' ||
          lowerText == 'todo') {
        return 'Please provide a meaningful description of the issue instead of "$text"';
      }
      return 'Please provide a more detailed description (at least 10 characters)';
    }

    // Check for excessive character repetition (e.g., "aaaaaaa", "hahahaha")
    if (_hasExcessiveRepetition(text)) {
      return 'Please enter a meaningful description without excessive repetition';
    }

    // Check for keyboard mashing patterns
    if (_isKeyboardMashing(text)) {
      return 'Please enter a valid description (keyboard mashing detected)';
    }

    // Check for excessive consecutive consonants or vowels
    if (_hasExcessiveConsonantsOrVowels(text)) {
      return 'Please enter a coherent description';
    }

    // Check if text has reasonable word structure
    if (!_hasReasonableWordStructure(text)) {
      return 'Please provide a meaningful description with proper words';
    }

    // Check for excessive special characters or numbers
    if (_hasExcessiveNonAlphabetic(text)) {
      return 'Please reduce the use of special characters and numbers';
    }

    return null;
  }

  /// Checks if text has excessive character repetition
  static bool _hasExcessiveRepetition(String text) {
    // Check for same character repeated more than 4 times
    if (RegExp(r'(.)\1{4,}').hasMatch(text)) {
      return true;
    }

    // Check for same pattern repeated (e.g., "hahaha", "lalala")
    if (RegExp(r'(.{2,4})\1{3,}', caseSensitive: false).hasMatch(text)) {
      return true;
    }

    return false;
  }

  /// Checks for common keyboard mashing patterns
  static bool _isKeyboardMashing(String text) {
    final lowerText = text.toLowerCase();
    
    // Common keyboard patterns
    final keyboardPatterns = [
      'qwertyuiop',
      'asdfghjkl',
      'zxcvbnm',
      'qwerty',
      'asdfgh',
      'zxcvb',
      '123456',
      'abcdef',
    ];

    for (final pattern in keyboardPatterns) {
      if (lowerText.contains(pattern)) {
        return true;
      }
      // Also check reverse
      if (lowerText.contains(pattern.split('').reversed.join())) {
        return true;
      }
    }

    return false;
  }

  /// Checks for excessive consecutive consonants or vowels
  static bool _hasExcessiveConsonantsOrVowels(String text) {
    // More than 5 consecutive consonants (excluding common Filipino patterns)
    if (RegExp(r'[bcdfghjklmnpqrstvwxyz]{6,}', caseSensitive: false)
        .hasMatch(text)) {
      return true;
    }

    // More than 4 consecutive vowels (unusual in most languages)
    if (RegExp(r'[aeiou]{5,}', caseSensitive: false).hasMatch(text)) {
      return true;
    }

    return false;
  }

  /// Checks if text has reasonable word structure
  static bool _hasReasonableWordStructure(String text) {
    // Split into words
    final words = text.split(RegExp(r'\s+'));
    
    // Filter out very short words (1-2 characters) for checking
    final meaningfulWords = words.where((w) => w.length > 2).toList();
    
    // Should have at least one word longer than 2 characters
    if (meaningfulWords.isEmpty && text.length > 20) {
      return false;
    }

    // Check if at least 30% of text consists of alphabetic characters
    final alphabeticCount = text.split('').where((c) => 
      RegExp(r'[a-zA-Z]').hasMatch(c)
    ).length;
    
    if (alphabeticCount < text.length * 0.3) {
      return false;
    }

    return true;
  }

  /// Checks for excessive non-alphabetic characters
  static bool _hasExcessiveNonAlphabetic(String text) {
    final nonAlphabeticCount = text.split('').where((c) => 
      !RegExp(r'[a-zA-Z\s]').hasMatch(c)
    ).length;

    // More than 50% non-alphabetic (excluding spaces) is suspicious
    return nonAlphabeticCount > text.length * 0.5;
  }
}

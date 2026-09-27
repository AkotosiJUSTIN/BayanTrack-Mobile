/// Validation rules shared by the KYC form and request serialization.
class KycValidators {
  KycValidators._();

  static final _nameRegex = RegExp(
    r"^[A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\s\-'.]+$",
  );
  static final _nationalityRegex = RegExp(
    r'^[A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\s\-]+$',
  );
  static final _mobileRegex = RegExp(
    r'^(?:(?:\+?63|0)9\d{9}|\+[1-9]\d{9,14})$',
  );
  static final _idNumberRegex = RegExp(r'^[A-Za-z0-9\s-]+$');
  static final _zipRegex = RegExp(r'^\d{4}$');

  static String? name(String? value, {String fieldName = 'Name'}) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) {
      return '$fieldName is required';
    }
    if (cleaned.runes.length > 50) {
      return '$fieldName must be at most 50 characters.';
    }
    if (!_nameRegex.hasMatch(cleaned)) {
      return '$fieldName may only contain letters, spaces, hyphens, apostrophes, or periods.';
    }
    return null;
  }

  static String? nationality(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return 'Nationality is required';
    if (!_nationalityRegex.hasMatch(cleaned)) {
      return 'Nationality may only contain letters, spaces, or hyphens.';
    }
    return null;
  }

  static String? dateOfBirth(DateTime? value) {
    if (value == null) return 'Date of birth is required';

    final today = _today();
    final date = DateTime(value.year, value.month, value.day);
    if (date.isAfter(today)) {
      return 'Date of birth cannot be in the future.';
    }

    var age = today.year - date.year;
    if (today.month < date.month ||
        (today.month == date.month && today.day < date.day)) {
      age--;
    }
    if (age < 18) {
      return 'Applicant must be at least 18 years old to submit KYC.';
    }

    if (age > 120) {
      return 'Date of birth is invalid. Maximum age allowed is 120 years.';
    }
    return null;
  }

  /// Normalizes local PH input and preserves accepted international numbers.
  static String normalizeMobileNumber(String value) {
    final cleaned = value.trim().replaceAll(RegExp(r'[\s-]'), '');
    if (RegExp(r'^9\d{9}$').hasMatch(cleaned)) return '0$cleaned';
    if (RegExp(r'^\+639\d{9}$').hasMatch(cleaned)) {
      return '0${cleaned.substring(3)}';
    }
    return cleaned;
  }

  /// Returns stored local or international number for the full-number field.
  static String mobileInputValue(String value) {
    return normalizeMobileNumber(value);
  }

  static String? mobileNumber(String? value) {
    final cleaned = normalizeMobileNumber(value ?? '');
    if (cleaned.isEmpty) return 'Mobile number is required';
    if (!_mobileRegex.hasMatch(cleaned)) {
      return 'Enter a valid mobile number (e.g. 09xxxxxxxxx or +639xxxxxxxxx).';
    }
    return null;
  }

  static String? idNumber(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return 'ID number cannot be blank.';
    if (cleaned.length < 4) {
      return 'ID number is too short. Minimum 4 characters required.';
    }
    if (!_idNumberRegex.hasMatch(cleaned)) {
      return 'ID number may only contain letters, digits, spaces, and hyphens.';
    }
    return null;
  }

  static String? zipCode(String? value) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.isEmpty) return null;
    if (!_zipRegex.hasMatch(cleaned)) {
      return 'Zip code must be exactly 4 digits (e.g. 2428).';
    }
    return null;
  }

  static String? addressField(
    String? value,
    String fieldName, {
    int maxLength = 255,
  }) {
    final cleaned = value?.trim() ?? '';
    if (cleaned.runes.length < 2) {
      return '$fieldName must be at least 2 characters.';
    }
    if (cleaned.runes.length > maxLength) {
      return '$fieldName must be at most $maxLength characters.';
    }
    return null;
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }
}

import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import 'kyc_models.dart';

enum KycOcrField {
  firstName,
  middleName,
  lastName,
  dateOfBirth,
  sex,
  nationality,
  civilStatus,
  address,
  cityMunicipality,
  province,
  zipCode,
  idNumber,
  idExpiryDate,
}

extension KycOcrFieldLabel on KycOcrField {
  String get label => switch (this) {
    KycOcrField.firstName => 'First name',
    KycOcrField.middleName => 'Middle name',
    KycOcrField.lastName => 'Last name',
    KycOcrField.dateOfBirth => 'Date of birth',
    KycOcrField.sex => 'Sex',
    KycOcrField.nationality => 'Nationality',
    KycOcrField.civilStatus => 'Civil status',
    KycOcrField.address => 'Address',
    KycOcrField.cityMunicipality => 'City / municipality',
    KycOcrField.province => 'Province',
    KycOcrField.zipCode => 'ZIP code',
    KycOcrField.idNumber => 'ID number',
    KycOcrField.idExpiryDate => 'ID expiry date',
  };
}

enum KycOcrConfidence { high, review }

enum KycOcrResultStatus { extracted, partial, unreadable, unsupported }

class KycOcrFieldValue {
  final String value;
  final KycOcrConfidence confidence;

  const KycOcrFieldValue({required this.value, required this.confidence});
}

class KycOcrResult {
  final IdType idType;
  final KycOcrResultStatus status;
  final Map<KycOcrField, KycOcrFieldValue> fields;
  final String? message;
  final String rawText;

  KycOcrResult({
    required this.idType,
    required this.status,
    Map<KycOcrField, KycOcrFieldValue> fields = const {},
    this.message,
    this.rawText = '',
  }) : fields = Map.unmodifiable(fields);

  bool get hasFields => fields.isNotEmpty;

  bool get needsManualReview =>
      status != KycOcrResultStatus.extracted ||
      fields.values.any((field) => field.confidence == KycOcrConfidence.review);
}

abstract final class KycOcrParser {
  static final _supportedTypes = {
    IdType.passport,
    IdType.nationalId,
    IdType.philsys,
    IdType.driversLicense,
    IdType.umid,
    IdType.prcProfessionalId,
  };

  static final _surnamePatterns = [
    RegExp(
      r'\b(?:surname|last\s+name|apelyido)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _givenNamePatterns = [
    RegExp(
      r'\b(?:given\s+names?|first\s+name|mga\s+pangalan|pangalan)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _middleNamePatterns = [
    RegExp(
      r'\b(?:middle\s+name|gitnang\s+(?:name|pangalan|apelyido))\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _fullNamePatterns = [
    RegExp(r'\bfull\s+name\b\s*[:\-]?\s*(.*)', caseSensitive: false),
    RegExp(r'^name\s*[:\-]\s*(.*)', caseSensitive: false),
  ];
  static final _dateOfBirthPatterns = [
    RegExp(
      r'\b(?:date\s+of\s+birth|petsa\s+ng\s+kapanganakan)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
    RegExp(r'\bbirth\s+date\b\s*[:\-]?\s*(.*)', caseSensitive: false),
  ];
  static final _expiryPatterns = [
    RegExp(r'\bdate\s+of\s+expiry\b\s*[:\-]?\s*(.*)', caseSensitive: false),
    RegExp(r'\bexpiration\s+date\b\s*[:\-]?\s*(.*)', caseSensitive: false),
    RegExp(r'\bexpiry\s+date\b\s*[:\-]?\s*(.*)', caseSensitive: false),
    RegExp(r'\bpic\s+validity\b\s*[:\-]?\s*(.*)', caseSensitive: false),
    RegExp(r'\bvalid(?:ity|\s+until)\b\s*[:\-]?\s*(.*)', caseSensitive: false),
  ];
  static final _sexPatterns = [
    RegExp(
      r'\b(?:sex|gender|kasarian)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _nationalityPatterns = [
    RegExp(
      r'\b(?:nationality|citizenship|nasyonalidad)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _civilStatusPatterns = [
    RegExp(
      r'\b(?:civil\s+status|marital\s+status|katayuang\s+sibil|kalagayang\s+sibil)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _nationalIdNumberPatterns = [
    RegExp(
      r'\b(?:philsys|phil\s*sys|philid|phil\s*id)\s*(?:card\s*)?(?:no\.?|number)\b\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
    RegExp(r'\b(?:pcn|psn)\b\s*[:#\-]?\s*(.*)', caseSensitive: false),
    RegExp(
      r'\b(?:national\s+id|national\s+identification)\s*(?:no\.?|number)\b\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _addressPatterns = [
    RegExp(
      r'\b(?:present\s+address|current\s+address|residential\s+address|address|tirahan|kasalukuyang\s+tirahan)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _cityPatterns = [
    RegExp(
      r'\b(?:city\s*/?\s*municipality|municipality|city|lungsod|munisipalidad)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _provincePatterns = [
    RegExp(r'\b(?:province|probinsya)\b\s*[:\-]?\s*(.*)', caseSensitive: false),
  ];
  static final _zipPatterns = [
    RegExp(
      r'\b(?:zip\s*code|postal\s*code|zip)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];

  static bool supports(IdType idType) => _supportedTypes.contains(idType);

  static KycOcrResult parse(IdType idType, String rawText) {
    if (!supports(idType)) {
      return KycOcrResult(
        idType: idType,
        status: KycOcrResultStatus.unsupported,
        message: 'OCR is not available for this ID type yet.',
        rawText: rawText,
      );
    }

    final lines = _lines(rawText);
    if (lines.isEmpty) {
      return KycOcrResult(
        idType: idType,
        status: KycOcrResultStatus.unreadable,
        message: 'No readable text was found. Enter details manually.',
        rawText: rawText,
      );
    }

    final fields = <KycOcrField, KycOcrFieldValue>{};
    switch (idType) {
      case IdType.passport:
        _parsePassport(lines, fields);
      case IdType.nationalId:
      case IdType.philsys:
        _parseNationalId(lines, fields);
      case IdType.driversLicense:
        _parseDriversLicense(lines, fields);
      case IdType.umid:
        _parseUmid(lines, fields);
      case IdType.prcProfessionalId:
        _parsePrc(lines, fields);
      case IdType.sss:
      case IdType.postal:
      case IdType.voters:
        break;
    }

    final status = fields.isEmpty
        ? KycOcrResultStatus.unreadable
        : fields.length < 2
        ? KycOcrResultStatus.partial
        : KycOcrResultStatus.extracted;
    return KycOcrResult(
      idType: idType,
      status: status,
      fields: fields,
      message: status == KycOcrResultStatus.unreadable
          ? 'The image text was incomplete. Enter details manually.'
          : null,
      rawText: rawText,
    );
  }

  static void _parseNationalId(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _parseNames(lines, fields);
    _addDate(
      fields,
      KycOcrField.dateOfBirth,
      _valueForPatterns(lines, _dateOfBirthPatterns),
    );
    _addSex(fields, _valueForPatterns(lines, _sexPatterns));
    _addNationality(fields, _valueForPatterns(lines, _nationalityPatterns));
    _addCivilStatus(fields, _valueForPatterns(lines, _civilStatusPatterns));
    _addText(
      fields,
      KycOcrField.address,
      _valueForLabeledBlock(lines, _addressPatterns),
    );
    _addText(
      fields,
      KycOcrField.cityMunicipality,
      _valueForPatterns(lines, _cityPatterns),
    );
    _addText(
      fields,
      KycOcrField.province,
      _valueForPatterns(lines, _provincePatterns),
    );
    _addText(
      fields,
      KycOcrField.zipCode,
      _valueForPatterns(lines, _zipPatterns),
    );
    _addId(fields, _valueForPatterns(lines, _nationalIdNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _expiryPatterns),
    );
  }

  static void _parsePassport(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _parseNames(lines, fields);
    _addDate(
      fields,
      KycOcrField.dateOfBirth,
      _valueForPatterns(lines, _dateOfBirthPatterns),
    );
    _addSex(fields, _valueForPatterns(lines, _sexPatterns));
    _addNationality(fields, _valueForPatterns(lines, _nationalityPatterns));
    _addId(fields, _valueForPatterns(lines, _passportNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _expiryPatterns),
    );
    _parsePassportMrz(lines, fields);
  }

  static void _parseDriversLicense(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _parseNames(lines, fields);
    _addDate(
      fields,
      KycOcrField.dateOfBirth,
      _valueForPatterns(lines, _dateOfBirthPatterns),
    );
    _addSex(fields, _valueForPatterns(lines, _sexPatterns));
    _addNationality(fields, _valueForPatterns(lines, _nationalityPatterns));
    _addId(fields, _valueForPatterns(lines, _licenseNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _expiryPatterns),
    );
  }

  static void _parseUmid(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _parseNames(lines, fields);
    _addDate(
      fields,
      KycOcrField.dateOfBirth,
      _valueForPatterns(lines, _dateOfBirthPatterns),
    );
    _addSex(fields, _valueForPatterns(lines, _sexPatterns));
    _addNationality(fields, _valueForPatterns(lines, _nationalityPatterns));
    _addCivilStatus(fields, _valueForPatterns(lines, _civilStatusPatterns));
    _addId(fields, _valueForPatterns(lines, _umidNumberPatterns));
  }

  static void _parsePrc(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _parseNames(lines, fields);
    _addDate(
      fields,
      KycOcrField.dateOfBirth,
      _valueForPatterns(lines, _dateOfBirthPatterns),
    );
    _addSex(fields, _valueForPatterns(lines, _sexPatterns));
    _addId(fields, _valueForPatterns(lines, _prcNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _expiryPatterns),
    );
  }

  static final _passportNumberPatterns = [
    RegExp(
      r'\bpassport\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _licenseNumberPatterns = [
    RegExp(
      r"\b(?:driver['’]?s?\s+)?license\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)",
      caseSensitive: false,
    ),
    RegExp(
      r'\blicen[cs]e\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _umidNumberPatterns = [
    RegExp(
      r'\bcommon\s+reference\s+number\b\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
    RegExp(
      r'\b(?:crn|ssn|ss\s+number|sss\s+(?:no\.?|number))\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _prcNumberPatterns = [
    RegExp(
      r'\bregistration\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
    RegExp(
      r'\blicense\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];

  static void _parseNames(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _addName(
      fields,
      KycOcrField.lastName,
      _valueForPatterns(lines, _surnamePatterns),
    );
    _addName(
      fields,
      KycOcrField.firstName,
      _valueForPatterns(lines, _givenNamePatterns),
    );
    _addName(
      fields,
      KycOcrField.middleName,
      _valueForPatterns(lines, _middleNamePatterns),
    );

    if (fields[KycOcrField.firstName] != null &&
        fields[KycOcrField.lastName] != null) {
      return;
    }

    final combined = _combinedNameValue(lines);
    if (combined == null) return;
    final parts = combined
        .split(RegExp(r'\s*,\s*'))
        .map(_cleanCandidate)
        .whereType<String>()
        .toList();
    if (parts.length >= 3) {
      _addName(fields, KycOcrField.lastName, parts[0]);
      _addName(fields, KycOcrField.firstName, parts[1]);
      _addName(fields, KycOcrField.middleName, parts[2]);
    } else if (parts.length == 2) {
      _addName(fields, KycOcrField.lastName, parts[0]);
      _addName(fields, KycOcrField.firstName, parts[1]);
    }
  }

  static String? _combinedNameValue(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      final lower = lines[i].toLowerCase();
      if (lower.contains('last name') && lower.contains('first name')) {
        return _nextValue(lines, i);
      }
    }
    return _valueForPatterns(lines, _fullNamePatterns);
  }

  static void _parsePassportMrz(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    for (final line in lines) {
      final compact = line.replaceAll(' ', '');
      final match = RegExp(
        r'([A-Z0-9]{9})\d([A-Z]{3})(\d{6})\d([MF<])(\d{6})',
      ).firstMatch(compact);
      if (match == null) continue;

      _addStrong(fields, KycOcrField.idNumber, match.group(1));
      _addStrong(
        fields,
        KycOcrField.nationality,
        _nationalityValue(match.group(2)),
      );
      _addStrong(fields, KycOcrField.dateOfBirth, _mrzDate(match.group(3)));
      _addStrong(fields, KycOcrField.sex, _sexValue(match.group(4)));
      _addStrong(fields, KycOcrField.idExpiryDate, _mrzDate(match.group(5)));
      break;
    }

    if (fields[KycOcrField.firstName] != null &&
        fields[KycOcrField.lastName] != null) {
      return;
    }
    for (final line in lines) {
      final compact = line.replaceAll(' ', '');
      final match = RegExp(r'^P<([A-Z]{3})(.+)$').firstMatch(compact);
      if (match == null) continue;
      final nameParts = match.group(2)!.split('<<');
      if (nameParts.length < 2) return;
      _addName(fields, KycOcrField.lastName, nameParts[0].replaceAll('<', ' '));
      _addName(
        fields,
        KycOcrField.firstName,
        nameParts[1].replaceAll('<', ' '),
      );
      return;
    }
  }

  static void _addName(
    Map<KycOcrField, KycOcrFieldValue> fields,
    KycOcrField field,
    String? value,
  ) {
    final cleaned = _cleanCandidate(value);
    if (cleaned == null ||
        !RegExp(r"^[A-Za-zÀ-ÖØ-öø-ÿ .'-]+$").hasMatch(cleaned)) {
      return;
    }
    fields.putIfAbsent(
      field,
      () =>
          KycOcrFieldValue(value: cleaned, confidence: KycOcrConfidence.review),
    );
  }

  static void _addId(Map<KycOcrField, KycOcrFieldValue> fields, String? value) {
    final cleaned = _cleanCandidate(
      value,
    )?.replaceAll(RegExp(r'[^A-Za-z0-9 -]'), '');
    if (cleaned == null || cleaned.trim().length < 4) return;
    fields.putIfAbsent(
      KycOcrField.idNumber,
      () => KycOcrFieldValue(
        value: cleaned.trim(),
        confidence: KycOcrConfidence.high,
      ),
    );
  }

  static void _addText(
    Map<KycOcrField, KycOcrFieldValue> fields,
    KycOcrField field,
    String? value,
  ) {
    final cleaned = _cleanCandidate(value);
    if (cleaned == null) return;
    fields.putIfAbsent(
      field,
      () =>
          KycOcrFieldValue(value: cleaned, confidence: KycOcrConfidence.review),
    );
  }

  static void _addDate(
    Map<KycOcrField, KycOcrFieldValue> fields,
    KycOcrField field,
    String? value,
  ) {
    final normalized = _normalizeDate(value);
    if (normalized == null) return;
    fields.putIfAbsent(
      field,
      () => KycOcrFieldValue(
        value: normalized,
        confidence: KycOcrConfidence.review,
      ),
    );
  }

  static void _addSex(
    Map<KycOcrField, KycOcrFieldValue> fields,
    String? value,
  ) {
    final normalized = _sexValue(value);
    if (normalized == null) return;
    fields.putIfAbsent(
      KycOcrField.sex,
      () => KycOcrFieldValue(
        value: normalized,
        confidence: KycOcrConfidence.review,
      ),
    );
  }

  static void _addNationality(
    Map<KycOcrField, KycOcrFieldValue> fields,
    String? value,
  ) {
    final normalized = _nationalityValue(value);
    if (normalized == null) return;
    fields.putIfAbsent(
      KycOcrField.nationality,
      () => KycOcrFieldValue(
        value: normalized,
        confidence: KycOcrConfidence.review,
      ),
    );
  }

  static void _addCivilStatus(
    Map<KycOcrField, KycOcrFieldValue> fields,
    String? value,
  ) {
    final lower = value?.trim().toLowerCase();
    final normalized = switch (lower) {
      'single' => 'single',
      'married' => 'married',
      'widowed' || 'widower' => 'widowed',
      'separated' || 'legally separated' => 'separated',
      'divorced' => 'divorced',
      _ => null,
    };
    if (normalized == null) return;
    fields.putIfAbsent(
      KycOcrField.civilStatus,
      () => KycOcrFieldValue(
        value: normalized,
        confidence: KycOcrConfidence.review,
      ),
    );
  }

  static void _addStrong(
    Map<KycOcrField, KycOcrFieldValue> fields,
    KycOcrField field,
    String? value,
  ) {
    final cleaned = _cleanCandidate(value);
    if (cleaned == null) return;
    fields[field] = KycOcrFieldValue(
      value: cleaned,
      confidence: KycOcrConfidence.high,
    );
  }

  static String? _valueForPatterns(
    List<String> lines,
    Iterable<RegExp> patterns,
  ) {
    for (var i = 0; i < lines.length; i++) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(lines[i]);
        if (match == null) continue;
        final sameLine = _cleanCandidate(match.group(1));
        if (sameLine != null && !_isFormatHint(sameLine)) return sameLine;
        final next = _nextValue(lines, i);
        if (next != null) return next;
      }
    }
    return null;
  }

  static String? _valueForLabeledBlock(
    List<String> lines,
    Iterable<RegExp> patterns,
  ) {
    for (var i = 0; i < lines.length; i++) {
      for (final pattern in patterns) {
        final match = pattern.firstMatch(lines[i]);
        if (match == null) continue;
        final sameLine = _cleanCandidate(match.group(1));
        if (sameLine != null && !_isFormatHint(sameLine)) return sameLine;

        final values = <String>[];
        for (var j = i + 1; j < lines.length && j <= i + 4; j++) {
          final candidate = _cleanCandidate(lines[j]);
          if (candidate == null) continue;
          if (_isStandaloneLabel(candidate)) break;
          values.add(candidate);
        }
        if (values.isNotEmpty) return values.join(', ');
      }
    }
    return null;
  }

  static String? _nextValue(List<String> lines, int index) {
    for (var i = index + 1; i < lines.length && i <= index + 3; i++) {
      final candidate = _cleanCandidate(lines[i]);
      if (candidate == null ||
          _isStandaloneLabel(candidate) ||
          _isFormatHint(candidate)) {
        continue;
      }
      return candidate;
    }
    return null;
  }

  static List<String> _lines(String rawText) => rawText
      .split(RegExp(r'\r?\n'))
      .map((line) => line.replaceAll(RegExp(r'\s+'), ' ').trim())
      .where((line) => line.isNotEmpty)
      .toList();

  static String? _cleanCandidate(String? value) {
    if (value == null) return null;
    final cleaned = value
        .replaceAll(RegExp(r'^\s*[:#\-]+\s*'), '')
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();
    return cleaned.isEmpty ? null : cleaned;
  }

  static bool _isFormatHint(String value) => RegExp(
    r'^\(?\s*(?:MM|DD|YYYY|MM/DD/YYYY|DD/MM/YYYY|MMDDYYYY)(?:[/.\-](?:MM|DD|YYYY))?\s*\)?$',
    caseSensitive: false,
  ).hasMatch(value);

  static bool _isStandaloneLabel(String value) => RegExp(
    r'^(?:passport|surname|last name|apelyido|first name|given names?|mga pangalan|pangalan|middle name|gitnang (?:name|pangalan|apelyido)|full name|date of birth|petsa ng kapanganakan|birth date|sex|gender|kasarian|nationality|citizenship|nasyonalidad|civil status|marital status|katayuang sibil|address|present address|current address|residential address|tirahan|city|municipality|city\s*/?\s*municipality|lungsod|munisipalidad|province|probinsya|zip|zip code|postal code|passport no\.?|passport number|license no\.?|license number|registration no\.?|registration number|crn|ss number|sss no\.?|pcn|psn|philsys card number|philid number|national id number)\s*(?:\([^)]*\))?\s*[:.\-]?$',
    caseSensitive: false,
  ).hasMatch(value);

  static String? _normalizeDate(String? value) {
    final cleaned = _cleanCandidate(value);
    if (cleaned == null) return null;

    final textual = RegExp(
      r'^(\d{1,2})\s+([A-Za-z]{3,9})\s+(\d{4})$',
    ).firstMatch(cleaned);
    if (textual != null) {
      return _dateIso(
        int.parse(textual.group(3)!),
        _monthNumber(textual.group(2)!),
        int.parse(textual.group(1)!),
      );
    }

    final textualReversed = RegExp(
      r'^([A-Za-z]{3,9})\s+(\d{1,2}),?\s+(\d{4})$',
    ).firstMatch(cleaned);
    if (textualReversed != null) {
      return _dateIso(
        int.parse(textualReversed.group(3)!),
        _monthNumber(textualReversed.group(1)!),
        int.parse(textualReversed.group(2)!),
      );
    }

    final yearFirst = RegExp(
      r'^(\d{4})[/.\-](\d{1,2})[/.\-](\d{1,2})$',
    ).firstMatch(cleaned);
    if (yearFirst != null) {
      return _dateIso(
        int.parse(yearFirst.group(1)!),
        int.parse(yearFirst.group(2)!),
        int.parse(yearFirst.group(3)!),
      );
    }

    final monthFirst = RegExp(
      r'^(\d{1,2})[/.\-](\d{1,2})[/.\-](\d{4})$',
    ).firstMatch(cleaned);
    if (monthFirst != null) {
      return _dateIso(
        int.parse(monthFirst.group(3)!),
        int.parse(monthFirst.group(1)!),
        int.parse(monthFirst.group(2)!),
      );
    }

    final umid = RegExp(r'^(\d{2})(\d{2})(\d{4})$').firstMatch(cleaned);
    if (umid != null) {
      return _dateIso(
        int.parse(umid.group(3)!),
        int.parse(umid.group(1)!),
        int.parse(umid.group(2)!),
      );
    }
    return null;
  }

  static String? _mrzDate(String? value) {
    if (value == null || !RegExp(r'^\d{6}$').hasMatch(value)) return null;
    final year = int.parse(value.substring(0, 2));
    final month = int.parse(value.substring(2, 4));
    final day = int.parse(value.substring(4, 6));
    return _dateIso(year >= 50 ? 1900 + year : 2000 + year, month, day);
  }

  static String? _dateIso(int year, int month, int day) {
    if (month < 1 || month > 12 || day < 1 || day > 31) return null;
    final date = DateTime(year, month, day);
    if (date.year != year || date.month != month || date.day != day) {
      return null;
    }
    return '${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
  }

  static int _monthNumber(String value) =>
      switch (value.toLowerCase().substring(0, 3)) {
        'jan' => 1,
        'feb' => 2,
        'mar' => 3,
        'apr' => 4,
        'may' => 5,
        'jun' => 6,
        'jul' => 7,
        'aug' => 8,
        'sep' => 9,
        'oct' => 10,
        'nov' => 11,
        'dec' => 12,
        'ene' => 1,
        'peb' => 2,
        'abr' => 4,
        'hun' => 6,
        'hul' => 7,
        'ago' => 8,
        'set' => 9,
        'okt' => 10,
        'dis' => 12,
        _ => 0,
      };

  static String? _sexValue(String? value) {
    final lower = value?.trim().toLowerCase();
    return switch (lower) {
      'm' || 'male' || 'lalaki' => 'male',
      'f' || 'female' || 'babae' => 'female',
      _ => null,
    };
  }

  static String? _nationalityValue(String? value) {
    final cleaned = _cleanCandidate(value);
    if (cleaned == null) return null;
    return cleaned.toUpperCase() == 'PHL' ? 'Filipino' : cleaned;
  }
}

abstract class KycOcrService {
  Future<KycOcrResult> scan({
    required IdType idType,
    required String imagePath,
  });

  Future<void> close();
}

class GoogleMlKitKycOcrService implements KycOcrService {
  final TextRecognizer _textRecognizer;

  GoogleMlKitKycOcrService({TextRecognizer? textRecognizer})
    : _textRecognizer =
          textRecognizer ?? TextRecognizer(script: TextRecognitionScript.latin);

  @override
  Future<KycOcrResult> scan({
    required IdType idType,
    required String imagePath,
  }) async {
    final inputImage = InputImage.fromFilePath(imagePath);
    final recognizedText = await _textRecognizer.processImage(inputImage);
    return KycOcrParser.parse(idType, recognizedText.text);
  }

  @override
  Future<void> close() => _textRecognizer.close();
}

final kycOcrServiceProvider = Provider<KycOcrService>((ref) {
  final service = GoogleMlKitKycOcrService();
  ref.onDispose(() {
    unawaited(service.close());
  });
  return service;
});

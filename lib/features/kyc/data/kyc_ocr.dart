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
    IdType.postal,
    IdType.gsisECard,
    IdType.voters,
    IdType.philHealth,
    IdType.prcProfessionalId,
  };

  static final _surnamePatterns = [
    RegExp(
      r'\b(?:surname|last\s+name|apelyido(?:\s*/\s*last\s+name)?)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _givenNamePatterns = [
    RegExp(
      r'\b(?:given\s+names?|first\s+name|mga\s+pangalan(?:\s*/\s*given\s+names?)?|pangalan)\b\s*[:\-]?\s*(.*)',
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
  static final _driversLicenseAddressPatterns = [
    ..._addressPatterns,
    RegExp(
      r'\b(?:house\s*(?:no\.?|number)|house\s*(?:no\.?|number)?\s*[/&]\s*street|street\s*/\s*barangay)\b\s*[:\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _driversLicenseDateOfBirthPatterns = [
    ..._dateOfBirthPatterns,
    RegExp(r'\b(?:birthdate|dob)\b\s*[:\-]?\s*(.*)', caseSensitive: false),
  ];
  static final _driversLicenseExpiryPatterns = [
    ..._expiryPatterns,
    RegExp(r'\b(?:expiry|expiration)\b\s*[:\-]?\s*(.*)', caseSensitive: false),
  ];
  static final _nationalIdAddressPatterns = [
    RegExp(
      r'\b(?:present\s+address|current\s+address|residential\s+address|address|tirahan(?:\s*/\s*address)?|kasalukuyang\s+tirahan)\b\s*[:\-]?\s*(.*)',
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
      case IdType.postal:
        _parsePostal(lines, fields);
      case IdType.gsisECard:
        _parseGsisECard(lines, fields);
      case IdType.voters:
        _parseVoters(lines, fields);
      case IdType.philHealth:
        _parsePhilHealth(lines, fields);
      case IdType.prcProfessionalId:
        _parsePrc(lines, fields);
      case IdType.sss:
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
    _addText(fields, KycOcrField.address, _nationalIdAddressValue(lines));
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
    _addId(fields, _nationalIdNumberValue(lines), allowMasked: true);
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
      _valueForPatterns(lines, _driversLicenseDateOfBirthPatterns),
    );
    _addSex(fields, _valueForPatterns(lines, _sexPatterns));
    _addNationality(fields, _valueForPatterns(lines, _nationalityPatterns));
    if (_containsDriversLicenseEvidence(lines)) {
      _addText(
        fields,
        KycOcrField.address,
        _valueForLabeledBlock(lines, _driversLicenseAddressPatterns),
      );
    }
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
    _addId(fields, _valueForPatterns(lines, _driversLicenseNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _driversLicenseExpiryPatterns),
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

  static void _parsePostal(
    List<String> lines,
    Map<KycOcrField, KycOcrFieldValue> fields,
  ) {
    _parseNames(lines, fields);
    _addDate(
      fields,
      KycOcrField.dateOfBirth,
      _valueForPatterns(lines, _dateOfBirthPatterns),
    );
    _addNationality(fields, _valueForPatterns(lines, _nationalityPatterns));
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
    _addId(fields, _valueForPatterns(lines, _postalNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _expiryPatterns),
    );
  }

  static void _parseGsisECard(
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
    _addId(fields, _valueForPatterns(lines, _gsisNumberPatterns));
    _addDate(
      fields,
      KycOcrField.idExpiryDate,
      _valueForPatterns(lines, _gsisExpiryPatterns),
    );
  }

  static void _parseVoters(
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
    _addId(fields, _valueForPatterns(lines, _voterNumberPatterns));
  }

  static void _parsePhilHealth(
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
    _addId(fields, _valueForPatterns(lines, _philHealthNumberPatterns));
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
  static final _driversLicenseNumberPatterns = [
    ..._licenseNumberPatterns,
    RegExp(
      r'\b(?:dl|lic\.?)\s*(?:no\.?|number|#)\s*[:#\-]?\s*(.*)',
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
  static final _postalNumberPatterns = [
    RegExp(
      r'\bpostal\s+reference\s+(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
    RegExp(r'\bprn\s*[:#\-]?\s*(.*)', caseSensitive: false),
  ];
  static final _gsisNumberPatterns = [
    RegExp(
      r'\bgsis\s+(?:id|member)\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
    RegExp(r'\bgsis\s+id\s*[:#\-]\s*(.*)', caseSensitive: false),
    RegExp(
      r'\bmember\s*(?:no\.?|number)\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];
  static final _gsisExpiryPatterns = [
    RegExp(
      r'\bvalid\s+(?:thru|through)\b\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
    ..._expiryPatterns,
  ];
  static final _voterNumberPatterns = [
    RegExp(r'\bvin\s*[:#\-]?\s*(.*)', caseSensitive: false),
    RegExp(
      r"\bvoter(?:'|’)?s?\s+(?:identification\s+)?(?:id\s+)?(?:no\.?|number)\s*[:#\-]?\s*(.*)",
      caseSensitive: false,
    ),
  ];
  static final _philHealthNumberPatterns = [
    RegExp(r'\bpin\s*[:#\-]?\s*(.*)', caseSensitive: false),
    RegExp(
      r'\bphilhealth\s+(?:identification\s+)?(?:no\.?|number)(?:\s*\(pin\))?\s*[:#\-]?\s*(.*)',
      caseSensitive: false,
    ),
  ];

  static String? _nationalIdNumberValue(List<String> lines) {
    final labeled = _valueForPatterns(lines, _nationalIdNumberPatterns);
    if (labeled != null) return labeled;

    for (final line in lines) {
      final candidate = _cleanCandidate(line);
      if (candidate != null && _isNationalIdNumber(candidate)) {
        return candidate;
      }
    }
    return null;
  }

  static bool _containsDriversLicenseEvidence(List<String> lines) => lines.any((
    line,
  ) {
    final normalized = _normalizedLabel(line);
    return RegExp(
      r'\b(?:driver s license|professional driver s license|non professional driver s license|land transportation office|lto|license no|license number|lic no|lic number|dl no|dl number|expiry|expiration)\b',
      caseSensitive: false,
    ).hasMatch(normalized);
  });

  static String? _nationalIdAddressValue(List<String> lines) {
    for (var i = 0; i < lines.length; i++) {
      for (final pattern in _nationalIdAddressPatterns) {
        final match = pattern.firstMatch(lines[i]);
        if (match == null) continue;

        final sameLine = _cleanCandidate(match.group(1));
        if (sameLine != null &&
            !_isFormatHint(sameLine) &&
            !_isNationalIdAddressNoise(sameLine) &&
            !_isPlaceholderValue(sameLine) &&
            !_isNationalIdAddressBoundary(sameLine)) {
          return sameLine;
        }

        final values = <String>[];
        var skipNextLabeledValue = false;
        for (var j = i + 1; j < lines.length; j++) {
          final candidate = _cleanCandidate(lines[j]);
          if (candidate == null) continue;
          if (skipNextLabeledValue) {
            skipNextLabeledValue = false;
            continue;
          }
          if (_isNationalIdIdentityLabel(candidate)) {
            skipNextLabeledValue = _isNationalIdIdentityLabelOnly(candidate);
            continue;
          }
          if (_isNationalIdAddressNoise(candidate)) {
            skipNextLabeledValue = RegExp(
              r'^(?:pcn|psn|philsys card number|philid number|national id number)$',
              caseSensitive: false,
            ).hasMatch(_normalizedLabel(candidate));
            continue;
          }
          if (_isNationalIdAddressBoundary(candidate)) break;
          if (_isPlaceholderValue(candidate)) continue;
          values.add(candidate);
        }
        if (values.isNotEmpty && values.any(_looksLikeAddressLine)) {
          return values.join(', ');
        }
      }
    }
    return null;
  }

  static bool _isNationalIdNumber(String value) => RegExp(
    r'^\d{4}\s*-\s*[0-9_*]{4}(?:\s*-\s*(?:\d{4}|[0-9_*]{4})){2}$',
  ).hasMatch(value);

  static bool _isNationalIdAddressNoise(String value) {
    final normalized = _normalizedLabel(value);
    return normalized.contains('pambansang pagkakakilanlan') ||
        normalized.contains('philippine identification card') ||
        normalized.contains('philippine identification') ||
        normalized == 'republic of the philippines' ||
        normalized == 'republika ng pilipinas' ||
        normalized == 'reoublic of the philippines' ||
        _isNationalIdAddressTemplate(value) ||
        RegExp(
          r'^(?:shif t|shift|cirl)$',
          caseSensitive: false,
        ).hasMatch(normalized) ||
        _isNationalIdNumber(value) ||
        _isNationalIdIdentityLabel(value) ||
        RegExp(
          r'^(?:pcn|psn|philsys card number|philid number|national id number)\b',
          caseSensitive: false,
        ).hasMatch(normalized);
  }

  static bool _isNationalIdAddressBoundary(String value) {
    if (_isPlaceholderValue(value) &&
        !_isStandaloneLabel(value) &&
        !_isLabeledField(value)) {
      return false;
    }
    if (_isStandaloneLabel(value) || _isLabeledField(value)) return true;

    final normalized = _normalizedLabel(value);
    return RegExp(
      r'^(?:surname|last name|apelyido|apelyido last name|first name|given names?|mga pangalan|mga pangalan given names?|pangalan|middle name|gitnang name|gitnang pangalan|date of birth|petsa ng kapanganakan|petsa ng kapanganakan date of birth|birth date|sex|gender|kasarian|nationality|citizenship|nasyonalidad|civil status|marital status|katayuang sibil|address|present address|current address|residential address|tirahan|tirahan address|kasalukuyang tirahan|city|municipality|city municipality|lungsod|munisipalidad|province|probinsya|zip|zip code|postal code|pcn|psn|philsys card number|philid number|national id number)$',
      caseSensitive: false,
    ).hasMatch(normalized);
  }

  static bool _isNationalIdAddressTemplate(String value) {
    final normalized = _normalizedLabel(value);
    return RegExp(
      r'^(?:house no street|house number street|house number barangay city municipality|house no street barangay city municipality|house number street barangay city municipality)$',
      caseSensitive: false,
    ).hasMatch(normalized);
  }

  static bool _isNationalIdIdentityLabel(String value) => RegExp(
    r'^(?:surname|last name|apelyido(?: last name)?|first name|given names?|mga pangalan(?: given names?)?|pangalan|middle name|gitnang name|gitnang pangalan|gitnang apelyido)\b',
    caseSensitive: false,
  ).hasMatch(_normalizedLabel(value));

  static bool _isNationalIdIdentityLabelOnly(String value) => RegExp(
    r'^(?:surname|last name|apelyido(?: last name)?|first name|given names?|mga pangalan(?: given names?)?|pangalan|middle name|gitnang name|gitnang pangalan|gitnang apelyido)$',
    caseSensitive: false,
  ).hasMatch(_normalizedLabel(value));

  static String _normalizedLabel(String value) =>
      value.toLowerCase().replaceAll(RegExp(r'[^a-z0-9]+'), ' ').trim();

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

  static void _addId(
    Map<KycOcrField, KycOcrFieldValue> fields,
    String? value, {
    bool allowMasked = false,
  }) {
    final cleaned = _cleanCandidate(value)?.replaceAll(
      RegExp(allowMasked ? r'[^A-Za-z0-9_* -]' : r'[^A-Za-z0-9 -]'),
      '',
    );
    if (cleaned == null || cleaned.trim().length < 4) return;
    fields.putIfAbsent(
      KycOcrField.idNumber,
      () => KycOcrFieldValue(
        value: cleaned.trim(),
        confidence: allowMasked && RegExp(r'[_*]').hasMatch(cleaned)
            ? KycOcrConfidence.review
            : KycOcrConfidence.high,
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
        if (sameLine != null &&
            !_isFormatHint(sameLine) &&
            !_isPlaceholderValue(sameLine)) {
          return sameLine;
        }
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
        if (sameLine != null &&
            !_isFormatHint(sameLine) &&
            !_isAddressNoise(sameLine)) {
          return sameLine;
        }

        final values = <String>[];
        var hasAddressComponent = false;
        for (var j = i + 1; j < lines.length && j <= i + 6; j++) {
          final candidate = _cleanCandidate(lines[j]);
          if (candidate == null) continue;

          if (_isDocumentHeader(candidate) ||
              _isNationalIdAddressNoise(candidate)) {
            continue;
          }
          if (_isStandaloneAddressComponentLabel(candidate) &&
              !RegExp(r'[:\-]').hasMatch(candidate)) {
            continue;
          }
          final addressComponent = _addressComponentValue(candidate);
          if (addressComponent != null) {
            values.add(addressComponent);
            hasAddressComponent = true;
            continue;
          }
          if (_isStandaloneAddressComponentLabel(candidate)) continue;
          if (_isAddressBoundary(candidate)) {
            break;
          }
          if (_isPlaceholderValue(candidate)) continue;
          values.add(candidate);
        }
        if (values.isNotEmpty &&
            (hasAddressComponent || values.any(_looksLikeAddressLine))) {
          return values.join(', ');
        }
      }
    }
    return null;
  }

  static String? _nextValue(List<String> lines, int index) {
    for (var i = index + 1; i < lines.length && i <= index + 3; i++) {
      final candidate = _cleanCandidate(lines[i]);
      if (candidate == null ||
          _isStandaloneLabel(candidate) ||
          _isStandaloneAddressComponentLabel(candidate) ||
          _isDocumentHeader(candidate) ||
          _isLabeledField(candidate) ||
          _isPlaceholderValue(candidate) ||
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

  static bool _isPlaceholderValue(String value) {
    final normalized = value
        .replaceFirst(RegExp(r'^[^A-Za-z0-9]+'), '')
        .replaceAll(RegExp(r'[^A-Za-z0-9]+'), ' ')
        .trim();
    return normalized.isEmpty ||
        _isStandaloneLabel(normalized) ||
        _isStandaloneAddressComponentLabel(normalized) ||
        _isDocumentHeader(normalized);
  }

  static bool _isAddressNoise(String value) =>
      _isAddressBoundary(value) ||
      _isNationalIdAddressNoise(value) ||
      _isPlaceholderValue(value);

  static bool _isAddressBoundary(String value) =>
      !_isStandaloneAddressComponentLabel(value) &&
      _addressComponentValue(value) == null &&
      (_isStandaloneLabel(value) || _isLabeledField(value));

  static bool _isStandaloneAddressComponentLabel(String value) => RegExp(
    r'^(?:house(?: no| number)?(?: street)?|hse(?: no| number)?(?: street)?|street(?: name)?|barangay|brgy|purok|sitio|zone|district)$',
    caseSensitive: false,
  ).hasMatch(_normalizedLabel(value));

  static String? _addressComponentValue(String value) {
    final match = RegExp(
      r'^(?:house\s*(?:no\.?|number)?|hse\s*(?:no\.?|number)?|street(?:\s+name)?|barangay|brgy|purok|sitio|zone|district)(?:\s*[/&]\s*(?:street|barangay))?\s*(?:[:.\-]\s*)+(.+)$',
      caseSensitive: false,
    ).firstMatch(value);
    return _cleanCandidate(match?.group(1));
  }

  static bool _looksLikeAddressLine(String value) => RegExp(
    r'\d|\b(?:street|st\.?|road|rd\.?|avenue|ave\.?|boulevard|blvd\.?|barangay|brgy\.?|purok|sitio|zone|village|subdivision|phase|block|lot|unit|house|hse)\b',
    caseSensitive: false,
  ).hasMatch(value);

  static bool _isDocumentHeader(String value) => RegExp(
    r'^(?:republic of the philippines|department of transportation|land transportation office|lto|driver s license|professional driver s license|non professional driver s license|philippine identification card|philippine identification|pambansang pagkakakilanlan|official receipt)$',
    caseSensitive: false,
  ).hasMatch(_normalizedLabel(value));

  static bool _isStandaloneLabel(String value) => RegExp(
    r'^(?:passport|surname|last name|apelyido|first name|given names?|mga pangalan|pangalan|name|middle name|gitnang (?:name|pangalan|apelyido)|full name|date of birth|petsa ng kapanganakan|birth date|birthdate|dob|sex|gender|kasarian|nationality|citizenship|nasyonalidad|civil status|marital status|katayuang sibil|address|address tirahan|present address|current address|residential address|tirahan|city|municipality|municipality city|city\s*/?\s*municipality|lungsod|munisipalidad|province|probinsya|zip|zip code|postal code|house no\.?|house number|street|street name|barangay|brgy|purok|sitio|zone|district|passport no\.?|passport number|license no\.?|license number|lic no\.?|lic number|dl no\.?|dl number|registration no\.?|registration number|crn|ss number|sss no\.?|pcn|psn|philsys card number|philid number|national id number|postal reference no\.?|postal reference number|prn|gsis id number|gsis id no\.?|member number|member no\.?|vin|precinct no\.?|pin|philhealth identification number|valid until|valid thru|valid through|expiry|expiration|membership category)\s*(?:\([^)]*\))?\s*[:.\-]?$',
    caseSensitive: false,
  ).hasMatch(value);

  static bool _isLabeledField(String value) => RegExp(
    r'^(?:passport|surname|last name|apelyido|first name|given names?|mga pangalan|pangalan|name|middle name|gitnang (?:name|pangalan|apelyido)|full name|date of birth|petsa ng kapanganakan|birth date|birthdate|dob|sex|gender|kasarian|nationality|citizenship|nasyonalidad|civil status|marital status|katayuang sibil|address|address tirahan|present address|current address|residential address|tirahan|city|municipality|municipality\s*/\s*city|city\s*/?\s*municipality|lungsod|munisipalidad|province|probinsya|zip|zip code|postal code|postal reference no\.?|postal reference number|prn|house no\.?|house number|hse no\.?|street|street name|barangay|brgy|purok|sitio|zone|district|passport no\.?|passport number|license no\.?|license number|lic no\.?|lic number|dl no\.?|dl number|registration no\.?|registration number|crn|ss number|sss no\.?|pcn|psn|philsys card number|philid number|national id number|vin|precinct no\.?|pin|philhealth identification number|valid until|valid thru|valid through|expiry|expiration|membership category)\s*[:.\-]',
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

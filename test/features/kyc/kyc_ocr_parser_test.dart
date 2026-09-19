import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_ocr.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

void _expectPartial(IdType idType, String text, KycOcrField field) {
  final result = KycOcrParser.parse(idType, text);

  expect(result.status, KycOcrResultStatus.partial);
  expect(result.fields[field], isNotNull);
  expect(result.fields.length, 1);
}

void _expectUnreadable(IdType idType) {
  final result = KycOcrParser.parse(idType, '   \n   ');

  expect(result.status, KycOcrResultStatus.unreadable);
  expect(result.fields, isEmpty);
}

String _sanitizedRawOcr(String rawText) => rawText
    .split(RegExp(r'\r?\n'))
    .map((line) {
      final trimmed = line.trim();
      if (trimmed.isEmpty) return '<blank>';
      if (RegExp(
        r'^(?:surname|last\s+name|given\s+names?|first\s+name|middle\s+name|date\s+of\s+birth|sex|address|city|municipality|province|zip|zip\s+code|pcn|psn|phil\s*sys|national\s+id)\b',
        caseSensitive: false,
      ).hasMatch(trimmed)) {
        return trimmed.replaceFirst(RegExp(r'[:#].*$'), ': <value>');
      }
      return '<value>';
    })
    .join('\n');

void main() {
  group('PhilSys / National ID OCR', () {
    test(
      'dispatches national_id key and extracts identity, address, and PCN',
      () {
        const rawText = '''
REPUBLIC OF THE PHILIPPINES
PHILIPPINE IDENTIFICATION CARD
SURNAME
DELA CRUZ
GIVEN NAME
JUAN
MIDDLE NAME
SANTOS
DATE OF BIRTH
01 JAN 1990
SEX
M
NATIONALITY
FILIPINO
ADDRESS
123 Mabini Street
Barangay San Antonio
CITY/MUNICIPALITY
Quezon City
PROVINCE
Metro Manila
ZIP CODE
1000
PHILSYS CARD NUMBER
1234-5678-9012
''';

        expect(KycOcrParser.supports(IdType.nationalId), isTrue);
        expect(KycOcrParser.supports(IdType.philsys), isTrue);
        final result = KycOcrParser.parse(IdType.nationalId, rawText);

        expect(result.rawText, rawText);
        expect(result.status, KycOcrResultStatus.extracted);
        expect(result.fields[KycOcrField.firstName]?.value, 'JUAN');
        expect(result.fields[KycOcrField.middleName]?.value, 'SANTOS');
        expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
        expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-01');
        expect(
          result.fields[KycOcrField.address]?.value,
          '123 Mabini Street, Barangay San Antonio',
        );
        expect(
          result.fields[KycOcrField.cityMunicipality]?.value,
          'Quezon City',
        );
        expect(result.fields[KycOcrField.province]?.value, 'Metro Manila');
        expect(result.fields[KycOcrField.zipCode]?.value, '1000');
        expect(result.fields[KycOcrField.idNumber]?.value, '1234-5678-9012');
        expect(result.fields[KycOcrField.idExpiryDate], isNull);

        final philsys = KycOcrParser.parse(IdType.philsys, rawText);
        expect(philsys.fields[KycOcrField.idNumber]?.value, '1234-5678-9012');
        expect(
          philsys.fields[KycOcrField.address]?.value,
          '123 Mabini Street, Barangay San Antonio',
        );
      },
    );

    test('captures sanitized raw OCR and rejects /Address placeholder', () {
      const rawText = '''
REPUBLIC OF THE PHILIPPINES
PHILIPPINE IDENTIFICATION CARD
SURNAME
DELA CRUZ
GIVEN NAME
JUAN
MIDDLE NAME
SANTOS
DATE OF BIRTH
01 JAN 1990
SEX
M
ADDRESS
/Address
123 Mabini Street
Barangay San Antonio
CITY/MUNICIPALITY
Quezon City
PROVINCE
Metro Manila
ZIP CODE
1000
PCN
1234-5678-9012
''';

      // Debug-only evidence: values are redacted; labels/line structure remain.
      debugPrint('Sanitized National ID OCR:\n${_sanitizedRawOcr(rawText)}');
      final result = KycOcrParser.parse(IdType.nationalId, rawText);

      expect(result.fields[KycOcrField.firstName]?.value, 'JUAN');
      expect(result.fields[KycOcrField.middleName]?.value, 'SANTOS');
      expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
      expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-01');
      expect(
        result.fields[KycOcrField.address]?.value,
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(result.fields[KycOcrField.cityMunicipality]?.value, 'Quezon City');
      expect(result.fields[KycOcrField.province]?.value, 'Metro Manila');
      expect(result.fields[KycOcrField.zipCode]?.value, '1000');
      expect(result.fields[KycOcrField.idNumber]?.value, '1234-5678-9012');
      expect(result.fields[KycOcrField.idExpiryDate], isNull);
      expect(
        result.fields.values.map((field) => field.value),
        isNot(contains('/Address')),
      );

      final sameLinePlaceholder = KycOcrParser.parse(
        IdType.nationalId,
        rawText.replaceFirst('ADDRESS\n/Address', 'ADDRESS: /Address'),
      );
      expect(
        sameLinePlaceholder.fields[KycOcrField.address]?.value,
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(
        KycOcrParser.parse(IdType.nationalId, 'ADDRESS: /Address').fields,
        isEmpty,
      );
    });

    test('separates PhilSys header, masked PCN, and address block', () {
      const rawText = '''
PAMBANSANG PAGKAKAKILANLAN
PHILIPPINE IDENTIFICATION CARD
APELYIDO/LAST NAME
DELA CRUZ
GIVEN NAMES
JUAN
MIDDLE NAME
SANTOS
DATE OF BIRTH
01 JAN 1990
SEX
M
ADDRESS
PAMBANSANG PAGKAKAKILANLAN
PHILIPPINE IDENTIFICATION CARD
5915-____-5187-____
123 Mabini Street
Barangay San Antonio
CITY/MUNICIPALITY
Quezon City
PROVINCE
Metro Manila
''';

      debugPrint('Sanitized PhilSys fixture:\n${_sanitizedRawOcr(rawText)}');
      final result = KycOcrParser.parse(IdType.philsys, rawText);

      expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
      expect(result.fields[KycOcrField.firstName]?.value, 'JUAN');
      expect(result.fields[KycOcrField.middleName]?.value, 'SANTOS');
      expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-01');
      expect(result.fields[KycOcrField.sex]?.value, 'male');
      expect(
        result.fields[KycOcrField.address]?.value,
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(result.fields[KycOcrField.idNumber]?.value, '5915-____-5187-____');
      expect(
        result.fields[KycOcrField.idNumber]?.confidence,
        KycOcrConfidence.review,
      );
      expect(result.fields[KycOcrField.idExpiryDate], isNull);
      expect(
        result.fields[KycOcrField.address]?.value,
        isNot(contains('PAMBANSANG PAGKAKILANLAN')),
      );
      expect(
        result.fields[KycOcrField.address]?.value,
        isNot(contains('PHILIPPINE IDENTIFICATION CARD')),
      );
      expect(
        result.fields[KycOcrField.address]?.value,
        isNot(contains('5915-____-5187-____')),
      );
    });

    test('leaves an ambiguous PhilSys address blank', () {
      final result = KycOcrParser.parse(IdType.nationalId, '''
ADDRESS
PAMBANSANG PAGKAKAKILANLAN
PHILIPPINE IDENTIFICATION CARD
5915-____-5187-____
APELYIDO/LAST NAME
''');

      expect(result.fields[KycOcrField.address], isNull);
      expect(result.fields[KycOcrField.idNumber]?.value, '5915-____-5187-____');
    });

    test('rejects PhilSys document labels from House No. / Street', () {
      final result = KycOcrParser.parse(IdType.nationalId, '''
TIRAHAN/ADDRESS
REPUBLIKA NG PILIPINAS
Reoublic of the Philippines
Philippine Identification Card
SHIF T
SURNAME
LASTNAME
MIDDLE NAME
MIDDLE
HOUSE NUMBER, BARANGAY, CITY/MUNICIPALITY
PANGASINAN
CIRL
Petsa ng Kapanganakan/Date of Birth
01 JAN 1990
''');

      expect(result.fields[KycOcrField.address], isNull);
    });

    test('rejects labeled PhilSys noise before real address', () {
      final result = KycOcrParser.parse(IdType.nationalId, '''
TIRAHAN/ADDRESS
Philippine Identification Card
PCN: 5915-1234-5187-9876
Apelyido/Last Name: DELA CRUZ
123 Mabini Street
Barangay San Antonio
CITY/MUNICIPALITY: Quezon City
PROVINCE: Metro Manila
ZIP CODE: 1000
''');

      expect(
        result.fields[KycOcrField.address]?.value,
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(result.fields[KycOcrField.idNumber]?.value, '5915-1234-5187-9876');
    });

    test(
      'same National ID OCR routes differently from driver license parser',
      () {
        const rawText = '''
SURNAME
DELA CRUZ
GIVEN NAME
JUAN
DATE OF BIRTH
01 JAN 1990
ADDRESS
/Address
123 Mabini Street
PCN
1234-5678-9012
''';

        final national = KycOcrParser.parse(IdType.nationalId, rawText);
        final driver = KycOcrParser.parse(IdType.driversLicense, rawText);

        expect(
          national.fields[KycOcrField.address]?.value,
          '123 Mabini Street',
        );
        expect(national.fields[KycOcrField.idNumber]?.value, '1234-5678-9012');
        expect(driver.fields[KycOcrField.firstName]?.value, 'JUAN');
        expect(driver.fields[KycOcrField.dateOfBirth]?.value, '1990-01-01');
        expect(driver.fields[KycOcrField.address], isNull);
        expect(driver.fields[KycOcrField.idNumber], isNull);
      },
    );

    test('does not route same text through driver license parser', () {
      const text = 'PHILSYS CARD NUMBER: 1234-5678-9012\nADDRESS: Cebu City';
      final national = KycOcrParser.parse(IdType.nationalId, text);
      final driver = KycOcrParser.parse(IdType.driversLicense, text);

      expect(national.fields[KycOcrField.idNumber]?.value, '1234-5678-9012');
      expect(national.fields[KycOcrField.address]?.value, 'Cebu City');
      expect(driver.fields[KycOcrField.idNumber], isNull);
      expect(driver.fields[KycOcrField.address], isNull);
    });

    test('keeps National ID partial and unreadable input manual', () {
      _expectPartial(
        IdType.nationalId,
        'PCN: 1234-5678-9012',
        KycOcrField.idNumber,
      );
      _expectUnreadable(IdType.nationalId);
    });
  });

  group('Philippine Passport OCR', () {
    test('extracts labeled fields and MRZ-safe values', () {
      final result = KycOcrParser.parse(IdType.passport, '''
PASSPORT
Surname
DELA CRUZ
Given Names
JUAN
Middle Name
SANTOS
Date of Birth
30 SEP 1990
Sex
M
Nationality
FILIPINO
Passport No.
D0009237A
Date of Expiry
06 DEC 2030
''');

      expect(result.status, KycOcrResultStatus.extracted);
      expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
      expect(result.fields[KycOcrField.firstName]?.value, 'JUAN');
      expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-09-30');
      expect(result.fields[KycOcrField.idNumber]?.value, 'D0009237A');
      expect(result.fields[KycOcrField.idExpiryDate]?.value, '2030-12-06');
    });

    test('keeps partial extraction reviewable', () {
      _expectPartial(
        IdType.passport,
        'Passport No.: D0009237A',
        KycOcrField.idNumber,
      );
    });

    test('does not guess from an unreadable image', () {
      _expectUnreadable(IdType.passport);
    });
  });

  group('LTO Driver’s License OCR', () {
    test('extracts supported identity and license fields', () {
      final result = KycOcrParser.parse(IdType.driversLicense, '''
Last Name: REYES
First Name: ANA
Middle Name: MARIA
Date of Birth: 1990/01/02
Sex: F
Nationality: PHL
License No.: N01-23-456789
Expiration Date: 2030/01/02
''');

      expect(result.status, KycOcrResultStatus.extracted);
      expect(result.fields[KycOcrField.firstName]?.value, 'ANA');
      expect(result.fields[KycOcrField.sex]?.value, 'female');
      expect(result.fields[KycOcrField.nationality]?.value, 'Filipino');
      expect(result.fields[KycOcrField.idNumber]?.value, 'N01-23-456789');
      expect(result.fields[KycOcrField.idExpiryDate]?.value, '2030-01-02');
    });

    test('extracts present LTO address fields without header text', () {
      const rawText = '''
REPUBLIC OF THE PHILIPPINES
DEPARTMENT OF TRANSPORTATION
LAND TRANSPORTATION OFFICE
DRIVER'S LICENSE
LAST NAME
REYES
FIRST NAME
ANA
MIDDLE NAME
MARIA
BIRTHDATE
1990/01/02
ADDRESS
123 Mabini Street
Barangay San Antonio
CITY/MUNICIPALITY
Quezon City
PROVINCE
Metro Manila
ZIP CODE
1000
LICENSE NO.
N01-23-456789
EXPIRY
2030/01/02
''';

      final result = KycOcrParser.parse(IdType.driversLicense, rawText);

      expect(result.status, KycOcrResultStatus.extracted);
      expect(result.fields[KycOcrField.firstName]?.value, 'ANA');
      expect(result.fields[KycOcrField.middleName]?.value, 'MARIA');
      expect(result.fields[KycOcrField.lastName]?.value, 'REYES');
      expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-02');
      expect(
        result.fields[KycOcrField.address]?.value,
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(result.fields[KycOcrField.cityMunicipality]?.value, 'Quezon City');
      expect(result.fields[KycOcrField.province]?.value, 'Metro Manila');
      expect(result.fields[KycOcrField.zipCode]?.value, '1000');
      expect(result.fields[KycOcrField.idNumber]?.value, 'N01-23-456789');
      expect(result.fields[KycOcrField.idExpiryDate]?.value, '2030-01-02');
      expect(
        result.fields[KycOcrField.address]?.value,
        isNot(
          anyOf(contains('LAND TRANSPORTATION OFFICE'), contains('DRIVER')),
        ),
      );
    });

    test('leaves header-only address evidence blank for review', () {
      final result = KycOcrParser.parse(IdType.driversLicense, '''
DRIVER'S LICENSE
ADDRESS
HOUSE NO. / STREET
LAND TRANSPORTATION OFFICE
LICENSE NO.
''');

      expect(result.fields[KycOcrField.address], isNull);
      expect(
        result.fields.values.map((field) => field.value),
        isNot(contains('HOUSE NO. / STREET')),
      );
      expect(
        result.fields.values.map((field) => field.value),
        isNot(contains('LAND TRANSPORTATION OFFICE')),
      );
    });

    test('keeps partial extraction reviewable', () {
      _expectPartial(
        IdType.driversLicense,
        'License No.: N01-23-456789',
        KycOcrField.idNumber,
      );
    });

    test('does not guess from an unreadable image', () {
      _expectUnreadable(IdType.driversLicense);
    });
  });

  group('UMID OCR', () {
    test('extracts CRN and demographic fields', () {
      final result = KycOcrParser.parse(IdType.umid, '''
SURNAME
DELA CRUZ
GIVEN NAME
JUAN
MIDDLE NAME
SANTOS
DATE OF BIRTH
01021990
SEX
F
CIVIL STATUS
MARRIED
CRN
1234-5678901-2
''');

      expect(result.status, KycOcrResultStatus.extracted);
      expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
      expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-02');
      expect(result.fields[KycOcrField.civilStatus]?.value, 'married');
      expect(result.fields[KycOcrField.idNumber]?.value, '1234-5678901-2');
    });

    test('keeps partial extraction reviewable', () {
      _expectPartial(IdType.umid, 'CRN: 1234-5678901-2', KycOcrField.idNumber);
    });

    test('does not guess from an unreadable image', () {
      _expectUnreadable(IdType.umid);
    });
  });

  group('PRC Professional ID OCR', () {
    test('extracts registration identity and validity fields', () {
      final result = KycOcrParser.parse(IdType.prcProfessionalId, '''
Full Name: DELA CRUZ, JUAN SANTOS
Date of Birth: 02/01/1990
Registration No.: 1234567
PIC Validity: 2030/02/01
''');

      expect(result.status, KycOcrResultStatus.extracted);
      expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
      expect(result.fields[KycOcrField.firstName]?.value, 'JUAN SANTOS');
      expect(result.fields[KycOcrField.idNumber]?.value, '1234567');
      expect(result.fields[KycOcrField.idExpiryDate]?.value, '2030-02-01');
    });

    test('keeps partial extraction reviewable', () {
      _expectPartial(
        IdType.prcProfessionalId,
        'Registration No.: 1234567',
        KycOcrField.idNumber,
      );
    });

    test('does not guess from an unreadable image', () {
      _expectUnreadable(IdType.prcProfessionalId);
    });
  });

  group('additional Philippine government ID OCR', () {
    test('Postal ID maps identity, address, PRN, and validity', () {
      final result = KycOcrParser.parse(IdType.postal, '''
PHILIPPINE POSTAL ID
NAME: DELA CRUZ, JUAN SANTOS
DATE OF BIRTH: 01 JAN 1990
NATIONALITY: FILIPINO
ADDRESS
123 Mabini Street
Barangay San Antonio
CITY/MUNICIPALITY: Quezon City
PROVINCE: Metro Manila
ZIP CODE: 1000
POSTAL REFERENCE NO.: PPN E99 2209719221
VALID UNTIL: 06 DEC 2028
''');

      expect(result.status, KycOcrResultStatus.extracted);
      expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
      expect(result.fields[KycOcrField.firstName]?.value, 'JUAN SANTOS');
      expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-01');
      expect(
        result.fields[KycOcrField.address]?.value,
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(result.fields[KycOcrField.cityMunicipality]?.value, 'Quezon City');
      expect(result.fields[KycOcrField.province]?.value, 'Metro Manila');
      expect(result.fields[KycOcrField.zipCode]?.value, '1000');
      expect(result.fields[KycOcrField.idNumber]?.value, 'PPN E99 2209719221');
      expect(result.fields[KycOcrField.idExpiryDate]?.value, '2028-12-06');
    });

    test(
      'GSIS eCard maps member identity, address, number, and optional validity',
      () {
        final result = KycOcrParser.parse(IdType.gsisECard, '''
GSIS eCARD
SURNAME: DELA CRUZ
FIRST NAME: JUAN
MIDDLE NAME: SANTOS
DATE OF BIRTH: 01/02/1990
SEX: F
ADDRESS: 28 Payapa Street, Bagong Diwa, Caloocan City
GSIS ID NUMBER: 123456789012
VALID THRU: 2030/01/02
''');

        expect(result.status, KycOcrResultStatus.extracted);
        expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
        expect(result.fields[KycOcrField.firstName]?.value, 'JUAN');
        expect(result.fields[KycOcrField.middleName]?.value, 'SANTOS');
        expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-01-02');
        expect(result.fields[KycOcrField.sex]?.value, 'female');
        expect(
          result.fields[KycOcrField.address]?.value,
          '28 Payapa Street, Bagong Diwa, Caloocan City',
        );
        expect(result.fields[KycOcrField.idNumber]?.value, '123456789012');
        expect(result.fields[KycOcrField.idExpiryDate]?.value, '2030-01-02');
      },
    );

    test(
      'Voter ID or certification maps voter identity, address, and VIN without expiry',
      () {
        final result = KycOcrParser.parse(IdType.voters, '''
VOTER'S IDENTIFICATION CARD
LAST NAME: DELA CRUZ
FIRST NAME: JUAN
MIDDLE NAME: SANTOS
DATE OF BIRTH: 02/01/1990
SEX: M
ADDRESS: 123 Mabini Street, Barangay San Antonio, Quezon City
PRECINCT NO.: 0019A
VIN: 7501-0019A-C145BCD
''');

        expect(result.status, KycOcrResultStatus.extracted);
        expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
        expect(result.fields[KycOcrField.firstName]?.value, 'JUAN');
        expect(result.fields[KycOcrField.middleName]?.value, 'SANTOS');
        expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-02-01');
        expect(result.fields[KycOcrField.sex]?.value, 'male');
        expect(
          result.fields[KycOcrField.address]?.value,
          '123 Mabini Street, Barangay San Antonio, Quezon City',
        );
        expect(
          result.fields[KycOcrField.idNumber]?.value,
          '7501-0019A-C145BCD',
        );
        expect(result.fields[KycOcrField.idExpiryDate], isNull);
      },
    );

    test(
      'PhilHealth ID maps PIN, identity, address, and no invented expiry',
      () {
        final result = KycOcrParser.parse(IdType.philHealth, '''
PHILHEALTH IDENTIFICATION CARD
PIN: 02-050329439-8
NAME: DELA CRUZ, JUAN SANTOS
DATE OF BIRTH: 02/01/1990
SEX: MALE
ADDRESS: 29 B5 Sitio Ma Corazon, Santa Cruz, Antipolo City, Rizal 1870
MEMBERSHIP CATEGORY: FORMAL ECONOMY
''');

        expect(result.status, KycOcrResultStatus.extracted);
        expect(result.fields[KycOcrField.lastName]?.value, 'DELA CRUZ');
        expect(result.fields[KycOcrField.firstName]?.value, 'JUAN SANTOS');
        expect(result.fields[KycOcrField.dateOfBirth]?.value, '1990-02-01');
        expect(result.fields[KycOcrField.sex]?.value, 'male');
        expect(
          result.fields[KycOcrField.address]?.value,
          '29 B5 Sitio Ma Corazon, Santa Cruz, Antipolo City, Rizal 1870',
        );
        expect(result.fields[KycOcrField.idNumber]?.value, '02-050329439-8');
        expect(result.fields[KycOcrField.idExpiryDate], isNull);
      },
    );

    test('dispatches each new ID key to its own mapping', () {
      expect(IdType.postal.apiValue, 'postal');
      expect(IdType.gsisECard.apiValue, 'gsis_ecard');
      expect(IdType.voters.apiValue, 'voters');
      expect(IdType.philHealth.apiValue, 'philhealth');
      expect(KycOcrParser.supports(IdType.postal), isTrue);
      expect(KycOcrParser.supports(IdType.gsisECard), isTrue);
      expect(KycOcrParser.supports(IdType.voters), isTrue);
      expect(KycOcrParser.supports(IdType.philHealth), isTrue);

      const postal = 'POSTAL REFERENCE NO.: PRN123456789';
      final postalResult = KycOcrParser.parse(IdType.postal, postal);
      final voterResult = KycOcrParser.parse(IdType.voters, postal);
      expect(postalResult.fields[KycOcrField.idNumber]?.value, 'PRN123456789');
      expect(voterResult.fields[KycOcrField.idNumber], isNull);
    });

    test(
      'keeps partial and unreadable OCR reviewable for every new ID key',
      () {
        _expectPartial(
          IdType.postal,
          'PRN: PRN123456789',
          KycOcrField.idNumber,
        );
        _expectPartial(
          IdType.gsisECard,
          'GSIS ID NUMBER: 123456789012',
          KycOcrField.idNumber,
        );
        _expectPartial(
          IdType.voters,
          'VIN: 7501-0019A-C145BCD',
          KycOcrField.idNumber,
        );
        _expectPartial(
          IdType.philHealth,
          'PIN: 02-050329439-8',
          KycOcrField.idNumber,
        );
        _expectUnreadable(IdType.postal);
        _expectUnreadable(IdType.gsisECard);
        _expectUnreadable(IdType.voters);
        _expectUnreadable(IdType.philHealth);
      },
    );
  });
}

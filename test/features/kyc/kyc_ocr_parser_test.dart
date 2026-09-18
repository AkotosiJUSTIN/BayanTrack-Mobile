import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_ocr.dart';
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

void main() {
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
}

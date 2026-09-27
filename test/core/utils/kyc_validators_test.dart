import 'package:bayantrack_mobile/core/utils/kyc_validators.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KycValidators', () {
    test('normalizes PH numbers and accepts backend international numbers', () {
      expect(KycValidators.normalizeMobileNumber('9123456789'), '09123456789');
      expect(
        KycValidators.normalizeMobileNumber('+639123456789'),
        '09123456789',
      );
      expect(
        KycValidators.normalizeMobileNumber('+14155552671'),
        '+14155552671',
      );
      expect(KycValidators.mobileNumber('9123456789'), isNull);
      expect(KycValidators.mobileNumber('+14155552671'), isNull);
      expect(KycValidators.mobileNumber('+123'), isNotNull);
    });

    test('enforces the KYC age range', () {
      final today = DateTime.now();
      expect(
        KycValidators.dateOfBirth(
          DateTime(today.year - 18, today.month, today.day),
        ),
        isNull,
      );
      expect(
        KycValidators.dateOfBirth(
          DateTime(today.year - 18, today.month, today.day + 1),
        ),
        contains('at least 18'),
      );
      expect(
        KycValidators.dateOfBirth(
          DateTime(today.year - 121, today.month, today.day),
        ),
        contains('Maximum age'),
      );
    });

    test('mirrors backend ID, zip, address, and name rules', () {
      expect(KycValidators.idNumber('AB'), contains('too short'));
      expect(KycValidators.idNumber('AB-12'), isNull);
      expect(KycValidators.zipCode('123'), contains('exactly 4 digits'));
      expect(KycValidators.zipCode('2428'), isNull);
      expect(KycValidators.addressField('A', 'Province'), contains('2'));
      expect(KycValidators.addressField('Calle José', 'Street'), isNull);
      expect(KycValidators.name('Jose O\'Neil'), isNull);
      expect(KycValidators.name('Jos\u00E9 O\'Neil'), isNull);
      expect(KycValidators.name('Juan2'), contains('may only contain'));
      expect(
        KycValidators.addressField(List.filled(255, 'A').join(), 'Street'),
        isNull,
      );
      expect(
        KycValidators.addressField(List.filled(256, 'A').join(), 'Street'),
        isNotNull,
      );
    });

    test('serializes the mobile number in backend format', () {
      const request = KycSubmitRequest(
        firstName: 'Juan',
        lastName: 'Dela Cruz',
        nationality: 'Filipino',
        email: 'juan@example.test',
        mobileNumber: '9123456789',
        streetBarangay: 'Main Street',
        cityMunicipality: 'Urdaneta',
        province: 'Pangasinan',
        idType: IdType.nationalId,
        idNumber: 'AB-12',
        idFrontImagePath: 'front.jpg',
        selfieImagePath: 'selfie.jpg',
      );

      expect(request.toFormDataMap()['mobile_number'], '09123456789');
    });
  });
}

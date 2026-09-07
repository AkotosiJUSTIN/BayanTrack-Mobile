import 'package:bayantrack_mobile/core/utils/kyc_validators.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('KycValidators', () {
    test('normalizes the UI mobile value to local PH format', () {
      expect(KycValidators.normalizeMobileNumber('9123456789'), '09123456789');
      expect(
        KycValidators.normalizeMobileNumber('+639123456789'),
        '09123456789',
      );
      expect(KycValidators.mobileNumber('9123456789'), isNull);
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
      expect(KycValidators.name('Jos\u00E9 O\'Neil'), isNull);
      expect(KycValidators.name('Juan2'), contains('may only contain'));
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

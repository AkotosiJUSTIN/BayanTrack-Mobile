import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_ocr.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart'
    as domain;
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:bayantrack_mobile/features/kyc/kyc_di.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _FakeKycOcrService implements KycOcrService {
  KycOcrResult result;
  var scanCount = 0;

  _FakeKycOcrService(this.result);

  @override
  Future<KycOcrResult> scan({
    required IdType idType,
    required String imagePath,
  }) async {
    scanCount++;
    return result;
  }

  @override
  Future<void> close() async {}
}

class _RawTextKycOcrService implements KycOcrService {
  final String rawText;

  _RawTextKycOcrService(this.rawText);

  @override
  Future<KycOcrResult> scan({
    required IdType idType,
    required String imagePath,
  }) async => KycOcrParser.parse(idType, rawText);

  @override
  Future<void> close() async {}
}

class _RecordingSubmitKycUseCase extends Mock implements SubmitKycUseCase {
  SubmitKycParams? submitted;

  @override
  Future<Result<KycStatusEntity>> call(SubmitKycParams params) async {
    submitted = params;
    return const Success(
      KycStatusEntity(status: domain.KycVerificationStatus.pending),
    );
  }
}

void main() {
  test('ID side requirements use canonical paths per ID type', () {
    expect(IdType.passport.requiresBackImage, isFalse);
    expect(IdType.prcProfessionalId.requiresBackImage, isFalse);
    expect(IdType.sss.requiresBackImage, isFalse);
    expect(IdType.postal.requiresBackImage, isFalse);
    expect(IdType.voters.requiresBackImage, isFalse);
    expect(IdType.gsisECard.requiresBackImage, isFalse);
    expect(IdType.philHealth.requiresBackImage, isFalse);
    expect(IdType.nationalId.requiresBackImage, isTrue);
    expect(IdType.driversLicense.requiresBackImage, isTrue);
    expect(IdType.philsys.requiresBackImage, isTrue);
    expect(IdType.umid.requiresBackImage, isTrue);

    const frontOnly = KycFormState(
      selectedIdType: IdType.passport,
      idFrontImagePath: 'front.jpg',
      selfieImagePath: 'selfie.jpg',
    );
    expect(frontOnly.hasRequiredIdImages, isTrue);
    expect(frontOnly.missingRequiredIdSide, isNull);
    expect(frontOnly.isImagesComplete, isTrue);

    const missingBack = KycFormState(
      selectedIdType: IdType.driversLicense,
      idFrontImagePath: 'front.jpg',
      selfieImagePath: 'selfie.jpg',
    );
    expect(missingBack.hasRequiredIdImages, isFalse);
    expect(missingBack.missingRequiredIdSide, KycIdImageSide.back);
    expect(missingBack.isImagesComplete, isFalse);

    const emptyFront = KycFormState(
      selectedIdType: IdType.passport,
      idFrontImagePath: '  ',
      selfieImagePath: 'selfie.jpg',
    );
    expect(emptyFront.hasRequiredIdImages, isFalse);
    expect(emptyFront.missingRequiredIdSide, KycIdImageSide.front);
  });

  test('front and back images replace independently', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(kycFormControllerProvider.notifier);

    controller.setIdType(IdType.driversLicense);
    controller.setIdFrontImage('front-1.jpg');
    controller.setIdBackImage('back-1.jpg');
    controller.setIdBackImage(null);
    var state = container.read(kycFormControllerProvider);
    expect(state.idFrontImagePath, 'front-1.jpg');
    expect(state.idBackImagePath, isNull);

    controller.setIdBackImage('back-2.jpg');
    controller.setIdFrontImage(null);
    state = container.read(kycFormControllerProvider);
    expect(state.idFrontImagePath, isNull);
    expect(state.idBackImagePath, 'back-2.jpg');

    controller.setIdFrontImage('front-2.jpg');
    state = container.read(kycFormControllerProvider);
    expect(state.hasRequiredIdImages, isTrue);
  });

  test(
    'scan keeps OCR suggestions in review until user applies them',
    () async {
      final result = KycOcrResult(
        idType: IdType.passport,
        status: KycOcrResultStatus.extracted,
        fields: {
          KycOcrField.firstName: const KycOcrFieldValue(
            value: 'Scanned',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.lastName: const KycOcrFieldValue(
            value: 'Citizen',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.idNumber: const KycOcrFieldValue(
            value: 'P1234567',
            confidence: KycOcrConfidence.high,
          ),
        },
      );
      final container = ProviderContainer(
        overrides: [
          kycOcrServiceProvider.overrideWithValue(_FakeKycOcrService(result)),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycFormControllerProvider.notifier);
      controller.setVerificationMethod(KycVerificationMethod.scanId);
      controller.setIdType(IdType.passport);
      controller.setIdFrontImage('front.jpg');
      controller.setFirstName('Already entered');
      await controller.scanId();

      var state = container.read(kycFormControllerProvider);
      expect(state.firstName, 'Already entered');
      expect(state.lastName, isEmpty);
      expect(state.idNumber, isEmpty);
      expect(state.ocrReviewValues[KycOcrField.firstName], 'Scanned');

      controller.setOcrReviewValue(KycOcrField.lastName, 'Corrected by user');
      controller.applyOcrReview();
      state = container.read(kycFormControllerProvider);
      expect(state.firstName, 'Scanned');
      expect(state.lastName, 'Corrected by user');
      expect(state.idNumber, 'P1234567');
    },
  );

  test('manual path never invokes OCR', () async {
    final service = _FakeKycOcrService(
      KycOcrResult(
        idType: IdType.passport,
        status: KycOcrResultStatus.extracted,
      ),
    );
    final container = ProviderContainer(
      overrides: [kycOcrServiceProvider.overrideWithValue(service)],
    );
    addTearDown(container.dispose);

    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.manual);
    controller.setIdType(IdType.passport);
    controller.setIdFrontImage('front.jpg');

    expect(await controller.scanId(), isNull);
    expect(service.scanCount, 0);
    expect(container.read(kycFormControllerProvider).ocrResult, isNull);
  });

  test(
    'National ID OCR maps address and government ID fields into draft',
    () async {
      final result = KycOcrResult(
        idType: IdType.nationalId,
        status: KycOcrResultStatus.extracted,
        rawText: 'ADDRESS: Cebu City',
        fields: {
          KycOcrField.address: const KycOcrFieldValue(
            value: 'Cebu City, Cebu',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.cityMunicipality: const KycOcrFieldValue(
            value: 'Cebu City',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.province: const KycOcrFieldValue(
            value: 'Cebu',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.zipCode: const KycOcrFieldValue(
            value: '6000',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.idNumber: const KycOcrFieldValue(
            value: '1234-5678-9012',
            confidence: KycOcrConfidence.high,
          ),
          KycOcrField.idExpiryDate: const KycOcrFieldValue(
            value: '2030-01-01',
            confidence: KycOcrConfidence.review,
          ),
        },
      );
      final container = ProviderContainer(
        overrides: [
          kycOcrServiceProvider.overrideWithValue(_FakeKycOcrService(result)),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycFormControllerProvider.notifier);
      controller.setVerificationMethod(KycVerificationMethod.scanId);
      controller.setIdType(IdType.nationalId);
      controller.setIdFrontImage('national-id.jpg');
      await controller.scanId();
      controller.applyOcrReview();

      var state = container.read(kycFormControllerProvider);
      expect(state.streetBarangay, 'Cebu City, Cebu');
      expect(state.cityMunicipality, 'Cebu City');
      expect(state.province, 'Cebu');
      expect(state.zipCode, '6000');
      expect(state.idNumber, '1234-5678-9012');
      expect(state.idExpiryDate, DateTime(2030, 1, 1));

      controller.setStreetBarangay('User corrected address');
      controller.setIdNumber('USER-CORRECTED-ID');
      controller.setIdFrontImage('national-id-replacement.jpg');
      await controller.scanId();
      controller.applyOcrReview();
      state = container.read(kycFormControllerProvider);
      expect(state.streetBarangay, 'User corrected address');
      expect(state.idNumber, 'USER-CORRECTED-ID');
    },
  );

  test(
    'realistic National ID OCR output reaches canonical KYC draft',
    () async {
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
NATIONALITY
FILIPINO
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
ZIP CODE
1000
''';
      final submitUseCase = _RecordingSubmitKycUseCase();
      final container = ProviderContainer(
        overrides: [
          kycOcrServiceProvider.overrideWithValue(
            _RawTextKycOcrService(rawText),
          ),
          submitKycUseCaseProvider.overrideWithValue(submitUseCase),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycFormControllerProvider.notifier);
      controller.setVerificationMethod(KycVerificationMethod.scanId);
      controller.setIdType(IdType.nationalId);
      controller.setIdFrontImage('national-id.jpg');
      await controller.scanId();
      controller.applyOcrReview();

      final state = container.read(kycFormControllerProvider);
      expect(state.firstName, 'JUAN');
      expect(state.middleName, 'SANTOS');
      expect(state.lastName, 'DELA CRUZ');
      expect(state.dateOfBirth, DateTime(1990, 1, 1));
      expect(state.sex, Sex.male);
      expect(state.streetBarangay, '123 Mabini Street, Barangay San Antonio');
      expect(state.cityMunicipality, 'Quezon City');
      expect(state.province, 'Metro Manila');
      expect(state.zipCode, '1000');
      expect(state.idNumber, '5915-____-5187-____');
      expect(state.idExpiryDate, isNull);

      controller.setStreetBarangay('User corrected National ID address');
      controller.setIdNumber('USER-CORRECTED-PCN');
      controller.applyOcrReview();
      final corrected = container.read(kycFormControllerProvider);
      expect(corrected.streetBarangay, 'User corrected National ID address');
      expect(corrected.idNumber, 'USER-CORRECTED-PCN');

      controller.setEmail('juan@example.com');
      controller.setMobileNumber('09171234567');
      controller.setIdBackImage('national-id-back.jpg');
      controller.setSelfieImage('selfie.jpg');
      controller.setDeclarationAccepted(true);
      await controller.submitKyc();

      expect(
        submitUseCase.submitted?.streetBarangay,
        'User corrected National ID address',
      );
      expect(submitUseCase.submitted?.idNumber, 'USER-CORRECTED-PCN');
      expect(submitUseCase.submitted?.idExpiryDate, isNull);
    },
  );

  test(
    'realistic Driver license OCR reaches draft and keeps manual address correction',
    () async {
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
      final container = ProviderContainer(
        overrides: [
          kycOcrServiceProvider.overrideWithValue(
            _RawTextKycOcrService(rawText),
          ),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycFormControllerProvider.notifier);
      controller.setVerificationMethod(KycVerificationMethod.scanId);
      controller.setIdType(IdType.driversLicense);
      controller.setIdFrontImage('drivers-license.jpg');

      await controller.scanId();
      var state = container.read(kycFormControllerProvider);
      expect(
        state.ocrReviewValues[KycOcrField.address],
        '123 Mabini Street, Barangay San Antonio',
      );
      expect(state.ocrReviewValues[KycOcrField.idNumber], 'N01-23-456789');

      controller.setOcrReviewValue(
        KycOcrField.address,
        'Human-corrected residence\nBarangay San Antonio',
      );
      controller.applyOcrReview();
      state = container.read(kycFormControllerProvider);

      expect(state.firstName, 'ANA');
      expect(state.middleName, 'MARIA');
      expect(state.lastName, 'REYES');
      expect(state.dateOfBirth, DateTime(1990, 1, 2));
      expect(
        state.streetBarangay,
        'Human-corrected residence\nBarangay San Antonio',
      );
      expect(state.cityMunicipality, 'Quezon City');
      expect(state.province, 'Metro Manila');
      expect(state.zipCode, '1000');
      expect(state.idNumber, 'N01-23-456789');
      expect(state.idExpiryDate, DateTime(2030, 1, 2));
    },
  );

  test('reviewed Postal ID values persist into later KYC steps', () async {
    final result = KycOcrResult(
      idType: IdType.postal,
      status: KycOcrResultStatus.extracted,
      fields: {
        KycOcrField.firstName: const KycOcrFieldValue(
          value: 'Juan',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.lastName: const KycOcrFieldValue(
          value: 'Dela Cruz',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.dateOfBirth: const KycOcrFieldValue(
          value: '1990-01-01',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.address: const KycOcrFieldValue(
          value: '123 Mabini Street, Barangay San Antonio',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.cityMunicipality: const KycOcrFieldValue(
          value: 'Quezon City',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.province: const KycOcrFieldValue(
          value: 'Metro Manila',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.idNumber: const KycOcrFieldValue(
          value: 'PPN E99 2209719221',
          confidence: KycOcrConfidence.high,
        ),
        KycOcrField.idExpiryDate: const KycOcrFieldValue(
          value: '2028-12-06',
          confidence: KycOcrConfidence.review,
        ),
      },
    );
    final container = ProviderContainer(
      overrides: [
        kycOcrServiceProvider.overrideWithValue(_FakeKycOcrService(result)),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.scanId);
    controller.setIdType(IdType.postal);
    controller.setIdFrontImage('postal.jpg');
    await controller.scanId();
    controller.setOcrReviewValue(
      KycOcrField.address,
      'Human-corrected Postal address',
    );
    controller.applyOcrReview();

    final state = container.read(kycFormControllerProvider);
    expect(state.selectedIdType, IdType.postal);
    expect(state.streetBarangay, 'Human-corrected Postal address');
    expect(state.cityMunicipality, 'Quezon City');
    expect(state.idNumber, 'PPN E99 2209719221');
    expect(state.idExpiryDate, DateTime(2028, 12, 6));
    expect(state.ocrReviewConfirmed, isTrue);
  });

  test(
    'confirmed OCR replaces stale draft values but keeps later edits',
    () async {
      final result = KycOcrResult(
        idType: IdType.nationalId,
        status: KycOcrResultStatus.extracted,
        fields: {
          KycOcrField.firstName: const KycOcrFieldValue(
            value: 'Scanned',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.dateOfBirth: const KycOcrFieldValue(
            value: '1990-01-01',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.address: const KycOcrFieldValue(
            value: '123 Mabini Street, Barangay San Antonio',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.cityMunicipality: const KycOcrFieldValue(
            value: 'Quezon City',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.province: const KycOcrFieldValue(
            value: 'Metro Manila',
            confidence: KycOcrConfidence.review,
          ),
          KycOcrField.idNumber: const KycOcrFieldValue(
            value: '1234-5678-9012',
            confidence: KycOcrConfidence.high,
          ),
          KycOcrField.idExpiryDate: const KycOcrFieldValue(
            value: '2030-01-01',
            confidence: KycOcrConfidence.review,
          ),
        },
      );
      final container = ProviderContainer(
        overrides: [
          kycOcrServiceProvider.overrideWithValue(_FakeKycOcrService(result)),
        ],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycFormControllerProvider.notifier);
      controller.setVerificationMethod(KycVerificationMethod.scanId);
      controller.setIdType(IdType.nationalId);
      controller.setFirstName('Old');
      controller.setDateOfBirth(DateTime(1980, 1, 1));
      controller.setStreetBarangay('Old address');
      controller.setCityMunicipality('Old city');
      controller.setProvince('Old province');
      controller.setIdNumber('OLD-1234');
      controller.setIdExpiryDate(DateTime(2029, 1, 1));
      controller.setIdFrontImage('national-id.jpg');

      await controller.scanId();
      controller.applyOcrReview();

      var state = container.read(kycFormControllerProvider);
      expect(state.firstName, 'Scanned');
      expect(state.dateOfBirth, DateTime(1990, 1, 1));
      expect(state.streetBarangay, '123 Mabini Street, Barangay San Antonio');
      expect(state.cityMunicipality, 'Quezon City');
      expect(state.province, 'Metro Manila');
      expect(state.idNumber, '1234-5678-9012');
      expect(state.idExpiryDate, DateTime(2030, 1, 1));

      controller.setStreetBarangay('Human-corrected address');
      controller.setIdNumber('HUMAN-CORRECTED-ID');
      controller.setDateOfBirth(DateTime(1991, 2, 2));
      controller.applyOcrReview();

      state = container.read(kycFormControllerProvider);
      expect(state.streetBarangay, 'Human-corrected address');
      expect(state.idNumber, 'HUMAN-CORRECTED-ID');
      expect(state.dateOfBirth, DateTime(1991, 2, 2));
    },
  );

  test(
    'removing front image clears only its OCR state and permits retake',
    () async {
      final service = _FakeKycOcrService(
        KycOcrResult(
          idType: IdType.passport,
          status: KycOcrResultStatus.extracted,
          fields: {
            KycOcrField.firstName: const KycOcrFieldValue(
              value: 'Scanned',
              confidence: KycOcrConfidence.review,
            ),
          },
        ),
      );
      final container = ProviderContainer(
        overrides: [kycOcrServiceProvider.overrideWithValue(service)],
      );
      addTearDown(container.dispose);

      final controller = container.read(kycFormControllerProvider.notifier);
      controller.setVerificationMethod(KycVerificationMethod.scanId);
      controller.setIdType(IdType.passport);
      controller.setIdBackImage('back.jpg');
      controller.setIdFrontImage('front.jpg');
      await controller.scanId();
      controller.setOcrReviewValue(KycOcrField.firstName, 'Corrected');
      controller.applyOcrReview();

      controller.setIdFrontImage(null);
      var state = container.read(kycFormControllerProvider);
      expect(state.idFrontImagePath, isNull);
      expect(state.idBackImagePath, 'back.jpg');
      expect(state.ocrResult, isNull);
      expect(state.firstName, isEmpty);

      controller.setIdFrontImage('retake.jpg');
      await controller.scanId();
      state = container.read(kycFormControllerProvider);
      expect(state.idFrontImagePath, 'retake.jpg');
      expect(state.ocrResult, isNotNull);
      controller.setOcrReviewValue(KycOcrField.firstName, 'Corrected again');
      controller.applyOcrReview();
      controller.setFirstName('Human edit');
      controller.setIdFrontImage(null);
      state = container.read(kycFormControllerProvider);
      expect(state.idFrontImagePath, isNull);
      expect(state.firstName, 'Human edit');
      expect(service.scanCount, 2);
    },
  );

  test('unreadable OCR remains a safe manual fallback', () async {
    final container = ProviderContainer(
      overrides: [
        kycOcrServiceProvider.overrideWithValue(
          _FakeKycOcrService(
            KycOcrResult(
              idType: IdType.passport,
              status: KycOcrResultStatus.unreadable,
              message: 'Unreadable',
            ),
          ),
        ),
      ],
    );
    addTearDown(container.dispose);

    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.scanId);
    controller.setIdType(IdType.passport);
    controller.setIdFrontImage('blurred.jpg');
    final result = await controller.scanId();

    expect(result?.status, KycOcrResultStatus.unreadable);
    expect(container.read(kycFormControllerProvider).firstName, isEmpty);
    controller.applyOcrReview();
    expect(container.read(kycFormControllerProvider).firstName, isEmpty);
  });
}

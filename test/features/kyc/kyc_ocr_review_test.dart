import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_ocr.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeKycOcrService implements KycOcrService {
  final KycOcrResult result;

  _FakeKycOcrService(this.result);

  @override
  Future<KycOcrResult> scan({
    required IdType idType,
    required String imagePath,
  }) async => result;

  @override
  Future<void> close() async {}
}

void main() {
  test(
    'review keeps existing values and accepts a deliberate correction',
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
      controller.setIdType(IdType.passport);
      controller.setIdFrontImage('front.jpg');
      controller.setFirstName('Already entered');
      await controller.scanId();

      var state = container.read(kycFormControllerProvider);
      expect(state.firstName, 'Already entered');
      expect(state.lastName, 'Citizen');
      expect(state.idNumber, 'P1234567');

      controller.setFirstName('Corrected by user');
      state = container.read(kycFormControllerProvider);
      expect(state.firstName, 'Corrected by user');
    },
  );
}

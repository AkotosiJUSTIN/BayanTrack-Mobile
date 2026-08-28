import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/features/kyc/domain/kyc_repository.dart';
import 'package:bayantrack_mobile/features/kyc/domain/usecases/resubmit_kyc_usecase.dart';
import 'package:bayantrack_mobile/features/kyc/domain/usecases/submit_kyc_usecase.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _KycRepositoryMock extends Mock implements KycRepository {}

const _params = SubmitKycParams(
  firstName: 'Juan',
  lastName: 'Dela Cruz',
  nationality: 'Filipino',
  email: 'juan@example.test',
  mobileNumber: '09170000000',
  streetBarangay: 'Bactad East',
  cityMunicipality: 'Urdaneta',
  province: 'Pangasinan',
  idType: 'national_id',
  idNumber: 'TEST-ID',
  idFrontImagePath: 'front.jpg',
  selfieImagePath: 'selfie.jpg',
);

void main() {
  late _KycRepositoryMock repository;

  setUp(() {
    repository = _KycRepositoryMock();
    when(
      () => repository.validateImages(
        idFrontImagePath: any(named: 'idFrontImagePath'),
        idBackImagePath: any(named: 'idBackImagePath'),
        selfieImagePath: any(named: 'selfieImagePath'),
        selfieWithIdImagePath: any(named: 'selfieWithIdImagePath'),
      ),
    ).thenReturn(const ['ID front image must be less than 10MB']);
  });

  test('submit validates images before repository submission', () async {
    final result = await SubmitKycUseCase(repository: repository)(_params);

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    expect(result.failureOrNull?.message, contains('less than 10MB'));
    verify(
      () => repository.validateImages(
        idFrontImagePath: 'front.jpg',
        idBackImagePath: null,
        selfieImagePath: 'selfie.jpg',
        selfieWithIdImagePath: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });

  test('resubmit validates images before repository submission', () async {
    final result = await ResubmitKycUseCase(repository: repository)(_params);

    expect(result.isFailure, isTrue);
    expect(result.failureOrNull, isA<ValidationFailure>());
    verify(
      () => repository.validateImages(
        idFrontImagePath: 'front.jpg',
        idBackImagePath: null,
        selfieImagePath: 'selfie.jpg',
        selfieWithIdImagePath: null,
      ),
    ).called(1);
    verifyNoMoreInteractions(repository);
  });
}

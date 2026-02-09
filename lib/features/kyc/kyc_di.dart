import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/kyc_repository.dart' as legacy;
import 'data/kyc_repository_impl.dart';
import 'domain/kyc_repository.dart';
import 'domain/usecases/get_form_options_usecase.dart';
import 'domain/usecases/get_kyc_status_usecase.dart';
import 'domain/usecases/resubmit_kyc_usecase.dart';
import 'domain/usecases/submit_kyc_usecase.dart';

/// Provides the [KycRepository] implementation.
final kycDomainRepositoryProvider = Provider<KycRepository>((ref) {
  final legacyRepo = ref.watch(legacy.kycRepositoryProvider);
  return KycRepositoryImpl(legacyRepo);
});

/// Provides the [GetKycStatusUseCase].
final getKycStatusUseCaseProvider = Provider<GetKycStatusUseCase>((ref) {
  final repo = ref.watch(kycDomainRepositoryProvider);
  return GetKycStatusUseCase(repository: repo);
});

/// Provides the [GetFormOptionsUseCase].
final getFormOptionsUseCaseProvider = Provider<GetFormOptionsUseCase>((ref) {
  final repo = ref.watch(kycDomainRepositoryProvider);
  return GetFormOptionsUseCase(repository: repo);
});

/// Provides the [SubmitKycUseCase].
final submitKycUseCaseProvider = Provider<SubmitKycUseCase>((ref) {
  final repo = ref.watch(kycDomainRepositoryProvider);
  return SubmitKycUseCase(repository: repo);
});

/// Provides the [ResubmitKycUseCase].
final resubmitKycUseCaseProvider = Provider<ResubmitKycUseCase>((ref) {
  final repo = ref.watch(kycDomainRepositoryProvider);
  return ResubmitKycUseCase(repository: repo);
});

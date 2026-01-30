import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/kyc_models.dart';
import '../data/kyc_repository.dart';

part 'kyc_controller.g.dart';

// ==================== KYC STATUS PROVIDER ====================

@riverpod
class KycStatusController extends _$KycStatusController {
  @override
  Future<KycStatusResponse?> build() async {
    return _fetchStatus();
  }

  Future<KycStatusResponse?> _fetchStatus() async {
    try {
      final repo = ref.read(kycRepositoryProvider);
      return await repo.getKycStatus();
    } catch (e) {
      // User might not have submitted KYC yet
      return null;
    }
  }

  /// Refresh KYC status
  Future<void> refresh() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _fetchStatus());
  }
}

// ==================== ID TYPES PROVIDER ====================

@riverpod
Future<List<String>> idTypes(Ref ref) async {
  final repo = ref.read(kycRepositoryProvider);
  return await repo.getIdTypes();
}

// ==================== KYC FORM STATE ====================

class KycFormState {
  final IdType? selectedIdType;
  final String? idNumber;
  final String fullName;
  final DateTime? dateOfBirth;
  final String? idImagePath;
  final String? idBackImagePath;
  final String? selfieImagePath;
  final bool isSubmitting;
  final String? error;

  const KycFormState({
    this.selectedIdType,
    this.idNumber,
    this.fullName = '',
    this.dateOfBirth,
    this.idImagePath,
    this.idBackImagePath,
    this.selfieImagePath,
    this.isSubmitting = false,
    this.error,
  });

  KycFormState copyWith({
    IdType? selectedIdType,
    String? idNumber,
    String? fullName,
    DateTime? dateOfBirth,
    String? idImagePath,
    String? idBackImagePath,
    String? selfieImagePath,
    bool? isSubmitting,
    String? error,
  }) {
    return KycFormState(
      selectedIdType: selectedIdType ?? this.selectedIdType,
      idNumber: idNumber ?? this.idNumber,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      idImagePath: idImagePath ?? this.idImagePath,
      idBackImagePath: idBackImagePath ?? this.idBackImagePath,
      selfieImagePath: selfieImagePath ?? this.selfieImagePath,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  bool get canSubmit =>
      selectedIdType != null &&
      fullName.trim().isNotEmpty &&
      idImagePath != null &&
      selfieImagePath != null &&
      (!selectedIdType!.requiresBackImage || idBackImagePath != null);

  bool get hasIdFront => idImagePath != null;
  bool get hasIdBack => idBackImagePath != null;
  bool get hasSelfie => selfieImagePath != null;
}

// ==================== KYC FORM CONTROLLER ====================

@riverpod
class KycFormController extends _$KycFormController {
  @override
  KycFormState build() => const KycFormState();

  void setIdType(IdType idType) {
    state = state.copyWith(selectedIdType: idType);
  }

  void setIdNumber(String idNumber) {
    state = state.copyWith(idNumber: idNumber);
  }

  void setFullName(String fullName) {
    state = state.copyWith(fullName: fullName);
  }

  void setDateOfBirth(DateTime? dateOfBirth) {
    state = state.copyWith(dateOfBirth: dateOfBirth);
  }

  void setIdImage(String? path) {
    state = state.copyWith(idImagePath: path);
  }

  void setIdBackImage(String? path) {
    state = state.copyWith(idBackImagePath: path);
  }

  void setSelfieImage(String? path) {
    state = state.copyWith(selfieImagePath: path);
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void reset() {
    state = const KycFormState();
  }

  /// Submit KYC for the first time
  Future<KycStatusResponse> submitKyc() async {
    if (!state.canSubmit) {
      throw Exception('Please complete all required fields');
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repo = ref.read(kycRepositoryProvider);

      final request = KycSubmitRequest(
        idType: state.selectedIdType!,
        idNumber: state.idNumber,
        fullName: state.fullName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().split('T')[0],
        idImagePath: state.idImagePath!,
        idBackImagePath: state.idBackImagePath,
        selfieImagePath: state.selfieImagePath!,
      );

      // Validate image sizes
      final validationErrors = repo.validateImages(request);
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.join('\n'));
      }

      final response = await repo.submitKyc(request);

      // Refresh the status controller
      ref.invalidate(kycStatusControllerProvider);

      state = state.copyWith(isSubmitting: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }

  /// Resubmit KYC after rejection
  Future<KycStatusResponse> resubmitKyc() async {
    if (!state.canSubmit) {
      throw Exception('Please complete all required fields');
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final repo = ref.read(kycRepositoryProvider);

      final request = KycSubmitRequest(
        idType: state.selectedIdType!,
        idNumber: state.idNumber,
        fullName: state.fullName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().split('T')[0],
        idImagePath: state.idImagePath!,
        idBackImagePath: state.idBackImagePath,
        selfieImagePath: state.selfieImagePath!,
      );

      // Validate image sizes
      final validationErrors = repo.validateImages(request);
      if (validationErrors.isNotEmpty) {
        throw Exception(validationErrors.join('\n'));
      }

      final response = await repo.resubmitKyc(request);

      // Refresh the status controller
      ref.invalidate(kycStatusControllerProvider);

      state = state.copyWith(isSubmitting: false);
      return response;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: e.toString(),
      );
      rethrow;
    }
  }
}

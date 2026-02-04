import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../data/kyc_models.dart';
import '../data/kyc_repository.dart';
import '../domain/entities/kyc_form_options.dart' as domain;
import '../domain/entities/kyc_status.dart';
import '../kyc_di.dart';

part 'kyc_controller.g.dart';

// ==================== KYC STATUS PROVIDER ====================

@riverpod
class KycStatusController extends _$KycStatusController {
  @override
  Future<KycStatusEntity?> build() async {
    return _fetchStatus();
  }

  Future<KycStatusEntity?> _fetchStatus() async {
    final getKycStatus = ref.read(getKycStatusUseCaseProvider);
    final result = await getKycStatus();
    return result.when(
      success: (entity) => entity,
      failure: (_) => null, // User might not have submitted KYC yet
    );
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

// ==================== FORM OPTIONS PROVIDER ====================

@riverpod
Future<domain.KycFormOptions> kycFormOptions(Ref ref) async {
  final getFormOptions = ref.read(getFormOptionsUseCaseProvider);
  final result = await getFormOptions();
  return result.when(
    success: (options) => options,
    failure: (failure) => throw Exception(failure.message),
  );
}

// ==================== KYC FORM STATE ====================

class KycFormState {
  // A. Basic Identity Information
  final String firstName;
  final String? middleName;
  final String lastName;
  final DateTime? dateOfBirth;
  final Sex? sex;
  final String nationality;
  final CivilStatus? civilStatus;

  // B. Contact Information
  final String email;
  final String mobileNumber;

  // C. Address Information
  final String streetBarangay;
  final String cityMunicipality;
  final String province;
  final String? zipCode;

  // D. Government ID Details
  final IdType? selectedIdType;
  final String idNumber;
  final DateTime? idExpiryDate;

  // E. ID Upload Images
  final String? idFrontImagePath;
  final String? idBackImagePath;

  // F. Selfie Verification
  final String? selfieImagePath;
  final String? selfieWithIdImagePath;

  // G. Declaration
  final bool declarationAccepted;

  // Form state
  final bool isSubmitting;
  final String? error;
  final int currentStep;

  const KycFormState({
    // Basic Identity
    this.firstName = '',
    this.middleName,
    this.lastName = '',
    this.dateOfBirth,
    this.sex,
    this.nationality = '',
    this.civilStatus,
    // Contact
    this.email = '',
    this.mobileNumber = '',
    // Address
    this.streetBarangay = '',
    this.cityMunicipality = '',
    this.province = '',
    this.zipCode,
    // ID Details
    this.selectedIdType,
    this.idNumber = '',
    this.idExpiryDate,
    // Images
    this.idFrontImagePath,
    this.idBackImagePath,
    this.selfieImagePath,
    this.selfieWithIdImagePath,
    // Declaration
    this.declarationAccepted = false,
    // Form state
    this.isSubmitting = false,
    this.error,
    this.currentStep = 0,
  });

  KycFormState copyWith({
    String? firstName,
    String? middleName,
    String? lastName,
    DateTime? dateOfBirth,
    Sex? sex,
    String? nationality,
    CivilStatus? civilStatus,
    String? email,
    String? mobileNumber,
    String? streetBarangay,
    String? cityMunicipality,
    String? province,
    String? zipCode,
    IdType? selectedIdType,
    String? idNumber,
    DateTime? idExpiryDate,
    String? idFrontImagePath,
    String? idBackImagePath,
    String? selfieImagePath,
    String? selfieWithIdImagePath,
    bool? declarationAccepted,
    bool? isSubmitting,
    String? error,
    int? currentStep,
  }) {
    return KycFormState(
      firstName: firstName ?? this.firstName,
      middleName: middleName ?? this.middleName,
      lastName: lastName ?? this.lastName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      sex: sex ?? this.sex,
      nationality: nationality ?? this.nationality,
      civilStatus: civilStatus ?? this.civilStatus,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      streetBarangay: streetBarangay ?? this.streetBarangay,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      province: province ?? this.province,
      zipCode: zipCode ?? this.zipCode,
      selectedIdType: selectedIdType ?? this.selectedIdType,
      idNumber: idNumber ?? this.idNumber,
      idExpiryDate: idExpiryDate ?? this.idExpiryDate,
      idFrontImagePath: idFrontImagePath ?? this.idFrontImagePath,
      idBackImagePath: idBackImagePath ?? this.idBackImagePath,
      selfieImagePath: selfieImagePath ?? this.selfieImagePath,
      selfieWithIdImagePath:
          selfieWithIdImagePath ?? this.selfieWithIdImagePath,
      declarationAccepted: declarationAccepted ?? this.declarationAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
      currentStep: currentStep ?? this.currentStep,
    );
  }

  /// Computed full name
  String get fullName {
    final parts = [
      firstName,
      middleName,
      lastName,
    ].where((p) => p != null && p.isNotEmpty).toList();
    return parts.join(' ');
  }

  /// Check if basic identity section is complete
  bool get isBasicIdentityComplete =>
      firstName.trim().isNotEmpty &&
      lastName.trim().isNotEmpty &&
      nationality.trim().isNotEmpty;

  /// Check if contact section is complete
  bool get isContactComplete =>
      email.trim().isNotEmpty && mobileNumber.trim().isNotEmpty;

  /// Check if address section is complete
  bool get isAddressComplete =>
      streetBarangay.trim().isNotEmpty &&
      cityMunicipality.trim().isNotEmpty &&
      province.trim().isNotEmpty;

  /// Check if ID details section is complete
  bool get isIdDetailsComplete =>
      selectedIdType != null && idNumber.trim().isNotEmpty;

  /// Check if required images are uploaded
  bool get isImagesComplete =>
      idFrontImagePath != null && selfieImagePath != null;

  /// Check if declaration is accepted
  bool get isDeclarationComplete => declarationAccepted;

  /// Check if form can be submitted
  bool get canSubmit =>
      isBasicIdentityComplete &&
      isContactComplete &&
      isAddressComplete &&
      isIdDetailsComplete &&
      isImagesComplete &&
      isDeclarationComplete &&
      !isSubmitting;

  /// Image state helpers
  bool get hasIdFront => idFrontImagePath != null;
  bool get hasIdBack => idBackImagePath != null;
  bool get hasSelfie => selfieImagePath != null;
  bool get hasSelfieWithId => selfieWithIdImagePath != null;
}

// ==================== KYC FORM CONTROLLER ====================

@riverpod
class KycFormController extends _$KycFormController {
  @override
  KycFormState build() => const KycFormState();

  // ===== A. Basic Identity Setters =====
  void setFirstName(String value) => state = state.copyWith(firstName: value);
  void setMiddleName(String? value) =>
      state = state.copyWith(middleName: value);
  void setLastName(String value) => state = state.copyWith(lastName: value);
  void setDateOfBirth(DateTime? value) =>
      state = state.copyWith(dateOfBirth: value);
  void setSex(Sex? value) => state = state.copyWith(sex: value);
  void setNationality(String value) =>
      state = state.copyWith(nationality: value);
  void setCivilStatus(CivilStatus? value) =>
      state = state.copyWith(civilStatus: value);

  // ===== B. Contact Setters =====
  void setEmail(String value) => state = state.copyWith(email: value);
  void setMobileNumber(String value) =>
      state = state.copyWith(mobileNumber: value);

  // ===== C. Address Setters =====
  void setStreetBarangay(String value) =>
      state = state.copyWith(streetBarangay: value);
  void setCityMunicipality(String value) =>
      state = state.copyWith(cityMunicipality: value);
  void setProvince(String value) => state = state.copyWith(province: value);
  void setZipCode(String? value) => state = state.copyWith(zipCode: value);

  // ===== D. ID Details Setters =====
  void setIdType(IdType value) => state = state.copyWith(selectedIdType: value);
  void setIdNumber(String value) => state = state.copyWith(idNumber: value);
  void setIdExpiryDate(DateTime? value) =>
      state = state.copyWith(idExpiryDate: value);

  // ===== E. Image Setters =====
  void setIdFrontImage(String? path) =>
      state = state.copyWith(idFrontImagePath: path);
  void setIdBackImage(String? path) =>
      state = state.copyWith(idBackImagePath: path);
  void setSelfieImage(String? path) =>
      state = state.copyWith(selfieImagePath: path);
  void setSelfieWithIdImage(String? path) =>
      state = state.copyWith(selfieWithIdImagePath: path);

  // ===== G. Declaration Setter =====
  void setDeclarationAccepted(bool value) =>
      state = state.copyWith(declarationAccepted: value);

  // ===== Form State =====
  void setCurrentStep(int step) => state = state.copyWith(currentStep: step);
  void clearError() => state = state.copyWith(error: null);

  /// Reset form to initial state
  void reset() => state = const KycFormState();

  /// Populate form from existing KYC data (for resubmission)
  void populateFromExisting(KycStatusEntity existing) {
    // Map domain enums to DTO enums (they have the same values, different types)
    Sex? sex;
    if (existing.sex != null) {
      sex = Sex.values.firstWhere(
        (e) => e.name == existing.sex!.name,
        orElse: () => Sex.male,
      );
    }

    CivilStatus? civilStatus;
    if (existing.civilStatus != null) {
      civilStatus = CivilStatus.values.firstWhere(
        (e) => e.name == existing.civilStatus!.name,
        orElse: () => CivilStatus.single,
      );
    }

    IdType? idType;
    if (existing.idType != null) {
      idType = IdType.values.firstWhere(
        (e) => e.name == existing.idType!.name,
        orElse: () => IdType.nationalId,
      );
    }

    state = KycFormState(
      firstName: existing.firstName ?? '',
      middleName: existing.middleName,
      lastName: existing.lastName ?? '',
      dateOfBirth: existing.dateOfBirth,
      sex: sex,
      nationality: existing.nationality ?? '',
      civilStatus: civilStatus,
      email: existing.email ?? '',
      mobileNumber: existing.mobileNumber ?? '',
      streetBarangay: existing.streetBarangay ?? '',
      cityMunicipality: existing.cityMunicipality ?? '',
      province: existing.province ?? '',
      zipCode: existing.zipCode,
      selectedIdType: idType,
      idNumber: existing.idNumber ?? '',
      idExpiryDate: existing.idExpiryDate,
    );
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
        // Basic Identity
        firstName: state.firstName,
        middleName: state.middleName,
        lastName: state.lastName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().split('T')[0],
        sex: state.sex,
        nationality: state.nationality,
        civilStatus: state.civilStatus,
        // Contact
        email: state.email,
        mobileNumber: state.mobileNumber,
        // Address
        streetBarangay: state.streetBarangay,
        cityMunicipality: state.cityMunicipality,
        province: state.province,
        zipCode: state.zipCode,
        // ID Details
        idType: state.selectedIdType!,
        idNumber: state.idNumber,
        idExpiryDate: state.idExpiryDate?.toIso8601String().split('T')[0],
        // Images
        idFrontImagePath: state.idFrontImagePath!,
        idBackImagePath: state.idBackImagePath,
        selfieImagePath: state.selfieImagePath!,
        selfieWithIdImagePath: state.selfieWithIdImagePath,
        // Declaration
        declarationAccepted: state.declarationAccepted,
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
      state = state.copyWith(isSubmitting: false, error: e.toString());
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
        // Basic Identity
        firstName: state.firstName,
        middleName: state.middleName,
        lastName: state.lastName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().split('T')[0],
        sex: state.sex,
        nationality: state.nationality,
        civilStatus: state.civilStatus,
        // Contact
        email: state.email,
        mobileNumber: state.mobileNumber,
        // Address
        streetBarangay: state.streetBarangay,
        cityMunicipality: state.cityMunicipality,
        province: state.province,
        zipCode: state.zipCode,
        // ID Details
        idType: state.selectedIdType!,
        idNumber: state.idNumber,
        idExpiryDate: state.idExpiryDate?.toIso8601String().split('T')[0],
        // Images
        idFrontImagePath: state.idFrontImagePath!,
        idBackImagePath: state.idBackImagePath,
        selfieImagePath: state.selfieImagePath!,
        selfieWithIdImagePath: state.selfieWithIdImagePath,
        // Declaration
        declarationAccepted: state.declarationAccepted,
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
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

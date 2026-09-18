import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/utils/kyc_validators.dart';
import '../data/kyc_ocr.dart';
import '../data/kyc_models.dart';
import '../domain/entities/kyc_form_options.dart' as domain;
import '../domain/entities/kyc_status.dart';
import '../domain/usecases/submit_kyc_usecase.dart';
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
  // Use domain layer - extract idTypes from form options
  final getFormOptions = ref.read(getFormOptionsUseCaseProvider);
  final result = await getFormOptions();
  return result.when(
    success: (options) => options.idTypes.map((item) => item.value).toList(),
    failure: (failure) => throw Exception(failure.message),
  );
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

  // Local OCR assistance. OCR never changes an existing non-empty value.
  final KycOcrResult? ocrResult;
  final bool isOcrScanning;
  final String? ocrError;

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
    this.ocrResult,
    this.isOcrScanning = false,
    this.ocrError,
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
    KycOcrResult? ocrResult,
    bool? isOcrScanning,
    String? ocrError,
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
      ocrResult: ocrResult ?? this.ocrResult,
      isOcrScanning: isOcrScanning ?? this.isOcrScanning,
      ocrError: ocrError,
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
      dateOfBirth != null &&
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

  bool get hasCurrentOcrResult =>
      ocrResult != null && ocrResult!.idType == selectedIdType;
}

// ==================== KYC FORM CONTROLLER ====================

@riverpod
class KycFormController extends _$KycFormController {
  int _ocrRequestId = 0;

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
  void setMobileNumber(String value) => state = state.copyWith(
    mobileNumber: KycValidators.normalizeMobileNumber(value),
  );

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
  void setIdFrontImage(String? path) {
    _ocrRequestId++;
    state = state.copyWith(idFrontImagePath: path);
  }

  void setIdBackImage(String? path) =>
      state = state.copyWith(idBackImagePath: path);
  void setSelfieImage(String? path) =>
      state = state.copyWith(selfieImagePath: path);
  void setSelfieWithIdImage(String? path) =>
      state = state.copyWith(selfieWithIdImagePath: path);

  /// Runs on-device OCR for the selected ID. Existing form values stay intact;
  /// only blank fields receive a suggestion and the result remains reviewable.
  Future<KycOcrResult?> scanId() async {
    final idType = state.selectedIdType;
    if (idType == null || state.idFrontImagePath == null) return null;
    final requestId = ++_ocrRequestId;

    if (!KycOcrParser.supports(idType)) {
      final result = KycOcrResult(
        idType: idType,
        status: KycOcrResultStatus.unsupported,
        message: 'OCR is not available for this ID type yet.',
      );
      state = state.copyWith(ocrResult: result, isOcrScanning: false);
      return result;
    }

    state = state.copyWith(isOcrScanning: true, ocrError: null);
    try {
      final result = await ref
          .read(kycOcrServiceProvider)
          .scan(idType: idType, imagePath: state.idFrontImagePath!);
      if (requestId != _ocrRequestId ||
          idType != state.selectedIdType ||
          result.idType != idType) {
        return null;
      }
      state = _prefillBlankFields(
        result,
      ).copyWith(ocrResult: result, isOcrScanning: false, ocrError: null);
      return result;
    } catch (_) {
      if (requestId != _ocrRequestId) return null;
      state = state.copyWith(
        isOcrScanning: false,
        ocrError: 'OCR could not read this image.',
      );
      return null;
    }
  }

  KycFormState _prefillBlankFields(KycOcrResult result) {
    var next = state;
    for (final entry in result.fields.entries) {
      final value = entry.value.value;
      switch (entry.key) {
        case KycOcrField.firstName:
          if (next.firstName.trim().isEmpty) {
            next = next.copyWith(firstName: value);
          }
        case KycOcrField.middleName:
          if (next.middleName?.trim().isNotEmpty != true) {
            next = next.copyWith(middleName: value);
          }
        case KycOcrField.lastName:
          if (next.lastName.trim().isEmpty) {
            next = next.copyWith(lastName: value);
          }
        case KycOcrField.dateOfBirth:
          if (next.dateOfBirth == null) {
            final date = DateTime.tryParse(value);
            if (date != null) next = next.copyWith(dateOfBirth: date);
          }
        case KycOcrField.sex:
          if (next.sex == null) {
            final sex = _sexFromOcr(value);
            if (sex != null) next = next.copyWith(sex: sex);
          }
        case KycOcrField.nationality:
          if (next.nationality.trim().isEmpty) {
            next = next.copyWith(nationality: value);
          }
        case KycOcrField.civilStatus:
          if (next.civilStatus == null) {
            final status = _civilStatusFromOcr(value);
            if (status != null) next = next.copyWith(civilStatus: status);
          }
        case KycOcrField.idNumber:
          if (next.idNumber.trim().isEmpty) {
            next = next.copyWith(idNumber: value);
          }
        case KycOcrField.idExpiryDate:
          if (next.idExpiryDate == null) {
            final date = DateTime.tryParse(value);
            if (date != null) next = next.copyWith(idExpiryDate: date);
          }
      }
    }
    return next;
  }

  Sex? _sexFromOcr(String value) {
    for (final sex in Sex.values) {
      if (sex.name == value) return sex;
    }
    return null;
  }

  CivilStatus? _civilStatusFromOcr(String value) {
    for (final status in CivilStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

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
      mobileNumber: KycValidators.normalizeMobileNumber(
        existing.mobileNumber ?? '',
      ),
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
  Future<KycStatusEntity> submitKyc() async {
    if (!state.canSubmit) {
      throw Exception('Please complete all required fields');
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final submitKycUseCase = ref.read(submitKycUseCaseProvider);

      // Create domain params
      final params = SubmitKycParams(
        // Basic Identity
        firstName: state.firstName,
        middleName: state.middleName,
        lastName: state.lastName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().split('T')[0],
        sex: state.sex?.apiValue,
        nationality: state.nationality,
        civilStatus: state.civilStatus?.apiValue,
        // Contact
        email: state.email,
        mobileNumber: state.mobileNumber,
        // Address
        streetBarangay: state.streetBarangay,
        cityMunicipality: state.cityMunicipality,
        province: state.province,
        zipCode: state.zipCode,
        // ID Details
        idType: state.selectedIdType!.apiValue,
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

      final result = await submitKycUseCase(params);

      // Refresh the status controller
      ref.invalidate(kycStatusControllerProvider);

      state = state.copyWith(isSubmitting: false);

      return await result.when(
        success: (entity) => entity,
        failure: (failure) => throw failure,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }

  /// Resubmit KYC after rejection
  Future<KycStatusEntity> resubmitKyc() async {
    if (!state.canSubmit) {
      throw Exception('Please complete all required fields');
    }

    state = state.copyWith(isSubmitting: true, error: null);

    try {
      final resubmitKycUseCase = ref.read(resubmitKycUseCaseProvider);

      // Create domain params
      final params = SubmitKycParams(
        // Basic Identity
        firstName: state.firstName,
        middleName: state.middleName,
        lastName: state.lastName,
        dateOfBirth: state.dateOfBirth?.toIso8601String().split('T')[0],
        sex: state.sex?.apiValue,
        nationality: state.nationality,
        civilStatus: state.civilStatus?.apiValue,
        // Contact
        email: state.email,
        mobileNumber: state.mobileNumber,
        // Address
        streetBarangay: state.streetBarangay,
        cityMunicipality: state.cityMunicipality,
        province: state.province,
        zipCode: state.zipCode,
        // ID Details
        idType: state.selectedIdType!.apiValue,
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

      final result = await resubmitKycUseCase(params);

      // Refresh the status controller
      ref.invalidate(kycStatusControllerProvider);

      state = state.copyWith(isSubmitting: false);

      return await result.when(
        success: (entity) => entity,
        failure: (failure) => throw failure,
      );
    } catch (e) {
      state = state.copyWith(isSubmitting: false, error: e.toString());
      rethrow;
    }
  }
}

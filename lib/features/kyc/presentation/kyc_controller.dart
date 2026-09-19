import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../core/domain/result.dart';
import '../../../core/utils/kyc_validators.dart';
import '../data/kyc_ocr.dart';
import '../data/kyc_models.dart';
import '../domain/entities/kyc_form_options.dart' as domain;
import '../domain/entities/kyc_enums.dart' as domain_enums;
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

  /// Withdraw a pending submission without changing local state on failure.
  Future<Result<KycStatusEntity>> withdrawKyc() async {
    final result = await ref.read(withdrawKycUseCaseProvider)();
    result.when(
      success: (entity) => state = AsyncValue.data(entity),
      failure: (_) {},
    );
    return result;
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

enum KycVerificationMethod { scanId, manual }

enum KycIdImageSide { front, back }

const _unset = Object();

class KycFormState {
  static const fixedNationality = 'Filipino';

  final KycVerificationMethod? verificationMethod;

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

  // Local OCR assistance and reviewed-draft provenance.
  final KycOcrResult? ocrResult;
  final bool isOcrScanning;
  final String? ocrError;
  final Map<KycOcrField, String> ocrReviewValues;
  final Map<KycOcrField, String> ocrAppliedValues;
  final Set<KycOcrField> ocrUserEditedFields;
  final bool ocrReviewConfirmed;

  // G. Declaration
  final bool declarationAccepted;

  // Form state
  final bool isSubmitting;
  final String? error;

  const KycFormState({
    this.verificationMethod,
    // Basic Identity
    this.firstName = '',
    this.middleName,
    this.lastName = '',
    this.dateOfBirth,
    this.sex,
    this.nationality = fixedNationality,
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
    this.ocrReviewValues = const {},
    this.ocrAppliedValues = const {},
    this.ocrUserEditedFields = const {},
    this.ocrReviewConfirmed = false,
    // Declaration
    this.declarationAccepted = false,
    // Form state
    this.isSubmitting = false,
    this.error,
  });

  KycFormState copyWith({
    KycVerificationMethod? verificationMethod,
    String? firstName,
    Object? middleName = _unset,
    String? lastName,
    Object? dateOfBirth = _unset,
    Object? sex = _unset,
    String? nationality,
    Object? civilStatus = _unset,
    String? email,
    String? mobileNumber,
    String? streetBarangay,
    String? cityMunicipality,
    String? province,
    Object? zipCode = _unset,
    Object? selectedIdType = _unset,
    String? idNumber,
    Object? idExpiryDate = _unset,
    Object? idFrontImagePath = _unset,
    Object? idBackImagePath = _unset,
    Object? selfieImagePath = _unset,
    Object? selfieWithIdImagePath = _unset,
    Object? ocrResult = _unset,
    bool? isOcrScanning,
    Object? ocrError = _unset,
    Map<KycOcrField, String>? ocrReviewValues,
    Map<KycOcrField, String>? ocrAppliedValues,
    Set<KycOcrField>? ocrUserEditedFields,
    bool? ocrReviewConfirmed,
    bool? declarationAccepted,
    bool? isSubmitting,
    Object? error = _unset,
  }) {
    return KycFormState(
      verificationMethod: verificationMethod ?? this.verificationMethod,
      firstName: firstName ?? this.firstName,
      middleName: identical(middleName, _unset)
          ? this.middleName
          : middleName as String?,
      lastName: lastName ?? this.lastName,
      dateOfBirth: identical(dateOfBirth, _unset)
          ? this.dateOfBirth
          : dateOfBirth as DateTime?,
      sex: identical(sex, _unset) ? this.sex : sex as Sex?,
      nationality: nationality ?? this.nationality,
      civilStatus: identical(civilStatus, _unset)
          ? this.civilStatus
          : civilStatus as CivilStatus?,
      email: email ?? this.email,
      mobileNumber: mobileNumber ?? this.mobileNumber,
      streetBarangay: streetBarangay ?? this.streetBarangay,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      province: province ?? this.province,
      zipCode: identical(zipCode, _unset) ? this.zipCode : zipCode as String?,
      selectedIdType: identical(selectedIdType, _unset)
          ? this.selectedIdType
          : selectedIdType as IdType?,
      idNumber: idNumber ?? this.idNumber,
      idExpiryDate: identical(idExpiryDate, _unset)
          ? this.idExpiryDate
          : idExpiryDate as DateTime?,
      idFrontImagePath: identical(idFrontImagePath, _unset)
          ? this.idFrontImagePath
          : idFrontImagePath as String?,
      idBackImagePath: identical(idBackImagePath, _unset)
          ? this.idBackImagePath
          : idBackImagePath as String?,
      selfieImagePath: identical(selfieImagePath, _unset)
          ? this.selfieImagePath
          : selfieImagePath as String?,
      selfieWithIdImagePath: identical(selfieWithIdImagePath, _unset)
          ? this.selfieWithIdImagePath
          : selfieWithIdImagePath as String?,
      ocrResult: identical(ocrResult, _unset)
          ? this.ocrResult
          : ocrResult as KycOcrResult?,
      isOcrScanning: isOcrScanning ?? this.isOcrScanning,
      ocrError: identical(ocrError, _unset)
          ? this.ocrError
          : ocrError as String?,
      ocrReviewValues: ocrReviewValues ?? this.ocrReviewValues,
      ocrAppliedValues: ocrAppliedValues ?? this.ocrAppliedValues,
      ocrUserEditedFields: ocrUserEditedFields ?? this.ocrUserEditedFields,
      ocrReviewConfirmed: ocrReviewConfirmed ?? this.ocrReviewConfirmed,
      declarationAccepted: declarationAccepted ?? this.declarationAccepted,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: identical(error, _unset) ? this.error : error as String?,
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
  bool get isImagesComplete => hasRequiredIdImages && hasSelfie;

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
  bool _hasImage(String? path) => path?.trim().isNotEmpty == true;

  bool get hasIdFront => _hasImage(idFrontImagePath);
  bool get hasIdBack => _hasImage(idBackImagePath);
  bool get hasSelfie => _hasImage(selfieImagePath);
  bool get hasSelfieWithId => _hasImage(selfieWithIdImagePath);
  bool get requiresIdBack => selectedIdType?.requiresBackImage == true;
  bool get hasRequiredIdImages => hasIdFront && (!requiresIdBack || hasIdBack);

  KycIdImageSide? get missingRequiredIdSide {
    if (!hasIdFront) return KycIdImageSide.front;
    if (requiresIdBack && !hasIdBack) return KycIdImageSide.back;
    return null;
  }

  bool get hasCurrentOcrResult =>
      ocrResult != null && ocrResult!.idType == selectedIdType;

  String? ocrReviewValue(KycOcrField field) => ocrReviewValues[field];
}

// ==================== KYC FORM CONTROLLER ====================

@riverpod
class KycFormController extends _$KycFormController {
  int _ocrRequestId = 0;

  @override
  KycFormState build() => const KycFormState();

  Map<KycOcrField, String> _withoutApplied(KycOcrField field) {
    final values = Map<KycOcrField, String>.from(state.ocrAppliedValues);
    values.remove(field);
    return values;
  }

  Map<KycOcrField, String> _withReviewedEdit(KycOcrField field, String value) {
    final values = Map<KycOcrField, String>.from(state.ocrReviewValues);
    if (state.ocrReviewConfirmed) values[field] = value;
    return values;
  }

  Set<KycOcrField> _withUserEditedField(KycOcrField field) {
    final fields = Set<KycOcrField>.from(state.ocrUserEditedFields);
    if (state.ocrReviewConfirmed) fields.add(field);
    return fields;
  }

  KycFormState _clearOcrState({bool preserveUserEdits = true}) {
    var next = state;
    for (final entry in state.ocrAppliedValues.entries) {
      final value = entry.value;
      switch (entry.key) {
        case KycOcrField.firstName:
          if (next.firstName == value) next = next.copyWith(firstName: '');
        case KycOcrField.middleName:
          if (next.middleName == value) next = next.copyWith(middleName: null);
        case KycOcrField.lastName:
          if (next.lastName == value) next = next.copyWith(lastName: '');
        case KycOcrField.dateOfBirth:
          if (_dateValue(next.dateOfBirth) == value) {
            next = next.copyWith(dateOfBirth: null);
          }
        case KycOcrField.sex:
          if (next.sex?.name == value) next = next.copyWith(sex: null);
        case KycOcrField.nationality:
          if (next.nationality == value) {
            next = next.copyWith(nationality: KycFormState.fixedNationality);
          }
        case KycOcrField.civilStatus:
          if (next.civilStatus?.name == value) {
            next = next.copyWith(civilStatus: null);
          }
        case KycOcrField.address:
          if (next.streetBarangay == value) {
            next = next.copyWith(streetBarangay: '');
          }
        case KycOcrField.cityMunicipality:
          if (next.cityMunicipality == value) {
            next = next.copyWith(cityMunicipality: '');
          }
        case KycOcrField.province:
          if (next.province == value) next = next.copyWith(province: '');
        case KycOcrField.zipCode:
          if (next.zipCode == value) next = next.copyWith(zipCode: null);
        case KycOcrField.idNumber:
          if (next.idNumber == value) next = next.copyWith(idNumber: '');
        case KycOcrField.idExpiryDate:
          if (_dateValue(next.idExpiryDate) == value) {
            next = next.copyWith(idExpiryDate: null);
          }
      }
    }
    return next.copyWith(
      ocrResult: null,
      isOcrScanning: false,
      ocrError: null,
      ocrReviewValues: const {},
      ocrAppliedValues: const {},
      ocrUserEditedFields: preserveUserEdits
          ? state.ocrUserEditedFields
          : const {},
      ocrReviewConfirmed: false,
    );
  }

  String? _dateValue(DateTime? value) =>
      value?.toIso8601String().split('T').first;

  // ===== Verification Method =====
  void setVerificationMethod(KycVerificationMethod method) {
    _ocrRequestId++;
    state = _clearOcrState(
      preserveUserEdits: false,
    ).copyWith(verificationMethod: method);
  }

  // ===== A. Basic Identity Setters =====
  void setFirstName(String value) => state = state.copyWith(
    firstName: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.firstName),
    ocrReviewValues: _withReviewedEdit(KycOcrField.firstName, value),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.firstName),
  );
  void setMiddleName(String? value) => state = state.copyWith(
    middleName: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.middleName),
    ocrReviewValues: _withReviewedEdit(KycOcrField.middleName, value ?? ''),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.middleName),
  );
  void setLastName(String value) => state = state.copyWith(
    lastName: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.lastName),
    ocrReviewValues: _withReviewedEdit(KycOcrField.lastName, value),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.lastName),
  );
  void setDateOfBirth(DateTime? value) => state = state.copyWith(
    dateOfBirth: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.dateOfBirth),
    ocrReviewValues: _withReviewedEdit(
      KycOcrField.dateOfBirth,
      _dateValue(value) ?? '',
    ),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.dateOfBirth),
  );
  void setSex(Sex? value) => state = state.copyWith(
    sex: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.sex),
    ocrReviewValues: _withReviewedEdit(KycOcrField.sex, value?.name ?? ''),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.sex),
  );
  void setNationality(String _) => state = state.copyWith(
    nationality: KycFormState.fixedNationality,
    ocrAppliedValues: _withoutApplied(KycOcrField.nationality),
    ocrReviewValues: _withReviewedEdit(
      KycOcrField.nationality,
      KycFormState.fixedNationality,
    ),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.nationality),
  );
  void setCivilStatus(CivilStatus? value) => state = state.copyWith(
    civilStatus: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.civilStatus),
    ocrReviewValues: _withReviewedEdit(
      KycOcrField.civilStatus,
      value?.name ?? '',
    ),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.civilStatus),
  );

  // ===== B. Contact Setters =====
  void seedContactFromProfile({String? email, String? mobileNumber}) {
    state = state.copyWith(
      email: state.email.trim().isEmpty && email != null
          ? email.trim()
          : state.email,
      mobileNumber: state.mobileNumber.trim().isEmpty && mobileNumber != null
          ? KycValidators.normalizeMobileNumber(mobileNumber)
          : state.mobileNumber,
    );
  }

  void setEmail(String value) => state = state.copyWith(email: value);
  void setMobileNumber(String value) => state = state.copyWith(
    mobileNumber: KycValidators.normalizeMobileNumber(value),
  );

  // ===== C. Address Setters =====
  void setStreetBarangay(String value) => state = state.copyWith(
    streetBarangay: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.address),
    ocrReviewValues: _withReviewedEdit(KycOcrField.address, value),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.address),
  );
  void setCityMunicipality(String value) => state = state.copyWith(
    cityMunicipality: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.cityMunicipality),
    ocrReviewValues: _withReviewedEdit(KycOcrField.cityMunicipality, value),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.cityMunicipality),
  );
  void setProvince(String value) => state = state.copyWith(
    province: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.province),
    ocrReviewValues: _withReviewedEdit(KycOcrField.province, value),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.province),
  );
  void setZipCode(String? value) => state = state.copyWith(
    zipCode: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.zipCode),
    ocrReviewValues: _withReviewedEdit(KycOcrField.zipCode, value ?? ''),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.zipCode),
  );

  // ===== D. ID Details Setters =====
  void setIdType(IdType value) {
    if (state.selectedIdType == value) return;
    _ocrRequestId++;
    state = _clearOcrState(preserveUserEdits: false).copyWith(
      selectedIdType: value,
      idFrontImagePath: null,
      idBackImagePath: null,
    );
  }

  void setIdNumber(String value) => state = state.copyWith(
    idNumber: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.idNumber),
    ocrReviewValues: _withReviewedEdit(KycOcrField.idNumber, value),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.idNumber),
  );
  void setIdExpiryDate(DateTime? value) => state = state.copyWith(
    idExpiryDate: value,
    ocrAppliedValues: _withoutApplied(KycOcrField.idExpiryDate),
    ocrReviewValues: _withReviewedEdit(
      KycOcrField.idExpiryDate,
      _dateValue(value) ?? '',
    ),
    ocrUserEditedFields: _withUserEditedField(KycOcrField.idExpiryDate),
  );

  // ===== E. Image Setters =====
  void setIdFrontImage(String? path) {
    _ocrRequestId++;
    state = _clearOcrState().copyWith(idFrontImagePath: path);
  }

  void setIdBackImage(String? path) =>
      state = state.copyWith(idBackImagePath: path);
  void setSelfieImage(String? path) =>
      state = state.copyWith(selfieImagePath: path);
  void setSelfieWithIdImage(String? path) =>
      state = state.copyWith(selfieWithIdImagePath: path);

  /// Runs on-device OCR for scan-assisted verification.
  Future<KycOcrResult?> scanId() async {
    if (state.isOcrScanning) return null;
    final idType = state.selectedIdType;
    if (state.verificationMethod != KycVerificationMethod.scanId ||
        idType == null ||
        !state.hasIdFront) {
      return null;
    }
    final requestId = ++_ocrRequestId;

    if (!KycOcrParser.supports(idType)) {
      final result = KycOcrResult(
        idType: idType,
        status: KycOcrResultStatus.unsupported,
        message: 'OCR is not available for this ID type yet.',
      );
      state = state.copyWith(
        ocrResult: result,
        ocrReviewValues: const {},
        isOcrScanning: false,
        ocrError: null,
      );
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
      state = state.copyWith(
        ocrResult: result,
        ocrReviewValues: {
          for (final entry in result.fields.entries)
            entry.key: entry.key == KycOcrField.nationality
                ? KycFormState.fixedNationality
                : entry.value.value,
        },
        isOcrScanning: false,
        ocrError: null,
      );
      return result;
    } catch (_) {
      if (requestId != _ocrRequestId) return null;
      state = state.copyWith(
        ocrResult: KycOcrResult(
          idType: idType,
          status: KycOcrResultStatus.unreadable,
          message: 'OCR could not read this image. Enter details manually.',
        ),
        ocrReviewValues: const {},
        isOcrScanning: false,
        ocrError: 'OCR could not read this image.',
      );
      return state.ocrResult;
    }
  }

  void setOcrReviewValue(KycOcrField field, String value) {
    final values = Map<KycOcrField, String>.from(state.ocrReviewValues);
    values[field] = field == KycOcrField.nationality
        ? KycFormState.fixedNationality
        : value;
    final applied = Map<KycOcrField, String>.from(state.ocrAppliedValues);
    applied.remove(field);
    final userEdited = Set<KycOcrField>.from(state.ocrUserEditedFields);
    userEdited.remove(field);
    state = state.copyWith(
      ocrReviewValues: values,
      ocrAppliedValues: applied,
      ocrUserEditedFields: userEdited,
    );
  }

  /// Applies reviewed OCR values to the canonical draft.
  void applyOcrReview() {
    final result = state.ocrResult;
    if (result == null || result.idType != state.selectedIdType) return;

    var next = state;
    final applied = Map<KycOcrField, String>.from(state.ocrAppliedValues);
    for (final entry in state.ocrReviewValues.entries) {
      final value = entry.value.trim();
      if (value.isEmpty) continue;
      if (state.ocrUserEditedFields.contains(entry.key)) continue;
      switch (entry.key) {
        case KycOcrField.firstName:
          next = next.copyWith(firstName: value);
          applied[entry.key] = value;
        case KycOcrField.middleName:
          next = next.copyWith(middleName: value);
          applied[entry.key] = value;
        case KycOcrField.lastName:
          next = next.copyWith(lastName: value);
          applied[entry.key] = value;
        case KycOcrField.dateOfBirth:
          final date = DateTime.tryParse(value);
          if (date != null) {
            next = next.copyWith(dateOfBirth: date);
            applied[entry.key] = value;
          }
        case KycOcrField.sex:
          final sex = _sexFromOcr(value);
          if (sex != null) {
            next = next.copyWith(sex: sex);
            applied[entry.key] = value;
          }
        case KycOcrField.nationality:
          next = next.copyWith(nationality: KycFormState.fixedNationality);
          applied[entry.key] = KycFormState.fixedNationality;
        case KycOcrField.civilStatus:
          final status = _civilStatusFromOcr(value);
          if (status != null) {
            next = next.copyWith(civilStatus: status);
            applied[entry.key] = value;
          }
        case KycOcrField.address:
          next = next.copyWith(streetBarangay: value);
          applied[entry.key] = value;
        case KycOcrField.cityMunicipality:
          next = next.copyWith(cityMunicipality: value);
          applied[entry.key] = value;
        case KycOcrField.province:
          next = next.copyWith(province: value);
          applied[entry.key] = value;
        case KycOcrField.zipCode:
          next = next.copyWith(zipCode: value);
          applied[entry.key] = value;
        case KycOcrField.idNumber:
          next = next.copyWith(idNumber: value);
          applied[entry.key] = value;
        case KycOcrField.idExpiryDate:
          final date = DateTime.tryParse(value);
          if (date != null) {
            next = next.copyWith(idExpiryDate: date);
            applied[entry.key] = value;
          }
      }
    }
    state = next.copyWith(ocrAppliedValues: applied, ocrReviewConfirmed: true);
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
      // PhilSys is the legacy API name for the National ID. Normalize it in
      // editable drafts while still accepting old records from the backend.
      idType = existing.idType == domain_enums.IdType.philsys
          ? IdType.nationalId
          : IdType.values.firstWhere(
              (e) => e.name == existing.idType!.name,
              orElse: () => IdType.nationalId,
            );
    }

    state = KycFormState(
      verificationMethod: KycVerificationMethod.manual,
      firstName: existing.firstName ?? '',
      middleName: existing.middleName,
      lastName: existing.lastName ?? '',
      dateOfBirth: existing.dateOfBirth,
      sex: sex,
      nationality: KycFormState.fixedNationality,
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

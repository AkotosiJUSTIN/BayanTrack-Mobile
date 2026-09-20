import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/domain/failures.dart';
import '../../../core/utils/kyc_validators.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/data/auth_models.dart';
import '../data/kyc_ocr.dart';
import '../data/kyc_models.dart';
import '../domain/entities/kyc_status.dart';
import '../../auth/presentation/profile_controller.dart';
import 'id_capture_screen.dart';
import 'kyc_controller.dart';

enum _KycStep {
  method,
  idImages,
  ocrReview,
  identity,
  contact,
  address,
  idDetails,
  selfie,
  declaration,
}

/// KYC Form Screen - Comprehensive user verification form
///
/// Sections:
/// A. Basic Identity Information
/// B. Contact Information
/// C. Address Information
/// D. Government ID Details
/// E. ID Upload Images
/// F. Selfie Verification
/// G. User Declaration
class KycFormScreen extends ConsumerStatefulWidget {
  final bool isResubmission;
  final KycStatusEntity? existingKyc;
  final int initialStep;

  const KycFormScreen({
    super.key,
    this.isResubmission = false,
    this.existingKyc,
    this.initialStep = 0,
  });

  @override
  ConsumerState<KycFormScreen> createState() => _KycFormScreenState();
}

class _KycFormScreenState extends ConsumerState<KycFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  static final _nameInputRegex = RegExp(
    r"[A-Za-z\u00C0-\u00D6\u00D8-\u00F6\u00F8-\u00FF\s\-'.]",
  );
  static final _addressInputRegex = RegExp(r"[A-Za-z0-9\s,.'#/()\-\n]");
  static final _idNumberRegex = RegExp(r"[A-Za-z0-9\s-]");

  // Text controllers for all fields
  final _firstNameController = TextEditingController();
  final _middleNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _nationalityController = TextEditingController();
  final _emailController = TextEditingController();
  final _mobileNumberController = TextEditingController();
  final _streetBarangayController = TextEditingController();
  final _cityMunicipalityController = TextEditingController();
  final _provinceController = TextEditingController();
  final _zipCodeController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _stepScrollController = ScrollController();
  final Map<KycOcrField, TextEditingController> _ocrReviewControllers = {};
  final Set<KycOcrField> _dirtyOcrReviewFields = {};

  Map<String, String> _backendFieldErrors = {};
  List<_KycStep>? _stepPlan;
  int _currentStep = 0;
  KycVerificationMethod? _initialVerificationMethod;
  bool _profileContactSeeded = false;
  bool _emailFromProfile = false;
  bool _mobileFromProfile = false;

  @override
  void initState() {
    super.initState();
    final initialState = ref.read(kycFormControllerProvider);
    _initialVerificationMethod = initialState.verificationMethod;
    _syncOcrControllers(initialState);
    ref.listenManual(
      profileControllerProvider,
      (_, next) => next.whenData((profile) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) _seedContactFromProfile(profile);
        });
      }),
      fireImmediately: true,
    );
    if (widget.initialStep >= 0) {
      _currentStep = widget.initialStep;
    }
    if (widget.existingKyc != null) {
      _populateFromExisting(widget.existingKyc!);
    }
  }

  void _seedContactFromProfile(UserProfile profile) {
    if (_profileContactSeeded || widget.existingKyc != null) return;
    _profileContactSeeded = true;

    final current = ref.read(kycFormControllerProvider);
    final email = profile.email.trim();
    final mobile = KycValidators.normalizeMobileNumber(profile.phone ?? '');
    final useEmail =
        current.email.trim().isEmpty && Validators.email(email) == null;
    final useMobile =
        current.mobileNumber.trim().isEmpty &&
        KycValidators.mobileNumber(mobile) == null;
    final controller = ref.read(kycFormControllerProvider.notifier);
    controller.seedContactFromProfile(
      email: useEmail ? email : null,
      mobileNumber: useMobile ? mobile : null,
    );

    _emailFromProfile = useEmail;
    _mobileFromProfile = useMobile;
    final seeded = ref.read(kycFormControllerProvider);
    _syncOcrControllers(seeded);
    if (_currentStep > 0 &&
        _stepPlan == null &&
        seeded.verificationMethod != null) {
      _stepPlan = _stepsForState(seeded);
    }
    if (mounted) setState(() {});
  }

  void _populateFromExisting(KycStatusEntity existing) {
    _firstNameController.text = existing.firstName ?? '';
    _middleNameController.text = existing.middleName ?? '';
    _lastNameController.text = existing.lastName ?? '';
    _nationalityController.text = KycFormState.fixedNationality;
    _emailController.text = existing.email ?? '';
    _mobileNumberController.text = KycValidators.mobileInputValue(
      existing.mobileNumber ?? '',
    );

    _streetBarangayController.text = existing.streetBarangay ?? '';

    _cityMunicipalityController.text = existing.cityMunicipality ?? '';
    _provinceController.text = existing.province ?? '';
    _zipCodeController.text = existing.zipCode ?? '';
    _idNumberController.text = existing.idNumber ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(kycFormControllerProvider.notifier);
      controller.populateFromExisting(existing);
      _stepPlan = _stepsForState(ref.read(kycFormControllerProvider));
      if (mounted) _setCurrentStep(1);
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _middleNameController.dispose();
    _lastNameController.dispose();
    _nationalityController.dispose();
    _emailController.dispose();
    _mobileNumberController.dispose();
    _streetBarangayController.dispose();
    _cityMunicipalityController.dispose();
    _provinceController.dispose();
    _zipCodeController.dispose();
    _idNumberController.dispose();
    _stepScrollController.dispose();
    for (final controller in _ocrReviewControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    try {
      final navigator = Navigator.of(context);
      final isIdImage = imageType == 'id_front' || imageType == 'id_back';
      final pickedFile = source == ImageSource.camera && isIdImage
          ? await navigator.push<XFile>(
              MaterialPageRoute(
                fullscreenDialog: true,
                builder: (_) => IdCaptureScreen(
                  side: imageType == 'id_front'
                      ? IdCaptureSide.front
                      : IdCaptureSide.back,
                ),
              ),
            )
          : await _imagePicker.pickImage(
              source: source,
              maxWidth: 1920,
              maxHeight: 1920,
              imageQuality: 85,
            );

      if (pickedFile == null) return;

      final controller = ref.read(kycFormControllerProvider.notifier);
      switch (imageType) {
        case 'id_front':
          _clearBackendError('id_front_image');
          controller.setIdFrontImage(pickedFile.path);
          if (ref.read(kycFormControllerProvider).verificationMethod ==
              KycVerificationMethod.scanId) {
            final result = await controller.scanId();
            final state = ref.read(kycFormControllerProvider);
            if (mounted && result != null && state.hasRequiredIdImages) {
              _setCurrentStep(
                _indexFor(
                  _KycStep.ocrReview,
                  ref.read(kycFormControllerProvider),
                ),
              );
            }
          }
          break;
        case 'id_back':
          _clearBackendError('id_back_image');
          controller.setIdBackImage(pickedFile.path);
          final state = ref.read(kycFormControllerProvider);
          if (mounted &&
              state.verificationMethod == KycVerificationMethod.scanId &&
              state.hasCurrentOcrResult &&
              !state.isOcrScanning &&
              state.hasRequiredIdImages) {
            _setCurrentStep(_indexFor(_KycStep.ocrReview, state));
          }
          break;
        case 'selfie':
          _clearBackendError('selfie_image');
          controller.setSelfieImage(pickedFile.path);
          break;
        case 'selfie_with_id':
          _clearBackendError('selfie_with_id_image');
          controller.setSelfieWithIdImage(pickedFile.path);
          break;
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context).imageAccessError);
      }
    }
  }

  void _syncOcrControllers(KycFormState state, {bool overwrite = false}) {
    if ((overwrite || _firstNameController.text.trim().isEmpty) &&
        state.firstName.trim().isNotEmpty) {
      _firstNameController.text = state.firstName;
    }
    if ((overwrite || _middleNameController.text.trim().isEmpty) &&
        state.middleName?.trim().isNotEmpty == true) {
      _middleNameController.text = state.middleName!;
    }
    if ((overwrite || _lastNameController.text.trim().isEmpty) &&
        state.lastName.trim().isNotEmpty) {
      _lastNameController.text = state.lastName;
    }
    _nationalityController.text = KycFormState.fixedNationality;
    if ((overwrite || _emailController.text.trim().isEmpty) &&
        state.email.trim().isNotEmpty) {
      _emailController.text = state.email;
    }
    if ((overwrite || _mobileNumberController.text.trim().isEmpty) &&
        state.mobileNumber.trim().isNotEmpty) {
      _mobileNumberController.text = KycValidators.mobileInputValue(
        state.mobileNumber,
      );
    }
    if ((overwrite || _idNumberController.text.trim().isEmpty) &&
        state.idNumber.trim().isNotEmpty) {
      _idNumberController.text = state.idNumber;
    }
    if ((overwrite || _streetBarangayController.text.trim().isEmpty) &&
        state.streetBarangay.trim().isNotEmpty) {
      _streetBarangayController.text = state.streetBarangay;
    }
    if ((overwrite || _cityMunicipalityController.text.trim().isEmpty) &&
        state.cityMunicipality.trim().isNotEmpty) {
      _cityMunicipalityController.text = state.cityMunicipality;
    }
    if ((overwrite || _provinceController.text.trim().isEmpty) &&
        state.province.trim().isNotEmpty) {
      _provinceController.text = state.province;
    }
    if ((overwrite || _zipCodeController.text.trim().isEmpty) &&
        state.zipCode?.trim().isNotEmpty == true) {
      _zipCodeController.text = state.zipCode!;
    }
  }

  void _commitOcrReviewValues() {
    if (_ocrReviewControllers.isEmpty) return;
    final state = ref.read(kycFormControllerProvider);
    final controller = ref.read(kycFormControllerProvider.notifier);
    for (final entry in _ocrReviewControllers.entries) {
      if (state.ocrReviewValues[entry.key] != entry.value.text) {
        controller.setOcrReviewValue(entry.key, entry.value.text);
      }
    }
    _dirtyOcrReviewFields.clear();
  }

  String? _backendError(String field) => _backendFieldErrors[field];

  void _clearBackendError(String field) {
    if (_backendFieldErrors.containsKey(field)) {
      setState(() => _backendFieldErrors.remove(field));
    }
  }

  void _syncTextFieldsToState() {
    final state = ref.read(kycFormControllerProvider);
    final steps = _steps(state);
    final step = steps[_currentIndex(state)];
    final controller = ref.read(kycFormControllerProvider.notifier);

    switch (step) {
      case _KycStep.identity:
        controller
          ..setFirstName(_firstNameController.text)
          ..setMiddleName(_middleNameController.text)
          ..setLastName(_lastNameController.text);
      case _KycStep.contact:
        controller
          ..setEmail(_emailController.text)
          ..setMobileNumber(_mobileNumberController.text);
      case _KycStep.address:
        controller
          ..setStreetBarangay(_streetBarangayController.text)
          ..setCityMunicipality(_cityMunicipalityController.text)
          ..setProvince(_provinceController.text)
          ..setZipCode(_zipCodeController.text);
      case _KycStep.idDetails:
        controller.setIdNumber(_idNumberController.text);
      case _:
        break;
    }
  }

  void _setCurrentStep(int step) {
    _syncTextFieldsToState();
    _commitOcrReviewValues();
    setState(() => _currentStep = step);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _stepScrollController.hasClients) {
        _stepScrollController.jumpTo(0);
      }
    });
  }

  bool _hasBackendError(Iterable<String> fields) =>
      fields.any(_backendFieldErrors.containsKey);

  bool _identityNeedsInput(KycFormState state) =>
      !state.isBasicIdentityComplete ||
      _hasBackendError({
        'first_name',
        'middle_name',
        'last_name',
        'date_of_birth',
        'sex',
        'nationality',
        'civil_status',
      });

  bool _contactNeedsInput(KycFormState state) =>
      Validators.email(state.email) != null ||
      KycValidators.mobileNumber(state.mobileNumber) != null ||
      _hasBackendError({'email', 'mobile_number'});

  bool _addressNeedsInput(KycFormState state) =>
      !state.isAddressComplete ||
      _hasBackendError({
        'street_barangay',
        'city_municipality',
        'province',
        'zip_code',
      });

  bool _idDetailsNeedInput(KycFormState state) =>
      !state.isIdDetailsComplete ||
      _hasBackendError({'id_type', 'id_number', 'id_expiry_date'});

  List<_KycStep> _stepsForState(KycFormState state) {
    switch (state.verificationMethod) {
      case KycVerificationMethod.scanId:
        final steps = <_KycStep>[
          _KycStep.method,
          _KycStep.idImages,
          _KycStep.ocrReview,
        ];
        if (state.ocrReviewConfirmed) {
          if (_identityNeedsInput(state)) steps.add(_KycStep.identity);
          if (_contactNeedsInput(state)) steps.add(_KycStep.contact);
          if (_addressNeedsInput(state)) steps.add(_KycStep.address);
          if (_idDetailsNeedInput(state)) steps.add(_KycStep.idDetails);
        }
        steps.addAll([_KycStep.selfie, _KycStep.declaration]);
        return steps;
      case KycVerificationMethod.manual:
        return [
          _KycStep.method,
          _KycStep.identity,
          if (_contactNeedsInput(state)) _KycStep.contact,
          _KycStep.address,
          _KycStep.idDetails,
          _KycStep.idImages,
          _KycStep.selfie,
          _KycStep.declaration,
        ];
      case null:
        return const [_KycStep.method];
    }
  }

  List<_KycStep> _steps(KycFormState state) {
    if (_stepPlan == null &&
        _currentStep > 0 &&
        state.verificationMethod != null &&
        (_profileContactSeeded ||
            state.verificationMethod != _initialVerificationMethod)) {
      _stepPlan = _stepsForState(state);
    }
    return _stepPlan ?? _stepsForState(state);
  }

  int _currentIndex(KycFormState state) {
    final steps = _steps(state);
    return _currentStep.clamp(0, steps.length - 1).toInt();
  }

  int _indexFor(_KycStep step, KycFormState state) {
    final index = _steps(state).indexOf(step);
    return index < 0 ? _currentIndex(state) : index;
  }

  void _selectVerificationMethod(KycVerificationMethod method) {
    if (ref.read(kycFormControllerProvider).verificationMethod != method) {
      _stepPlan = null;
    }
    ref.read(kycFormControllerProvider.notifier).setVerificationMethod(method);
    _clearBackendError('verification_method');
  }

  void _showImageSourceDialog(String imageType, String title) {
    final l10n = AppLocalizations.of(context);
    showModalBottomSheet(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(l10n.takePhoto),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, imageType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(l10n.chooseFromGallery),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.gallery, imageType);
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Find which step has validation errors
  _KycStep? _findStepWithErrors() {
    final state = ref.read(kycFormControllerProvider);

    if (state.verificationMethod == null) return _KycStep.method;

    if (_backendFieldErrors.isNotEmpty) {
      return _stepForBackendField(_backendFieldErrors.keys.first);
    }

    if (state.verificationMethod == KycVerificationMethod.scanId) {
      if (state.selectedIdType == null) return _KycStep.idImages;
      if (!state.hasRequiredIdImages ||
          state.isOcrScanning ||
          !state.hasCurrentOcrResult) {
        return _KycStep.idImages;
      }
    }

    // Check Basic Identity.
    if (KycValidators.name(
              _firstNameController.text,
              fieldName: 'First name',
            ) !=
            null ||
        (_middleNameController.text.trim().isNotEmpty &&
            KycValidators.name(
                  _middleNameController.text,
                  fieldName: 'Middle name',
                ) !=
                null) ||
        KycValidators.name(_lastNameController.text, fieldName: 'Last name') !=
            null ||
        KycValidators.dateOfBirth(state.dateOfBirth) != null ||
        KycValidators.nationality(_nationalityController.text) != null) {
      return _KycStep.identity;
    }

    // Check Contact.
    final email = _emailController.text.trim();
    final mobile = _mobileNumberController.text.trim();
    if (Validators.email(email) != null) {
      return _KycStep.contact;
    }
    if (KycValidators.mobileNumber(mobile) != null) {
      return _KycStep.contact;
    }

    // Check Address.
    if (KycValidators.addressField(
              _streetBarangayController.text,
              'Street/barangay address',
            ) !=
            null ||
        KycValidators.addressField(
              _cityMunicipalityController.text,
              'City/municipality',
            ) !=
            null ||
        KycValidators.addressField(_provinceController.text, 'Province') !=
            null ||
        KycValidators.zipCode(_zipCodeController.text) != null) {
      return _KycStep.address;
    }

    // Check ID Details.
    if (state.selectedIdType == null ||
        KycValidators.idNumber(_idNumberController.text) != null) {
      return _KycStep.idDetails;
    }

    // Check ID images.
    if (!state.hasRequiredIdImages) {
      return _KycStep.idImages;
    }

    if (!state.hasSelfie) return _KycStep.selfie;

    if (!state.declarationAccepted) return _KycStep.declaration;

    return null;
  }

  /// Get error message for a specific step
  String _getStepErrorMessage(_KycStep step) {
    final l10n = AppLocalizations.of(context);
    switch (step) {
      case _KycStep.method:
        return l10n.chooseVerificationMethod;
      case _KycStep.idImages:
        final state = ref.read(kycFormControllerProvider);
        if (_backendError('id_type') != null) {
          return _backendError('id_type')!;
        }
        if (state.selectedIdType == null) return l10n.selectIdType;
        if (_backendError('id_back_image') != null) {
          return _backendError('id_back_image')!;
        }
        if (_backendError('id_front_image') != null) {
          return _backendError('id_front_image')!;
        }
        if (state.missingRequiredIdSide == KycIdImageSide.back) {
          return l10n.idBackRequired;
        }
        if (state.isOcrScanning) {
          return l10n.ocrScanning;
        }
        return l10n.idFrontRequired;
      case _KycStep.ocrReview:
        return l10n.reviewExtractedDetailsDescription;
      case _KycStep.identity:
        return _backendError('first_name') ??
            _backendError('middle_name') ??
            _backendError('last_name') ??
            _backendError('date_of_birth') ??
            _backendError('nationality') ??
            KycValidators.name(
              _firstNameController.text,
              fieldName: 'First name',
            ) ??
            (_middleNameController.text.trim().isEmpty
                ? null
                : KycValidators.name(
                    _middleNameController.text,
                    fieldName: 'Middle name',
                  )) ??
            KycValidators.name(
              _lastNameController.text,
              fieldName: 'Last name',
            ) ??
            KycValidators.dateOfBirth(
              ref.read(kycFormControllerProvider).dateOfBirth,
            ) ??
            KycValidators.nationality(_nationalityController.text) ??
            '${l10n.basicIdentity}: ${l10n.allRequiredFields}';
      case _KycStep.contact:
        final email = _emailController.text.trim();
        if (_backendError('email') != null) return _backendError('email')!;
        if (email.isEmpty) return l10n.emailAddressRequired;
        if (Validators.email(email) != null) {
          return l10n.invalidEmail;
        }
        return _backendError('mobile_number') ??
            KycValidators.mobileNumber(_mobileNumberController.text) ??
            l10n.mobileNumberDigits;
      case _KycStep.address:
        return _backendError('street_barangay') ??
            _backendError('city_municipality') ??
            _backendError('province') ??
            _backendError('zip_code') ??
            KycValidators.addressField(
              _streetBarangayController.text,
              'Street/barangay address',
            ) ??
            KycValidators.addressField(
              _cityMunicipalityController.text,
              'City/municipality',
            ) ??
            KycValidators.addressField(_provinceController.text, 'Province') ??
            KycValidators.zipCode(_zipCodeController.text) ??
            '${l10n.reportLocation}: ${l10n.allRequiredFields}';
      case _KycStep.idDetails:
        return _backendError('id_type') ??
            _backendError('id_number') ??
            _backendError('id_expiry_date') ??
            KycValidators.idNumber(_idNumberController.text) ??
            '${l10n.selectIdType} / ${l10n.idNumberRequired}';
      case _KycStep.selfie:
        return _backendError('selfie_image') ??
            _backendError('selfie_with_id_image') ??
            l10n.selfieRequired;
      case _KycStep.declaration:
        return _backendError('declaration_accepted') ??
            l10n.declarationRequired;
    }
  }

  void _continueStep() {
    _syncTextFieldsToState();
    _commitOcrReviewValues();
    final state = ref.read(kycFormControllerProvider);
    _stepPlan ??= _stepsForState(state);
    final steps = _stepPlan!;
    final currentIndex = _currentIndex(state);
    final currentStep = steps[currentIndex];

    if (currentStep == _KycStep.ocrReview) {
      ref.read(kycFormControllerProvider.notifier).applyOcrReview();
      final reviewedState = ref.read(kycFormControllerProvider);
      _syncOcrControllers(reviewedState, overwrite: true);
      _stepPlan = _stepsForState(reviewedState);
      final reviewedSteps = _stepPlan!;
      final reviewIndex = reviewedSteps.indexOf(_KycStep.ocrReview);
      if (reviewIndex >= 0 && reviewIndex < reviewedSteps.length - 1) {
        _setCurrentStep(reviewIndex + 1);
      }
      return;
    }

    final errorStep = _findStepWithErrors();
    if (errorStep != null && steps.indexOf(errorStep) <= currentIndex) {
      _formKey.currentState?.validate();
      AppToast.error(context, _getStepErrorMessage(errorStep));
      return;
    }

    final nextSteps = _steps(ref.read(kycFormControllerProvider));
    final nextIndex = nextSteps.indexOf(currentStep);
    if (nextIndex >= 0 && nextIndex < nextSteps.length - 1) {
      _setCurrentStep(nextIndex + 1);
    }
  }

  Future<bool> _confirmResubmission() async {
    final l10n = AppLocalizations.of(context);
    return await showDialog<bool>(
          barrierColor: Colors.black.withValues(alpha: 0.46),
          context: context,
          builder: (context) {
            final theme = Theme.of(context);
            final colors = theme.colorScheme;

            return Dialog(
              insetPadding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 24,
              ),
              backgroundColor: colors.surfaceContainerHigh,
              surfaceTintColor: Colors.transparent,
              elevation: 8,
              shadowColor: colors.shadow.withValues(alpha: 0.18),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(28),
              ),
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 420),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        l10n.confirmSubmit,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.1,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        l10n.reviewAndResubmit,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          color: colors.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          style: FilledButton.styleFrom(
                            minimumSize: const Size.fromHeight(52),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(16),
                            ),
                          ),
                          child: Text(l10n.confirm),
                        ),
                      ),
                      const SizedBox(height: 4),
                      SizedBox(
                        width: double.infinity,
                        child: TextButton(
                          onPressed: () => Navigator.pop(context, false),
                          style: TextButton.styleFrom(
                            foregroundColor: colors.onSurfaceVariant,
                            minimumSize: const Size.fromHeight(48),
                          ),
                          child: Text(l10n.cancel),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ) ??
        false;
  }

  Future<void> _submitForm() async {
    _syncTextFieldsToState();
    // First check which step has errors
    final errorStep = _findStepWithErrors();

    if (errorStep != null) {
      final errorMessage = _getStepErrorMessage(errorStep);
      final state = ref.read(kycFormControllerProvider);
      final errorIndex = _indexFor(errorStep, state);

      // Navigate to the step with errors
      if (_currentStep != errorIndex) {
        _setCurrentStep(errorIndex);
      }

      AppToast.error(context, errorMessage);
      return;
    }

    // Run form validation to trigger field-level error display
    if (!_formKey.currentState!.validate()) {
      AppToast.error(context, AppLocalizations.of(context).fixFormErrors);
      return;
    }

    final state = ref.read(kycFormControllerProvider);
    if (!state.canSubmit) {
      AppToast.error(
        context,
        AppLocalizations.of(context).completeRequiredUploadImages,
      );
      return;
    }

    if (widget.isResubmission && !await _confirmResubmission()) return;

    try {
      _backendFieldErrors = {};
      final controller = ref.read(kycFormControllerProvider.notifier);

      if (widget.isResubmission) {
        await controller.resubmitKyc();
      } else {
        await controller.submitKyc();
      }

      ref.invalidate(kycStatusControllerProvider);

      if (mounted) {
        AppToast.success(
          context,
          widget.isResubmission
              ? AppLocalizations.of(context).verificationResubmitted
              : AppLocalizations.of(context).verificationSubmitted,
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        if (e is ValidationFailure &&
            e.fieldErrors != null &&
            e.fieldErrors!.isNotEmpty) {
          final recognizedErrors = Map<String, String>.from(e.fieldErrors!)
            ..removeWhere((field, _) => _stepForBackendField(field) == null);
          if (recognizedErrors.isNotEmpty) {
            setState(() => _backendFieldErrors = recognizedErrors);
            final errorStep = _stepForBackendField(
              recognizedErrors.keys.first,
            )!;
            final errorIndex = _indexFor(
              errorStep,
              ref.read(kycFormControllerProvider),
            );
            if (_currentStep != errorIndex) _setCurrentStep(errorIndex);
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _formKey.currentState?.validate();
            });
          }
          AppToast.error(
            context,
            recognizedErrors.isNotEmpty
                ? recognizedErrors.values.first
                : e.fieldErrors!.values.first,
          );
          return;
        }
        AppToast.error(
          context,
          e is Failure
              ? e.message
              : AppLocalizations.of(context).verificationSubmitFailed,
        );
      }
    }
  }

  _KycStep? _stepForBackendField(String field) {
    if (field == 'id_type' &&
        ref.read(kycFormControllerProvider).verificationMethod ==
            KycVerificationMethod.scanId) {
      return _KycStep.idImages;
    }
    return switch (field) {
      'first_name' ||
      'middle_name' ||
      'last_name' ||
      'date_of_birth' ||
      'sex' ||
      'civil_status' ||
      'nationality' => _KycStep.identity,
      'email' || 'mobile_number' => _KycStep.contact,
      'street_barangay' ||
      'city_municipality' ||
      'province' ||
      'zip_code' => _KycStep.address,
      'id_type' || 'id_number' || 'id_expiry_date' => _KycStep.idDetails,
      'id_front_image' || 'id_back_image' => _KycStep.idImages,
      'selfie_image' || 'selfie_with_id_image' => _KycStep.selfie,
      'declaration_accepted' => _KycStep.declaration,
      _ => null,
    };
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycFormControllerProvider);
    final l10n = AppLocalizations.of(context);
    final steps = _steps(state);
    final currentIndex = _currentIndex(state);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isResubmission
              ? l10n.resubmitUserVerification
              : l10n.submitUserVerification,
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: Semantics(
            container: true,
            label: l10n.stepOf(currentIndex + 1, steps.length),
            child: LinearProgressIndicator(
              value: (currentIndex + 1) / steps.length,
              minHeight: 4,
            ),
          ),
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: SafeArea(
          child: Column(
            children: [
              _buildStepHeader(state),
              Expanded(
                child: SingleChildScrollView(
                  controller: _stepScrollController,
                  keyboardDismissBehavior:
                      ScrollViewKeyboardDismissBehavior.onDrag,
                  padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 640),
                      child: _buildCurrentStep(state, steps[currentIndex]),
                    ),
                  ),
                ),
              ),
              _buildWizardControls(state, l10n),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStepHeader(KycFormState state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final steps = _steps(state);
    final currentIndex = _currentIndex(state);
    final currentStep = steps[currentIndex];

    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            l10n.stepOf(currentIndex + 1, steps.length),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _stepTitle(currentStep, state, l10n),
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            _stepSubtitle(currentStep, state, l10n),
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  String _stepTitle(_KycStep step, KycFormState state, AppLocalizations l10n) =>
      switch (step) {
        _KycStep.method => l10n.chooseVerificationMethod,
        _KycStep.idImages =>
          state.verificationMethod == KycVerificationMethod.scanId
              ? l10n.scanId
              : l10n.uploadIdImages,
        _KycStep.ocrReview => l10n.reviewExtractedDetails,
        _KycStep.identity => l10n.basicIdentity,
        _KycStep.contact => l10n.contactInfo,
        _KycStep.address => l10n.reportLocation,
        _KycStep.idDetails => l10n.governmentId,
        _KycStep.selfie => l10n.selfie,
        _KycStep.declaration => l10n.declaration,
      };

  String _stepSubtitle(
    _KycStep step,
    KycFormState state,
    AppLocalizations l10n,
  ) => switch (step) {
    _KycStep.method => l10n.chooseVerificationMethodDescription,
    _KycStep.idImages =>
      state.verificationMethod == KycVerificationMethod.scanId
          ? l10n.scanIdDescription
          : l10n.maxImageFormats,
    _KycStep.ocrReview => l10n.reviewExtractedDetailsDescription,
    _KycStep.identity => l10n.personalInformation,
    _KycStep.contact => l10n.emailPhone,
    _KycStep.address => l10n.currentResidence,
    _KycStep.idDetails => l10n.idTypeNumber,
    _KycStep.selfie => l10n.faceVerification,
    _KycStep.declaration => l10n.confirmSubmit,
  };

  Widget _buildCurrentStep(KycFormState state, _KycStep step) => switch (step) {
    _KycStep.method => _buildMethodSection(state),
    _KycStep.idImages => _buildIdImagesSection(state),
    _KycStep.ocrReview => _buildOcrReviewSection(state),
    _KycStep.identity => _buildBasicIdentitySection(state),
    _KycStep.contact => _buildContactSection(state),
    _KycStep.address => _buildAddressSection(state),
    _KycStep.idDetails => _buildIdDetailsSection(
      state,
      includeType: state.verificationMethod == KycVerificationMethod.manual,
    ),
    _KycStep.selfie => _buildSelfieSection(state),
    _KycStep.declaration => _buildDeclarationSection(state),
  };

  Widget _buildWizardControls(KycFormState state, AppLocalizations l10n) {
    final steps = _steps(state);
    final currentIndex = _currentIndex(state);
    final isLastStep =
        steps[currentIndex] != _KycStep.method &&
        currentIndex == steps.length - 1;
    return Padding(
      padding: const EdgeInsets.fromLTRB(24, 8, 24, 12),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: state.isSubmitting
                  ? null
                  : !isLastStep
                  ? _continueStep
                  : _submitForm,
              child: state.isSubmitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Text(
                      !isLastStep
                          ? l10n.continueLabel
                          : widget.isResubmission
                          ? l10n.resubmitDocuments
                          : l10n.submit,
                    ),
            ),
          ),
          if (currentIndex > 0) ...[
            const SizedBox(width: 12),
            Expanded(
              child: OutlinedButton(
                onPressed: state.isSubmitting
                    ? null
                    : () => _setCurrentStep(currentIndex - 1),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size.fromHeight(52),
                  side: BorderSide(
                    color: Theme.of(context).colorScheme.outline,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(l10n.back),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==================== SECTION BUILDERS ====================

  Widget _buildMethodSection(KycFormState state) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chooseVerificationMethodDescription,
          style: theme.textTheme.bodyLarge,
        ),
        const SizedBox(height: 20),
        _buildMethodCard(
          method: KycVerificationMethod.scanId,
          title: l10n.scanIdOptionTitle,
          description: l10n.scanIdOptionDescription,
          icon: Icons.document_scanner_outlined,
          selected: state.verificationMethod == KycVerificationMethod.scanId,
        ),
        const SizedBox(height: 12),
        _buildMethodCard(
          method: KycVerificationMethod.manual,
          title: l10n.manualEntryOptionTitle,
          description: l10n.manualEntryOptionDescription,
          icon: Icons.edit_note_outlined,
          selected: state.verificationMethod == KycVerificationMethod.manual,
        ),
      ],
    );
  }

  Widget _buildMethodCard({
    required KycVerificationMethod method,
    required String title,
    required String description,
    required IconData icon,
    required bool selected,
  }) {
    final theme = Theme.of(context);
    return Semantics(
      button: true,
      selected: selected,
      label: '$title. $description',
      child: Material(
        color: selected
            ? theme.colorScheme.primaryContainer
            : theme.colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          onTap: () => _selectVerificationMethod(method),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  icon,
                  size: 28,
                  color: selected
                      ? theme.colorScheme.onPrimaryContainer
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          color: selected
                              ? theme.colorScheme.onPrimaryContainer
                              : null,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(description, style: theme.textTheme.bodyMedium),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  selected ? Icons.check_circle : Icons.radio_button_unchecked,
                  color: selected
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIdTypeSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    return DropdownButtonFormField<IdType>(
      decoration: InputDecoration(
        labelText: '${l10n.idType} *',
        border: _inputBorder(),
        prefixIcon: const Icon(Icons.badge_outlined),
      ),
      initialValue: state.selectedIdType,
      items: _idTypeOptions(state.selectedIdType)
          .map(
            (type) => DropdownMenuItem(
              value: type,
              child: Text(_idTypeLabel(type, l10n)),
            ),
          )
          .toList(),
      onChanged: (value) {
        if (value != null) {
          _clearBackendError('id_type');
          controller.setIdType(value);
        }
      },
      validator: (value) =>
          _backendError('id_type') ??
          (value == null ? l10n.selectIdType : null),
    );
  }

  bool _showIdentityField(KycFormState state, KycOcrField field) {
    if (state.verificationMethod != KycVerificationMethod.scanId ||
        state.ocrResult == null) {
      return true;
    }
    return _backendError(_backendFieldForOcrField(field)) != null ||
        !state.ocrAppliedValues.containsKey(field);
  }

  Widget _buildBasicIdentitySection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final showFirstName = _showIdentityField(state, KycOcrField.firstName);
    final showMiddleName = _showIdentityField(state, KycOcrField.middleName);
    final showLastName = _showIdentityField(state, KycOcrField.lastName);
    final showDateOfBirth = _showIdentityField(state, KycOcrField.dateOfBirth);
    final showSex = _showIdentityField(state, KycOcrField.sex);
    final showNationality = _showIdentityField(state, KycOcrField.nationality);
    final showCivilStatus = _showIdentityField(state, KycOcrField.civilStatus);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildVerificationNotice(),
        const SizedBox(height: 16),

        // Rejection reason banner
        if (widget.isResubmission &&
            widget.existingKyc?.rejectionReason != null)
          _buildRejectionBanner(widget.existingKyc!.rejectionReason!),

        if (widget.isResubmission &&
            widget.existingKyc?.rejectionReason != null)
          const SizedBox(height: 16),

        if (showFirstName) ...[
          // First Name *
          TextFormField(
            controller: _firstNameController,
            decoration: InputDecoration(
              labelText: '${l10n.firstName} *',
              border: _inputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(_nameInputRegex),
              LengthLimitingTextInputFormatter(50),
            ],
            onChanged: (v) {
              _clearBackendError('first_name');
            },
            validator: (v) {
              if (_backendError('first_name') != null) {
                return _backendError('first_name');
              }
              if (v == null || v.trim().isEmpty) return l10n.firstNameRequired;
              return KycValidators.name(v, fieldName: 'First name');
            },
          ),
          const SizedBox(height: 16),
        ],

        if (showMiddleName) ...[
          // Middle Name
          TextFormField(
            controller: _middleNameController,
            decoration: InputDecoration(
              labelText: l10n.middleName,
              border: _inputBorder(),
              prefixIcon: Icon(Icons.person_outline),
            ),
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(_nameInputRegex),
              LengthLimitingTextInputFormatter(50),
            ],
            onChanged: (v) {
              _clearBackendError('middle_name');
            },
            validator: (v) =>
                _backendError('middle_name') ??
                (v == null || v.trim().isEmpty
                    ? null
                    : KycValidators.name(v, fieldName: 'Middle name')),
          ),
          const SizedBox(height: 16),
        ],

        if (showLastName) ...[
          // Last Name *
          TextFormField(
            controller: _lastNameController,
            decoration: InputDecoration(
              labelText: '${l10n.lastName} *',
              border: _inputBorder(),
              prefixIcon: Icon(Icons.person),
            ),
            textCapitalization: TextCapitalization.words,
            inputFormatters: [
              FilteringTextInputFormatter.allow(_nameInputRegex),
              LengthLimitingTextInputFormatter(50),
            ],
            onChanged: (v) {
              _clearBackendError('last_name');
            },
            validator: (v) {
              if (_backendError('last_name') != null) {
                return _backendError('last_name');
              }
              if (v == null || v.trim().isEmpty) return l10n.lastNameRequired;
              return KycValidators.name(v, fieldName: 'Last name');
            },
          ),
          const SizedBox(height: 16),
        ],

        if (showDateOfBirth) ...[
          // Date of Birth *
          FormField<DateTime>(
            initialValue: state.dateOfBirth,
            validator: (_) =>
                _backendError('date_of_birth') ??
                KycValidators.dateOfBirth(state.dateOfBirth),
            builder: (field) => Semantics(
              button: true,
              label: '${l10n.dateOfBirth}, ${l10n.selectDate}',
              child: InkWell(
                onTap: () async {
                  final today = DateTime.now();
                  final lastDate = DateTime(
                    today.year - 18,
                    today.month,
                    today.day,
                  );
                  final firstDate = DateTime(
                    today.year - 120,
                    today.month,
                    today.day,
                  );
                  final currentDate = state.dateOfBirth;
                  final initialDate = currentDate == null
                      ? DateTime(1990)
                      : currentDate.isBefore(firstDate)
                      ? firstDate
                      : currentDate.isAfter(lastDate)
                      ? lastDate
                      : currentDate;
                  final date = await showDatePicker(
                    context: context,
                    initialDate: initialDate,
                    firstDate: firstDate,
                    lastDate: lastDate,
                  );
                  if (date != null) {
                    _clearBackendError('date_of_birth');
                    controller.setDateOfBirth(date);
                    field.didChange(date);
                  }
                },
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: '${l10n.dateOfBirth} *',
                    border: _inputBorder(),
                    prefixIcon: const Icon(Icons.calendar_today),
                    errorText:
                        _backendError('date_of_birth') ?? field.errorText,
                  ),
                  child: Text(
                    state.dateOfBirth == null
                        ? l10n.selectDate
                        : '${state.dateOfBirth!.year}-${state.dateOfBirth!.month.toString().padLeft(2, '0')}-${state.dateOfBirth!.day.toString().padLeft(2, '0')}',
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],

        if (showSex) ...[
          // Sex
          DropdownButtonFormField<Sex>(
            decoration: InputDecoration(
              labelText: l10n.sex,
              border: _inputBorder(),
              prefixIcon: Icon(Icons.wc),
            ),
            initialValue: state.sex,
            items: Sex.values
                .map(
                  (s) => DropdownMenuItem(
                    value: s,
                    child: Text(_sexLabel(s, l10n)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              _clearBackendError('sex');
              controller.setSex(v);
            },
            validator: (_) => _backendError('sex'),
          ),
          const SizedBox(height: 16),
        ],

        if (showNationality) ...[
          // Nationality *
          TextFormField(
            controller: _nationalityController,
            readOnly: true,
            decoration: InputDecoration(
              labelText: '${l10n.nationality} *',
              border: _inputBorder(),
              prefixIcon: Icon(Icons.flag),
            ),
            validator: (_) => _backendError('nationality'),
          ),
          const SizedBox(height: 16),
        ],

        if (showCivilStatus) ...[
          // Civil Status
          DropdownButtonFormField<CivilStatus>(
            decoration: InputDecoration(
              labelText: l10n.civilStatus,
              border: _inputBorder(),
              prefixIcon: Icon(Icons.favorite),
            ),
            initialValue: state.civilStatus,
            items: CivilStatus.values
                .map(
                  (c) => DropdownMenuItem(
                    value: c,
                    child: Text(_civilStatusLabel(c, l10n)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              _clearBackendError('civil_status');
              controller.setCivilStatus(v);
            },
            validator: (_) => _backendError('civil_status'),
          ),
        ],
      ],
    );
  }

  Widget _buildContactSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // Email *
        TextFormField(
          key: const ValueKey('kyc-profile-email'),
          controller: _emailController,
          readOnly: _emailFromProfile,
          decoration: InputDecoration(
            labelText: '${l10n.emailAddress} *',
            border: _inputBorder(),
            prefixIcon: Icon(Icons.email),
            suffixIcon: _emailFromProfile
                ? const Icon(Icons.lock_outline)
                : null,
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: _emailFromProfile
              ? null
              : (v) {
                  _clearBackendError('email');
                },
          validator: (value) =>
              _backendError('email') ?? Validators.email(value, l10n: l10n),
        ),
        const SizedBox(height: 16),

        // Mobile Number *
        TextFormField(
          controller: _mobileNumberController,
          readOnly: _mobileFromProfile,
          decoration: InputDecoration(
            labelText: '${l10n.mobileNumberRequired} *',
            border: _inputBorder(),
            prefixIcon: Icon(Icons.phone),
            prefixText: '+63 ',
            hintText: '9123456789',
            suffixIcon: _mobileFromProfile
                ? const Icon(Icons.lock_outline)
                : null,
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: _mobileFromProfile
              ? null
              : (v) {
                  _clearBackendError('mobile_number');
                },
          validator: (v) =>
              _backendError('mobile_number') ?? KycValidators.mobileNumber(v),
        ),
      ],
    );
  }

  Widget _buildAddressSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // House No. / Street *
        TextFormField(
          controller: _streetBarangayController,
          decoration: InputDecoration(
            labelText: '${l10n.houseStreet} *',
            border: _inputBorder(),
            prefixIcon: Icon(Icons.home),
            hintText: l10n.houseStreetHint,
          ),
          textCapitalization: TextCapitalization.words,
          keyboardType: TextInputType.multiline,
          textInputAction: TextInputAction.newline,
          minLines: 1,
          maxLines: 2,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_addressInputRegex),
            LengthLimitingTextInputFormatter(255),
          ],
          onChanged: (v) {
            _clearBackendError('street_barangay');
          },
          validator: (v) =>
              _backendError('street_barangay') ??
              KycValidators.addressField(v, 'Street/barangay address'),
        ),
        const SizedBox(height: 16),

        // City *
        TextFormField(
          controller: _cityMunicipalityController,
          decoration: InputDecoration(
            labelText: '${l10n.city} *',
            border: _inputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_addressInputRegex),
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (v) {
            _clearBackendError('city_municipality');
          },
          validator: (v) =>
              _backendError('city_municipality') ??
              KycValidators.addressField(v, 'City/municipality'),
        ),
        const SizedBox(height: 16),

        // Province *
        TextFormField(
          controller: _provinceController,
          decoration: InputDecoration(
            labelText: '${l10n.province} *',
            border: _inputBorder(),
            prefixIcon: Icon(Icons.map),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_addressInputRegex),
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (v) {
            _clearBackendError('province');
          },
          validator: (v) =>
              _backendError('province') ??
              KycValidators.addressField(v, 'Province'),
        ),
        const SizedBox(height: 16),

        // ZIP Code
        TextFormField(
          controller: _zipCodeController,
          decoration: InputDecoration(
            labelText: l10n.zipCode,
            border: _inputBorder(),
            prefixIcon: Icon(Icons.markunread_mailbox),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(4),
          ],
          onChanged: (v) {
            _clearBackendError('zip_code');
          },
          validator: (v) =>
              _backendError('zip_code') ?? KycValidators.zipCode(v),
        ),
      ],
    );
  }

  Widget _buildIdDetailsSection(
    KycFormState state, {
    required bool includeType,
  }) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        if (includeType) ...[
          // ID Type *
          DropdownButtonFormField<IdType>(
            decoration: InputDecoration(
              labelText: '${l10n.idType} *',
              border: _inputBorder(),
              prefixIcon: const Icon(Icons.badge),
            ),
            initialValue: state.selectedIdType,
            items: _idTypeOptions(state.selectedIdType)
                .map(
                  (type) => DropdownMenuItem(
                    value: type,
                    child: Text(_idTypeLabel(type, l10n)),
                  ),
                )
                .toList(),
            onChanged: (v) {
              if (v != null) {
                _clearBackendError('id_type');
                controller.setIdType(v);
              }
            },
            validator: (v) =>
                _backendError('id_type') ??
                (v == null ? l10n.selectIdType : null),
          ),
          const SizedBox(height: 16),
        ],

        // ID Number *
        TextFormField(
          controller: _idNumberController,
          decoration: InputDecoration(
            labelText: '${l10n.idNumber} *',
            border: _inputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(_idNumberRegex),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (v) {
            _clearBackendError('id_number');
          },
          validator: (v) =>
              _backendError('id_number') ?? KycValidators.idNumber(v),
        ),
        const SizedBox(height: 16),

        // ID Expiry Date
        Semantics(
          button: true,
          label: '${l10n.idExpiryDate}, ${l10n.selectOptionalDate}',
          child: InkWell(
            onTap: () async {
              final date = await showDatePicker(
                context: context,
                initialDate:
                    state.idExpiryDate ??
                    DateTime.now().add(const Duration(days: 365)),
                firstDate: DateTime.now(),
                lastDate: DateTime.now().add(const Duration(days: 3650)),
              );
              if (date != null) {
                _clearBackendError('id_expiry_date');
                controller.setIdExpiryDate(date);
              }
            },
            child: InputDecorator(
              decoration: InputDecoration(
                labelText: l10n.idExpiryDate,
                border: _inputBorder(),
                prefixIcon: Icon(Icons.event),
                errorText: _backendError('id_expiry_date'),
              ),
              child: Text(
                state.idExpiryDate == null
                    ? l10n.selectOptionalDate
                    : '${state.idExpiryDate!.year}-${state.idExpiryDate!.month.toString().padLeft(2, '0')}-${state.idExpiryDate!.day.toString().padLeft(2, '0')}',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdImagesSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final requiresBack = state.requiresIdBack;
    final isScanPath = state.verificationMethod == KycVerificationMethod.scanId;
    final canReview =
        state.hasCurrentOcrResult &&
        !state.isOcrScanning &&
        state.hasRequiredIdImages;

    if (isScanPath && state.selectedIdType == null) {
      return _buildIdTypeSection(state);
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isScanPath) ...[
          _buildIdTypeSection(state),
          const SizedBox(height: 24),
        ],
        Text(
          l10n.uploadGovId,
          style: TextStyle(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          isScanPath
              ? '${l10n.scanIdDescription}\n${l10n.maxImageFormats}'
              : l10n.maxImageFormats,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 16),

        // ID Front *
        _buildImagePicker(
          title: isScanPath
              ? '${l10n.scanId} · ${l10n.idFrontPhoto} *'
              : '${l10n.idFrontPhoto} *',
          imagePath: state.idFrontImagePath,
          onTap: () => _showImageSourceDialog(
            'id_front',
            isScanPath ? l10n.scanId : l10n.idFrontPhoto,
          ),
          onRemove: () => controller.setIdFrontImage(null),
        ),
        const SizedBox(height: 16),

        // ID Back (conditional)
        if (requiresBack) ...[
          _buildImagePicker(
            title: '${l10n.idBackPhoto} *',
            imagePath: state.idBackImagePath,
            onTap: () => _showImageSourceDialog('id_back', l10n.idBackPhoto),
            onRemove: () => controller.setIdBackImage(null),
          ),
        ],
        if (isScanPath && state.isOcrScanning) ...[
          const SizedBox(height: 16),
          LinearProgressIndicator(semanticsLabel: l10n.ocrScanning),
          const SizedBox(height: 8),
          Text(l10n.ocrScanning),
        ],
        if (isScanPath && state.ocrError != null) ...[
          const SizedBox(height: 12),
          Text(
            l10n.ocrUnreadable,
            style: TextStyle(color: Theme.of(context).colorScheme.error),
          ),
        ],
        if (isScanPath && canReview) ...[
          const SizedBox(height: 16),
          FilledButton.tonalIcon(
            onPressed: () =>
                _setCurrentStep(_indexFor(_KycStep.ocrReview, state)),
            icon: const Icon(Icons.fact_check_outlined),
            label: Text(l10n.reviewExtractedDetails),
          ),
        ],
      ],
    );
  }

  Widget _buildOcrReviewSection(KycFormState state) {
    final l10n = AppLocalizations.of(context);
    final result = state.ocrResult;
    final theme = Theme.of(context);

    if (result == null || result.idType != state.selectedIdType) {
      return _buildOcrRecovery(l10n.ocrUnreadable, Icons.info_outline, l10n);
    }
    if (result.status == KycOcrResultStatus.unsupported) {
      return _buildOcrRecovery(
        l10n.ocrUnsupported,
        Icons.edit_note_outlined,
        l10n,
      );
    }
    if (!result.hasFields) {
      return _buildOcrRecovery(
        result.message ?? l10n.ocrUnreadable,
        Icons.document_scanner_outlined,
        l10n,
      );
    }

    final controller = ref.read(kycFormControllerProvider.notifier);
    final fields = result.fields;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOcrReviewNotice(
          l10n.ocrAuthenticityNotice,
          Icons.shield_outlined,
        ),
        const SizedBox(height: 16),
        if (result.status == KycOcrResultStatus.partial)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(
              l10n.ocrPartial,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant),
            ),
          ),
        ...fields.entries.expand((entry) {
          final value = entry.value;
          final confidence = value.confidence == KycOcrConfidence.high
              ? l10n.ocrHighConfidence
              : l10n.ocrManualReview;
          return [
            _buildOcrField(
              field: entry.key,
              value: value,
              confidenceLabel: confidence,
              controller: controller,
            ),
            const SizedBox(height: 14),
          ];
        }),
        Text(
          l10n.reviewExtractedDetailsDescription,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }

  Widget _buildOcrReviewNotice(String message, IconData icon) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: theme.colorScheme.onSecondaryContainer),
          const SizedBox(width: 12),
          Expanded(child: Text(message)),
        ],
      ),
    );
  }

  Widget _buildOcrRecovery(
    String message,
    IconData icon,
    AppLocalizations l10n,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildOcrReviewNotice(message, icon),
        const SizedBox(height: 16),
        FilledButton.tonalIcon(
          onPressed: () => _setCurrentStep(
            _indexFor(_KycStep.idImages, ref.read(kycFormControllerProvider)),
          ),
          icon: const Icon(Icons.refresh),
          label: Text(l10n.scanId),
        ),
      ],
    );
  }

  Widget _buildOcrField({
    required KycOcrField field,
    required KycOcrFieldValue value,
    required String confidenceLabel,
    required KycFormController controller,
  }) {
    final l10n = AppLocalizations.of(context);
    final currentState = ref.read(kycFormControllerProvider);
    final fieldLabel = switch (field) {
      KycOcrField.firstName => '${l10n.firstName} *',
      KycOcrField.middleName => l10n.middleName,
      KycOcrField.lastName => '${l10n.lastName} *',
      KycOcrField.dateOfBirth => '${l10n.dateOfBirth} *',
      KycOcrField.sex => l10n.sex,
      KycOcrField.nationality => '${l10n.nationality} *',
      KycOcrField.civilStatus => l10n.civilStatus,
      KycOcrField.address => l10n.houseStreet,
      KycOcrField.cityMunicipality => l10n.city,
      KycOcrField.province => l10n.province,
      KycOcrField.zipCode => l10n.zipCode,
      KycOcrField.idNumber => '${l10n.idNumber} *',
      KycOcrField.idExpiryDate => l10n.idExpiryDate,
    };
    final reviewValue = field == KycOcrField.nationality
        ? KycFormState.fixedNationality
        : currentState.ocrReviewValue(field) ?? value.value;

    if (field == KycOcrField.dateOfBirth || field == KycOcrField.idExpiryDate) {
      final date = DateTime.tryParse(reviewValue);
      return Semantics(
        button: true,
        label: fieldLabel,
        child: InkWell(
          onTap: () => _editOcrDate(field, controller, date),
          child: InputDecorator(
            decoration: InputDecoration(labelText: fieldLabel),
            child: Row(
              children: [
                Expanded(
                  child: Text(date == null ? reviewValue : _formatDate(date)),
                ),
                _buildOcrConfidenceChip(confidenceLabel),
              ],
            ),
          ),
        ),
      );
    }

    if (field == KycOcrField.sex || field == KycOcrField.civilStatus) {
      final selectedSex = _sexFromReview(reviewValue);
      final selectedCivilStatus = _civilStatusFromReview(reviewValue);
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DropdownButtonFormField<Object>(
            decoration: InputDecoration(labelText: fieldLabel),
            initialValue: field == KycOcrField.sex
                ? selectedSex
                : selectedCivilStatus,
            items: field == KycOcrField.sex
                ? Sex.values
                      .map(
                        (sex) => DropdownMenuItem<Object>(
                          value: sex,
                          child: Text(_sexLabel(sex, l10n)),
                        ),
                      )
                      .toList()
                : CivilStatus.values
                      .map(
                        (status) => DropdownMenuItem<Object>(
                          value: status,
                          child: Text(_civilStatusLabel(status, l10n)),
                        ),
                      )
                      .toList(),
            onChanged: (selected) {
              if (field == KycOcrField.sex && selected is Sex) {
                _clearBackendError('sex');
                controller.setOcrReviewValue(field, selected.name);
              } else if (field == KycOcrField.civilStatus &&
                  selected is CivilStatus) {
                _clearBackendError('civil_status');
                controller.setOcrReviewValue(field, selected.name);
              }
            },
          ),
          const SizedBox(height: 6),
          _buildOcrConfidenceChip(confidenceLabel),
        ],
      );
    }

    final textController = switch (field) {
      KycOcrField.firstName => _firstNameController,
      KycOcrField.middleName => _middleNameController,
      KycOcrField.lastName => _lastNameController,
      KycOcrField.nationality => _nationalityController,
      KycOcrField.address => _streetBarangayController,
      KycOcrField.cityMunicipality => _cityMunicipalityController,
      KycOcrField.province => _provinceController,
      KycOcrField.zipCode => _zipCodeController,
      KycOcrField.idNumber => _idNumberController,
      _ => null,
    };
    if (textController == null) return const SizedBox.shrink();
    final reviewController = _ocrReviewControllers.putIfAbsent(
      field,
      () => TextEditingController(text: reviewValue),
    );
    if (!_dirtyOcrReviewFields.contains(field) &&
        reviewController.text != reviewValue) {
      reviewController.value = TextEditingValue(
        text: reviewValue,
        selection: TextSelection.collapsed(offset: reviewValue.length),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          key: ValueKey('ocr-${field.name}'),
          controller: reviewController,
          readOnly: field == KycOcrField.nationality,
          decoration: InputDecoration(labelText: fieldLabel),
          onChanged: field == KycOcrField.nationality
              ? null
              : (text) {
                  _dirtyOcrReviewFields.add(field);
                  _clearBackendError(_backendFieldForOcrField(field));
                },
        ),
        const SizedBox(height: 6),
        _buildOcrConfidenceChip(confidenceLabel),
      ],
    );
  }

  Widget _buildOcrConfidenceChip(String label) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Text(label, style: theme.textTheme.labelMedium),
      ),
    );
  }

  String _backendFieldForOcrField(KycOcrField field) => switch (field) {
    KycOcrField.firstName => 'first_name',
    KycOcrField.middleName => 'middle_name',
    KycOcrField.lastName => 'last_name',
    KycOcrField.dateOfBirth => 'date_of_birth',
    KycOcrField.sex => 'sex',
    KycOcrField.nationality => 'nationality',
    KycOcrField.civilStatus => 'civil_status',
    KycOcrField.address => 'street_barangay',
    KycOcrField.cityMunicipality => 'city_municipality',
    KycOcrField.province => 'province',
    KycOcrField.zipCode => 'zip_code',
    KycOcrField.idNumber => 'id_number',
    KycOcrField.idExpiryDate => 'id_expiry_date',
  };

  Sex? _sexFromReview(String value) {
    for (final sex in Sex.values) {
      if (sex.name == value) return sex;
    }
    return null;
  }

  CivilStatus? _civilStatusFromReview(String value) {
    for (final status in CivilStatus.values) {
      if (status.name == value) return status;
    }
    return null;
  }

  Future<void> _editOcrDate(
    KycOcrField field,
    KycFormController controller,
    DateTime? currentDate,
  ) async {
    final now = DateTime.now();
    final firstDate = field == KycOcrField.dateOfBirth
        ? DateTime(now.year - 120, now.month, now.day)
        : now;
    final lastDate = field == KycOcrField.dateOfBirth
        ? DateTime(now.year - 18, now.month, now.day)
        : DateTime(now.year + 20, now.month, now.day);
    final initialDate = currentDate == null
        ? field == KycOcrField.dateOfBirth
              ? DateTime(now.year - 30, now.month, now.day)
              : DateTime(now.year + 1, now.month, now.day)
        : currentDate.isBefore(firstDate)
        ? firstDate
        : currentDate.isAfter(lastDate)
        ? lastDate
        : currentDate;
    final date = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
    );
    if (date == null) return;
    _clearBackendError(_backendFieldForOcrField(field));
    controller.setOcrReviewValue(field, _formatDate(date));
  }

  String _formatDate(DateTime date) =>
      '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';

  Widget _buildSelfieSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.selfieInstructions,
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // Selfie *
        _buildImagePicker(
          title: '${l10n.selfiePhoto} *',
          imagePath: state.selfieImagePath,
          onTap: () => _showImageSourceDialog('selfie', l10n.selfiePhoto),
          onRemove: () => controller.setSelfieImage(null),
        ),
        const SizedBox(height: 16),

        // Selfie with ID (optional but recommended)
        _buildImagePicker(
          title: l10n.selfieHoldingId,
          imagePath: state.selfieWithIdImagePath,
          onTap: () =>
              _showImageSourceDialog('selfie_with_id', l10n.selfieHoldingId),
          onRemove: () => controller.setSelfieWithIdImage(null),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.holdIdInstruction,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }

  Widget _buildDeclarationSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Summary card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.submissionSummary,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow(l10n.name, state.fullName),
                _buildSummaryRow(l10n.email, state.email),
                _buildSummaryRow(l10n.mobile, state.mobileNumber),
                _buildSummaryRow(
                  l10n.idType,
                  state.selectedIdType == null
                      ? '-'
                      : _idTypeLabel(state.selectedIdType!, l10n),
                ),
                _buildSummaryRow(l10n.idNumber, state.idNumber),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      state.hasIdFront ? Icons.check_circle : Icons.cancel,
                      color: state.hasIdFront
                          ? AppColors.success
                          : AppColors.alertHigh,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.idFrontPhoto),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      state.hasSelfie ? Icons.check_circle : Icons.cancel,
                      color: state.hasSelfie
                          ? AppColors.success
                          : AppColors.alertHigh,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Text(l10n.selfiePhoto),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Declaration checkbox
        CheckboxListTile(
          value: state.declarationAccepted,
          onChanged: (v) {
            _clearBackendError('declaration_accepted');
            controller.setDeclarationAccepted(v ?? false);
          },
          title: Text(l10n.declarationFullText, style: TextStyle(fontSize: 14)),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        if (!state.declarationAccepted)
          Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              l10n.acceptDeclaration,
              style: TextStyle(color: AppColors.alertHigh, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================

  InputBorder _inputBorder() =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(12));

  Widget _buildVerificationNotice() {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.18),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.shield_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.verificationNotice,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.declarationFullText,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.4),
                ),
                const SizedBox(height: 6),
                Text(
                  l10n.allRequiredFields,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  List<IdType> _idTypeOptions(IdType? current) {
    final options = IdType.values
        .where((type) => type != IdType.philsys)
        .toList();
    if (current == IdType.philsys) {
      final nationalIdIndex = options.indexOf(IdType.nationalId);
      if (nationalIdIndex >= 0) options[nationalIdIndex] = IdType.philsys;
    }
    return options;
  }

  String _idTypeLabel(IdType value, AppLocalizations l10n) => switch (value) {
    IdType.passport => l10n.idPassport,
    IdType.nationalId => l10n.idNational,
    IdType.driversLicense => l10n.idDriversLicense,
    // PhilSys remains a legacy API alias, but is presented as National ID.
    IdType.philsys => l10n.idNational,
    IdType.sss => l10n.idSss,
    IdType.umid => l10n.idUmid,
    IdType.postal => l10n.idPostal,
    IdType.voters => l10n.idVoters,
    IdType.gsisECard => l10n.idGsisECard,
    IdType.philHealth => l10n.idPhilHealth,
    IdType.prcProfessionalId => l10n.idPrc,
  };

  String _sexLabel(Sex value, AppLocalizations l10n) => switch (value) {
    Sex.male => l10n.male,
    Sex.female => l10n.female,
  };

  String _civilStatusLabel(CivilStatus value, AppLocalizations l10n) =>
      switch (value) {
        CivilStatus.single => l10n.single,
        CivilStatus.married => l10n.married,
        CivilStatus.widowed => l10n.widowed,
        CivilStatus.separated => l10n.separated,
        CivilStatus.divorced => l10n.divorced,
      };

  Widget _buildRejectionBanner(String reason) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.errorContainer.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.22),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: theme.colorScheme.error),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.previousRejectionReason,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(reason, style: theme.textTheme.bodyMedium),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text(
              '$label:',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ),
          Expanded(child: Text(value.isEmpty ? '-' : value)),
        ],
      ),
    );
  }

  Widget _buildImagePicker({
    required String title,
    required String? imagePath,
    required VoidCallback onTap,
    required VoidCallback onRemove,
  }) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        if (imagePath?.trim().isNotEmpty != true)
          Semantics(
            button: true,
            label: '$title, ${l10n.tapAddPhoto}',
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  height: 150,
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest,
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(alpha: 0.42),
                    ),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.add_a_photo_outlined,
                          size: 40,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 8),
                        Text(l10n.tapAddPhoto),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          )
        else
          Semantics(
            image: true,
            label: title,
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    File(imagePath!),
                    height: 150,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (_, _, _) => Container(
                      height: 150,
                      width: double.infinity,
                      color: theme.colorScheme.surfaceContainerHighest,
                      alignment: Alignment.center,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
                PositionedDirectional(
                  top: 8,
                  end: 8,
                  child: Semantics(
                    button: true,
                    label: '${l10n.remove} $title',
                    child: Material(
                      color: theme.colorScheme.errorContainer,
                      shape: const CircleBorder(),
                      clipBehavior: Clip.antiAlias,
                      child: SizedBox.square(
                        dimension: 48,
                        child: IconButton(
                          tooltip: l10n.remove,
                          padding: EdgeInsets.zero,
                          constraints: const BoxConstraints.tightFor(
                            width: 48,
                            height: 48,
                          ),
                          icon: Icon(
                            Icons.close,
                            color: theme.colorScheme.onErrorContainer,
                          ),
                          onPressed: onRemove,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

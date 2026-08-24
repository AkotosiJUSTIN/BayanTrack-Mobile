import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../data/kyc_models.dart';
import '../domain/entities/kyc_status.dart';
import '../../auth/presentation/barangays_provider.dart';
import 'kyc_controller.dart';

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

  const KycFormScreen({
    super.key,
    this.isResubmission = false,
    this.existingKyc,
  });

  @override
  ConsumerState<KycFormScreen> createState() => _KycFormScreenState();
}

class _KycFormScreenState extends ConsumerState<KycFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final _imagePicker = ImagePicker();
  static final _nameInputRegex = RegExp(r"[A-Za-z\s\-'`]");
  static final _addressInputRegex = RegExp(r"[A-Za-z0-9\s,.'#/()-]");
  static final _idNumberRegex = RegExp(r"[A-Za-z0-9\-/]");

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

  String? _selectedBarangayName;
  int _currentStep = 0;

  @override
  void initState() {
    super.initState();
    if (widget.existingKyc != null) {
      _populateFromExisting(widget.existingKyc!);
    }
  }

  void _populateFromExisting(KycStatusEntity existing) {
    _firstNameController.text = existing.firstName ?? '';
    _middleNameController.text = existing.middleName ?? '';
    _lastNameController.text = existing.lastName ?? '';
    _nationalityController.text = existing.nationality ?? '';
    _emailController.text = existing.email ?? '';
    _mobileNumberController.text = existing.mobileNumber ?? '';

    final fullAddress = existing.streetBarangay ?? '';
    if (fullAddress.contains(',')) {
      final parts = fullAddress.split(',');
      _selectedBarangayName = parts.last.trim();
      _streetBarangayController.text = parts
          .sublist(0, parts.length - 1)
          .join(',')
          .trim();
    } else {
      _streetBarangayController.text = fullAddress;
    }

    _cityMunicipalityController.text = existing.cityMunicipality ?? '';
    _provinceController.text = existing.province ?? '';
    _zipCodeController.text = existing.zipCode ?? '';
    _idNumberController.text = existing.idNumber ?? '';

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = ref.read(kycFormControllerProvider.notifier);
      controller.populateFromExisting(existing);
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
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source, String imageType) async {
    try {
      final pickedFile = await _imagePicker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (pickedFile == null) return;

      final controller = ref.read(kycFormControllerProvider.notifier);
      switch (imageType) {
        case 'id_front':
          controller.setIdFrontImage(pickedFile.path);
          break;
        case 'id_back':
          controller.setIdBackImage(pickedFile.path);
          break;
        case 'selfie':
          controller.setSelfieImage(pickedFile.path);
          break;
        case 'selfie_with_id':
          controller.setSelfieWithIdImage(pickedFile.path);
          break;
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context).imageAccessError);
      }
    }
  }

  void _validateLive() => _formKey.currentState?.validate();

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
  int? _findStepWithErrors() {
    final state = ref.read(kycFormControllerProvider);

    // Check Basic Identity (Step 0)
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        state.dateOfBirth == null ||
        _nationalityController.text.trim().isEmpty) {
      return 0;
    }

    // Check Contact (Step 1)
    final email = _emailController.text.trim();
    final mobile = _mobileNumberController.text.trim();
    if (Validators.email(email) != null) {
      return 1;
    }
    if (mobile.isEmpty ||
        mobile.length != 10 ||
        !RegExp(r'^[0-9]+$').hasMatch(mobile)) {
      return 1;
    }

    // Check Address (Step 2)
    if (_streetBarangayController.text.trim().isEmpty ||
        _selectedBarangayName == null ||
        _cityMunicipalityController.text.trim().isEmpty ||
        _provinceController.text.trim().isEmpty) {
      return 2;
    }

    // Check ID Details (Step 3)
    if (state.selectedIdType == null ||
        _idNumberController.text.trim().isEmpty) {
      return 3;
    }

    // Check Images (Steps 4-5)
    if (state.idFrontImagePath == null) return 4;
    if (state.selfieImagePath == null) return 5;

    // Check Declaration (Step 6)
    if (!state.declarationAccepted) return 6;

    return null;
  }

  /// Get error message for a specific step
  String _getStepErrorMessage(int step) {
    final l10n = AppLocalizations.of(context);
    switch (step) {
      case 0:
        return '${l10n.basicIdentity}: ${l10n.allRequiredFields}';
      case 1:
        final email = _emailController.text.trim();
        if (email.isEmpty) return l10n.emailAddressRequired;
        if (Validators.email(email) != null) {
          return l10n.invalidEmail;
        }
        return l10n.mobileNumberDigits;
      case 2:
        return '${l10n.reportLocation}: ${l10n.allRequiredFields}';
      case 3:
        return '${l10n.selectIdType} / ${l10n.idNumberRequired}';
      case 4:
        return l10n.idFrontRequired;
      case 5:
        return l10n.selfieRequired;
      case 6:
        return l10n.declarationRequired;
      default:
        return l10n.allRequiredFields;
    }
  }

  void _continueStep() {
    final errorStep = _findStepWithErrors();
    if (errorStep != null && errorStep <= _currentStep) {
      _formKey.currentState?.validate();
      AppToast.error(context, _getStepErrorMessage(errorStep));
      return;
    }

    setState(() => _currentStep++);
  }

  Future<void> _submitForm() async {
    // First check which step has errors
    final errorStep = _findStepWithErrors();

    if (errorStep != null) {
      final errorMessage = _getStepErrorMessage(errorStep);

      // Navigate to the step with errors
      if (_currentStep != errorStep) {
        setState(() => _currentStep = errorStep);
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

    try {
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
        AppToast.error(
          context,
          AppLocalizations.of(context).verificationSubmitFailed,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycFormControllerProvider);
    final l10n = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.isResubmission
              ? l10n.resubmitUserVerification
              : l10n.submitUserVerification,
        ),
      ),
      body: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 6) {
              _continueStep();
            } else {
              _submitForm();
            }
          },
          onStepCancel: () {
            if (_currentStep > 0) {
              setState(() => _currentStep--);
            }
          },
          onStepTapped: (step) => setState(() => _currentStep = step),
          controlsBuilder: (context, details) {
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  if (_currentStep < 6)
                    Expanded(
                      child: ElevatedButton(
                        onPressed: details.onStepContinue,
                        child: Text(l10n.continueLabel),
                      ),
                    )
                  else
                    Expanded(
                      child: ElevatedButton(
                        onPressed: state.isSubmitting ? null : _submitForm,
                        child: state.isSubmitting
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                widget.isResubmission
                                    ? l10n.resubmitDocuments
                                    : l10n.submit,
                              ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: details.onStepCancel,
                        style: OutlinedButton.styleFrom(
                          minimumSize: const Size.fromHeight(48),
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
              ),
            );
          },
          steps: [
            // ===== STEP 0: Basic Identity =====
            Step(
              title: Text(l10n.basicIdentity),
              subtitle: Text(l10n.personalInformation),
              isActive: _currentStep >= 0,
              state: state.isBasicIdentityComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildBasicIdentitySection(state),
            ),
            // ===== STEP 1: Contact Information =====
            Step(
              title: Text(l10n.contactInfo),
              subtitle: Text(l10n.emailPhone),
              isActive: _currentStep >= 1,
              state: state.isContactComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildContactSection(state),
            ),
            // ===== STEP 2: Address =====
            Step(
              title: Text(l10n.reportLocation),
              subtitle: Text(l10n.currentResidence),
              isActive: _currentStep >= 2,
              state: state.isAddressComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildAddressSection(state),
            ),
            // ===== STEP 3: Government ID =====
            Step(
              title: Text(l10n.governmentId),
              subtitle: Text(l10n.idTypeNumber),
              isActive: _currentStep >= 3,
              state: state.isIdDetailsComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildIdDetailsSection(state),
            ),
            // ===== STEP 4: ID Images =====
            Step(
              title: Text(l10n.idPhotos),
              subtitle: Text(l10n.uploadIdImages),
              isActive: _currentStep >= 4,
              state: (state.hasIdFront)
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildIdImagesSection(state),
            ),
            // ===== STEP 5: Selfie =====
            Step(
              title: Text(l10n.selfie),
              subtitle: Text(l10n.faceVerification),
              isActive: _currentStep >= 5,
              state: state.hasSelfie ? StepState.complete : StepState.indexed,
              content: _buildSelfieSection(state),
            ),
            // ===== STEP 6: Declaration =====
            Step(
              title: Text(l10n.declaration),
              subtitle: Text(l10n.confirmSubmit),
              isActive: _currentStep >= 6,
              state: state.isDeclarationComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildDeclarationSection(state),
            ),
          ],
        ),
      ),
    );
  }

  // ==================== SECTION BUILDERS ====================

  Widget _buildBasicIdentitySection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Rejection reason banner
        if (widget.isResubmission &&
            widget.existingKyc?.rejectionReason != null)
          _buildRejectionBanner(widget.existingKyc!.rejectionReason!),

        const SizedBox(height: 8),

        // First Name *
        TextFormField(
          controller: _firstNameController,
          decoration: InputDecoration(
            labelText: '${l10n.firstName} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_nameInputRegex),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (v) {
            controller.setFirstName(v);
            _validateLive();
          },
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.firstNameRequired : null,
        ),
        const SizedBox(height: 16),

        // Middle Name
        TextFormField(
          controller: _middleNameController,
          decoration: InputDecoration(
            labelText: l10n.middleName,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_nameInputRegex),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (v) {
            controller.setMiddleName(v);
            _validateLive();
          },
        ),
        const SizedBox(height: 16),

        // Last Name *
        TextFormField(
          controller: _lastNameController,
          decoration: InputDecoration(
            labelText: '${l10n.lastName} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_nameInputRegex),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (v) {
            controller.setLastName(v);
            _validateLive();
          },
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.lastNameRequired : null,
        ),
        const SizedBox(height: 16),

        // Date of Birth *
        InkWell(
          onTap: () async {
            final date = await showDatePicker(
              context: context,
              initialDate: state.dateOfBirth ?? DateTime(1990),
              firstDate: DateTime(1900),
              lastDate: DateTime.now(),
            );
            if (date != null) {
              controller.setDateOfBirth(date);
              _validateLive();
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: '${l10n.dateOfBirth} *',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              state.dateOfBirth == null
                  ? l10n.selectDate
                  : '${state.dateOfBirth!.year}-${state.dateOfBirth!.month.toString().padLeft(2, '0')}-${state.dateOfBirth!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sex
        DropdownButtonFormField<Sex>(
          decoration: InputDecoration(
            labelText: l10n.sex,
            border: OutlineInputBorder(),
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
          onChanged: (v) => controller.setSex(v),
        ),
        const SizedBox(height: 16),

        // Nationality *
        TextFormField(
          controller: _nationalityController,
          decoration: InputDecoration(
            labelText: '${l10n.nationality} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag),
            hintText: l10n.nationalityExample,
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_nameInputRegex),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (v) {
            controller.setNationality(v);
            _validateLive();
          },
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.nationalityRequired : null,
        ),
        const SizedBox(height: 16),

        // Civil Status
        DropdownButtonFormField<CivilStatus>(
          decoration: InputDecoration(
            labelText: l10n.civilStatus,
            border: OutlineInputBorder(),
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
          onChanged: (v) => controller.setCivilStatus(v),
        ),
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
          controller: _emailController,
          decoration: InputDecoration(
            labelText: '${l10n.emailAddress} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: (v) {
            controller.setEmail(v);
            _validateLive();
          },
          validator: (value) => Validators.email(value, l10n: l10n),
        ),
        const SizedBox(height: 16),

        // Mobile Number *
        TextFormField(
          controller: _mobileNumberController,
          decoration: InputDecoration(
            labelText: '${l10n.mobileNumberRequired} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            prefixText: '+63 ',
            hintText: '9123456789',
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (v) {
            controller.setMobileNumber(v);
            _validateLive();
          },
          validator: (v) {
            if (v == null || v.trim().isEmpty) {
              return l10n.mobileNumberRequiredError;
            }
            if (v.length != 10) {
              return l10n.mobileNumberDigits;
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context);

    // Update the controller whenever either field changes
    void updateStreetBarangay() {
      final street = _streetBarangayController.text.trim();
      final barangay = _selectedBarangayName ?? '';
      if (street.isNotEmpty && barangay.isNotEmpty) {
        controller.setStreetBarangay('$street, $barangay');
      } else if (street.isNotEmpty) {
        controller.setStreetBarangay(street);
      } else if (barangay.isNotEmpty) {
        controller.setStreetBarangay(barangay);
      } else {
        controller.setStreetBarangay('');
      }
      _validateLive();
    }

    return Column(
      children: [
        // House No. / Street *
        TextFormField(
          controller: _streetBarangayController,
          decoration: InputDecoration(
            labelText: '${l10n.houseStreet} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
            hintText: l10n.houseStreetHint,
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_addressInputRegex),
            LengthLimitingTextInputFormatter(255),
          ],
          onChanged: (v) {
            updateStreetBarangay();
          },
          validator: (v) => v == null || v.trim().isEmpty
              ? l10n.fieldRequired(l10n.houseStreet)
              : null,
        ),
        const SizedBox(height: 16),

        // Barangay Dropdown *
        ref
            .watch(barangaysProvider)
            .when(
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => Text(
                l10n.failedLoadBarangays,
                style: TextStyle(color: theme.colorScheme.error),
              ),
              data: (barangays) {
                final validBarangay =
                    barangays.any((b) => b.name == _selectedBarangayName)
                    ? _selectedBarangayName
                    : null;

                return DropdownButtonFormField<String>(
                  value: validBarangay,
                  isExpanded: true,
                  decoration: InputDecoration(
                    labelText: '${l10n.barangay} *',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.location_city_outlined),
                    hintText: l10n.selectYourBarangay,
                  ),
                  items: barangays
                      .map(
                        (b) => DropdownMenuItem(
                          value: b.name,
                          child: Text(b.name),
                        ),
                      )
                      .toList(),
                  onChanged: (value) {
                    setState(() => _selectedBarangayName = value);
                    updateStreetBarangay();
                  },
                  validator: (_) => _selectedBarangayName == null
                      ? l10n.pleaseSelectBarangay
                      : null,
                );
              },
            ),
        const SizedBox(height: 16),

        // City *
        TextFormField(
          controller: _cityMunicipalityController,
          decoration: InputDecoration(
            labelText: '${l10n.city} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_addressInputRegex),
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (v) {
            controller.setCityMunicipality(v);
            _validateLive();
          },
          validator: (v) =>
              v == null || v.trim().isEmpty
                  ? l10n.fieldRequired(l10n.city)
                  : null,
        ),
        const SizedBox(height: 16),

        // Province *
        TextFormField(
          controller: _provinceController,
          decoration: InputDecoration(
            labelText: '${l10n.province} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.map),
          ),
          textCapitalization: TextCapitalization.words,
          inputFormatters: [
            FilteringTextInputFormatter.allow(_addressInputRegex),
            LengthLimitingTextInputFormatter(100),
          ],
          onChanged: (v) {
            controller.setProvince(v);
            _validateLive();
          },
          validator: (v) =>
              v == null || v.trim().isEmpty
                  ? l10n.fieldRequired(l10n.province)
                  : null,
        ),
        const SizedBox(height: 16),

        // ZIP Code
        TextFormField(
          controller: _zipCodeController,
          decoration: InputDecoration(
            labelText: l10n.zipCode,
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.markunread_mailbox),
          ),
          keyboardType: TextInputType.number,
          inputFormatters: [
            FilteringTextInputFormatter.digitsOnly,
            LengthLimitingTextInputFormatter(10),
          ],
          onChanged: (v) {
            controller.setZipCode(v);
            _validateLive();
          },
        ),
      ],
    );
  }

  Widget _buildIdDetailsSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);

    return Column(
      children: [
        // ID Type *
        DropdownButtonFormField<IdType>(
          decoration: InputDecoration(
            labelText: '${l10n.idType} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.badge),
          ),
          initialValue: state.selectedIdType,
          items: IdType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(_idTypeLabel(type, l10n)),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) controller.setIdType(v);
          },
          validator: (v) => v == null ? l10n.selectIdType : null,
        ),
        const SizedBox(height: 16),

        // ID Number *
        TextFormField(
          controller: _idNumberController,
          decoration: InputDecoration(
            labelText: '${l10n.idNumber} *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
          inputFormatters: [
            FilteringTextInputFormatter.allow(_idNumberRegex),
            LengthLimitingTextInputFormatter(50),
          ],
          onChanged: (v) {
            controller.setIdNumber(v);
            _validateLive();
          },
          validator: (v) =>
              v == null || v.trim().isEmpty ? l10n.idNumberRequired : null,
        ),
        const SizedBox(height: 16),

        // ID Expiry Date
        InkWell(
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
              controller.setIdExpiryDate(date);
            }
          },
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: l10n.idExpiryDate,
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event),
            ),
            child: Text(
              state.idExpiryDate == null
                  ? l10n.selectOptionalDate
                  : '${state.idExpiryDate!.year}-${state.idExpiryDate!.month.toString().padLeft(2, '0')}-${state.idExpiryDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdImagesSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final l10n = AppLocalizations.of(context);
    final requiresBack = state.selectedIdType?.requiresBackImage ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.uploadGovId,
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 8),
        Text(
          l10n.maxImageFormats,
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),

        // ID Front *
        _buildImagePicker(
          title: '${l10n.idFrontPhoto} *',
          imagePath: state.idFrontImagePath,
          onTap: () => _showImageSourceDialog('id_front', l10n.idFrontPhoto),
          onRemove: () => controller.setIdFrontImage(null),
        ),
        const SizedBox(height: 16),

        // ID Back (conditional)
        if (requiresBack) ...[
          _buildImagePicker(
            title: l10n.idBackPhoto,
            imagePath: state.idBackImagePath,
            onTap: () => _showImageSourceDialog('id_back', l10n.idBackPhoto),
            onRemove: () => controller.setIdBackImage(null),
          ),
          const SizedBox(height: 8),
          Text(
            l10n.backPhotoRecommended(
              state.selectedIdType == null
                  ? ''
                  : _idTypeLabel(state.selectedIdType!, l10n),
            ),
            style: TextStyle(
              fontSize: 12,
              color: Theme.of(context).colorScheme.outline,
            ),
          ),
        ],
      ],
    );
  }

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
            color: Theme.of(context).colorScheme.outline,
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
          onChanged: (v) => controller.setDeclarationAccepted(v ?? false),
          title: Text(
            l10n.declarationFullText,
            style: TextStyle(fontSize: 14),
          ),
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

  String _idTypeLabel(IdType value, AppLocalizations l10n) => switch (value) {
    IdType.passport => l10n.idPassport,
    IdType.nationalId => l10n.idNational,
    IdType.driversLicense => l10n.idDriversLicense,
    IdType.philsys => l10n.idPhilsys,
    IdType.sss => l10n.idSss,
    IdType.umid => l10n.idUmid,
    IdType.postal => l10n.idPostal,
    IdType.voters => l10n.idVoters,
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
    return Card(
      color: AppColors.alertHigh.withValues(alpha: 0.1),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.info_outline, color: AppColors.alertHigh),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    l10n.previousRejectionReason,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  Text(reason, style: const TextStyle(fontSize: 13)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(color: Colors.grey)),
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
        const SizedBox(height: 8),
        if (imagePath == null)
          InkWell(
            onTap: onTap,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(
                  color: Theme.of(context).colorScheme.outline,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_a_photo,
                      size: 40,
                      color: Theme.of(context).colorScheme.outline,
                    ),
                    const SizedBox(height: 8),
                    Text(l10n.tapAddPhoto),
                  ],
                ),
              ),
            ),
          )
        else
          Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(imagePath),
                  height: 150,
                  width: double.infinity,
                  fit: BoxFit.cover,
                ),
              ),
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  radius: 18,
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(
                      Icons.close,
                      color: Colors.white,
                      size: 18,
                    ),
                    onPressed: onRemove,
                    padding: EdgeInsets.zero,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

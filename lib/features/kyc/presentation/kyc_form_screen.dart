import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../data/kyc_models.dart';
import '../domain/entities/kyc_status.dart';
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
    _streetBarangayController.text = existing.streetBarangay ?? '';
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error picking image: $e')));
      }
    }
  }

  void _showImageSourceDialog(String imageType, String title) {
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
              title: const Text('Take Photo'),
              onTap: () {
                Navigator.pop(context);
                _pickImage(ImageSource.camera, imageType);
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
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
    // Check Basic Identity (Step 0)
    if (_firstNameController.text.trim().isEmpty ||
        _lastNameController.text.trim().isEmpty ||
        _nationalityController.text.trim().isEmpty) {
      return 0;
    }

    // Check Contact (Step 1)
    final email = _emailController.text.trim();
    final mobile = _mobileNumberController.text.trim();
    if (email.isEmpty ||
        !RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return 1;
    }
    final cleanedMobile = mobile.replaceAll(RegExp(r'[\s\-]'), '');
    if (mobile.isEmpty ||
        !RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleanedMobile)) {
      return 1;
    }

    // Check Address (Step 2)
    if (_streetBarangayController.text.trim().isEmpty ||
        _cityMunicipalityController.text.trim().isEmpty ||
        _provinceController.text.trim().isEmpty) {
      return 2;
    }

    // Check ID Details (Step 3)
    final state = ref.read(kycFormControllerProvider);
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
    switch (step) {
      case 0:
        return 'Please complete Basic Identity: First Name, Last Name, and Nationality are required';
      case 1:
        final email = _emailController.text.trim();
        if (email.isEmpty) return 'Email address is required';
        if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
          return 'Please enter a valid email address (e.g., name@example.com)';
        }
        return 'Please enter a valid mobile number';
      case 2:
        return 'Please complete Address: Street/Barangay, City/Municipality, and Province are required';
      case 3:
        return 'Please select an ID type and enter ID number';
      case 4:
        return 'Please upload a photo of your ID (front side)';
      case 5:
        return 'Please upload a selfie photo';
      case 6:
        return 'Please accept the declaration to submit';
      default:
        return 'Please complete all required fields';
    }
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

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: AppColors.alertHigh,
          duration: const Duration(seconds: 4),
        ),
      );
      return;
    }

    // Run form validation to trigger field-level error display
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the highlighted errors in the form'),
          backgroundColor: AppColors.alertHigh,
        ),
      );
      return;
    }

    final state = ref.read(kycFormControllerProvider);
    if (!state.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Please complete all required fields and upload images',
          ),
          backgroundColor: AppColors.alertHigh,
        ),
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
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              widget.isResubmission
                  ? 'KYC resubmitted successfully!'
                  : 'KYC submitted successfully!',
            ),
            backgroundColor: AppColors.success,
          ),
        );
        Navigator.pop(context, true);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: AppColors.alertHigh,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(kycFormControllerProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isResubmission ? 'Resubmit KYC' : 'Submit KYC'),
      ),
      body: Form(
        key: _formKey,
        child: Stepper(
          currentStep: _currentStep,
          onStepContinue: () {
            if (_currentStep < 6) {
              setState(() => _currentStep++);
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
                        child: const Text('Continue'),
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
                                widget.isResubmission ? 'Resubmit' : 'Submit',
                              ),
                      ),
                    ),
                  const SizedBox(width: 12),
                  if (_currentStep > 0)
                    Expanded(
                      child: TextButton(
                        onPressed: details.onStepCancel,
                        child: const Text('Back'),
                      ),
                    ),
                ],
              ),
            );
          },
          steps: [
            // ===== STEP 0: Basic Identity =====
            Step(
              title: const Text('Basic Identity'),
              subtitle: const Text('Personal information'),
              isActive: _currentStep >= 0,
              state: state.isBasicIdentityComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildBasicIdentitySection(state),
            ),
            // ===== STEP 1: Contact Information =====
            Step(
              title: const Text('Contact Info'),
              subtitle: const Text('Email & phone'),
              isActive: _currentStep >= 1,
              state: state.isContactComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildContactSection(state),
            ),
            // ===== STEP 2: Address =====
            Step(
              title: const Text('Address'),
              subtitle: const Text('Current residence'),
              isActive: _currentStep >= 2,
              state: state.isAddressComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildAddressSection(state),
            ),
            // ===== STEP 3: Government ID =====
            Step(
              title: const Text('Government ID'),
              subtitle: const Text('ID type & number'),
              isActive: _currentStep >= 3,
              state: state.isIdDetailsComplete
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildIdDetailsSection(state),
            ),
            // ===== STEP 4: ID Images =====
            Step(
              title: const Text('ID Photos'),
              subtitle: const Text('Upload ID images'),
              isActive: _currentStep >= 4,
              state: (state.hasIdFront)
                  ? StepState.complete
                  : StepState.indexed,
              content: _buildIdImagesSection(state),
            ),
            // ===== STEP 5: Selfie =====
            Step(
              title: const Text('Selfie'),
              subtitle: const Text('Face verification'),
              isActive: _currentStep >= 5,
              state: state.hasSelfie ? StepState.complete : StepState.indexed,
              content: _buildSelfieSection(state),
            ),
            // ===== STEP 6: Declaration =====
            Step(
              title: const Text('Declaration'),
              subtitle: const Text('Confirm & submit'),
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
          decoration: const InputDecoration(
            labelText: 'First Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setFirstName,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'First name is required' : null,
        ),
        const SizedBox(height: 16),

        // Middle Name
        TextFormField(
          controller: _middleNameController,
          decoration: const InputDecoration(
            labelText: 'Middle Name',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person_outline),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setMiddleName,
        ),
        const SizedBox(height: 16),

        // Last Name *
        TextFormField(
          controller: _lastNameController,
          decoration: const InputDecoration(
            labelText: 'Last Name *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.person),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setLastName,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Last name is required' : null,
        ),
        const SizedBox(height: 16),

        // Date of Birth
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
            }
          },
          child: InputDecorator(
            decoration: const InputDecoration(
              labelText: 'Date of Birth',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.calendar_today),
            ),
            child: Text(
              state.dateOfBirth == null
                  ? 'Select date'
                  : '${state.dateOfBirth!.year}-${state.dateOfBirth!.month.toString().padLeft(2, '0')}-${state.dateOfBirth!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Sex
        DropdownButtonFormField<Sex>(
          decoration: const InputDecoration(
            labelText: 'Sex',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.wc),
          ),
          initialValue: state.sex,
          items: Sex.values
              .map(
                (s) => DropdownMenuItem(value: s, child: Text(s.displayName)),
              )
              .toList(),
          onChanged: (v) => controller.setSex(v),
        ),
        const SizedBox(height: 16),

        // Nationality *
        TextFormField(
          controller: _nationalityController,
          decoration: const InputDecoration(
            labelText: 'Nationality *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.flag),
            hintText: 'e.g., Filipino',
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setNationality,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Nationality is required' : null,
        ),
        const SizedBox(height: 16),

        // Civil Status
        DropdownButtonFormField<CivilStatus>(
          decoration: const InputDecoration(
            labelText: 'Civil Status',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.favorite),
          ),
          initialValue: state.civilStatus,
          items: CivilStatus.values
              .map(
                (c) => DropdownMenuItem(value: c, child: Text(c.displayName)),
              )
              .toList(),
          onChanged: (v) => controller.setCivilStatus(v),
        ),
      ],
    );
  }

  Widget _buildContactSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);

    return Column(
      children: [
        // Email *
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(
            labelText: 'Email Address *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.email),
          ),
          keyboardType: TextInputType.emailAddress,
          onChanged: controller.setEmail,
          validator: (v) {
            if (v == null || v.trim().isEmpty) return 'Email is required';
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(v)) {
              return 'Enter a valid email';
            }
            return null;
          },
        ),
        const SizedBox(height: 16),

        // Mobile Number *
        TextFormField(
          controller: _mobileNumberController,
          decoration: const InputDecoration(
            labelText: 'Mobile Number *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.phone),
            hintText: '+63 9XX XXX XXXX',
          ),
          keyboardType: TextInputType.phone,
          onChanged: controller.setMobileNumber,
          validator: (v) {
            if (v == null || v.trim().isEmpty){
              return 'Mobile number is required';
            }
            final cleaned = v.replaceAll(RegExp(r'[\s\-]'), '');
            if (!RegExp(r'^\+?[0-9]{10,15}$').hasMatch(cleaned)) {
              return 'Enter a valid mobile number (10-15 digits)';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildAddressSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);

    return Column(
      children: [
        // Street / Barangay *
        TextFormField(
          controller: _streetBarangayController,
          decoration: const InputDecoration(
            labelText: 'Street / Barangay *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.home),
            hintText: 'House No., Street, Barangay',
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setStreetBarangay,
          validator: (v) => v == null || v.trim().isEmpty
              ? 'Street/Barangay is required'
              : null,
        ),
        const SizedBox(height: 16),

        // City / Municipality *
        TextFormField(
          controller: _cityMunicipalityController,
          decoration: const InputDecoration(
            labelText: 'City / Municipality *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.location_city),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setCityMunicipality,
          validator: (v) => v == null || v.trim().isEmpty
              ? 'City/Municipality is required'
              : null,
        ),
        const SizedBox(height: 16),

        // Province *
        TextFormField(
          controller: _provinceController,
          decoration: const InputDecoration(
            labelText: 'Province *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.map),
          ),
          textCapitalization: TextCapitalization.words,
          onChanged: controller.setProvince,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'Province is required' : null,
        ),
        const SizedBox(height: 16),

        // ZIP Code
        TextFormField(
          controller: _zipCodeController,
          decoration: const InputDecoration(
            labelText: 'ZIP Code',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.markunread_mailbox),
          ),
          keyboardType: TextInputType.number,
          onChanged: controller.setZipCode,
        ),
      ],
    );
  }

  Widget _buildIdDetailsSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);

    return Column(
      children: [
        // ID Type *
        DropdownButtonFormField<IdType>(
          decoration: const InputDecoration(
            labelText: 'ID Type *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.badge),
          ),
          initialValue: state.selectedIdType,
          items: IdType.values
              .map(
                (type) => DropdownMenuItem(
                  value: type,
                  child: Text(type.displayName),
                ),
              )
              .toList(),
          onChanged: (v) {
            if (v != null) controller.setIdType(v);
          },
          validator: (v) => v == null ? 'Please select an ID type' : null,
        ),
        const SizedBox(height: 16),

        // ID Number *
        TextFormField(
          controller: _idNumberController,
          decoration: const InputDecoration(
            labelText: 'ID Number *',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.numbers),
          ),
          onChanged: controller.setIdNumber,
          validator: (v) =>
              v == null || v.trim().isEmpty ? 'ID number is required' : null,
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
            decoration: const InputDecoration(
              labelText: 'ID Expiry Date (if applicable)',
              border: OutlineInputBorder(),
              prefixIcon: Icon(Icons.event),
            ),
            child: Text(
              state.idExpiryDate == null
                  ? 'Select date (optional)'
                  : '${state.idExpiryDate!.year}-${state.idExpiryDate!.month.toString().padLeft(2, '0')}-${state.idExpiryDate!.day.toString().padLeft(2, '0')}',
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildIdImagesSection(KycFormState state) {
    final controller = ref.read(kycFormControllerProvider.notifier);
    final requiresBack = state.selectedIdType?.requiresBackImage ?? false;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Upload clear photos of your Government ID',
          style: TextStyle(color: Theme.of(context).colorScheme.outline),
        ),
        const SizedBox(height: 8),
        Text(
          'Max 10MB each • JPG, PNG formats',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.outline,
          ),
        ),
        const SizedBox(height: 16),

        // ID Front *
        _buildImagePicker(
          title: 'ID Front Photo *',
          imagePath: state.idFrontImagePath,
          onTap: () => _showImageSourceDialog('id_front', 'ID Front Photo'),
          onRemove: () => controller.setIdFrontImage(null),
        ),
        const SizedBox(height: 16),

        // ID Back (conditional)
        if (requiresBack) ...[
          _buildImagePicker(
            title: 'ID Back Photo',
            imagePath: state.idBackImagePath,
            onTap: () => _showImageSourceDialog('id_back', 'ID Back Photo'),
            onRemove: () => controller.setIdBackImage(null),
          ),
          const SizedBox(height: 8),
          Text(
            'Back photo recommended for ${state.selectedIdType?.displayName}',
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

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Take a clear selfie for face verification',
          style: TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 16),

        // Selfie *
        _buildImagePicker(
          title: 'Selfie Photo *',
          imagePath: state.selfieImagePath,
          onTap: () => _showImageSourceDialog('selfie', 'Selfie Photo'),
          onRemove: () => controller.setSelfieImage(null),
        ),
        const SizedBox(height: 16),

        // Selfie with ID (optional but recommended)
        _buildImagePicker(
          title: 'Selfie Holding ID (Recommended)',
          imagePath: state.selfieWithIdImagePath,
          onTap: () =>
              _showImageSourceDialog('selfie_with_id', 'Selfie Holding ID'),
          onRemove: () => controller.setSelfieWithIdImage(null),
        ),
        const SizedBox(height: 8),
        Text(
          'Hold your ID next to your face for stronger verification',
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
                const Text(
                  'Submission Summary',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const SizedBox(height: 12),
                _buildSummaryRow('Name', state.fullName),
                _buildSummaryRow('Email', state.email),
                _buildSummaryRow('Mobile', state.mobileNumber),
                _buildSummaryRow(
                  'ID Type',
                  state.selectedIdType?.displayName ?? '-',
                ),
                _buildSummaryRow('ID Number', state.idNumber),
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
                    const Text('ID Front Photo'),
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
                    const Text('Selfie Photo'),
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
          title: const Text(
            'I declare that all information provided is true and accurate. I consent to the processing of my personal data for identity verification purposes.',
            style: TextStyle(fontSize: 14),
          ),
          controlAffinity: ListTileControlAffinity.leading,
          contentPadding: EdgeInsets.zero,
        ),

        if (!state.declarationAccepted)
          const Padding(
            padding: EdgeInsets.only(top: 8),
            child: Text(
              '* You must accept the declaration to submit',
              style: TextStyle(color: AppColors.alertHigh, fontSize: 12),
            ),
          ),
      ],
    );
  }

  // ==================== HELPER WIDGETS ====================

  Widget _buildRejectionBanner(String reason) {
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
                  const Text(
                    'Previous Rejection Reason:',
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
                    const Text('Tap to add photo'),
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

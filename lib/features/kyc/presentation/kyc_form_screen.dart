import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/theme/app_colors.dart';
import '../data/kyc_models.dart';
import 'kyc_controller.dart';

/// KYC Form Screen - collect user information and documents
class KycFormScreen extends ConsumerStatefulWidget {
  final bool isResubmission;
  final KycStatusResponse? existingKyc;

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
  final _fullNameController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();
    if (widget.existingKyc != null) {
      _fullNameController.text = widget.existingKyc!.fullName;
      _idNumberController.text = widget.existingKyc!.idNumber ?? '';
      
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(kycFormControllerProvider.notifier).setIdType(
          widget.existingKyc!.idType,
        );
        if (widget.existingKyc!.dateOfBirth != null) {
          try {
            final dob = DateTime.parse(widget.existingKyc!.dateOfBirth!);
            ref.read(kycFormControllerProvider.notifier).setDateOfBirth(dob);
          } catch (e) {
            // Invalid date format
          }
        }
      });
    }
  }

  @override
  void dispose() {
    _fullNameController.dispose();
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
          controller.setIdImage(pickedFile.path);
          break;
        case 'id_back':
          controller.setIdBackImage(pickedFile.path);
          break;
        case 'selfie':
          controller.setSelfieImage(pickedFile.path);
          break;
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error picking image: $e')),
        );
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

  Future<void> _submitForm() async {
    if (!_formKey.currentState!.validate()) return;

    final state = ref.read(kycFormControllerProvider);
    if (!state.canSubmit) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please complete all required fields'),
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
    final idTypesAsync = ref.watch(idTypesProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.isResubmission ? 'Resubmit KYC' : 'Submit KYC'),
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Instructions
            if (widget.isResubmission && widget.existingKyc?.rejectionReason != null)
              Card(
                color: AppColors.alertHigh.withOpacity(0.1),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.alertHigh),
                          SizedBox(width: 8),
                          Text(
                            'Rejection Reason',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(widget.existingKyc!.rejectionReason!),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 16),

            // ID Type Selection
            idTypesAsync.when(
              data: (idTypes) {
                return DropdownButtonFormField<IdType>(
                  decoration: const InputDecoration(
                    labelText: 'ID Type',
                    border: OutlineInputBorder(),
                    prefixIcon: Icon(Icons.badge),
                  ),
                  value: state.selectedIdType,
                  items: IdType.values.map((type) {
                    return DropdownMenuItem(
                      value: type,
                      child: Text(type.displayName),
                    );
                  }).toList(),
                  onChanged: (value) {
                    if (value != null) {
                      ref.read(kycFormControllerProvider.notifier).setIdType(value);
                    }
                  },
                  validator: (value) {
                    if (value == null) return 'Please select an ID type';
                    return null;
                  },
                );
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (error, stack) => Text('Error loading ID types: $error'),
            ),

            const SizedBox(height: 16),

            // Full Name
            TextFormField(
              controller: _fullNameController,
              decoration: const InputDecoration(
                labelText: 'Full Name',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
                hintText: 'As shown on your ID',
              ),
              textCapitalization: TextCapitalization.words,
              onChanged: (value) {
                ref.read(kycFormControllerProvider.notifier).setFullName(value);
              },
              validator: (value) {
                if (value == null || value.trim().isEmpty) {
                  return 'Full name is required';
                }
                return null;
              },
            ),

            const SizedBox(height: 16),

            // ID Number (Optional)
            TextFormField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: 'ID Number (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.numbers),
              ),
              onChanged: (value) {
                ref.read(kycFormControllerProvider.notifier).setIdNumber(value);
              },
            ),

            const SizedBox(height: 16),

            // Date of Birth (Optional)
            InkWell(
              onTap: () async {
                final date = await showDatePicker(
                  context: context,
                  initialDate: state.dateOfBirth ?? DateTime(1990),
                  firstDate: DateTime(1900),
                  lastDate: DateTime.now(),
                );
                if (date != null) {
                  ref.read(kycFormControllerProvider.notifier).setDateOfBirth(date);
                }
              },
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Date of Birth (Optional)',
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

            const SizedBox(height: 24),
            const Text(
              'Document Photos',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Supported formats: JPG, PNG (Max 10MB each)',
              style: TextStyle(fontSize: 12, color: Theme.of(context).colorScheme.outline),
            ),
            const SizedBox(height: 16),

            // ID Front Image
            _buildImagePicker(
              title: 'ID Front *',
              imagePath: state.idImagePath,
              onTap: () => _showImageSourceDialog('id_front', 'ID Front'),
              onRemove: () {
                ref.read(kycFormControllerProvider.notifier).setIdImage(null);
              },
            ),

            const SizedBox(height: 16),

            // ID Back Image (conditional)
            if (state.selectedIdType?.requiresBackImage ?? false)
              _buildImagePicker(
                title: 'ID Back *',
                imagePath: state.idBackImagePath,
                onTap: () => _showImageSourceDialog('id_back', 'ID Back'),
                onRemove: () {
                  ref.read(kycFormControllerProvider.notifier).setIdBackImage(null);
                },
              ),

            if (state.selectedIdType?.requiresBackImage ?? false)
              const SizedBox(height: 16),

            // Selfie Image
            _buildImagePicker(
              title: 'Selfie with ID *',
              imagePath: state.selfieImagePath,
              onTap: () => _showImageSourceDialog('selfie', 'Selfie'),
              onRemove: () {
                ref.read(kycFormControllerProvider.notifier).setSelfieImage(null);
              },
            ),

            const SizedBox(height: 32),

            // Submit Button
            SizedBox(
              height: 50,
              child: ElevatedButton(
                onPressed: state.isSubmitting ? null : _submitForm,
                child: state.isSubmitting
                    ? const CircularProgressIndicator(color: Colors.white)
                    : Text(widget.isResubmission ? 'Resubmit KYC' : 'Submit KYC'),
              ),
            ),
          ],
        ),
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
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const SizedBox(height: 8),
        if (imagePath == null)
          InkWell(
            onTap: onTap,
            child: Container(
              height: 150,
              decoration: BoxDecoration(
                border: Border.all(color: Theme.of(context).colorScheme.outline),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.add_a_photo, size: 48, color: Theme.of(context).colorScheme.outline),
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
                  backgroundColor: Colors.red,
                  child: IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 20),
                    onPressed: onRemove,
                  ),
                ),
              ),
            ],
          ),
      ],
    );
  }
}

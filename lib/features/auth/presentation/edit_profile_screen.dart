import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/utils/validators.dart';
import '../data/auth_models.dart';
import 'profile_controller.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  bool _isLoading = false;
  bool _isAvatarUploading = false;
  File? _selectedImage;

  Future<void> _showImagePickerOptions() async {
    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from Gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a Photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );

    if (source != null) {
      await _pickImage(source);
    }
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: source, imageQuality: 70);

    if (pickedFile != null) {
      if (mounted)
        setState(() {
          _selectedImage = File(pickedFile.path);
          _isAvatarUploading = true;
        });

      try {
        await ref
            .read(profileControllerProvider.notifier)
            .uploadAvatar(_selectedImage!);
        if (mounted) {
          AppToast.success(context, 'Avatar updated successfully.');
        }
      } catch (e) {
        if (mounted) {
          AppToast.error(context, 'Failed to upload avatar. Please try again.');
          setState(() {
            _selectedImage = null; // Reset on failure
          });
        }
      } finally {
        if (mounted) setState(() => _isAvatarUploading = false);
      }
    }
  }

  @override
  void initState() {
    super.initState();
    // Pre-fill data
    final profileAsync = ref.read(profileControllerProvider);
    profileAsync.whenData((profile) {
      _firstNameController.text = profile.firstName;
      _lastNameController.text = profile.lastName;
    });
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);
    try {
      final request = ProfileUpdateRequest(
        firstName: _firstNameController.text,
        lastName: _lastNameController.text,
      );
      await ref.read(profileControllerProvider.notifier).updateProfile(request);
      if (mounted) {
        AppToast.success(context, 'Your profile has been updated.');
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(
          context,
          'Unable to update your profile right now. Please try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value;

    // Get initials handling empty names
    String getInitials() {
      if (profile == null) return '';
      final firstInitial = profile.firstName.isNotEmpty
          ? profile.firstName[0].toUpperCase()
          : '';
      final lastInitial = profile.lastName.isNotEmpty
          ? profile.lastName[0].toUpperCase()
          : '';
      if (firstInitial.isEmpty && lastInitial.isEmpty) {
        return profile.email.isNotEmpty ? profile.email[0].toUpperCase() : '?';
      }
      return '$firstInitial$lastInitial';
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              if (profile != null)
                Center(
                  child: Stack(
                    children: [
                      CircleAvatar(
                        radius: 50,
                        backgroundColor: AppColors.primary,
                        backgroundImage: _selectedImage != null
                            ? FileImage(_selectedImage!)
                            : (profile.avatarUrl != null &&
                                  profile.avatarUrl!.isNotEmpty)
                            ? NetworkImage(
                                    ApiConstants.getImageUrl(
                                      profile.avatarUrl!,
                                    ),
                                  )
                                  as ImageProvider
                            : null,
                        child:
                            _selectedImage == null &&
                                (profile.avatarUrl == null ||
                                    profile.avatarUrl!.isEmpty)
                            ? Text(
                                getInitials(),
                                style: const TextStyle(
                                  fontSize: 32,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              )
                            : null,
                      ),
                      if (_isAvatarUploading)
                        const Positioned.fill(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: IconButton(
                            icon: const Icon(
                              Icons.camera_alt,
                              color: Colors.white,
                              size: 20,
                            ),
                            onPressed: _isAvatarUploading
                                ? null
                                : _showImagePickerOptions,
                            constraints: const BoxConstraints(),
                            padding: const EdgeInsets.all(8),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              const SizedBox(height: 24),
              TextFormField(
                controller: _firstNameController,
                decoration: const InputDecoration(labelText: 'First Name'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\s\-'`]")),
                  LengthLimitingTextInputFormatter(100),
                ],
                onChanged: (_) => _formKey.currentState?.validate(),
                validator: (v) =>
                    Validators.lettersOnly(v, fieldName: 'First name'),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _lastNameController,
                decoration: const InputDecoration(labelText: 'Last Name'),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r"[A-Za-z\s\-'`]")),
                  LengthLimitingTextInputFormatter(100),
                ],
                onChanged: (_) => _formKey.currentState?.validate(),
                validator: (v) =>
                    Validators.lettersOnly(v, fieldName: 'Last name'),
              ),
              const SizedBox(height: 24),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _submit,
                  child: _isLoading
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Save Changes'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

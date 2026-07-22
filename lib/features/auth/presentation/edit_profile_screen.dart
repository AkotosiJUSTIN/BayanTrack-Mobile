import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/theme/app_colors.dart';
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
  final _phoneController = TextEditingController();

  bool _seeded = false;
  bool _seeding = false;
  bool _isLoading = false;
  bool _isAvatarUploading = false;
  bool _hasChanges = false;
  double _uploadProgress = 0;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _phoneController,
    ]) {
      controller.addListener(_markChanged);
    }
    ref.read(profileControllerProvider).whenData(_seedForm);
  }

  void _seedForm(UserProfile profile) {
    if (_seeded) return;
    _seeded = true;
    _seeding = true;
    _firstNameController.text = profile.firstName;
    _lastNameController.text = profile.lastName;
    _phoneController.text = _phoneDigits(profile.phone);
    _seeding = false;
    _hasChanges = false;
  }

  String _phoneDigits(String? phone) {
    final digits = (phone ?? '').replaceAll(RegExp(r'\D'), '');
    return digits.startsWith('63') ? digits.substring(2) : digits;
  }

  void _markChanged() {
    if (_seeded && !_seeding && !_hasChanges && mounted) {
      setState(() => _hasChanges = true);
    }
  }

  Future<void> _showImagePickerOptions() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: const Text('Choose from gallery'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: const Text('Take a photo'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = await ImagePicker().pickImage(
      source: source,
      imageQuality: 90,
      maxWidth: 2048,
      maxHeight: 2048,
    );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    if (await file.length() > 5 * 1024 * 1024) {
      await _deleteFile(file);
      if (mounted) {
        AppToast.error(context, 'Choose an image smaller than 5 MB.');
      }
      return;
    }

    await _deleteTemporaryAvatar();
    if (!mounted) {
      await _deleteFile(file);
      return;
    }
    setState(() {
      _selectedImage = file;
      _uploadProgress = 0;
    });
    await _uploadSelectedAvatar();
  }

  Future<void> _uploadSelectedAvatar() async {
    final file = _selectedImage;
    if (file == null || _isAvatarUploading) return;
    setState(() {
      _isAvatarUploading = true;
      _uploadProgress = 0;
    });
    try {
      await ref.read(profileControllerProvider.notifier).uploadAvatar(
        file,
        onSendProgress: (sent, total) {
          if (!mounted || total <= 0) return;
          setState(() => _uploadProgress = sent / total);
        },
      );
      await _deleteTemporaryAvatar();
      if (!mounted) return;
      AppToast.success(context, 'Profile picture updated.');
    } catch (_) {
      if (!mounted) return;
      AppToast.error(
        context,
        'Upload failed. Keep this preview and tap Retry when ready.',
      );
    } finally {
      if (mounted) setState(() => _isAvatarUploading = false);
    }
  }

  Future<void> _removeAvatar() async {
    if (_isAvatarUploading) return;
    setState(() => _isAvatarUploading = true);
    try {
      await ref.read(profileControllerProvider.notifier).removeAvatar();
      await _deleteTemporaryAvatar();
      if (mounted) AppToast.success(context, 'Profile picture removed.');
    } catch (_) {
      if (mounted) {
        AppToast.error(context, 'Unable to remove the profile picture.');
      }
    } finally {
      if (mounted) setState(() => _isAvatarUploading = false);
    }
  }

  Future<void> _deleteTemporaryAvatar() async {
    final file = _selectedImage;
    _selectedImage = null;
    if (file != null) await _deleteFile(file);
  }

  Future<void> _deleteFile(File file) async {
    try {
      if (await file.exists()) await file.delete();
    } on FileSystemException {
      // The picker cache may already have been cleared by the platform.
    }
  }

  Future<void> _submit(UserProfile profile) async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final digits = _phoneController.text;
      await ref.read(profileControllerProvider.notifier).updateProfile(
        ProfileUpdateRequest(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          phone: digits.isEmpty ? null : '+63$digits',
          expectedRevision: profile.profileRevision,
        ),
      );
      if (!mounted) return;
      _hasChanges = false;
      AppToast.success(context, 'Your profile has been updated.');
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          'Unable to save. Refresh the profile and try again.',
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<bool> _confirmDiscard() async {
    if (!_hasChanges && _selectedImage == null) return true;
    return await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Discard changes?'),
            content: const Text('Your unsaved profile changes will be lost.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: const Text('Keep editing'),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: const Text('Discard'),
              ),
            ],
          ),
        ) ??
        false;
  }

  @override
  void dispose() {
    for (final controller in [
      _firstNameController,
      _lastNameController,
      _phoneController,
    ]) {
      controller.removeListener(_markChanged);
      controller.dispose();
    }
    final temporary = _selectedImage;
    if (temporary != null) unawaited(_deleteFile(temporary));
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value;
    if (profile != null) _seedForm(profile);

    return PopScope(
      canPop: !_hasChanges && _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !await _confirmDiscard() || !mounted) return;
        _hasChanges = false;
        await _deleteTemporaryAvatar();
        if (mounted) Navigator.pop(context, result);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: const Text('Edit Profile')),
        body: SafeArea(
          child: profile == null
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    16,
                    16,
                    16,
                    24 + MediaQuery.viewInsetsOf(context).bottom,
                  ),
                  child: Form(
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _AvatarEditor(
                          profile: profile,
                          selectedImage: _selectedImage,
                          isUploading: _isAvatarUploading,
                          progress: _uploadProgress,
                          onChoose: _showImagePickerOptions,
                          onRetry: _uploadSelectedAvatar,
                          onRemove: _removeAvatar,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: const InputDecoration(
                            labelText: 'First name',
                          ),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.givenName],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[A-Za-z\s\-'`]"),
                            ),
                            LengthLimitingTextInputFormatter(100),
                          ],
                          validator: (value) => Validators.lettersOnly(
                            value,
                            fieldName: 'First name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: const InputDecoration(
                            labelText: 'Last name',
                          ),
                          textInputAction: TextInputAction.next,
                          autofillHints: const [AutofillHints.familyName],
                          inputFormatters: [
                            FilteringTextInputFormatter.allow(
                              RegExp(r"[A-Za-z\s\-'`]"),
                            ),
                            LengthLimitingTextInputFormatter(100),
                          ],
                          validator: (value) => Validators.lettersOnly(
                            value,
                            fieldName: 'Last name',
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: const InputDecoration(
                            labelText: 'Phone number',
                            prefixText: '+63 ',
                            helperText: 'Enter 10 digits, for example 9123456789.',
                          ),
                          keyboardType: TextInputType.phone,
                          textInputAction: TextInputAction.done,
                          autofillHints: const [AutofillHints.telephoneNumber],
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(10),
                          ],
                          validator: (value) {
                            if (value == null || value.isEmpty) return null;
                            if (value.length != 10 || !value.startsWith('9')) {
                              return 'Enter a valid 10-digit Philippine mobile number.';
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) => _submit(profile),
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed:
                              !_hasChanges ||
                                  _isLoading ||
                                  _isAvatarUploading
                              ? null
                              : () => _submit(profile),
                          child: _isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Text('Save changes'),
                        ),
                      ],
                    ),
                  ),
                ),
        ),
      ),
    );
  }
}

class _AvatarEditor extends StatelessWidget {
  const _AvatarEditor({
    required this.profile,
    required this.selectedImage,
    required this.isUploading,
    required this.progress,
    required this.onChoose,
    required this.onRetry,
    required this.onRemove,
  });

  final UserProfile profile;
  final File? selectedImage;
  final bool isUploading;
  final double progress;
  final VoidCallback onChoose;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    final remoteAvatar = profile.avatarUrl;
    final image = selectedImage != null
        ? FileImage(selectedImage!) as ImageProvider
        : remoteAvatar != null && remoteAvatar.isNotEmpty
        ? NetworkImage(ApiConstants.getImageUrl(remoteAvatar))
        : null;
    final initials = name.isNotEmpty
        ? name
              .split(RegExp(r'\s+'))
              .take(2)
              .map((part) => part[0].toUpperCase())
              .join()
        : 'U';

    return Semantics(
      label: name.isEmpty ? 'Profile picture' : '$name profile picture',
      image: true,
      child: Column(
        children: [
          CircleAvatar(
            radius: 52,
            backgroundColor: AppColors.primary,
            backgroundImage: image,
            child: image == null
                ? Text(
                    initials,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 30,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          const SizedBox(height: 12),
          if (isUploading) ...[
            LinearProgressIndicator(value: progress == 0 ? null : progress),
            const SizedBox(height: 8),
            Text('Uploading ${(progress * 100).round()}%'),
          ],
          if (profile.avatarStorageStatus == 'degraded') ...[
            const SizedBox(height: 8),
            const Text(
              'Profile picture available; backup replication is pending.',
              textAlign: TextAlign.center,
            ),
          ],
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 8,
            runSpacing: 8,
            children: [
              OutlinedButton.icon(
                onPressed: isUploading ? null : onChoose,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(image == null ? 'Add picture' : 'Replace'),
              ),
              if (selectedImage != null && !isUploading)
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                ),
              if (image != null)
                TextButton.icon(
                  onPressed: isUploading ? null : onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Remove'),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'JPEG, PNG, or WebP. Maximum 5 MB.',
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

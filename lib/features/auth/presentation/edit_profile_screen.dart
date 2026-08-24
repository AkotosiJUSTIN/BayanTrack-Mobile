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
import '../../../l10n/app_localizations.dart';
import '../data/auth_models.dart';
import 'profile_controller.dart';

enum _AvatarOperation { uploading, removing }

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key, this.pickImage});

  final Future<XFile?> Function(ImageSource source)? pickImage;

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
  _AvatarOperation? _avatarOperation;
  bool _hasChanges = false;
  double _uploadProgress = 0;
  File? _selectedImage;
  Uint8List? _selectedImageBytes;

  bool get _isBusy => _isLoading || _avatarOperation != null;

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
    if (_isBusy) return;
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Wrap(
          children: [
            ListTile(
              leading: const Icon(Icons.photo_library),
              title: Text(AppLocalizations.of(context)!.chooseFromGallery),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt),
              title: Text(AppLocalizations.of(context)!.takePhoto),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
          ],
        ),
      ),
    );
    if (source == null || !mounted) return;

    final picked = widget.pickImage != null
        ? await widget.pickImage!(source)
        : await ImagePicker().pickImage(
            source: source,
            imageQuality: 90,
            maxWidth: 2048,
            maxHeight: 2048,
          );
    if (picked == null || !mounted) return;

    final file = File(picked.path);
    if (file.lengthSync() > 5 * 1024 * 1024) {
      await _deleteFile(file);
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context)!.imageTooLarge);
      }
      return;
    }
    final bytes = file.readAsBytesSync();

    await _deleteTemporaryAvatar();
    if (!mounted) {
      await _deleteFile(file);
      return;
    }
    setState(() {
      _selectedImage = file;
      _selectedImageBytes = bytes;
      _uploadProgress = 0;
    });
    await _uploadSelectedAvatar();
  }

  Future<void> _uploadSelectedAvatar() async {
    final file = _selectedImage;
    if (file == null || _isBusy) return;
    setState(() {
      _avatarOperation = _AvatarOperation.uploading;
      _uploadProgress = 0;
    });
    try {
      await ref
          .read(profileControllerProvider.notifier)
          .uploadAvatar(
            file,
            onSendProgress: (sent, total) {
              if (!mounted || total <= 0) return;
              setState(() => _uploadProgress = sent / total);
            },
          );
      await _deleteTemporaryAvatar();
      if (!mounted) return;
      AppToast.success(context, AppLocalizations.of(context)!.profilePictureUpdated);
    } catch (_) {
      if (!mounted) return;
      AppToast.error(
        context,
        AppLocalizations.of(context)!.avatarUploadFailed,
      );
    } finally {
      if (mounted) setState(() => _avatarOperation = null);
    }
  }

  Future<void> _removeAvatar() async {
    if (_isBusy) return;
    setState(() => _avatarOperation = _AvatarOperation.removing);
    try {
      await ref.read(profileControllerProvider.notifier).removeAvatar();
      await _deleteTemporaryAvatar();
      if (mounted) AppToast.success(context, AppLocalizations.of(context)!.profilePictureRemoved);
    } catch (_) {
      if (mounted) {
        AppToast.error(context, AppLocalizations.of(context)!.removePictureFailed);
      }
    } finally {
      if (mounted) setState(() => _avatarOperation = null);
    }
  }

  Future<void> _deleteTemporaryAvatar() async {
    final file = _selectedImage;
    if (file == null) return;
    if (mounted) {
      setState(() {
        _selectedImage = null;
        _selectedImageBytes = null;
      });
      await WidgetsBinding.instance.endOfFrame;
    } else {
      _selectedImage = null;
      _selectedImageBytes = null;
    }
    await _deleteFile(file);
  }

  Future<void> _deleteFile(File file) async {
    for (var attempt = 0; attempt < 3; attempt++) {
      try {
        if (file.existsSync()) file.deleteSync();
        return;
      } on FileSystemException {
        if (attempt == 2) return;
        await Future<void>.delayed(const Duration(milliseconds: 25));
      }
    }
  }

  Future<void> _submit(UserProfile profile) async {
    if (_isBusy) return;
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      final digits = _phoneController.text;
      await ref
          .read(profileControllerProvider.notifier)
          .updateProfile(
            ProfileUpdateRequest(
              firstName: _firstNameController.text.trim(),
              lastName: _lastNameController.text.trim(),
              phone: digits.isEmpty ? null : '+63$digits',
              expectedRevision: profile.profileRevision,
            ),
          );
      if (!mounted) return;
      _hasChanges = false;
      AppToast.success(context, AppLocalizations.of(context)!.profileUpdated);
      Navigator.pop(context);
    } catch (_) {
      if (mounted) {
        AppToast.error(
          context,
          AppLocalizations.of(context)!.saveProfileFailed,
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
            title: Text(AppLocalizations.of(context)!.discardChanges),
            content: Text(AppLocalizations.of(context)!.unsavedProfileChanges),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text(AppLocalizations.of(context)!.keepEditing),
              ),
              FilledButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text(AppLocalizations.of(context)!.discard),
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
    if (temporary != null) {
      WidgetsBinding.instance.addPostFrameCallback(
        (_) => unawaited(_deleteFile(temporary)),
      );
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileControllerProvider);
    final profile = profileState.value;
    final l10n = AppLocalizations.of(context)!;
    if (profile != null) _seedForm(profile);

    return PopScope(
      canPop: !_hasChanges && _selectedImage == null,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop || !await _confirmDiscard() || !mounted) return;
        _hasChanges = false;
        await _deleteTemporaryAvatar();
        if (mounted) Navigator.pop(this.context, result);
      },
      child: Scaffold(
        resizeToAvoidBottomInset: true,
        appBar: AppBar(title: Text(l10n.editProfile)),
        body: SafeArea(
          child: profile == null
              ? profileState.when(
                  data: (_) => const SizedBox.shrink(),
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, _) => Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            l10n.profileLoadFailed,
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 12),
                          OutlinedButton.icon(
                            onPressed: () =>
                                ref.invalidate(profileControllerProvider),
                            icon: const Icon(Icons.refresh),
                            label: Text(l10n.retry),
                          ),
                        ],
                      ),
                    ),
                  ),
                )
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
                          selectedImageBytes: _selectedImageBytes,
                          operation: _avatarOperation,
                          isBusy: _isBusy,
                          progress: _uploadProgress,
                          onChoose: _showImagePickerOptions,
                          onRetry: _uploadSelectedAvatar,
                          onRemove: _removeAvatar,
                        ),
                        const SizedBox(height: 24),
                        TextFormField(
                          controller: _firstNameController,
                          decoration: InputDecoration(
                            labelText: l10n.firstName,
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
                            fieldName: l10n.firstName,
                            l10n: l10n,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _lastNameController,
                          decoration: InputDecoration(
                            labelText: l10n.lastName,
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
                            fieldName: l10n.lastName,
                            l10n: l10n,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                            labelText: l10n.phoneNumber,
                            prefixText: '+63 ',
                            helperText:
                                l10n.phoneHelper,
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
                              return l10n.invalidPhone;
                            }
                            return null;
                          },
                          onFieldSubmitted: (_) {
                            if (_hasChanges && !_isBusy) _submit(profile);
                          },
                        ),
                        const SizedBox(height: 24),
                        FilledButton(
                          onPressed: !_hasChanges || _isBusy
                              ? null
                              : () => _submit(profile),
                          child: _isLoading
                              ? const SizedBox.square(
                                  dimension: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                  ),
                                )
                              : Text(l10n.saveChanges),
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
    required this.selectedImageBytes,
    required this.operation,
    required this.isBusy,
    required this.progress,
    required this.onChoose,
    required this.onRetry,
    required this.onRemove,
  });

  final UserProfile profile;
  final File? selectedImage;
  final Uint8List? selectedImageBytes;
  final _AvatarOperation? operation;
  final bool isBusy;
  final double progress;
  final VoidCallback onChoose;
  final VoidCallback onRetry;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final name = '${profile.firstName} ${profile.lastName}'.trim();
    final remoteAvatar = profile.avatarUrl;
    final image = selectedImageBytes != null
        ? MemoryImage(selectedImageBytes!) as ImageProvider
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
      label: name.isEmpty ? l10n.profilePicture : '$name ${l10n.profilePicture}',
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
          if (operation != null) ...[
            LinearProgressIndicator(
              value: operation == _AvatarOperation.uploading && progress > 0
                  ? progress
                  : null,
            ),
            const SizedBox(height: 8),
            Text(
              operation == _AvatarOperation.removing
                  ? l10n.removingProfilePicture
                  : l10n.uploadingPercent((progress * 100).round()),
            ),
          ],
          if (profile.avatarStorageStatus == 'degraded') ...[
            const SizedBox(height: 8),
            Text(
              l10n.profilePictureReplicationPending,
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
                onPressed: isBusy ? null : onChoose,
                icon: const Icon(Icons.photo_camera_outlined),
                label: Text(image == null ? l10n.addPicture : l10n.replace),
              ),
              if (selectedImage != null && !isBusy)
                OutlinedButton.icon(
                  onPressed: onRetry,
                  icon: const Icon(Icons.refresh),
                  label: Text(l10n.retry),
                ),
              if (image != null)
                TextButton.icon(
                  onPressed: isBusy ? null : onRemove,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(l10n.remove),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            l10n.imageFormats,
            style: Theme.of(context).textTheme.bodySmall,
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

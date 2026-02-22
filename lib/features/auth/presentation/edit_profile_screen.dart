import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
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

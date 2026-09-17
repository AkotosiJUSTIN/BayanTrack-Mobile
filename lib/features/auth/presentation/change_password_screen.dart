import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/password_strength_indicator.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import '../data/auth_models.dart';
import 'profile_controller.dart';

class ChangePasswordScreen extends ConsumerStatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  ConsumerState<ChangePasswordScreen> createState() =>
      _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends ConsumerState<ChangePasswordScreen> {
  final _formKey = GlobalKey<FormState>();
  final _currentController = TextEditingController();
  final _newController = TextEditingController();
  final _confirmController = TextEditingController();
  bool _isLoading = false;
  bool _obscureCurrentPassword = true;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _currentController.dispose();
    _newController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final l10n = AppLocalizations.of(context);
    if (!_formKey.currentState!.validate()) return;

    if (_newController.text != _confirmController.text) {
      AppToast.error(context, l10n.newPasswordMismatch);
      return;
    }

    setState(() => _isLoading = true);
    try {
      final request = ChangePasswordRequest(
        currentPassword: _currentController.text,
        newPassword: _newController.text,
        newPasswordConfirm: _confirmController.text,
      );
      await ref
          .read(profileControllerProvider.notifier)
          .changePassword(request);
      if (mounted) {
        AppToast.success(context, l10n.passwordChanged);
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        AppToast.error(context, l10n.passwordChangeFailed);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: AppBar(title: Text(l10n.changePassword)),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            20,
            16,
            20,
            24 + MediaQuery.viewInsetsOf(context).bottom,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                TextFormField(
                  controller: _currentController,
                  decoration: InputDecoration(
                    labelText: l10n.currentPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureCurrentPassword = !_obscureCurrentPassword;
                        });
                      },
                      tooltip: _obscureCurrentPassword
                          ? l10n.showPassword
                          : l10n.hidePassword,
                      icon: Icon(
                        _obscureCurrentPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  obscureText: _obscureCurrentPassword,
                  validator: (v) =>
                      v?.isNotEmpty == true ? null : l10n.requiredShort,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _newController,
                  decoration: InputDecoration(
                    labelText: l10n.newPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureNewPassword = !_obscureNewPassword;
                        });
                      },
                      tooltip: _obscureNewPassword
                          ? l10n.showPassword
                          : l10n.hidePassword,
                      icon: Icon(
                        _obscureNewPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  obscureText: _obscureNewPassword,
                  validator: (value) => Validators.password(value, l10n: l10n),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _newController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) {
                      return const SizedBox.shrink();
                    }
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: PasswordStrengthIndicator(password: value.text),
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _confirmController,
                  decoration: InputDecoration(
                    labelText: l10n.confirmNewPassword,
                    suffixIcon: IconButton(
                      onPressed: () {
                        setState(() {
                          _obscureConfirmPassword = !_obscureConfirmPassword;
                        });
                      },
                      tooltip: _obscureConfirmPassword
                          ? l10n.showPassword
                          : l10n.hidePassword,
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                      ),
                    ),
                  ),
                  obscureText: _obscureConfirmPassword,
                  validator: (v) {
                    if (v == null || v.isEmpty) return l10n.requiredShort;
                    if (v != _newController.text) {
                      return l10n.passwordsDoNotMatch;
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: _isLoading ? null : _submit,
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Text(l10n.changePassword),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

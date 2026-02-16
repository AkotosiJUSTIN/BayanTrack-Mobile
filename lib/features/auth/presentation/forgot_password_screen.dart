import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import 'login_screen.dart';

enum _ResetStep { email, otp, password }

/// Forgot Password screen with 3 phases:
/// 1) Email, 2) OTP, 3) New password + confirmation.
class ForgotPasswordScreen extends ConsumerStatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  ConsumerState<ForgotPasswordScreen> createState() =>
      _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends ConsumerState<ForgotPasswordScreen> {
  final _emailFormKey = GlobalKey<FormState>();
  final _otpFormKey = GlobalKey<FormState>();
  final _passwordFormKey = GlobalKey<FormState>();

  final _emailController = TextEditingController();
  final _otpController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  _ResetStep _step = _ResetStep.email;
  String? _resetToken;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _otpController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleSendOtp() async {
    if (!(_emailFormKey.currentState?.validate() ?? false)) return;

    final success = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted || !success) return;

    setState(() {
      _step = _ResetStep.otp;
      _otpController.clear();
    });

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('OTP sent to your email.')));
  }

  Future<void> _handleVerifyOtp() async {
    if (!(_otpFormKey.currentState?.validate() ?? false)) return;

    final resetToken = await ref
        .read(authControllerProvider.notifier)
        .verifyResetOtp(
          email: _emailController.text.trim(),
          otp: _otpController.text.trim(),
        );

    if (!mounted || resetToken == null) return;

    setState(() {
      _resetToken = resetToken;
      _step = _ResetStep.password;
      _newPasswordController.clear();
      _confirmPasswordController.clear();
    });
  }

  Future<void> _handleResetPassword() async {
    if (!(_passwordFormKey.currentState?.validate() ?? false)) return;

    final resetToken = _resetToken;
    if (resetToken == null || resetToken.isEmpty) {
      setState(() {
        _step = _ResetStep.otp;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Session expired. Please verify OTP again.'),
          backgroundColor: AppColors.alertHigh,
        ),
      );
      return;
    }

    final success = await ref
        .read(authControllerProvider.notifier)
        .resetPassword(
          resetToken: resetToken,
          newPassword: _newPasswordController.text,
          newPasswordConfirm: _confirmPasswordController.text,
        );

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Password reset successful. Please login.')),
    );

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  Future<void> _handleResendOtp() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted || !success) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('OTP resent. Check your email.')),
    );
  }

  void _handleBack() {
    switch (_step) {
      case _ResetStep.email:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LoginScreen()),
        );
        return;
      case _ResetStep.otp:
        setState(() {
          _step = _ResetStep.email;
          _resetToken = null;
        });
        return;
      case _ResetStep.password:
        setState(() {
          _step = _ResetStep.otp;
        });
        return;
    }
  }

  String _title() {
    return switch (_step) {
      _ResetStep.email => 'Forgot Password?',
      _ResetStep.otp => 'Enter OTP',
      _ResetStep.password => 'Set New Password',
    };
  }

  String _subtitle() {
    return switch (_step) {
      _ResetStep.email =>
        'Enter your email and we will send a 6-digit OTP code.',
      _ResetStep.otp => 'Enter the OTP sent to ${_emailController.text.trim()}',
      _ResetStep.password => 'Create your new password.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.message),
            backgroundColor: AppColors.alertHigh,
          ),
        );
      }
    });

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
        title: const Text('Reset Password'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 36),
              Center(
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: (isDark ? AppColors.primaryLight : AppColors.primary)
                        .withValues(alpha: 0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    switch (_step) {
                      _ResetStep.email => Icons.email_outlined,
                      _ResetStep.otp => Icons.password_outlined,
                      _ResetStep.password => Icons.lock_reset,
                    },
                    size: 40,
                    color: isDark ? AppColors.primaryLight : AppColors.primary,
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                _title(),
                style: theme.textTheme.headlineLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 10),
              Text(
                _subtitle(),
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: isDark
                      ? AppColors.darkTextSecondary
                      : AppColors.lightTextSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 28),
              if (_step == _ResetStep.email) ...[
                Form(
                  key: _emailFormKey,
                  child: TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _handleSendOtp(),
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _handleSendOtp,
                    child: const Text('Send OTP'),
                  ),
              ],
              if (_step == _ResetStep.otp) ...[
                Form(
                  key: _otpFormKey,
                  child: TextFormField(
                    controller: _otpController,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onFieldSubmitted: (_) => _handleVerifyOtp(),
                    decoration: const InputDecoration(
                      hintText: 'Enter 6-digit OTP',
                      prefixIcon: Icon(Icons.confirmation_number_outlined),
                    ),
                    validator: (value) {
                      final otp = value?.trim() ?? '';
                      if (otp.isEmpty) return 'OTP is required';
                      if (!RegExp(r'^\d{6}$').hasMatch(otp)) {
                        return 'OTP must be 6 digits';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else ...[
                  ElevatedButton(
                    onPressed: _handleVerifyOtp,
                    child: const Text('Verify OTP'),
                  ),
                  const SizedBox(height: 12),
                  OutlinedButton(
                    onPressed: _handleResendOtp,
                    child: const Text('Resend OTP'),
                  ),
                ],
              ],
              if (_step == _ResetStep.password) ...[
                Form(
                  key: _passwordFormKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextFormField(
                        controller: _newPasswordController,
                        obscureText: _obscureNewPassword,
                        textInputAction: TextInputAction.next,
                        enabled: !isLoading,
                        decoration: InputDecoration(
                          hintText: 'New password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                            icon: Icon(
                              _obscureNewPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: Validators.password,
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        textInputAction: TextInputAction.done,
                        enabled: !isLoading,
                        onFieldSubmitted: (_) => _handleResetPassword(),
                        decoration: InputDecoration(
                          hintText: 'Confirm new password',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword =
                                    !_obscureConfirmPassword;
                              });
                            },
                            icon: Icon(
                              _obscureConfirmPassword
                                  ? Icons.visibility_off
                                  : Icons.visibility,
                            ),
                          ),
                        ),
                        validator: Validators.confirmPassword(
                          _newPasswordController.text,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                if (isLoading)
                  const Center(child: CircularProgressIndicator())
                else
                  ElevatedButton(
                    onPressed: _handleResetPassword,
                    child: const Text('Reset Password'),
                  ),
              ],
              const SizedBox(height: 28),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'Remember your password? ',
                    style: theme.textTheme.bodyMedium,
                  ),
                  GestureDetector(
                    onTap: () {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (_) => const LoginScreen()),
                      );
                    },
                    child: Text(
                      'Login',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

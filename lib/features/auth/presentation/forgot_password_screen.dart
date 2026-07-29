import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/password_strength_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import 'auth_wrapper.dart';

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

    AppToast.success(context, 'OTP sent. Please check your email.');
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
      AppToast.error(
        context,
        'Your session expired. Please verify the OTP again.',
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

    AppToast.success(context, 'Password reset successful. Please log in.');

    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
  }

  Future<void> _handleResendOtp() async {
    final success = await ref
        .read(authControllerProvider.notifier)
        .forgotPassword(_emailController.text.trim());

    if (!mounted || !success) return;

    AppToast.info(context, 'OTP resent. Please check your email.');
  }

  void _handleBack() {
    switch (_step) {
      case _ResetStep.email:
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthWrapper()),
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

  void _handleLogin() {
    Navigator.of(
      context,
    ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
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
        'Enter your email and we’ll send you a 6-digit OTP code.',
      _ResetStep.otp => 'Enter the OTP sent to ${_emailController.text.trim()}',
      _ResetStep.password => 'Create your new password.',
    };
  }

  Widget _buildEmailBody({
    required ThemeData theme,
    required bool isDark,
    required bool isLoading,
  }) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 620;
        final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 24.0;
        final topPadding = compact ? 4.0 : 8.0;
        final minContentHeight = (constraints.maxHeight - topPadding - 16)
            .clamp(0.0, double.infinity);
        final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

        return SingleChildScrollView(
          key: const ValueKey('forgot-password-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            16,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: minContentHeight),
            child: IntrinsicHeight(
              child: Form(
                key: _emailFormKey,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    SizedBox(
                      height: compact ? 145 : 190,
                      child: Image.asset(
                        'assets/images/auth/forgot_password_mascot.webp',
                        key: const ValueKey('forgot-password-illustration'),
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                        excludeFromSemantics: true,
                      ),
                    ),
                    SizedBox(height: compact ? 6 : 10),
                    Text(
                      _title(),
                      key: const ValueKey('forgot-password-title'),
                      style: theme.textTheme.headlineLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _subtitle(),
                      key: const ValueKey('forgot-password-subtitle'),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    Expanded(
                      child: Align(
                        alignment: compact
                            ? Alignment.topCenter
                            : const Alignment(0, -0.65),
                        child: ConstrainedBox(
                          constraints: const BoxConstraints(maxWidth: 440),
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              vertical: compact ? 18 : 26,
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Semantics(
                                  label: 'Email',
                                  textField: true,
                                  child: TextFormField(
                                    key: const ValueKey(
                                      'forgot-password-email-field',
                                    ),
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    textInputAction: TextInputAction.done,
                                    enabled: !isLoading,
                                    onChanged: (_) =>
                                        _emailFormKey.currentState?.validate(),
                                    onFieldSubmitted: (_) => _handleSendOtp(),
                                    decoration: const InputDecoration(
                                      hintText: 'Enter your email',
                                      prefixIcon: Icon(Icons.email_outlined),
                                    ),
                                    validator: Validators.email,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                if (isLoading)
                                  const Center(
                                    child: CircularProgressIndicator(
                                      semanticsLabel: 'Sending OTP',
                                    ),
                                  )
                                else
                                  ElevatedButton(
                                    key: const ValueKey(
                                      'forgot-password-submit-button',
                                    ),
                                    onPressed: _handleSendOtp,
                                    child: const Text('Send OTP'),
                                  ),
                                const SizedBox(height: 18),
                                Wrap(
                                  alignment: WrapAlignment.center,
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  children: [
                                    Text(
                                      'Remember your password?',
                                      key: const ValueKey(
                                        'forgot-password-login-prompt',
                                      ),
                                      style: theme.textTheme.bodyMedium,
                                    ),
                                    TextButton(
                                      key: const ValueKey(
                                        'forgot-password-login-button',
                                      ),
                                      style: TextButton.styleFrom(
                                        foregroundColor: accentColor,
                                        minimumSize: const Size(44, 44),
                                        padding: const EdgeInsets.symmetric(
                                          horizontal: 6,
                                        ),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : _handleLogin,
                                      child: const Text('Login'),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = authState is AuthLoading;

    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        AppToast.error(context, next.message);
      }
    });

    if (_step == _ResetStep.email) {
      return Scaffold(
        key: const ValueKey('forgot-password-scaffold'),
        backgroundColor: isDark
            ? AppColors.darkBackground
            : AppColors.lightBackground,
        appBar: AppBar(
          leading: IconButton(
            key: const ValueKey('forgot-password-back-button'),
            tooltip: 'Back',
            icon: const Icon(Icons.arrow_back),
            onPressed: _handleBack,
          ),
        ),
        body: SafeArea(
          child: _buildEmailBody(
            theme: theme,
            isDark: isDark,
            isLoading: isLoading,
          ),
        ),
      );
    }

    final isOtpStep = _step == _ResetStep.otp;
    final accentColor = isDark ? AppColors.primaryLight : AppColors.primary;

    return Scaffold(
      key: const ValueKey('forgot-password-recovery-scaffold'),
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      appBar: AppBar(
        leading: IconButton(
          key: const ValueKey('forgot-password-recovery-back-button'),
          tooltip: 'Back',
          icon: const Icon(Icons.arrow_back),
          onPressed: _handleBack,
        ),
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 620;
            final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 24.0;
            final topPadding = compact ? 4.0 : 8.0;
            final minContentHeight = (constraints.maxHeight - topPadding - 16)
                .clamp(0.0, double.infinity);

            return SingleChildScrollView(
              key: ValueKey(
                isOtpStep
                    ? 'forgot-password-otp-scroll'
                    : 'forgot-password-password-scroll',
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: EdgeInsets.fromLTRB(
                horizontalPadding,
                topPadding,
                horizontalPadding,
                16,
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: minContentHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      SizedBox(
                        height: compact ? 145 : 190,
                        child: Image.asset(
                          isOtpStep
                              ? 'assets/images/auth/check_otp_mascot.webp'
                              : 'assets/images/auth/change_password_mascot.webp',
                          key: ValueKey(
                            isOtpStep
                                ? 'forgot-password-otp-illustration'
                                : 'forgot-password-password-illustration',
                          ),
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                          excludeFromSemantics: true,
                        ),
                      ),
                      SizedBox(height: compact ? 6 : 10),
                      Text(
                        _title(),
                        key: ValueKey(
                          isOtpStep
                              ? 'forgot-password-otp-title'
                              : 'forgot-password-password-title',
                        ),
                        style: theme.textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _subtitle(),
                        key: ValueKey(
                          isOtpStep
                              ? 'forgot-password-otp-subtitle'
                              : 'forgot-password-password-subtitle',
                        ),
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Expanded(
                        child: Align(
                          alignment: compact
                              ? Alignment.topCenter
                              : const Alignment(0, -0.65),
                          child: ConstrainedBox(
                            constraints: const BoxConstraints(maxWidth: 440),
                            child: Padding(
                              padding: EdgeInsets.symmetric(
                                vertical: compact ? 18 : 26,
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  if (isOtpStep)
                                    Form(
                                      key: _otpFormKey,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      child: Semantics(
                                        label: 'OTP code',
                                        textField: true,
                                        child: TextFormField(
                                          key: const ValueKey(
                                            'forgot-password-otp-field',
                                          ),
                                          controller: _otpController,
                                          keyboardType: TextInputType.number,
                                          textInputAction: TextInputAction.done,
                                          enabled: !isLoading,
                                          inputFormatters: [
                                            FilteringTextInputFormatter
                                                .digitsOnly,
                                            LengthLimitingTextInputFormatter(6),
                                          ],
                                          onChanged: (_) => _otpFormKey
                                              .currentState
                                              ?.validate(),
                                          onFieldSubmitted: (_) =>
                                              _handleVerifyOtp(),
                                          decoration: const InputDecoration(
                                            hintText: 'Enter 6-digit OTP',
                                            prefixIcon: Icon(
                                              Icons
                                                  .confirmation_number_outlined,
                                            ),
                                          ),
                                          validator: (value) {
                                            final otp = value?.trim() ?? '';
                                            if (otp.isEmpty) {
                                              return 'OTP is required';
                                            }
                                            if (!RegExp(
                                              r'^\d{6}$',
                                            ).hasMatch(otp)) {
                                              return 'OTP must be 6 digits';
                                            }
                                            return null;
                                          },
                                        ),
                                      ),
                                    )
                                  else
                                    Form(
                                      key: _passwordFormKey,
                                      autovalidateMode:
                                          AutovalidateMode.onUserInteraction,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Semantics(
                                            label: 'New password',
                                            textField: true,
                                            child: TextFormField(
                                              key: const ValueKey(
                                                'forgot-password-new-password-field',
                                              ),
                                              controller:
                                                  _newPasswordController,
                                              obscureText: _obscureNewPassword,
                                              textInputAction:
                                                  TextInputAction.next,
                                              enabled: !isLoading,
                                              onChanged: (_) => _passwordFormKey
                                                  .currentState
                                                  ?.validate(),
                                              decoration: InputDecoration(
                                                hintText: 'New password',
                                                prefixIcon: const Icon(
                                                  Icons.lock_outline,
                                                ),
                                                suffixIcon: IconButton(
                                                  key: const ValueKey(
                                                    'forgot-password-new-password-toggle',
                                                  ),
                                                  tooltip: _obscureNewPassword
                                                      ? 'Show new password'
                                                      : 'Hide new password',
                                                  onPressed: isLoading
                                                      ? null
                                                      : () {
                                                          setState(() {
                                                            _obscureNewPassword =
                                                                !_obscureNewPassword;
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
                                          ),
                                          ValueListenableBuilder<
                                            TextEditingValue
                                          >(
                                            valueListenable:
                                                _newPasswordController,
                                            builder: (context, value, child) {
                                              if (value.text.isEmpty) {
                                                return const SizedBox.shrink();
                                              }
                                              return Padding(
                                                padding: const EdgeInsets.only(
                                                  top: 12,
                                                ),
                                                child: MediaQuery.withClampedTextScaling(
                                                  maxScaleFactor: 1.15,
                                                  child:
                                                      PasswordStrengthIndicator(
                                                        password: value.text,
                                                      ),
                                                ),
                                              );
                                            },
                                          ),
                                          const SizedBox(height: 12),
                                          Semantics(
                                            label: 'Confirm new password',
                                            textField: true,
                                            child: TextFormField(
                                              key: const ValueKey(
                                                'forgot-password-confirm-password-field',
                                              ),
                                              controller:
                                                  _confirmPasswordController,
                                              obscureText:
                                                  _obscureConfirmPassword,
                                              textInputAction:
                                                  TextInputAction.done,
                                              enabled: !isLoading,
                                              onChanged: (_) => _passwordFormKey
                                                  .currentState
                                                  ?.validate(),
                                              onFieldSubmitted: (_) =>
                                                  _handleResetPassword(),
                                              decoration: InputDecoration(
                                                hintText: 'Confirm password',
                                                prefixIcon: const Icon(
                                                  Icons.lock_outline,
                                                ),
                                                suffixIcon: IconButton(
                                                  key: const ValueKey(
                                                    'forgot-password-confirm-password-toggle',
                                                  ),
                                                  tooltip:
                                                      _obscureConfirmPassword
                                                      ? 'Show confirmed password'
                                                      : 'Hide confirmed password',
                                                  onPressed: isLoading
                                                      ? null
                                                      : () {
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
                                              validator: (value) =>
                                                  Validators.confirmPassword(
                                                    _newPasswordController.text,
                                                  )(value),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  const SizedBox(height: 20),
                                  if (isLoading)
                                    SizedBox(
                                      height: 52,
                                      child: Center(
                                        child: CircularProgressIndicator(
                                          semanticsLabel: isOtpStep
                                              ? 'Verifying OTP'
                                              : 'Changing password',
                                        ),
                                      ),
                                    )
                                  else
                                    ElevatedButton(
                                      key: ValueKey(
                                        isOtpStep
                                            ? 'forgot-password-verify-button'
                                            : 'forgot-password-reset-button',
                                      ),
                                      onPressed: isOtpStep
                                          ? _handleVerifyOtp
                                          : _handleResetPassword,
                                      child: Text(
                                        isOtpStep
                                            ? 'Verify OTP'
                                            : 'Reset Password',
                                      ),
                                    ),
                                  if (isOtpStep && !isLoading) ...[
                                    const SizedBox(height: 12),
                                    OutlinedButton(
                                      key: const ValueKey(
                                        'forgot-password-resend-button',
                                      ),
                                      onPressed: _handleResendOtp,
                                      child: const Text('Resend OTP'),
                                    ),
                                  ],
                                  const SizedBox(height: 18),
                                  Wrap(
                                    alignment: WrapAlignment.center,
                                    crossAxisAlignment:
                                        WrapCrossAlignment.center,
                                    children: [
                                      Text(
                                        'Remember your password?',
                                        key: const ValueKey(
                                          'forgot-password-recovery-login-prompt',
                                        ),
                                        style: theme.textTheme.bodyMedium,
                                      ),
                                      TextButton(
                                        key: const ValueKey(
                                          'forgot-password-recovery-login-button',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: accentColor,
                                          minimumSize: const Size(44, 44),
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 6,
                                          ),
                                        ),
                                        onPressed: _handleLogin,
                                        child: const Text('Login'),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import 'forgot_password_screen.dart';
import 'register_screen.dart';

const _brandBlue = Color(0xFF064BEE);

/// Login screen matching the BayanTrack design mockup.
/// Features: Bantay artwork and email/password authentication.
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _obscurePassword = true;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (_formKey.currentState?.validate() ?? false) {
      await ref
          .read(authControllerProvider.notifier)
          .login(_emailController.text.trim(), _passwordController.text);
    }
  }

  void _navigateToRegister() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const RegisterScreen()));
  }

  void _navigateToForgotPassword() {
    Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const ForgotPasswordScreen()));
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = authState is AuthLoading;

    return Scaffold(
      key: const ValueKey('login-scaffold'),
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 700;
            final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 24.0;
            final topPadding = compact ? 8.0 : 16.0;
            final minContentHeight = (constraints.maxHeight - topPadding - 16)
                .clamp(0.0, double.infinity);
            final brandBlue = isDark ? AppColors.primaryLight : _brandBlue;

            return SingleChildScrollView(
              key: const ValueKey('login-scroll'),
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
                    key: _formKey,
                    autovalidateMode: AutovalidateMode.onUserInteraction,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        SizedBox(
                          height: compact ? 170 : 230,
                          child: Image.asset(
                            'assets/images/auth/login_mascot.webp',
                            key: const ValueKey('login-illustration'),
                            semanticLabel: 'Bantay waving',
                            fit: BoxFit.contain,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                        SizedBox(height: compact ? 8 : 12),
                        Text(
                          'Welcome Back!',
                          key: const ValueKey('login-welcome'),
                          style: theme.textTheme.displayMedium?.copyWith(
                            fontSize: compact ? 28 : 30,
                            fontWeight: FontWeight.w800,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Sign in to continue',
                          key: const ValueKey('login-subtitle'),
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        if (authState case AuthError(:final message)) ...[
                          const SizedBox(height: 16),
                          Semantics(
                            liveRegion: true,
                            child: Container(
                              key: const ValueKey('login-error-message'),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: theme.colorScheme.errorContainer,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                message,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onErrorContainer,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                        ],
                        Expanded(
                          child: Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 440),
                              child: Padding(
                                padding: EdgeInsets.symmetric(
                                  vertical: compact ? 18 : 28,
                                ),
                                child: Column(
                                  key: const ValueKey('login-form'),
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Text(
                                      'Email',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Semantics(
                                      label: 'Email',
                                      textField: true,
                                      child: TextFormField(
                                        key: const ValueKey(
                                          'login-email-field',
                                        ),
                                        controller: _emailController,
                                        keyboardType:
                                            TextInputType.emailAddress,
                                        textInputAction: TextInputAction.next,
                                        enabled: !isLoading,
                                        onChanged: (_) =>
                                            _formKey.currentState?.validate(),
                                        decoration: const InputDecoration(
                                          hintText: 'Enter your email',
                                          prefixIcon: Icon(
                                            Icons.email_outlined,
                                          ),
                                        ),
                                        validator: Validators.email,
                                      ),
                                    ),
                                    const SizedBox(height: 16),
                                    Text(
                                      'Password',
                                      style: theme.textTheme.titleMedium,
                                    ),
                                    const SizedBox(height: 8),
                                    Semantics(
                                      label: 'Password',
                                      textField: true,
                                      child: TextFormField(
                                        key: const ValueKey(
                                          'login-password-field',
                                        ),
                                        controller: _passwordController,
                                        obscureText: _obscurePassword,
                                        textInputAction: TextInputAction.done,
                                        enabled: !isLoading,
                                        onChanged: (_) =>
                                            _formKey.currentState?.validate(),
                                        onFieldSubmitted: (_) => _handleLogin(),
                                        decoration: InputDecoration(
                                          hintText: 'Enter your password',
                                          prefixIcon: const Icon(
                                            Icons.lock_outline,
                                          ),
                                          suffixIcon: IconButton(
                                            key: const ValueKey(
                                              'login-password-toggle',
                                            ),
                                            tooltip: _obscurePassword
                                                ? 'Show password'
                                                : 'Hide password',
                                            icon: Icon(
                                              _obscurePassword
                                                  ? Icons.visibility_outlined
                                                  : Icons
                                                        .visibility_off_outlined,
                                            ),
                                            onPressed: isLoading
                                                ? null
                                                : () {
                                                    setState(() {
                                                      _obscurePassword =
                                                          !_obscurePassword;
                                                    });
                                                  },
                                          ),
                                        ),
                                        validator: (value) =>
                                            Validators.required(
                                              value,
                                              'Password',
                                            ),
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Align(
                                      alignment: Alignment.centerRight,
                                      child: TextButton(
                                        key: const ValueKey(
                                          'login-forgot-button',
                                        ),
                                        style: TextButton.styleFrom(
                                          foregroundColor: brandBlue,
                                          minimumSize: const Size(44, 44),
                                        ),
                                        onPressed: isLoading
                                            ? null
                                            : _navigateToForgotPassword,
                                        child: const Text('Forgot Password?'),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ElevatedButton(
                                      key: const ValueKey(
                                        'login-submit-button',
                                      ),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _brandBlue,
                                        foregroundColor: Colors.white,
                                        minimumSize: const Size.fromHeight(52),
                                      ),
                                      onPressed: isLoading
                                          ? null
                                          : _handleLogin,
                                      child: isLoading
                                          ? const SizedBox.square(
                                              dimension: 22,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2.5,
                                                color: Colors.white,
                                                semanticsLabel: 'Logging in',
                                              ),
                                            )
                                          : const Text('Login'),
                                    ),
                                    const SizedBox(height: 20),
                                    Wrap(
                                      alignment: WrapAlignment.center,
                                      crossAxisAlignment:
                                          WrapCrossAlignment.center,
                                      children: [
                                        Text(
                                          "Don't have an account?",
                                          key: const ValueKey(
                                            'login-register-prompt',
                                          ),
                                          style: theme.textTheme.bodyMedium,
                                        ),
                                        TextButton(
                                          key: const ValueKey(
                                            'login-register-button',
                                          ),
                                          style: TextButton.styleFrom(
                                            foregroundColor: brandBlue,
                                            minimumSize: const Size(44, 44),
                                            padding: const EdgeInsets.symmetric(
                                              horizontal: 6,
                                            ),
                                          ),
                                          onPressed: isLoading
                                              ? null
                                              : _navigateToRegister,
                                          child: const Text('Register'),
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
        ),
      ),
    );
  }
}

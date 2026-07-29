import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/password_strength_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import 'auth_controller.dart';
import 'barangays_provider.dart';

const _brandBlue = Color(0xFF064BEE);
const _brandOrange = Color(0xFFF86A05);

/// Registration form with compact Bantay artwork.
class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _termsAndPrivacyAccepted = false;
  String? _selectedBarangayId;

  bool get _agreeToTerms => _termsAndPrivacyAccepted;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_agreeToTerms) {
      AppToast.warning(
        context,
        'Please read and accept Terms & Conditions and Privacy Policy',
      );
      return;
    }

    if (_selectedBarangayId == null) {
      AppToast.warning(context, 'Please select your barangay');
      return;
    }

    if (_formKey.currentState?.validate() ?? false) {
      final success = await ref
          .read(authControllerProvider.notifier)
          .register(
            email: _emailController.text.trim(),
            password: _passwordController.text,
            passwordConfirm: _confirmPasswordController.text,
            firstName: _firstNameController.text.trim(),
            lastName: _lastNameController.text.trim(),
            barangayId: _selectedBarangayId!,
          );

      if (success && mounted) {
        AppToast.success(
          context,
          'Registration successful! Welcome to BayanTrack.',
        );
        // Pop register screen so AuthWrapper (now showing MainNavigationShell
        // due to AuthSuccess state) becomes visible immediately
        Navigator.of(context).pop();
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pop();
  }

  void _showTermsAndPrivacyPolicy() {
    _showPolicyDialog(
      'Terms & Conditions and Privacy Policy',
      onAccepted: () {
        _termsAndPrivacyAccepted = true;
      },
    );
  }

  Future<void> _showPolicyDialog(
    String title, {
    required VoidCallback onAccepted,
  }) async {
    final accepted = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (_) => _PolicyDialog(title: title),
    );

    if (accepted == true && mounted) {
      setState(() {
        onAccepted();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authControllerProvider);
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isLoading = authState is AuthLoading;
    final mediaQuery = MediaQuery.of(context);
    final usableHeight =
        mediaQuery.size.height -
        mediaQuery.padding.vertical -
        mediaQuery.viewInsets.bottom;
    final compact = usableHeight < 700;
    final horizontalPadding = mediaQuery.size.width < 360 ? 20.0 : 24.0;
    final brandBlue = isDark ? AppColors.primaryLight : _brandBlue;

    // Show error snackbar when auth fails
    ref.listen<AuthState>(authControllerProvider, (previous, next) {
      if (next is AuthError) {
        AppToast.error(context, next.message);
      }
    });

    return Scaffold(
      key: const ValueKey('register-scaffold'),
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightBackground,
      body: SafeArea(
        child: SingleChildScrollView(
          key: const ValueKey('register-scroll'),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            4,
            horizontalPadding,
            24,
          ),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: IconButton(
                    key: const ValueKey('register-back-button'),
                    tooltip: 'Back',
                    onPressed: isLoading ? null : _navigateToLogin,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                SizedBox(
                  height: compact ? 112 : 136,
                  child: Image.asset(
                    'assets/images/Mascot4_waving_register.png',
                    key: const ValueKey('register-illustration'),
                    semanticLabel: 'Bantay waving',
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(height: compact ? 8 : 12),
                Text(
                  'Create Account',
                  key: const ValueKey('register-title'),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  'Join the community of civic reporters',
                  key: const ValueKey('register-subtitle'),
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Center(
                  child: Container(
                    key: const ValueKey('register-accent'),
                    width: 36,
                    height: 3,
                    decoration: BoxDecoration(
                      color: _brandOrange,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 16 : 20),

                // First Name field
                Text('First Name', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: 'First Name',
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-first-name-field'),
                    controller: _firstNameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    enabled: !isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z\s\-'`]"),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
                    onChanged: (_) => _formKey.currentState?.validate(),
                    decoration: const InputDecoration(
                      hintText: 'Enter your first name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        Validators.lettersOnly(value, fieldName: 'First name'),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name field
                Text('Last Name', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Last Name',
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-last-name-field'),
                    controller: _lastNameController,
                    textInputAction: TextInputAction.next,
                    textCapitalization: TextCapitalization.words,
                    enabled: !isLoading,
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(
                        RegExp(r"[A-Za-z\s\-'`]"),
                      ),
                      LengthLimitingTextInputFormatter(100),
                    ],
                    onChanged: (_) => _formKey.currentState?.validate(),
                    decoration: const InputDecoration(
                      hintText: 'Enter your last name',
                      prefixIcon: Icon(Icons.person_outline),
                    ),
                    validator: (value) =>
                        Validators.lettersOnly(value, fieldName: 'Last name'),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                Text('Email', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Email',
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-email-field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    decoration: const InputDecoration(
                      hintText: 'Enter your email',
                      prefixIcon: Icon(Icons.email_outlined),
                    ),
                    validator: Validators.email,
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                Text('Password', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Password',
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-password-field'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      hintText: 'Create a password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        key: const ValueKey('register-password-toggle'),
                        tooltip: _obscurePassword
                            ? 'Show password'
                            : 'Hide password',
                        icon: Icon(
                          _obscurePassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                      ),
                    ),
                    validator: Validators.password,
                  ),
                ),
                ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _passwordController,
                  builder: (context, value, child) {
                    if (value.text.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(top: 12.0),
                      child: PasswordStrengthIndicator(password: value.text),
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Confirm Password field
                Text('Confirm Password', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: 'Confirm Password',
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-confirm-password-field'),
                    controller: _confirmPasswordController,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    enabled: !isLoading,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    onFieldSubmitted: (_) => _handleRegister(),
                    decoration: InputDecoration(
                      hintText: 'Confirm your password',
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        key: const ValueKey('register-confirm-password-toggle'),
                        tooltip: _obscureConfirmPassword
                            ? 'Show confirm password'
                            : 'Hide confirm password',
                        icon: Icon(
                          _obscureConfirmPassword
                              ? Icons.visibility_outlined
                              : Icons.visibility_off_outlined,
                        ),
                        onPressed: isLoading
                            ? null
                            : () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please confirm your password';
                      }
                      if (value != _passwordController.text) {
                        return 'Passwords do not match';
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Barangay field
                Text('Barangay', style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ref
                    .watch(barangaysProvider)
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => Text(
                        'Failed to load barangays. Please restart the app.',
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      data: (barangays) => DropdownButtonFormField<String>(
                        key: const ValueKey('register-barangay-field'),
                        initialValue: _selectedBarangayId,
                        isExpanded: true,
                        decoration: const InputDecoration(
                          hintText: 'Select your barangay',
                          prefixIcon: Icon(Icons.location_city_outlined),
                        ),
                        items: barangays
                            .map(
                              (b) => DropdownMenuItem(
                                value: b.id,
                                child: Text(b.name),
                              ),
                            )
                            .toList(),
                        onChanged: isLoading
                            ? null
                            : (value) =>
                                  setState(() => _selectedBarangayId = value),
                        validator: (_) => _selectedBarangayId == null
                            ? 'Please select your barangay'
                            : null,
                      ),
                    ),
                const SizedBox(height: 16),

                // Terms & Conditions and Privacy Policy checkbox
                Row(
                  key: const ValueKey('register-terms-row'),
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Checkbox(
                      key: const ValueKey('register-terms-checkbox'),
                      value: _agreeToTerms,
                      onChanged: null,
                    ),
                    Expanded(
                      child: Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'I agree to the',
                            style: theme.textTheme.bodyMedium,
                          ),
                          TextButton(
                            key: const ValueKey('register-terms-button'),
                            style: TextButton.styleFrom(
                              foregroundColor: brandBlue,
                              minimumSize: const Size(44, 44),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                            ),
                            onPressed: isLoading
                                ? null
                                : _showTermsAndPrivacyPolicy,
                            child: const Text(
                              'Terms & Conditions and Privacy Policy',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Register button
                ElevatedButton(
                  key: const ValueKey('register-submit-button'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _brandBlue,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                  ),
                  onPressed: isLoading ? null : _handleRegister,
                  child: isLoading
                      ? const SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                            semanticsLabel: 'Creating account',
                          ),
                        )
                      : const Text('Create Account'),
                ),
                const SizedBox(height: 16),

                // Login link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      'Already have an account?',
                      key: const ValueKey('register-login-prompt'),
                      style: theme.textTheme.bodyMedium,
                    ),
                    TextButton(
                      key: const ValueKey('register-login-button'),
                      style: TextButton.styleFrom(
                        foregroundColor: brandBlue,
                        minimumSize: const Size(44, 44),
                        padding: const EdgeInsets.symmetric(horizontal: 6),
                      ),
                      onPressed: isLoading ? null : _navigateToLogin,
                      child: const Text('Login'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PolicyDialog extends StatefulWidget {
  const _PolicyDialog({required this.title});

  final String title;

  @override
  State<_PolicyDialog> createState() => _PolicyDialogState();
}

class _PolicyDialogState extends State<_PolicyDialog> {
  late final ScrollController _scrollController;
  bool _canAccept = false;

  static const String _dummyContent = '''
========================================
TERMS & CONDITIONS
========================================

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer in massa id massa finibus ullamcorper. Sed volutpat ullamcorper eros, et dictum augue laoreet non. Curabitur bibendum tincidunt ante, at tristique ex dignissim non.

Vivamus nec justo vitae eros feugiat efficitur. Fusce interdum, justo in elementum feugiat, nisl nunc posuere mi, a hendrerit elit orci at nibh. Suspendisse potenti. Quisque lobortis mi id ipsum dignissim, non ullamcorper nisl eleifend.

Mauris porttitor neque id justo egestas, et varius mi porttitor. Nunc euismod, mi in viverra viverra, augue leo convallis neque, in blandit risus justo vitae orci. Proin ultrices sapien eu sem fermentum, ac laoreet lectus pellentesque.

Nulla facilisi. Pellentesque in gravida urna. Donec pretium arcu vitae leo ultricies, in euismod nibh laoreet. In in aliquam odio, in sollicitudin lectus. Cras cursus egestas sapien, sed imperdiet eros elementum ac.

Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia curae; Integer tristique libero ac lacus placerat, vel ultricies est volutpat. Nunc posuere, turpis in fermentum viverra, ipsum lectus tristique justo, id convallis metus justo nec mauris.


========================================
PRIVACY POLICY
========================================

Aliquam erat volutpat. Etiam aliquam sapien ac odio volutpat, eu scelerisque erat bibendum. Morbi in malesuada elit. Integer tincidunt vulputate dui, in gravida purus tincidunt non. Sed sagittis commodo est, ut bibendum lorem blandit vel.

Lorem ipsum dolor sit amet, consectetur adipiscing elit. Integer in massa id massa finibus ullamcorper. Sed volutpat ullamcorper eros, et dictum augue laoreet non. Curabitur bibendum tincidunt ante, at tristique ex dignissim non.

Vivamus nec justo vitae eros feugiat efficitur. Fusce interdum, justo in elementum feugiat, nisl nunc posuere mi, a hendrerit elit orci at nibh. Suspendisse potenti. Quisque lobortis mi id ipsum dignissim, non ullamcorper nisl eleifend.

Mauris porttitor neque id justo egestas, et varius mi porttitor. Nunc euismod, mi in viverra viverra, augue leo convallis neque, in blandit risus justo vitae orci. Proin ultrices sapien eu sem fermentum, ac laoreet lectus pellentesque.


By tapping Accept, you acknowledge you have read and understood both the Terms & Conditions and Privacy Policy.
''';

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController()..addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _onScroll();
    });
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_scrollController.hasClients || _canAccept) return;
    final position = _scrollController.position;
    final reachedBottom = position.pixels >= position.maxScrollExtent - 12;
    if (reachedBottom) {
      setState(() {
        _canAccept = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.title),
      content: SizedBox(
        width: 360,
        height: 320,
        child: Column(
          children: [
            Expanded(
              child: Scrollbar(
                controller: _scrollController,
                thumbVisibility: true,
                child: SingleChildScrollView(
                  controller: _scrollController,
                  child: const Text(_dummyContent),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              _canAccept
                  ? 'You can now accept.'
                  : 'Scroll to the bottom to enable Accept.',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: const Text('Close'),
        ),
        ElevatedButton(
          onPressed: _canAccept ? () => Navigator.of(context).pop(true) : null,
          child: const Text('Accept'),
        ),
      ],
    );
  }
}

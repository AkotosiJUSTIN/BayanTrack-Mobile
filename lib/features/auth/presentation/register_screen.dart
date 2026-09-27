import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/presentation/widgets/app_toast.dart';
import '../../../core/presentation/widgets/password_strength_indicator.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/validators.dart';
import '../../../l10n/app_localizations.dart';
import 'auth_controller.dart';
import 'barangays_provider.dart';

const _brandBlue = AppColors.brandBlue;
const _brandOrange = AppColors.brandOrange;

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
      AppToast.warning(context, AppLocalizations.of(context)!.termsAndPrivacy);
      return;
    }

    if (_selectedBarangayId == null) {
      AppToast.warning(
        context,
        AppLocalizations.of(context)!.pleaseSelectBarangay,
      );
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
          AppLocalizations.of(context)!.registrationSuccess,
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
      AppLocalizations.of(context)!.termsAndPrivacy,
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
    final screenSize = MediaQuery.sizeOf(context);
    final screenPadding = MediaQuery.paddingOf(context);
    final viewInsets = MediaQuery.viewInsetsOf(context);
    final usableHeight =
        screenSize.height - screenPadding.vertical - viewInsets.bottom;
    final compact = usableHeight < 700;
    final horizontalPadding = screenSize.width < 360 ? 20.0 : 24.0;
    final brandBlue = isDark ? AppColors.primaryLight : _brandBlue;
    final l10n = AppLocalizations.of(context)!;

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
                    tooltip: l10n.back,
                    onPressed: isLoading ? null : _navigateToLogin,
                    icon: const Icon(Icons.arrow_back_rounded),
                  ),
                ),
                SizedBox(
                  height: compact ? 112 : 136,
                  child: Image.asset(
                    'assets/images/auth/register_mascot.webp',
                    key: const ValueKey('register-illustration'),
                    semanticLabel: l10n.bantayWaving,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(height: compact ? 8 : 12),
                Text(
                  l10n.createAccount,
                  key: const ValueKey('register-title'),
                  style: theme.textTheme.displayMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.joinCitizenReporters,
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
                Text(l10n.firstName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.firstName,
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
                    decoration: InputDecoration(
                      hintText: l10n.enterYourFirstName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) => Validators.lettersOnly(
                      value,
                      fieldName: l10n.firstName,
                      required: false,
                      l10n: l10n,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Last Name field
                Text(l10n.lastName, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.lastName,
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
                    decoration: InputDecoration(
                      hintText: l10n.enterYourLastName,
                      prefixIcon: const Icon(Icons.person_outline),
                    ),
                    validator: (value) => Validators.lettersOnly(
                      value,
                      fieldName: l10n.lastName,
                      required: false,
                      l10n: l10n,
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Email field
                Text(l10n.email, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.email,
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-email-field'),
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      hintText: l10n.enterYourEmail,
                      prefixIcon: const Icon(Icons.email_outlined),
                    ),
                    validator: (value) =>
                        Validators.registrationEmail(value, l10n: l10n),
                  ),
                ),
                const SizedBox(height: 16),

                // Password field
                Text(l10n.password, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.password,
                  textField: true,
                  child: TextFormField(
                    key: const ValueKey('register-password-field'),
                    controller: _passwordController,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    enabled: !isLoading,
                    onChanged: (_) => _formKey.currentState?.validate(),
                    decoration: InputDecoration(
                      hintText: l10n.createPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        key: const ValueKey('register-password-toggle'),
                        tooltip: _obscurePassword
                            ? l10n.showPassword
                            : l10n.hidePassword,
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
                    validator: (value) =>
                        Validators.password(value, l10n: l10n),
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
                Text(l10n.confirmPassword, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                Semantics(
                  label: l10n.confirmPassword,
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
                      hintText: l10n.confirmYourPassword,
                      prefixIcon: const Icon(Icons.lock_outline),
                      suffixIcon: IconButton(
                        key: const ValueKey('register-confirm-password-toggle'),
                        tooltip: _obscureConfirmPassword
                            ? l10n.showPassword
                            : l10n.hidePassword,
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
                        return l10n.confirmPasswordPrompt;
                      }
                      if (value != _passwordController.text) {
                        return l10n.passwordsDoNotMatch;
                      }
                      return null;
                    },
                  ),
                ),
                const SizedBox(height: 16),

                // Barangay field
                Text(l10n.barangay, style: theme.textTheme.titleMedium),
                const SizedBox(height: 8),
                ref
                    .watch(barangaysProvider)
                    .when(
                      loading: () => const LinearProgressIndicator(),
                      error: (_, _) => Text(
                        l10n.failedLoadBarangays,
                        style: TextStyle(color: theme.colorScheme.error),
                      ),
                      data: (barangays) => DropdownButtonFormField<String>(
                        key: const ValueKey('register-barangay-field'),
                        initialValue: _selectedBarangayId,
                        isExpanded: true,
                        decoration: InputDecoration(
                          hintText: l10n.selectYourBarangay,
                          prefixIcon: const Icon(Icons.location_city_outlined),
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
                            ? l10n.pleaseSelectBarangay
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
                            l10n.iAgreeTo,
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
                            child: Text(l10n.termsAndPrivacy),
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
                      ? SizedBox.square(
                          dimension: 22,
                          child: CircularProgressIndicator(
                            strokeWidth: 2.5,
                            color: Colors.white,
                            semanticsLabel: l10n.creatingAccount,
                          ),
                        )
                      : Text(l10n.createAccount),
                ),
                const SizedBox(height: 16),

                // Login link
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.alreadyHaveAccount,
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
                      child: Text(l10n.login),
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

  List<String> _policyBlocks(String content) {
    return content
        .split(RegExp(r'\n\s*\n'))
        .map((block) => block.trim())
        .where((block) => block.isNotEmpty)
        .toList();
  }

  Widget _buildPolicyContent(BuildContext context, String content) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final blocks = _policyBlocks(content);
    final bodyColor = isDark
        ? AppColors.darkTextSecondary
        : AppColors.lightTextSecondary;
    final headingColor = isDark
        ? AppColors.darkTextPrimary
        : AppColors.lightTextPrimary;

    return ListView.separated(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 20),
      itemCount: blocks.length,
      separatorBuilder: (_, index) {
        final next = blocks[index + 1];
        final isNextHeading =
            next == next.toUpperCase() &&
            next.length > 4 &&
            !next.contains(RegExp(r'[.!?]'));
        return SizedBox(height: isNextHeading ? 20 : 14);
      },
      itemBuilder: (context, index) {
        final block = blocks[index];
        final isHeading =
            block == block.toUpperCase() &&
            block.length > 4 &&
            !block.contains(RegExp(r'[.!?]'));

        if (isHeading) {
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 4,
                height: 22,
                margin: const EdgeInsets.only(right: 10, top: 1),
                decoration: BoxDecoration(
                  color: _brandOrange,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              Expanded(
                child: Text(
                  block,
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: headingColor,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.4,
                  ),
                ),
              ),
            ],
          );
        }

        return Text(
          block,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: bodyColor,
            height: 1.55,
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = isDark
        ? AppColors.darkSurfaceVariant
        : AppColors.lightSurfaceVariant;
    final statusColor = _canAccept
        ? AppColors.success
        : (isDark ? AppColors.primaryLight : _brandBlue);

    return AlertDialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      titlePadding: const EdgeInsets.fromLTRB(24, 22, 24, 0),
      contentPadding: const EdgeInsets.fromLTRB(24, 10, 24, 4),
      actionsPadding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
      actionsAlignment: MainAxisAlignment.spaceBetween,
      title: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (isDark ? AppColors.primaryLight : _brandBlue).withValues(
                alpha: 0.12,
              ),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Icon(
              Icons.fact_check_outlined,
              color: isDark ? AppColors.primaryLight : _brandBlue,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.policyDialogSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: isDark
                        ? AppColors.darkTextSecondary
                        : AppColors.lightTextSecondary,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: (MediaQuery.sizeOf(context).width - 80)
            .clamp(240.0, 480.0)
            .toDouble(),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.sizeOf(context).height * 0.58,
          ),
          child: Column(
            children: [
              const SizedBox(height: 8),
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surface,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color:
                          (isDark
                                  ? AppColors.darkBorder
                                  : AppColors.lightBorder)
                              .withValues(alpha: 0.65),
                    ),
                  ),
                  child: Scrollbar(
                    controller: _scrollController,
                    thumbVisibility: true,
                    radius: const Radius.circular(10),
                    child: _buildPolicyContent(
                      context,
                      l10n.termsPolicyContent,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 9,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.10),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(
                      _canAccept
                          ? Icons.check_circle_outline_rounded
                          : Icons.swipe_down_rounded,
                      size: 18,
                      color: statusColor,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        _canAccept
                            ? l10n.policyCanAccept
                            : l10n.policyScrollToAccept,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: statusColor,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(false),
          child: Text(l10n.close),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandBlue,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          onPressed: _canAccept ? () => Navigator.of(context).pop(true) : null,
          child: Text(l10n.accept),
        ),
      ],
    );
  }
}

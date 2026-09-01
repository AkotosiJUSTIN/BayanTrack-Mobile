import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../auth/presentation/auth_wrapper.dart';
import '../../onboarding/presentation/onboarding_screen.dart';
import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';

const _deepBlue = AppColors.brandBlue;
const _richOrange = AppColors.brandOrange;

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  static const _minimumDisplayDuration = Duration(milliseconds: 1400);

  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: const Interval(0, 0.7, curve: Curves.easeOut),
      ),
    );

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _start();
  }

  Future<void> _start() async {
    final onboardingCheck = ref
        .read(appPreferencesProvider.notifier)
        .isOnboardingComplete();

    await Future.wait([
      _controller.forward(),
      Future<void>.delayed(_minimumDisplayDuration),
    ]);
    final isOnboardingComplete = await onboardingCheck;

    if (!mounted) {
      return;
    }

    Navigator.of(context).pushReplacement(
      PageRouteBuilder(
        pageBuilder: (_, _, _) => isOnboardingComplete
            ? const AuthWrapper()
            : const OnboardingScreen(),
        transitionsBuilder: (_, animation, _, child) =>
            FadeTransition(opacity: animation, child: child),
        transitionDuration: const Duration(milliseconds: 320),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reduceMotion = MediaQuery.disableAnimationsOf(context);
    final brandBlue = isDark ? AppColors.primaryLight : _deepBlue;
    final l10n = AppLocalizations.of(context)!;

    Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 650;
        final logoWidth = compact ? 180.0 : 220.0;

        return SingleChildScrollView(
          padding: EdgeInsets.symmetric(
            horizontal: 24,
            vertical: compact ? 16 : 24,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight - 48),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Image.asset(
                    'assets/images/branding/bt_logo_mark.webp',
                    key: const ValueKey('splash-logo'),
                    width: logoWidth,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                    excludeFromSemantics: true,
                  ),
                  SizedBox(height: compact ? 16 : 24),
                  Semantics(
                    header: true,
                    label: 'BayanTrack',
                    child: ExcludeSemantics(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text.rich(
                          key: const ValueKey('splash-wordmark'),
                          TextSpan(
                            style: theme.textTheme.displayMedium?.copyWith(
                              fontSize: compact ? 34 : 40,
                              fontWeight: FontWeight.w800,
                              letterSpacing: -0.8,
                            ),
                            children: [
                              TextSpan(
                                text: 'Bayan',
                                style: TextStyle(color: brandBlue),
                              ),
                              const TextSpan(
                                text: 'Track',
                                style: TextStyle(color: _richOrange),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    l10n.reportTrackResolve,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: isDark
                          ? AppColors.darkTextSecondary
                          : AppColors.lightTextSecondary,
                      fontSize: compact ? 16 : 17,
                      fontWeight: FontWeight.w600,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: compact ? 24 : 32),
                  SizedBox.square(
                    dimension: 28,
                    child: CircularProgressIndicator(
                      key: const ValueKey('splash-loader'),
                      value: reduceMotion ? 0.72 : null,
                      color: brandBlue,
                      backgroundColor: brandBlue.withValues(alpha: 0.14),
                      strokeWidth: 3,
                      strokeCap: StrokeCap.round,
                      semanticsLabel: '${l10n.loading} ${l10n.appName}',
                      semanticsValue: l10n.loading,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );

    if (!reduceMotion) {
      content = FadeTransition(
        key: const ValueKey('splash-entrance'),
        opacity: _fadeAnimation,
        child: ScaleTransition(scale: _scaleAnimation, child: content),
      );
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppColors.darkBackground
          : AppColors.lightSurface,
      body: SafeArea(child: content),
    );
  }
}

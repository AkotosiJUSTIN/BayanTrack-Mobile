import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_wrapper.dart';

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  static const List<OnboardingContent> _contents = [
    OnboardingContent(
      mascot: 'assets/onboarding/Mascot1_thumbs_up_full.png',
      scenery: 'assets/onboarding/scenery/city_report.svg',
      title: 'Submit Reports',
      description:
          'Report local issues quickly with location tagging and photo uploads.',
    ),
    OnboardingContent(
      mascot: 'assets/onboarding/Mascot2_headset_full.png',
      scenery: 'assets/onboarding/scenery/progress_board.svg',
      title: 'Track Progress',
      description:
          'Monitor your report status and receive updates as it is reviewed and resolved.',
    ),
    OnboardingContent(
      mascot: 'assets/onboarding/Mascot3_megaphone_full.png',
      scenery: 'assets/onboarding/scenery/neighborhood_informed.svg',
      title: 'Stay Informed',
      description:
          'Get notified about important updates, alerts, and community announcements.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _onNext() {
    if (_currentPage < _contents.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } else {
      _finishOnboarding();
    }
  }

  void _onBack() {
    if (_currentPage > 0) {
      _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _finishOnboarding() async {
    await ref.read(appPreferencesProvider.notifier).setOnboardingComplete();
    if (mounted) {
      Navigator.of(
        context,
      ).pushReplacement(MaterialPageRoute(builder: (_) => const AuthWrapper()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLastPage = _currentPage == _contents.length - 1;

    return Scaffold(
      backgroundColor: AppColors.lightSurface,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  return _OnboardingPage(
                    key: ValueKey('onboarding-page-$index'),
                    content: _contents[index],
                  );
                },
              ),
            ),
            _OnboardingFooter(
              currentPage: _currentPage,
              pageCount: _contents.length,
              primaryLabel: isLastPage ? 'Get Started' : 'Next',
              onBackOrSkip: _currentPage > 0 ? _onBack : _finishOnboarding,
              onNext: _onNext,
            ),
          ],
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({super.key, required this.content});

  final OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 560;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final scalePenalty = 1 + ((textScale - 1).clamp(0, 1) * 0.35);
        final visualHeight =
            (constraints.maxHeight * (compact ? 0.42 : 0.5) / scalePenalty)
                .clamp(180.0, 350.0)
                .toDouble();
        final verticalPadding = compact ? 12.0 : 20.0;

        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            24,
            verticalPadding,
            24,
            verticalPadding,
          ),
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minHeight: constraints.maxHeight - (verticalPadding * 2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Semantics(
                  header: true,
                  label: 'BayanTrack',
                  child: ExcludeSemantics(
                    child: Text.rich(
                      TextSpan(
                        style: theme.textTheme.headlineLarge?.copyWith(
                          fontSize: compact ? 24 : 28,
                          fontWeight: FontWeight.w800,
                        ),
                        children: const [
                          TextSpan(
                            text: 'Bayan',
                            style: TextStyle(color: AppColors.primary),
                          ),
                          TextSpan(
                            text: 'Track',
                            style: TextStyle(color: AppColors.accent),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 8 : 16),
                SizedBox(
                  height: visualHeight,
                  child: ExcludeSemantics(
                    child: IgnorePointer(
                      child: Stack(
                        fit: StackFit.expand,
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            right: 0,
                            bottom: 0,
                            left: 0,
                            height: visualHeight * 0.36,
                            child: SvgPicture.asset(
                              content.scenery,
                              fit: BoxFit.fill,
                            ),
                          ),
                          Positioned.fill(
                            top: 4,
                            right: 20,
                            bottom: 6,
                            left: 20,
                            child: Image.asset(
                              content.mascot,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(height: compact ? 12 : 20),
                Text(
                  content.title,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.headlineLarge?.copyWith(
                    color: AppColors.primary,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Text(
                    content.description,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: AppColors.lightTextSecondary,
                      height: 1.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _OnboardingFooter extends StatelessWidget {
  const _OnboardingFooter({
    required this.currentPage,
    required this.pageCount,
    required this.primaryLabel,
    required this.onBackOrSkip,
    required this.onNext,
  });

  final int currentPage;
  final int pageCount;
  final String primaryLabel;
  final VoidCallback onBackOrSkip;
  final VoidCallback onNext;

  @override
  Widget build(BuildContext context) {
    final textScale = MediaQuery.textScalerOf(context).scale(1);
    final stackActions =
        textScale > 1.8 ||
        (MediaQuery.sizeOf(context).width < 360 && textScale > 1.3);

    final secondaryButton = TextButton(
      key: const ValueKey('onboarding-secondary-button'),
      onPressed: onBackOrSkip,
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Text(currentPage > 0 ? 'Back' : 'Skip'),
    );
    final primaryButton = ElevatedButton(
      key: const ValueKey('onboarding-primary-button'),
      onPressed: onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(132, 52),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      child: Text(
        primaryLabel,
        maxLines: 2,
        textAlign: TextAlign.center,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
      ),
    );

    return ColoredBox(
      color: AppColors.lightSurface,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(pageCount, (index) {
                final isActive = currentPage == index;
                return Semantics(
                  label: 'Page ${index + 1} of $pageCount',
                  selected: isActive,
                  child: ExcludeSemantics(
                    child: AnimatedContainer(
                      key: ValueKey('onboarding-indicator-$index'),
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 8,
                      width: isActive ? 28 : 8,
                      decoration: BoxDecoration(
                        color: isActive
                            ? AppColors.primary
                            : AppColors.lightBorder,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 20),
            if (stackActions)
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  primaryButton,
                  const SizedBox(height: 8),
                  Center(child: secondaryButton),
                ],
              )
            else
              Row(children: [secondaryButton, const Spacer(), primaryButton]),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String mascot;
  final String scenery;
  final String title;
  final String description;

  const OnboardingContent({
    required this.mascot,
    required this.scenery,
    required this.title,
    required this.description,
  });
}

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/presentation/auth_wrapper.dart';

abstract final class _OnboardingColors {
  static const deepBlue = Color(0xFF064BEE);
  static const richOrange = Color(0xFFF86A05);
}

class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _pageTransitionInProgress = false;

  static const List<OnboardingContent> _contents = [
    OnboardingContent(
      mascot: 'assets/onboarding/Mascot1_thumbs_up_full.png',
      title: 'Report Issues in Your Community',
      description:
          'Quickly report floods, potholes, broken streetlights, garbage, and other local concerns directly to the LGU.',
    ),
    OnboardingContent(
      mascot: 'assets/onboarding/Mascot2_headset_full.png',
      title: 'Track Your Report’s Progress',
      description:
          'Follow your report’s status and receive updates as it moves toward resolution.',
    ),
    OnboardingContent(
      mascot: 'assets/onboarding/Mascot3_megaphone_full.png',
      title: 'Stay Informed',
      description:
          'Receive important updates and safety alerts for your community.',
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> _onNext() async {
    if (_pageTransitionInProgress) return;

    _pageTransitionInProgress = true;
    try {
      if (_currentPage < _contents.length - 1) {
        await _pageController.nextPage(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      } else {
        await _finishOnboarding();
      }
    } finally {
      _pageTransitionInProgress = false;
    }
  }

  Future<void> _onBack() async {
    if (_pageTransitionInProgress || _currentPage == 0) return;

    _pageTransitionInProgress = true;
    try {
      await _pageController.previousPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      _pageTransitionInProgress = false;
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
        child: LayoutBuilder(
          builder: (context, constraints) {
            final compact = constraints.maxHeight < 620;
            final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 24.0;

            return Column(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(
                    horizontalPadding,
                    compact ? 8 : 16,
                    horizontalPadding,
                    0,
                  ),
                  child: _OnboardingHeader(compact: compact),
                ),
                SizedBox(height: compact ? 4 : 8),
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
                        pageIndex: index,
                        content: _contents[index],
                      );
                    },
                  ),
                ),
                _OnboardingFooter(
                  currentPage: _currentPage,
                  pageCount: _contents.length,
                  primaryLabel: isLastPage ? 'Get Started' : 'Continue',
                  onBackOrSkip: _currentPage > 0 ? _onBack : _finishOnboarding,
                  onNext: _onNext,
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _OnboardingPage extends StatelessWidget {
  const _OnboardingPage({
    super.key,
    required this.pageIndex,
    required this.content,
  });

  final int pageIndex;
  final OnboardingContent content;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 520;
        final textScale = MediaQuery.textScalerOf(context).scale(1);
        final scalePenalty = 1 + ((textScale - 1).clamp(0, 1) * 0.85);
        final maxVisualHeight = constraints.maxWidth - 40;
        final visualHeight =
            (constraints.maxHeight * (compact ? 0.48 : 0.56) / scalePenalty)
                .clamp(190.0, maxVisualHeight)
                .toDouble();
        final horizontalPadding = constraints.maxWidth < 360 ? 20.0 : 24.0;
        final availableWidth = constraints.maxWidth - (horizontalPadding * 2);
        final textGroupWidth = (availableWidth * 0.96)
            .clamp(0.0, 340.0)
            .toDouble();
        final topPadding = compact ? 8.0 : 16.0;
        const bottomPadding = 8.0;
        final mainContent = Column(
          key: ValueKey('onboarding-main-$pageIndex'),
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              key: ValueKey('onboarding-artwork-$pageIndex'),
              height: visualHeight,
              width: double.infinity,
              child: OverflowBox(
                maxWidth: constraints.maxWidth,
                child: Image.asset(
                  content.mascot,
                  excludeFromSemantics: true,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high,
                ),
              ),
            ),
            SizedBox(height: compact ? 4 : 8),
            _OnboardingBodyText(
              pageIndex: pageIndex,
              title: content.title,
              description: content.description,
              width: textGroupWidth,
              compact: compact,
            ),
          ],
        );
        if (compact && textScale > 1.3) {
          return SingleChildScrollView(
            key: ValueKey('onboarding-scroll-$pageIndex'),
            padding: EdgeInsets.fromLTRB(
              horizontalPadding,
              topPadding,
              horizontalPadding,
              bottomPadding,
            ),
            child: mainContent,
          );
        }

        return Padding(
          padding: EdgeInsets.fromLTRB(
            horizontalPadding,
            topPadding,
            horizontalPadding,
            bottomPadding,
          ),
          child: LayoutBuilder(
            builder: (context, mainConstraints) {
              return SingleChildScrollView(
                key: ValueKey('onboarding-scroll-$pageIndex'),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: mainConstraints.maxHeight,
                  ),
                  child: Center(child: mainContent),
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _OnboardingHeader extends StatelessWidget {
  const _OnboardingHeader({required this.compact});

  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      key: const ValueKey('onboarding-header'),
      children: [
        Semantics(
          header: true,
          label: 'BayanTrack',
          child: ExcludeSemantics(
            child: Text.rich(
              key: const ValueKey('onboarding-wordmark'),
              TextSpan(
                style: theme.textTheme.headlineLarge?.copyWith(
                  fontSize: compact ? 24 : 28,
                  fontWeight: FontWeight.w800,
                ),
                children: const [
                  TextSpan(
                    text: 'Bayan',
                    style: TextStyle(color: _OnboardingColors.deepBlue),
                  ),
                  TextSpan(
                    text: 'Track',
                    style: TextStyle(color: _OnboardingColors.richOrange),
                  ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'Watching over communities, supporting local action.',
          key: const ValueKey('onboarding-tagline'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: _OnboardingColors.deepBlue,
            fontWeight: FontWeight.w600,
            height: 1.3,
          ),
        ),
      ],
    );
  }
}

class _OnboardingBodyText extends StatelessWidget {
  const _OnboardingBodyText({
    required this.pageIndex,
    required this.title,
    required this.description,
    required this.width,
    required this.compact,
  });

  final int pageIndex;
  final String title;
  final String description;
  final double width;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final underlineWidth = (width * 0.36).clamp(92.0, 124.0).toDouble();

    return SizedBox(
      key: ValueKey('onboarding-body-$pageIndex'),
      width: width,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            title,
            key: ValueKey('onboarding-title-$pageIndex'),
            textAlign: TextAlign.center,
            style: theme.textTheme.headlineLarge?.copyWith(
              color: _OnboardingColors.deepBlue,
              fontSize: compact ? 28 : 30,
              fontWeight: FontWeight.w800,
              height: 1.12,
            ),
          ),
          const SizedBox(height: 4),
          ExcludeSemantics(
            child: SizedBox(
              key: ValueKey('onboarding-title-underline-$pageIndex'),
              width: underlineWidth,
              height: 12,
              child: SvgPicture.asset(
                'assets/onboarding/doodles/title_underline.svg',
                fit: BoxFit.fill,
                colorFilter: const ColorFilter.mode(
                  _OnboardingColors.richOrange,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Text(
            description,
            key: ValueKey('onboarding-description-$pageIndex'),
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: AppColors.lightTextPrimary,
              fontSize: compact ? 16 : 17,
              fontWeight: FontWeight.w500,
              height: 1.42,
            ),
          ),
        ],
      ),
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
        textScale > 1.3 ||
        (MediaQuery.sizeOf(context).width <= 360 && textScale > 1.1);

    final secondaryButton = TextButton(
      key: const ValueKey('onboarding-secondary-button'),
      onPressed: onBackOrSkip,
      style: TextButton.styleFrom(
        foregroundColor: _OnboardingColors.richOrange,
        minimumSize: const Size(88, 48),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
      ),
      child: Text(currentPage > 0 ? 'Back' : 'Skip'),
    );
    final primaryButton = ElevatedButton(
      key: const ValueKey('onboarding-primary-button'),
      onPressed: onNext,
      style: ElevatedButton.styleFrom(
        backgroundColor: _OnboardingColors.deepBlue,
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
              key: const ValueKey('onboarding-indicator-group'),
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
                            ? _OnboardingColors.deepBlue
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
                  Align(
                    alignment: Alignment.centerLeft,
                    child: secondaryButton,
                  ),
                  const SizedBox(height: 8),
                  primaryButton,
                ],
              )
            else
              Row(
                children: [
                  secondaryButton,
                  const SizedBox(width: 8),
                  Expanded(
                    child: Align(
                      alignment: Alignment.centerRight,
                      child: primaryButton,
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String mascot;
  final String title;
  final String description;

  const OnboardingContent({
    required this.mascot,
    required this.title,
    required this.description,
  });
}

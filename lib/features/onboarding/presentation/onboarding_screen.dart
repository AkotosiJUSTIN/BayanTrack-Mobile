import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../core/providers/locale_provider.dart';
import '../../../core/providers/app_preferences_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../l10n/app_localizations.dart';
import '../../auth/presentation/auth_wrapper.dart';

abstract final class _OnboardingColors {
  static const deepBlue = AppColors.brandBlue;
  static const richOrange = AppColors.brandOrange;

  static bool isDark(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark;

  static Color brandBlue(BuildContext context) =>
      isDark(context) ? AppColors.primaryLight : deepBlue;

  static Color background(BuildContext context) =>
      isDark(context) ? AppColors.darkBackground : AppColors.lightSurface;

  static Color text(BuildContext context) =>
      isDark(context) ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;

  static Color border(BuildContext context) =>
      isDark(context) ? AppColors.darkBorder : AppColors.lightBorder;
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
  late Locale _selectedLocale;

  static const _contentCount = 3;
  static const _pageCount = _contentCount + 1;

  @override
  void initState() {
    super.initState();
    _selectedLocale = ref.read(appLocaleProvider);
  }

  List<OnboardingContent> _contents(AppLocalizations l10n) => [
    OnboardingContent(
      mascot: 'assets/images/onboarding/step_1.webp',
      title: l10n.onboardingReportTitle,
      description: l10n.onboardingReportDescription,
    ),
    OnboardingContent(
      mascot: 'assets/images/onboarding/step_2.webp',
      title: l10n.onboardingTrackTitle,
      description: l10n.onboardingTrackDescription,
    ),
    OnboardingContent(
      mascot: 'assets/images/onboarding/step_3.webp',
      title: l10n.onboardingStayInformedTitle,
      description: l10n.onboardingStayInformedDescription,
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
      if (_currentPage < _pageCount - 1) {
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

  Future<void> _selectLocale(Locale locale) async {
    setState(() => _selectedLocale = locale);
    await ref.read(appLocaleProvider.notifier).setLocale(locale);
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
    final l10n = AppLocalizations.of(context)!;
    final contents = _contents(l10n);
    final isLastPage = _currentPage == _pageCount - 1;

    return Scaffold(
      key: const ValueKey('onboarding-scaffold'),
      backgroundColor: _OnboardingColors.background(context),
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
                    itemCount: _pageCount,
                    itemBuilder: (context, index) {
                      if (index == 0) {
                        return _LanguageSelectionPage(
                          selectedLocale: _selectedLocale,
                          onSelected: _selectLocale,
                        );
                      }

                      final content = contents[index - 1];
                      return _OnboardingPage(
                        key: ValueKey('onboarding-page-$index'),
                        pageIndex: index,
                        content: content,
                      );
                    },
                  ),
                ),
                _OnboardingFooter(
                  currentPage: _currentPage,
                  pageCount: _pageCount,
                  primaryLabel: isLastPage
                      ? l10n.getStarted
                      : l10n.continueLabel,
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

class _LanguageSelectionPage extends StatelessWidget {
  const _LanguageSelectionPage({
    required this.selectedLocale,
    required this.onSelected,
  });

  final Locale selectedLocale;
  final ValueChanged<Locale> onSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);
    final brandBlue = _OnboardingColors.brandBlue(context);
    final options = [
      (const Locale('en'), l10n.english),
      (const Locale('fil'), l10n.filipino),
    ];

    return SingleChildScrollView(
      key: const ValueKey('onboarding-language-scroll'),
      padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(minHeight: 360),
        child: Column(
          key: const ValueKey('onboarding-language-page'),
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.translate, size: 56, color: brandBlue),
            const SizedBox(height: 24),
            Text(
              l10n.chooseLanguage,
              key: const ValueKey('onboarding-language-title'),
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineMedium?.copyWith(
                color: brandBlue,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              l10n.chooseLanguageSubtitle,
              key: const ValueKey('onboarding-language-subtitle'),
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 28),
            ...options.map((option) {
              final (locale, label) = option;
              final selected =
                  selectedLocale.languageCode == locale.languageCode;
              return Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Semantics(
                  selected: selected,
                  button: true,
                  label: label,
                  child: OutlinedButton(
                    key: ValueKey('onboarding-language-${locale.languageCode}'),
                    onPressed: () => onSelected(locale),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size.fromHeight(56),
                      side: BorderSide(
                        color: selected
                            ? brandBlue
                            : _OnboardingColors.border(context),
                        width: selected ? 2 : 1,
                      ),
                      backgroundColor: selected
                          ? brandBlue.withValues(alpha: 0.08)
                          : null,
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            label,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: selected ? brandBlue : null,
                              fontWeight: selected ? FontWeight.w700 : null,
                            ),
                          ),
                        ),
                        if (selected)
                          Icon(Icons.check_circle, color: brandBlue),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ],
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
    final brandBlue = _OnboardingColors.brandBlue(context);
    final logoSize = compact ? 42.0 : 48.0;
    final wordmarkTextScale = MediaQuery.textScalerOf(
      context,
    ).scale(1).clamp(1.0, 1.5).toDouble();

    return Column(
      key: const ValueKey('onboarding-header'),
      children: [
        Semantics(
          header: true,
          label: 'BayanTrack',
          child: ExcludeSemantics(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox.square(
                  dimension: logoSize,
                  child: Image.asset(
                    'assets/images/branding/bt_logo_mark.webp',
                    key: const ValueKey('onboarding-header-logo'),
                    excludeFromSemantics: true,
                    fit: BoxFit.contain,
                    filterQuality: FilterQuality.high,
                  ),
                ),
                SizedBox(width: compact ? 6 : 8),
                Flexible(
                  child: Text.rich(
                    key: const ValueKey('onboarding-wordmark'),
                    textScaler: TextScaler.linear(wordmarkTextScale),
                    TextSpan(
                      style: theme.textTheme.headlineLarge?.copyWith(
                        fontSize: compact ? 24 : 28,
                        fontWeight: FontWeight.w800,
                      ),
                      children: [
                        TextSpan(
                          text: 'Bayan',
                          style: TextStyle(color: brandBlue),
                        ),
                        const TextSpan(
                          text: 'Track',
                          style: TextStyle(color: _OnboardingColors.richOrange),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          AppLocalizations.of(context)!.brandTagline,
          key: const ValueKey('onboarding-tagline'),
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: brandBlue,
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
    final brandBlue = _OnboardingColors.brandBlue(context);
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
              color: brandBlue,
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
              color: _OnboardingColors.text(context),
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
    final brandBlue = _OnboardingColors.brandBlue(context);
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
      child: Text(
        currentPage > 0
            ? AppLocalizations.of(context)!.back
            : AppLocalizations.of(context)!.skip,
      ),
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
      key: const ValueKey('onboarding-footer'),
      color: _OnboardingColors.background(context),
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
                  label: AppLocalizations.of(
                    context,
                  )!.pageOf(index + 1, pageCount),
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
                            ? brandBlue
                            : _OnboardingColors.border(context),
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

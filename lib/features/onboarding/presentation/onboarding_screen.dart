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

  final List<OnboardingContent> _contents = const [
    OnboardingContent(
      image: 'assets/images/Onboarding-1.svg',
      title: 'Submit Reports',
      description:
          'Report issues quickly with location tagging and photo uploads',
    ),
    OnboardingContent(
      image: 'assets/images/Onboarding-2.svg',
      title: 'Track Progress',
      description:
          'Check the status of your reports and receive updates as they are resolved',
    ),
    OnboardingContent(
      image: 'assets/images/Onboarding-3.svg',
      title: 'Stay Informed',
      description:
          'Get notified about important updates and safety alerts in your community',
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
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;
    final isLastPage = _currentPage == _contents.length - 1;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      // SafeArea ensures we don't overlap with system bars
      body: SafeArea(
        child: Column(
          children: [
            // Middle Content: PageView takes all available space
            Expanded(
              child: PageView.builder(
                controller: _pageController,
                physics: const BouncingScrollPhysics(),
                onPageChanged: (index) {
                  setState(() => _currentPage = index);
                },
                itemCount: _contents.length,
                itemBuilder: (context, index) {
                  final content = _contents[index];
                  // Padding around each page content
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Spacer(flex: 1),
                        // Image - fixed height relative to screen to ensure visibility
                        SizedBox(
                          height: size.height * 0.4,
                          child: SvgPicture.asset(
                            content.image,
                            fit: BoxFit.contain,
                            placeholderBuilder: (context) => Container(
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Colors.grey.shade200,
                                borderRadius: BorderRadius.circular(16),
                              ),
                              child: const Icon(
                                Icons.image_outlined,
                                size: 64,
                                color: Colors.grey,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 32),
                        // Title
                        Text(
                          content.title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: AppColors.accent,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 16),
                        // Description
                        Text(
                          content.description,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(
                              alpha: 0.6,
                            ),
                            height: 1.5,
                          ),
                          textAlign: TextAlign.center,
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  );
                },
              ),
            ),

            // Bottom Section: Dots and Buttons
            Container(
              padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Dots Indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(_contents.length, (index) {
                      final isActive = _currentPage == index;
                      return AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        height: 8,
                        width: isActive ? 28 : 8,
                        decoration: BoxDecoration(
                          color: isActive
                              ? AppColors.primary
                              : Colors.grey.shade300,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      );
                    }),
                  ),
                  const SizedBox(height: 32),

                  // Navigation Buttons Row
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Left Button: Skip or Back
                      SizedBox(
                        width: 100, // Fixed width for alignment
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: TextButton(
                            onPressed: _currentPage > 0
                                ? _onBack
                                : _finishOnboarding,
                            style: TextButton.styleFrom(
                              padding: EdgeInsets
                                  .zero, // Remove defaults for alignment
                              minimumSize: const Size(
                                50,
                                40,
                              ), // Ensure touch target
                              alignment: Alignment.centerLeft,
                            ),
                            child: Text(
                              _currentPage > 0 ? 'Back' : 'Skip',
                              style: TextStyle(
                                fontSize: 16,
                                color: theme.colorScheme.secondary,
                                fontWeight: _currentPage > 0
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Right Button: Next or Get Started
                      ElevatedButton(
                        onPressed: _onNext,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 24,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          minimumSize: const Size(120, 48), // Consistent size
                          elevation: 0,
                        ),
                        child: Text(
                          isLastPage ? 'Get Started' : 'Next',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class OnboardingContent {
  final String image;
  final String title;
  final String description;

  const OnboardingContent({
    required this.image,
    required this.title,
    required this.description,
  });
}

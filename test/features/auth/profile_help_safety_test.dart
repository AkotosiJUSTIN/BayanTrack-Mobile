import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_screen.dart';
import 'package:bayantrack_mobile/features/help/presentation/help_screens.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets(
    'Profile has one emergency entry and opens separate FAQ and hotline pages',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final prefs = await SharedPreferences.getInstance();

      await tester.pumpWidget(
        ProviderScope(
          retry: (_, _) => null,
          overrides: [
            sharedPrefsProvider.overrideWithValue(prefs),
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            profileControllerProvider.overrideWithBuild(
              (_, _) =>
                  const UserProfile(id: 'test-user', email: 'test@example.com'),
            ),
            profileStatsControllerProvider.overrideWithBuild(
              (_, _) => const {'total': 0, 'resolved': 0, 'pending': 0},
            ),
            kycStatusControllerProvider.overrideWithBuild((_, _) async => null),
          ],
          child: MaterialApp(
            theme: AppTheme.light,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const ProfileScreen(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final profileScroll = tester.state<ScrollableState>(
        find.byType(Scrollable).first,
      );
      profileScroll.position.jumpTo(profileScroll.position.maxScrollExtent);
      await tester.pumpAndSettle();

      final faqEntry = find.byKey(const ValueKey('profile-help-faq'));
      expect(find.text('Help & Safety'), findsOneWidget);
      expect(find.text('Contact Support'), findsNothing);
      expect(find.text('View Emergency Hotlines'), findsOneWidget);
      expect(find.text('Emergency Hotlines'), findsNothing);
      expect(find.byKey(const ValueKey('profile-help-hotlines')), findsNothing);
      await tester.tap(faqEntry);
      await tester.pumpAndSettle();
      expect(find.text('Help & FAQs'), findsOneWidget);
      expect(find.byType(EmergencyHotlineSection), findsNothing);
      expect(
        find.byKey(const ValueKey('help-faq-search')).hitTestable(),
        findsOneWidget,
      );

      await tester.pageBack();
      await tester.pumpAndSettle();
      final hotlineEntry = find.text('View Emergency Hotlines');
      await tester.ensureVisible(hotlineEntry);
      await tester.pumpAndSettle();
      await tester.tap(hotlineEntry);
      await tester.pumpAndSettle();
      expect(find.text('Emergency Hotlines'), findsOneWidget);
      expect(find.byKey(const ValueKey('hotline-call-911')), findsOneWidget);
    },
  );
}

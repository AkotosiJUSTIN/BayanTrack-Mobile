import 'package:bayantrack_mobile/core/providers/locale_provider.dart';
import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_screen.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_controller.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  testWidgets('Profile language setting switches the app immediately', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
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
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(appLocaleProvider),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text('Language'), findsOneWidget);
    await tester.ensureVisible(find.text('Language'));
    await tester.tap(find.text('Language'));
    await tester.pumpAndSettle();
    expect(find.text('Filipino'), findsOneWidget);

    await tester.tap(find.text('Filipino'));
    await tester.pumpAndSettle();

    expect(find.text('Wika'), findsOneWidget);
    expect(prefs.getString('app_locale'), 'fil');
  });
}

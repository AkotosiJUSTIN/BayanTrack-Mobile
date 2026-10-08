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

class _FailingProfileController extends ProfileController {
  @override
  Future<UserProfile> build() async {
    throw Exception('private backend details');
  }
}

void main() {
  testWidgets('Profile language setting switches the app immediately', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(960, 1600);
    tester.view.devicePixelRatio = 3;
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
        child: Consumer(
          builder: (context, ref, _) => MaterialApp(
            locale: ref.watch(appLocaleProvider),
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            builder: (context, child) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.3)),
              child: child!,
            ),
            home: const ProfileScreen(),
          ),
        ),
      ),
    );
    await tester.pump();

    final language = find.byKey(
      const ValueKey('profile-language'),
      skipOffstage: false,
    );
    await tester.scrollUntilVisible(
      language,
      200,
      scrollable: find.byType(Scrollable),
    );
    await tester.pumpAndSettle();
    expect(language, findsOneWidget);
    await tester.tap(language);
    await tester.pumpAndSettle();
    expect(find.text('Filipino'), findsOneWidget);

    await tester.tap(find.text('Filipino'));
    await tester.pumpAndSettle();

    expect(find.text('Wika'), findsOneWidget);
    expect(prefs.getString('app_locale'), 'fil');
  });

  testWidgets('Profile failure shows safe retry guidance', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    await tester.pumpWidget(
      ProviderScope(
        retry: (_, _) => null,
        overrides: [
          sharedPrefsProvider.overrideWithValue(prefs),
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
          profileControllerProvider.overrideWith(_FailingProfileController.new),
          profileStatsControllerProvider.overrideWithBuild(
            (_, _) => const {'total': 0, 'resolved': 0, 'pending': 0},
          ),
          kycStatusControllerProvider.overrideWithBuild((_, _) async => null),
        ],
        child: const MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: ProfileScreen(),
        ),
      ),
    );
    await tester.pump();
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text('Unable to load profile.', skipOffstage: false),
      findsOneWidget,
    );
    expect(find.text('private backend details'), findsNothing);
    expect(find.widgetWithText(FilledButton, 'Retry'), findsOneWidget);
  });
}

import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/profile_screen.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_models.dart';
import 'package:bayantrack_mobile/features/system_governance/system_governance_provider.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

PublishedTerms _terms(String version) => PublishedTerms(
  versionId: version,
  checksum: 'checksum-$version',
  translations: {
    'en': LegalTranslation(
      title: 'Published English policy $version',
      terms: 'English terms $version',
      privacy: 'English privacy $version',
    ),
    'fil': LegalTranslation(
      title: 'Mga tuntuning inilathala $version',
      terms: 'Mga tuntunin $version',
      privacy: 'Pribasiya $version',
    ),
  },
);

class _Reachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
}

class _Repository extends SystemGovernanceRepository {
  _Repository() : super(Dio());

  PublishedTerms document = _terms('version-1');
  int acceptances = 0;

  @override
  Future<PublishedTerms> currentTerms() async => document;

  @override
  Future<void> accept(PublishedTerms terms, String language) async {
    acceptances++;
  }
}

void main() {
  for (final language in ['en', 'fil']) {
    for (final scale in [1.0, 2.0]) {
      testWidgets(
        'Profile reads latest $language terms at ${scale}x without accepting',
        (tester) async {
          tester.view.physicalSize = const Size(320, 568);
          tester.view.devicePixelRatio = 1;
          addTearDown(tester.view.reset);
          SharedPreferences.setMockInitialValues({});
          final prefs = await SharedPreferences.getInstance();
          final repository = _Repository();
          final container = ProviderContainer(
            retry: (_, _) => null,
            overrides: [
              backendReachabilityProvider.overrideWith(_Reachability.new),
              sharedPrefsProvider.overrideWithValue(prefs),
              userPermissionsProvider.overrideWithValue(UserPermissions(null)),
              profileControllerProvider.overrideWithBuild(
                (_, _) => const UserProfile(
                  id: 'test-user',
                  email: 'test@example.com',
                ),
              ),
              profileStatsControllerProvider.overrideWithBuild(
                (_, _) => const {'total': 0, 'resolved': 0, 'pending': 0},
              ),
              kycStatusControllerProvider.overrideWithBuild(
                (_, _) async => null,
              ),
              systemGovernanceRepositoryProvider.overrideWithValue(repository),
            ],
          );
          addTearDown(container.dispose);
          await container.read(publishedTermsProvider.future);
          repository.document = _terms('version-2');
          await tester.pumpWidget(
            UncontrolledProviderScope(
              container: container,
              child: MaterialApp(
                locale: Locale(language),
                theme: AppTheme.light,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: AppLocalizations.localizationsDelegates,
                builder: (context, child) => MediaQuery(
                  data: MediaQuery.of(
                    context,
                  ).copyWith(textScaler: TextScaler.linear(scale)),
                  child: child!,
                ),
                home: const ProfileScreen(),
              ),
            ),
          );
          await tester.pumpAndSettle();
          final entry = find.byKey(const ValueKey('profile-terms-and-privacy'));
          await tester.scrollUntilVisible(entry, 200);
          await tester.ensureVisible(entry);
          await tester.pumpAndSettle();
          expect(entry.hitTestable(), findsOneWidget);
          await tester.tap(entry);
          await tester.pumpAndSettle();
          expect(
            find.text(repository.document.translation(language).content),
            findsOneWidget,
          );
          expect(
            find.byKey(const Key('governance-consent-checkbox')),
            findsNothing,
          );
          expect(
            find.byKey(const Key('governance-accept-button')),
            findsNothing,
          );
          expect(tester.takeException(), isNull);
          await tester.tap(find.byType(BackButton));
          await tester.pumpAndSettle();
          repository.document = _terms('version-3');
          await tester.ensureVisible(entry);
          await tester.pumpAndSettle();
          await tester.tap(entry);
          await tester.pumpAndSettle();
          expect(
            find.text(repository.document.translation(language).content),
            findsOneWidget,
          );
          expect(repository.acceptances, 0);
          expect(tester.takeException(), isNull);
        },
      );
    }
  }
}

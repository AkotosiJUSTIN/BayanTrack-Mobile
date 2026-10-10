import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/verification_widgets.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app(KycVerificationStatus status, {bool compact = true}) {
  return ProviderScope(
    child: MaterialApp(
      theme: AppTheme.dark,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: Scaffold(
        body: VerificationBanner(
          permissions: UserPermissions(KycStatusEntity(status: status)),
          compact: compact,
        ),
      ),
    ),
  );
}

void main() {
  for (final status in KycVerificationStatus.values) {
    testWidgets('compact verification preserves the $status action', (
      tester,
    ) async {
      await tester.pumpWidget(_app(status));
      await tester.pumpAndSettle();
      if (status == KycVerificationStatus.verified) {
        expect(find.byType(TextButton), findsNothing);
        expect(find.byKey(const Key('home-verification-toggle')), findsNothing);
        return;
      }
      final context = tester.element(find.byType(VerificationBanner));
      final l10n = AppLocalizations.of(context);
      final permissions = UserPermissions(KycStatusEntity(status: status));
      expect(
        find.text(localizedVerificationActionLabel(permissions, l10n)),
        findsOneWidget,
      );
      expect(
        find.text(localizedVerificationStatusMessage(permissions, l10n)),
        findsNothing,
      );
      await tester.tap(find.byKey(const Key('home-verification-toggle')));
      await tester.pumpAndSettle();
      expect(
        find.text(localizedVerificationStatusMessage(permissions, l10n)),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('shared verification banner keeps its default layout', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(KycVerificationStatus.unverified, compact: false),
    );
    await tester.pumpAndSettle();
    expect(find.text('User Verification'), findsOneWidget);
    expect(find.text('Verify Identity'), findsOneWidget);
    expect(find.byKey(const Key('home-verification-toggle')), findsNothing);
  });
}

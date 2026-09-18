import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_status_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> _pumpStatus(
  WidgetTester tester, {
  required ThemeData theme,
  Locale locale = const Locale('en'),
  KycStatusEntity? status,
}) async {
  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kycStatusControllerProvider.overrideWithBuild((_, _) async => status),
      ],
      child: MaterialApp(
        locale: locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme,
        home: const KycStatusScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('explains identity verification before the first submission', (
    tester,
  ) async {
    await _pumpStatus(tester, theme: AppTheme.light);

    expect(find.text('Terms & Conditions and Privacy Policy'), findsOneWidget);
    expect(find.text('Verify Identity'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps the entry state readable in Filipino dark mode', (
    tester,
  ) async {
    await _pumpStatus(
      tester,
      theme: AppTheme.dark,
      locale: const Locale('fil'),
    );

    expect(
      find.text('Mga Tuntunin at Kundisyon at Patakaran sa Privacy'),
      findsOneWidget,
    );
    expect(find.text('Wala pang naisumiteng beripikasyon'), findsOneWidget);
    expect(find.text('I-verify ang Pagkakakilanlan'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'does not show blank submitted information for an unverified user',
    (tester) async {
      await _pumpStatus(
        tester,
        theme: AppTheme.light,
        status: const KycStatusEntity(status: KycVerificationStatus.unverified),
      );

      expect(find.text('No verification submitted yet'), findsOneWidget);
      expect(find.text('Submitted Information'), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('submitted information labels share one scan edge', (
    tester,
  ) async {
    await _pumpStatus(
      tester,
      theme: AppTheme.dark,
      status: KycStatusEntity(
        status: KycVerificationStatus.pending,
        firstName: 'Henry',
        lastName: 'Citizen',
        idType: IdType.nationalId,
        idNumber: '123456789',
        dateOfBirth: DateTime(1990, 1, 9),
      ),
    );

    final scrollable = tester.state<ScrollableState>(find.byType(Scrollable));
    scrollable.position.jumpTo(scrollable.position.maxScrollExtent);
    await tester.pump();

    final fullNameX = tester.getTopLeft(find.text('Full Name')).dx;
    final idTypeX = tester.getTopLeft(find.text('ID Type')).dx;
    expect((fullNameX - idTypeX).abs(), lessThan(1));
  });

  testWidgets('rejected status shows reason and Correct & Resubmit action', (
    tester,
  ) async {
    await _pumpStatus(
      tester,
      theme: AppTheme.light,
      status: const KycStatusEntity(
        status: KycVerificationStatus.rejected,
        rejectionReason: 'ID image is blurry',
      ),
    );

    expect(find.text('ID image is blurry'), findsOneWidget);
    expect(find.text('Correct & Resubmit'), findsOneWidget);
  });

  testWidgets(
    'resubmit requested status shows reason and Correct & Resubmit action',
    (tester) async {
      await _pumpStatus(
        tester,
        theme: AppTheme.light,
        status: const KycStatusEntity(
          status: KycVerificationStatus.resubmitRequested,
          rejectionReason: 'Add the back of the ID.',
        ),
      );

      expect(find.text('Add the back of the ID.'), findsOneWidget);
      expect(find.text('Correct & Resubmit'), findsOneWidget);
    },
  );

  testWidgets('pending and verified statuses stay read-only', (tester) async {
    for (final status in [
      KycVerificationStatus.pending,
      KycVerificationStatus.verified,
    ]) {
      await _pumpStatus(
        tester,
        theme: AppTheme.light,
        status: KycStatusEntity(status: status),
      );
      expect(find.text('Correct & Resubmit'), findsNothing);
    }
  });
}

import 'dart:async';

import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/presentation/widgets/civic_components.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bayantrack_mobile/features/kyc/kyc_di.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_status_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _GetKycStatusMock extends Mock implements GetKycStatusUseCase {}

Future<void> _pumpStatus(
  WidgetTester tester, {
  required ThemeData theme,
  Locale locale = const Locale('en'),
  KycStatusEntity? status,
  Future<KycStatusEntity?>? pendingStatus,
  GetKycStatusUseCase? getStatus,
  Size size = const Size(360, 800),
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        if (getStatus != null)
          getKycStatusUseCaseProvider.overrideWithValue(getStatus),
        kycStatusControllerProvider.overrideWithBuild(
          (_, _) async => pendingStatus != null ? await pendingStatus : status,
        ),
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
  for (final theme in [AppTheme.light, AppTheme.dark]) {
    testWidgets('KYC loading stays neutral in ${theme.brightness.name}', (
      tester,
    ) async {
      final pending = Completer<KycStatusEntity?>();
      await _pumpStatus(
        tester,
        theme: theme,
        pendingStatus: pending.future,
        size: const Size(320, 640),
      );

      expect(find.byType(CivicSkeletonBlock), findsWidgets);
      expect(find.byType(CircularProgressIndicator), findsNothing);
      expect(find.bySemanticsLabel(RegExp(r'^Loading')), findsOneWidget);
      expect(find.text('Verify Identity'), findsNothing);
      expect(find.text('Verified'), findsNothing);
      expect(find.text('Rejected'), findsNothing);
      expect(tester.takeException(), isNull);

      pending.complete(null);
      await tester.pumpAndSettle();

      expect(find.byType(CivicSkeletonBlock), findsNothing);
      expect(find.text('Verify Identity'), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets('keeps KYC status visible during refresh', (tester) async {
    final getStatus = _GetKycStatusMock();
    final pending = Completer<Result<KycStatusEntity>>();
    when(getStatus.call).thenAnswer((_) => pending.future);
    await _pumpStatus(tester, theme: AppTheme.light, getStatus: getStatus);

    await tester.tap(find.byIcon(Icons.refresh));
    await tester.pump();

    expect(find.text('Verify Identity'), findsOneWidget);
    expect(find.byType(CivicSkeletonBlock), findsNothing);

    pending.complete(
      const Success(
        KycStatusEntity(
          status: KycVerificationStatus.rejected,
          rejectionReason: 'ID image is blurry',
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ID image is blurry'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

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

  testWidgets('pending and verified statuses do not show resubmit action', (
    tester,
  ) async {
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

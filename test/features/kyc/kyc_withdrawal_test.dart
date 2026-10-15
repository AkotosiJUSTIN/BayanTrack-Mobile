import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/features/kyc/domain/kyc_repository.dart';
import 'package:bayantrack_mobile/features/kyc/domain/usecases/get_kyc_status_usecase.dart';
import 'package:bayantrack_mobile/features/kyc/domain/usecases/withdraw_kyc_usecase.dart';
import 'package:bayantrack_mobile/features/kyc/kyc_di.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_status_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _KycRepositoryMock extends Mock implements KycRepository {}

Future<void> _pumpPending(
  WidgetTester tester, {
  required _KycRepositoryMock repository,
}) async {
  when(() => repository.getKycStatus()).thenAnswer(
    (_) async => const Success(
      KycStatusEntity(status: KycVerificationStatus.unverified),
    ),
  );

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        kycStatusControllerProvider.overrideWithBuild(
          (_, _) async =>
              const KycStatusEntity(status: KycVerificationStatus.pending),
        ),
        getKycStatusUseCaseProvider.overrideWithValue(
          GetKycStatusUseCase(repository: repository),
        ),
        withdrawKycUseCaseProvider.overrideWithValue(
          WithdrawKycUseCase(repository: repository),
        ),
      ],
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const KycStatusScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  test('withdrawal keeps preferred and legacy routes defined', () {
    expect(ApiConstants.verificationWithdraw, '/auth/verification/withdraw/');
    expect(ApiConstants.kycWithdraw, '/auth/kyc/withdraw/');
  });

  testWidgets('pending status exposes a confirmed withdrawal action', (
    tester,
  ) async {
    final repository = _KycRepositoryMock();
    when(() => repository.withdrawKyc()).thenAnswer(
      (_) async => const Success(
        KycStatusEntity(status: KycVerificationStatus.unverified),
      ),
    );
    await _pumpPending(tester, repository: repository);

    expect(find.text('Withdraw submission'), findsOneWidget);
    await tester.tap(find.text('Withdraw submission'));
    await tester.pumpAndSettle();

    expect(
      find.text(
        'Your application will be removed from staff review. You can edit and submit it again.',
      ),
      findsOneWidget,
    );
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('Cancel'), findsOneWidget);
  });

  testWidgets('withdrawal confirmation shows progress until the request ends', (
    tester,
  ) async {
    final repository = _KycRepositoryMock();
    final withdrawal = Completer<Result<KycStatusEntity>>();
    when(() => repository.withdrawKyc()).thenAnswer((_) => withdrawal.future);
    await _pumpPending(tester, repository: repository);

    await tester.tap(find.text('Withdraw submission'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Withdraw submission'));
    await tester.pump();

    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Loading…'), findsOneWidget);
    verify(() => repository.withdrawKyc()).called(1);

    withdrawal.complete(
      const Success(KycStatusEntity(status: KycVerificationStatus.unverified)),
    );
    await tester.pumpAndSettle();
    expect(find.byType(Dialog), findsNothing);
  });

  testWidgets('successful withdrawal refreshes to editable state', (
    tester,
  ) async {
    final repository = _KycRepositoryMock();
    when(() => repository.withdrawKyc()).thenAnswer(
      (_) async => const Success(
        KycStatusEntity(status: KycVerificationStatus.unverified),
      ),
    );
    await _pumpPending(tester, repository: repository);

    await tester.tap(find.text('Withdraw submission'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Withdraw submission'));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for review'), findsNothing);
    expect(find.text('Verify Identity'), findsOneWidget);
    verify(() => repository.withdrawKyc()).called(1);
    verify(() => repository.getKycStatus()).called(1);
  });

  testWidgets('failed withdrawal keeps pending state', (tester) async {
    final repository = _KycRepositoryMock();
    when(() => repository.withdrawKyc()).thenAnswer(
      (_) async => const Err(
        ValidationFailure('Pending review changed. Refresh and try again.'),
      ),
    );
    await _pumpPending(tester, repository: repository);

    await tester.tap(find.text('Withdraw submission'));
    await tester.pumpAndSettle();
    await tester.tap(find.widgetWithText(FilledButton, 'Withdraw submission'));
    await tester.pumpAndSettle();

    expect(find.text('Waiting for review'), findsOneWidget);
    expect(find.text('Verify Identity'), findsNothing);
    verifyNever(() => repository.getKycStatus());
  });
}

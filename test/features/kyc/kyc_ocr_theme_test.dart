import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_ocr.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_form_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _ThemeOcrService implements KycOcrService {
  @override
  Future<KycOcrResult> scan({
    required IdType idType,
    required String imagePath,
  }) async {
    return KycOcrResult(
      idType: idType,
      status: KycOcrResultStatus.extracted,
      fields: {
        KycOcrField.firstName: const KycOcrFieldValue(
          value: 'Juan',
          confidence: KycOcrConfidence.review,
        ),
      },
    );
  }

  @override
  Future<void> close() async {}
}

Future<void> _pumpReview(
  WidgetTester tester, {
  required ThemeData theme,
}) async {
  final container = ProviderContainer(
    overrides: [kycOcrServiceProvider.overrideWithValue(_ThemeOcrService())],
  );
  addTearDown(container.dispose);
  final controller = container.read(kycFormControllerProvider.notifier);
  controller.setVerificationMethod(KycVerificationMethod.scanId);
  controller.setIdType(IdType.passport);
  controller.setIdFrontImage('front.jpg');
  await controller.scanId();

  tester.view.physicalSize = const Size(360, 800);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: theme,
        home: const KycFormScreen(initialStep: 2),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('review notice remains readable in light theme', (tester) async {
    await _pumpReview(tester, theme: AppTheme.light);
    expect(
      find.text(
        'OCR only helps fill the form. It does not verify that the ID is authentic.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('review notice remains readable in dark theme', (tester) async {
    await _pumpReview(tester, theme: AppTheme.dark);
    expect(
      find.text(
        'OCR only helps fill the form. It does not verify that the ID is authentic.',
      ),
      findsOneWidget,
    );
    expect(tester.takeException(), isNull);
  });
}

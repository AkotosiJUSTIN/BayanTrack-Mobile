import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_form_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestBarangays extends Barangays {
  @override
  FutureOr<List<BarangayModel>> build() => bundledUrdanetaBarangays;
}

void main() {
  testWidgets('continue blocks when the current KYC step is incomplete', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      ProviderScope(
        overrides: [barangaysProvider.overrideWith(_TestBarangays.new)],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const KycFormScreen(),
        ),
      ),
    );
    await tester.pump();

    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 0);

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
    );
    await tester.pump();

    expect(tester.widget<Stepper>(find.byType(Stepper)).currentStep, 0);
    expect(find.text('First name is required'), findsOneWidget);
  });
}

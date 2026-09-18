import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/kyc/data/kyc_models.dart' as dto;
import 'package:bayantrack_mobile/features/kyc/data/kyc_ocr.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_form_screen.dart';
import 'package:bayantrack_mobile/features/kyc/presentation/kyc_controller.dart';
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_enums.dart'
    as domain;
import 'package:bayantrack_mobile/features/kyc/domain/entities/kyc_status.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

class _TestBarangays extends Barangays {
  @override
  FutureOr<List<BarangayModel>> build() => bundledUrdanetaBarangays;
}

class _CompleteOcrService implements KycOcrService {
  @override
  Future<KycOcrResult> scan({
    required dto.IdType idType,
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
        KycOcrField.middleName: const KycOcrFieldValue(
          value: 'Santos',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.lastName: const KycOcrFieldValue(
          value: 'Dela Cruz',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.dateOfBirth: const KycOcrFieldValue(
          value: '1990-01-01',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.sex: const KycOcrFieldValue(
          value: 'male',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.nationality: const KycOcrFieldValue(
          value: 'Filipino',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.civilStatus: const KycOcrFieldValue(
          value: 'single',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.address: const KycOcrFieldValue(
          value: '123 Mabini Street, Cebu City',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.cityMunicipality: const KycOcrFieldValue(
          value: 'Cebu City',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.province: const KycOcrFieldValue(
          value: 'Cebu',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.zipCode: const KycOcrFieldValue(
          value: '6000',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.idNumber: const KycOcrFieldValue(
          value: 'P1234567',
          confidence: KycOcrConfidence.high,
        ),
        KycOcrField.idExpiryDate: const KycOcrFieldValue(
          value: '2030-01-01',
          confidence: KycOcrConfidence.review,
        ),
      },
    );
  }

  @override
  Future<void> close() async {}
}

class _PartialOcrService implements KycOcrService {
  @override
  Future<KycOcrResult> scan({
    required dto.IdType idType,
    required String imagePath,
  }) async {
    return KycOcrResult(
      idType: idType,
      status: KycOcrResultStatus.partial,
      fields: {
        KycOcrField.firstName: const KycOcrFieldValue(
          value: 'Juan',
          confidence: KycOcrConfidence.review,
        ),
        KycOcrField.lastName: const KycOcrFieldValue(
          value: 'Dela Cruz',
          confidence: KycOcrConfidence.review,
        ),
      },
    );
  }

  @override
  Future<void> close() async {}
}

void main() {
  testWidgets('partial OCR identity step shows only missing fields', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        kycOcrServiceProvider.overrideWithValue(_PartialOcrService()),
      ],
    );
    addTearDown(container.dispose);
    final keepAlive = container.listen(kycFormControllerProvider, (_, _) {});
    addTearDown(keepAlive.close);
    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.scanId);
    controller.setIdType(dto.IdType.passport);
    controller.setIdFrontImage('front.jpg');
    await controller.scanId();
    controller.applyOcrReview();

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const KycFormScreen(initialStep: 4),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basic Identity'), findsOneWidget);
    expect(find.text('First name *'), findsNothing);
    expect(find.text('Last name *'), findsNothing);
    expect(find.text('Date of Birth *'), findsOneWidget);
    expect(find.text('Nationality *'), findsOneWidget);
  });

  testWidgets('reviewed OCR draft persists without duplicate identity step', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [
        barangaysProvider.overrideWith(_TestBarangays.new),
        kycOcrServiceProvider.overrideWithValue(_CompleteOcrService()),
      ],
    );
    addTearDown(container.dispose);
    final keepAlive = container.listen(kycFormControllerProvider, (_, _) {});
    addTearDown(keepAlive.close);
    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.scanId);
    controller.setIdType(dto.IdType.passport);
    controller.setIdFrontImage('front.jpg');
    await controller.scanId();
    controller.setOcrReviewValue(KycOcrField.firstName, 'Corrected Juan');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const KycFormScreen(initialStep: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
    );
    await tester.pumpAndSettle();

    final state = container.read(kycFormControllerProvider);
    expect(state.firstName, 'Corrected Juan');
    expect(state.lastName, 'Dela Cruz');
    expect(state.dateOfBirth, DateTime(1990, 1, 1));
    expect(state.idNumber, 'P1234567');
    expect(state.streetBarangay, '123 Mabini Street, Cebu City');
    expect(state.cityMunicipality, 'Cebu City');
    expect(state.province, 'Cebu');
    expect(state.zipCode, '6000');
    expect(state.isIdentityDraftComplete, isTrue);
    expect(state.ocrReviewConfirmed, isTrue);
    expect(state.scanIdentityStepRequired, isFalse);

    expect(find.text('Contact Info'), findsOneWidget);
    expect(find.text('Basic Identity'), findsNothing);
  });

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

    expect(find.byType(Stepper), findsNothing);
    expect(find.text('Choose how to verify'), findsOneWidget);

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
    );
    await tester.pump();

    expect(find.byType(Stepper), findsNothing);
    expect(find.text('Choose how to verify'), findsNWidgets(2));
  });

  testWidgets('manual choice goes straight to identity fields without OCR', (
    tester,
  ) async {
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

    expect(find.text('Choose how to verify'), findsOneWidget);
    expect(find.text('Scan an ID'), findsOneWidget);
    expect(find.text('Enter details manually'), findsOneWidget);

    await tester.tap(find.text('Enter details manually').first);
    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
    );
    await tester.pump();

    expect(find.text('Basic Identity'), findsOneWidget);
    expect(find.text('Reading your ID on this device…'), findsNothing);
  });

  testWidgets(
    'scan choice selects ID type before capture and identity fields',
    (tester) async {
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

      await tester.tap(find.text('Scan an ID').first);
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
      );
      await tester.pump();
      expect(find.text('ID Type *'), findsOneWidget);
      expect(find.text('First name *'), findsNothing);

      await tester.tap(find.byType(DropdownButtonFormField<dto.IdType>));
      await tester.pump();
      await tester.tap(find.text('Passport').last);
      await tester.pumpAndSettle();
      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
      );
      await tester.pump();

      expect(find.textContaining('ID Front Photo'), findsOneWidget);
      expect(find.text('First name *'), findsNothing);
    },
  );

  testWidgets('uploaded image remove control removes only that image', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.manual);
    controller.setIdType(dto.IdType.driversLicense);
    controller.setIdFrontImage('front.jpg');
    controller.setIdBackImage('back.jpg');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const KycFormScreen(initialStep: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byTooltip('Remove'), findsNWidgets(2));
    await tester.tap(find.byTooltip('Remove').first);
    await tester.pump();

    final state = container.read(kycFormControllerProvider);
    expect(state.idFrontImagePath, isNull);
    expect(state.idBackImagePath, 'back.jpg');
    expect(find.byTooltip('Remove'), findsOneWidget);
    expect(find.byIcon(Icons.add_a_photo_outlined), findsOneWidget);
  });

  testWidgets('ID types requiring a back side keep both capture slots', (
    tester,
  ) async {
    final container = ProviderContainer();
    addTearDown(container.dispose);
    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.manual);
    controller.setIdType(dto.IdType.driversLicense);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const KycFormScreen(initialStep: 5),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('ID Front Photo *'), findsOneWidget);
    expect(find.text('ID Back Photo *'), findsOneWidget);
  });

  testWidgets(
    'resubmission confirmation uses the compact confirmation surface',
    (tester) async {
      final container = ProviderContainer(
        overrides: [barangaysProvider.overrideWith(_TestBarangays.new)],
      );
      addTearDown(container.dispose);
      final keepAlive = container.listen(kycFormControllerProvider, (_, _) {});
      addTearDown(keepAlive.close);
      final controller = container.read(kycFormControllerProvider.notifier);

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const KycFormScreen(
              isResubmission: true,
              existingKyc: KycStatusEntity(
                status: domain.KycVerificationStatus.resubmitRequested,
                firstName: 'Juan',
                lastName: 'Dela Cruz',
                sex: domain.Sex.male,
                nationality: 'Filipino',
                civilStatus: domain.CivilStatus.single,
                email: 'juan@example.com',
                mobileNumber: '09171234567',
                streetBarangay: 'Main Street, San Vicente',
                cityMunicipality: 'Urdaneta',
                province: 'Pangasinan',
                idType: domain.IdType.passport,
                idNumber: 'P1234567',
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      controller.setDateOfBirth(DateTime(1990, 1, 1));
      controller.setIdFrontImage('front.jpg');
      controller.setSelfieImage('selfie.jpg');
      controller.setDeclarationAccepted(true);
      await tester.pump();

      for (var i = 0; i < 6; i++) {
        await tester.tap(
          find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
        );
        await tester.pumpAndSettle();
      }

      await tester.tap(
        find.widgetWithText(ElevatedButton, 'Correct & Resubmit').hitTestable(),
      );
      await tester.pumpAndSettle();

      expect(find.byType(AlertDialog), findsNothing);
      expect(find.text('Confirm & submit'), findsNWidgets(2));
      expect(
        find.text('Review the feedback and resubmit with corrected documents'),
        findsOneWidget,
      );
      expect(find.text('Confirm'), findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
    },
  );

  testWidgets('resubmission opens preserved values in manual flow', (
    tester,
  ) async {
    await tester.pumpWidget(
      ProviderScope(
        overrides: [barangaysProvider.overrideWith(_TestBarangays.new)],
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: KycFormScreen(
            isResubmission: true,
            existingKyc: const KycStatusEntity(
              status: domain.KycVerificationStatus.resubmitRequested,
              firstName: 'Juan',
              lastName: 'Dela Cruz',
              idType: domain.IdType.passport,
              idNumber: 'P1234567',
              rejectionReason: 'Retake the ID photo',
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Basic Identity'), findsOneWidget);
    expect(find.text('Retake the ID photo'), findsOneWidget);
    expect(find.widgetWithText(TextFormField, 'Juan'), findsOneWidget);
  });

  testWidgets('outside-Urdaneta address remains valid KYC address data', (
    tester,
  ) async {
    final container = ProviderContainer(
      overrides: [barangaysProvider.overrideWith(_TestBarangays.new)],
    );
    addTearDown(container.dispose);
    final keepAlive = container.listen(kycFormControllerProvider, (_, _) {});
    addTearDown(keepAlive.close);
    final controller = container.read(kycFormControllerProvider.notifier);
    controller.setVerificationMethod(KycVerificationMethod.manual);
    controller.setFirstName('Juan');
    controller.setLastName('Citizen');
    controller.setDateOfBirth(DateTime(1990, 1, 1));
    controller.setNationality('Filipino');
    controller.setEmail('juan@example.com');
    controller.setMobileNumber('9171234567');
    controller.setStreetBarangay('123 Mabini Street, Barangay San Antonio');
    controller.setCityMunicipality('Quezon City');
    controller.setProvince('Metro Manila');
    controller.setIdType(dto.IdType.passport);
    controller.setIdNumber('P1234567');

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const KycFormScreen(initialStep: 3),
        ),
      ),
    );
    await tester.pumpAndSettle();

    await tester.tap(
      find.widgetWithText(ElevatedButton, 'Continue').hitTestable(),
    );
    await tester.pump();

    expect(find.text('ID Type *'), findsOneWidget);
    expect(
      container.read(kycFormControllerProvider).streetBarangay,
      '123 Mabini Street, Barangay San Antonio',
    );
  });
}

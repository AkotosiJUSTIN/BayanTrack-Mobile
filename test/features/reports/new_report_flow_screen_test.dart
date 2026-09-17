import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_controller.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_details_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_location_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_photos_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_review_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/quick_report_geo.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/report_flow_widgets.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:mocktail/mocktail.dart';

class _TestMunicipalities extends Municipalities {
  @override
  FutureOr<List<MunicipalityModel>> build() => const [
    bundledUrdanetaMunicipality,
  ];
}

class _TestMunicipalityBarangays extends MunicipalityBarangays {
  @override
  FutureOr<List<BarangayModel>> build(String municipalityId) =>
      bundledUrdanetaBarangays;
}

class _AuthRepositoryMock extends Mock implements AuthRepository {}

class _ReviewReportController extends NewReportController {
  @override
  NewReportState build() => const NewReportState(
    description: 'Blocked road',
    municipalityId: 'urdaneta',
    cityMunicipality: 'Urdaneta',
    province: 'Pangasinan',
    barangayId: 'bactad_east',
    barangay: 'Bactad East',
    zone: 'Bactad East',
    streetLandmark: 'Public Market',
    latitude: 15.979204,
    longitude: 120.622210,
    location: 'Phone GPS',
    landmarkLookupCompleted: true,
  );
}

Position _position(double latitude, double longitude) => Position(
  latitude: latitude,
  longitude: longitude,
  timestamp: DateTime(2026, 7, 19),
  accuracy: 5,
  altitude: 0,
  altitudeAccuracy: 0,
  heading: 0,
  headingAccuracy: 0,
  speed: 0,
  speedAccuracy: 0,
);

Widget _app(
  Widget child, {
  required ThemeData theme,
  AuthRepository? authRepository,
}) {
  return ProviderScope(
    overrides: [
      userPermissionsProvider.overrideWithValue(UserPermissions(null)),
      municipalitiesProvider.overrideWith(_TestMunicipalities.new),
      municipalityBarangaysProvider.overrideWith(
        _TestMunicipalityBarangays.new,
      ),
      if (authRepository != null)
        authRepositoryProvider.overrideWithValue(authRepository),
    ],
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      theme: theme,
      home: child,
    ),
  );
}

void main() {
  testWidgets('standard photo step has clear requirements and safe actions', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      _app(const NewReportPhotosScreen(), theme: AppTheme.light),
    );
    await tester.pump();

    expect(find.text('Step 1 of 4'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Add Photos'), findsOneWidget);
    expect(find.text('Camera'), findsOneWidget);
    expect(find.text('Gallery'), findsOneWidget);
    expect(find.text('Continue'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('standard details step remains readable at large text scale', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(
      MediaQuery(
        data: MediaQueryData(textScaler: TextScaler.linear(1.5)),
        child: _app(const NewReportDetailsScreen(), theme: AppTheme.dark),
      ),
    );
    await tester.pump();

    expect(find.text('Step 3 of 4'), findsOneWidget);
    expect(find.text('Report Details'), findsOneWidget);
    expect(find.text('Required'), findsOneWidget);
    expect(find.text('Optional'), findsNWidgets(2));
    expect(find.text('Continue to Review'), findsOneWidget);
    expect(find.text('Urdaneta City'), findsOneWidget);
    expect(find.byKey(const Key('full-report-city')), findsOneWidget);
    expect(find.byKey(const Key('full-report-barangay')), findsOneWidget);
    expect(find.byType(DropdownButtonFormField<String>), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'standard location keeps city fixed and refreshes barangay from pin',
    (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final auth = _AuthRepositoryMock();
      when(
        () => auth.getNearbyLandmarks(
          latitude: any(named: 'latitude'),
          longitude: any(named: 'longitude'),
        ),
      ).thenAnswer((_) async => const Success([]));

      await tester.pumpWidget(
        _app(
          NewReportLocationScreen(
            locationOverride: () async => _position(15.979204, 120.622210),
          ),
          theme: AppTheme.light,
          authRepository: auth,
        ),
      );
      await tester.pump();
      await tester.pump();
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pump(const Duration(milliseconds: 100));

      expect(find.text('Urdaneta City'), findsOneWidget);
      expect(find.byType(DropdownButtonFormField<String>), findsNothing);
      expect(find.text('Barangay: Bactad East'), findsOneWidget);

      await tester.tap(find.text('Manual Pin'));
      await tester.pump();
      final onMapTap = tester
          .widget<FlutterMap>(find.byType(FlutterMap))
          .options
          .onTap!;
      onMapTap(
        const TapPosition(Offset.zero, Offset.zero),
        const LatLng(15.9763, 120.5776),
      );
      await tester.pump();
      await tester.pump();

      expect(find.text('Barangay: Bactad East'), findsNothing);
      expect(find.text('Barangay: Bayaoas'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'review shows derived location values as read-only confirmation',
    (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            municipalitiesProvider.overrideWith(_TestMunicipalities.new),
            municipalityBarangaysProvider.overrideWith(
              _TestMunicipalityBarangays.new,
            ),
            newReportControllerProvider.overrideWith(
              _ReviewReportController.new,
            ),
          ],
          child: MaterialApp(
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            theme: AppTheme.light,
            home: const NewReportReviewScreen(),
          ),
        ),
      );
      await tester.pump();

      expect(find.text('Urdaneta City'), findsOneWidget);
      expect(find.text('Bactad East'), findsOneWidget);
      expect(find.text('Public Market'), findsOneWidget);
      expect(find.text('15.979204, 120.622210'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('review summary does not guess among landmark choices', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: ReportLocationSummary(
              city: 'Urdaneta City',
              landmarkLookupCompleted: true,
              landmarkSuggestions: ['Clinic', 'Market'],
            ),
          ),
        ),
      ),
    );
    await tester.pump();

    expect(find.text(chooseNearbyLandmark), findsOneWidget);
    expect(find.text(noNearbyLandmarkFound), findsNothing);
    expect(find.text('Clinic'), findsOneWidget);
    expect(find.text('Market'), findsOneWidget);
  });
}

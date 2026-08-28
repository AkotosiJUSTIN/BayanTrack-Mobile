import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_details_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/new_report/new_report_photos_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

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

Widget _app(Widget child, {required ThemeData theme}) {
  return ProviderScope(
    overrides: [
      userPermissionsProvider.overrideWithValue(UserPermissions(null)),
      municipalitiesProvider.overrideWith(_TestMunicipalities.new),
      municipalityBarangaysProvider.overrideWith(
        _TestMunicipalityBarangays.new,
      ),
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
    expect(find.text('Required'), findsNWidgets(2));
    expect(find.text('Optional'), findsNWidgets(2));
    expect(find.text('Continue to Review'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

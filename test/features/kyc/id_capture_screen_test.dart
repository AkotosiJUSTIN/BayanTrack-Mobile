import 'package:bayantrack_mobile/features/kyc/presentation/id_capture_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _app({required IdCaptureSide side, ThemeData? theme}) {
  return MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    theme: theme,
    home: IdCaptureScreen(side: side, cameraLoader: () async => const []),
  );
}

void main() {
  testWidgets('renders guide copy and accessible controls', (tester) async {
    tester.view.physicalSize = const Size(360, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(side: IdCaptureSide.front));
    await tester.pump();

    expect(find.byKey(const ValueKey('id-capture-guide')), findsOneWidget);
    expect(find.text('Fit your ID inside the frame'), findsOneWidget);
    expect(find.text('Keep it flat and readable'), findsOneWidget);
    expect(find.byTooltip('Back'), findsOneWidget);
    expect(find.byTooltip('Take Photo'), findsOneWidget);
    expect(tester.getSize(find.byTooltip('Back')), const Size(48, 48));
    expect(tester.getSize(find.byTooltip('Take Photo')), const Size(64, 64));
  });

  testWidgets('keeps front and back capture variants labeled', (tester) async {
    await tester.pumpWidget(_app(side: IdCaptureSide.front));
    await tester.pump();
    expect(find.text('ID Front Photo'), findsOneWidget);

    await tester.pumpWidget(_app(side: IdCaptureSide.back));
    await tester.pump();
    expect(find.text('ID Back Photo'), findsOneWidget);
  });

  testWidgets('renders without layout errors on compact landscape view', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(844, 390);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(_app(side: IdCaptureSide.back));
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byKey(const ValueKey('id-capture-guide')), findsOneWidget);
  });

  testWidgets('keeps controls readable in dark theme', (tester) async {
    await tester.pumpWidget(
      _app(
        side: IdCaptureSide.front,
        theme: ThemeData.dark(useMaterial3: true),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.text('Fit your ID inside the frame'), findsOneWidget);
    expect(find.byTooltip('Take Photo'), findsOneWidget);
  });
}

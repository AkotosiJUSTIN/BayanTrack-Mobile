import 'dart:async';
import 'dart:io';
import 'dart:ui' as ui;

import 'package:bayantrack_mobile/core/providers/connectivity_provider.dart';
import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/app_updates/domain/app_version.dart';
import 'package:bayantrack_mobile/features/app_updates/presentation/app_update_controller.dart';
import 'package:bayantrack_mobile/features/app_updates/presentation/app_update_gate.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app_update_fakes.dart';

class _Connectivity extends ConnectivityNotifier {
  @override
  bool build() => true;
  @override
  void setOnline(bool value) => state = value;
}

Future<ProviderContainer> pumpApp(
  WidgetTester tester,
  FakeAppUpdateRepository repository, {
  Future<bool> Function()? openReleases,
  String language = 'en',
  double textScale = 1,
  VoidCallback? onContinue,
  ThemeData? theme,
}) async {
  SharedPreferences.setMockInitialValues({});
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      sharedPrefsProvider.overrideWithValue(preferences),
      appUpdateRepositoryProvider.overrideWithValue(repository),
      isOnlineProvider.overrideWith(_Connectivity.new),
      if (openReleases != null)
        openAppReleasesProvider.overrideWithValue(openReleases),
    ],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: RepaintBoundary(
        key: const Key('update-preview'),
        child: MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: theme ?? AppTheme.light,
          locale: Locale(language),
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          builder: (context, child) => MediaQuery(
            data: MediaQuery.of(
              context,
            ).copyWith(textScaler: TextScaler.linear(textScale)),
            child: AppUpdateGate(child: child!),
          ),
          home: Scaffold(
            appBar: AppBar(
              title: const Text('Home'),
              actions: const [AppVersionCheckButton()],
            ),
            body: TextButton(
              key: const Key('continue'),
              onPressed: onContinue ?? () {},
              child: const Text('Continue'),
            ),
          ),
        ),
      ),
    ),
  );
  await tester.pump();
  return container;
}

void main() {
  testWidgets('startup remains unobstructed while a check is pending', (
    tester,
  ) async {
    final pending = Completer<AppVersion>();
    await pumpApp(
      tester,
      FakeAppUpdateRepository()..nextLatest = pending.future,
    );
    expect(find.byType(AppVersionDialog), findsNothing);
    expect(find.text('Continue'), findsOneWidget);
    pending.complete(AppVersion('1.0.0', 1004));
    await tester.pumpAndSettle();
    expect(find.byType(AppVersionDialog), findsNothing);
  });

  testWidgets('required prompt survives outside tap, Back and pushed routes', (
    tester,
  ) async {
    var continued = 0;
    var opens = 0;
    await pumpApp(
      tester,
      FakeAppUpdateRepository()..latest = AppVersion('1.0.0', 1005),
      onContinue: () => continued++,
      openReleases: () async {
        opens++;
        return true;
      },
    );
    await tester.pumpAndSettle();
    expect(find.text('Update required'), findsOneWidget);
    expect(find.text('Close'), findsNothing);
    await tester.tapAt(const Offset(10, 10));
    await tester.tap(find.byKey(const Key('continue')), warnIfMissed: false);
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
    expect(continued, 0);
    expect(find.text('Update required'), findsOneWidget);

    final navigator = tester.state<NavigatorState>(find.byType(Navigator));
    unawaited(
      navigator.push(
        MaterialPageRoute<void>(
          builder: (_) => const Scaffold(body: Text('Another route')),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Update required'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-update-download')));
    await tester.pumpAndSettle();
    expect(opens, 1);
    expect(find.text('Update required'), findsOneWidget);
  });

  testWidgets('browser failure stays retryable without dismissing the block', (
    tester,
  ) async {
    var opens = 0;
    await pumpApp(
      tester,
      FakeAppUpdateRepository()..latest = AppVersion('1.0.0', 1005),
      openReleases: () async {
        opens++;
        if (opens == 1) throw StateError('No browser');
        return true;
      },
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-update-download')));
    await tester.pumpAndSettle();
    expect(find.textContaining('could not be opened'), findsOneWidget);
    await tester.tap(find.byKey(const Key('app-update-download')));
    await tester.pumpAndSettle();
    expect(opens, 2);
    expect(find.textContaining('could not be opened'), findsNothing);
  });

  testWidgets('manual check confirms installed and latest versions', (
    tester,
  ) async {
    final repository = FakeAppUpdateRepository();
    await pumpApp(tester, repository);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-version-check')));
    await tester.pumpAndSettle();
    expect(find.text('Your app is up to date.'), findsOneWidget);
    expect(find.text('Installed: 1.0.0+1004'), findsOneWidget);
    expect(find.text('Latest release: 1.0.0+1004'), findsOneWidget);
    expect(repository.checks, 2);
    await tester.tap(find.text('Close'));
    await tester.pumpAndSettle();
    expect(find.byType(AppVersionDialog), findsNothing);
  });

  testWidgets('manual failure reports unknown and retry can recover', (
    tester,
  ) async {
    final repository = FakeAppUpdateRepository()..unavailable = true;
    await pumpApp(tester, repository);
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(const Key('app-version-check')));
    await tester.pumpAndSettle();
    expect(find.text('Your app is up to date.'), findsNothing);
    expect(find.textContaining('could not be checked'), findsOneWidget);
    repository.unavailable = false;
    await tester.tap(find.text('Try again'));
    await tester.pumpAndSettle();
    expect(find.text('Your app is up to date.'), findsOneWidget);
  });

  testWidgets('resume and reconnect recheck without duplicate prompts', (
    tester,
  ) async {
    final repository = FakeAppUpdateRepository();
    final container = await pumpApp(tester, repository);
    await tester.pumpAndSettle();
    repository.latest = AppVersion('1.0.0', 1005);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(repository.checks, 2);
    expect(find.text('Update required'), findsOneWidget);
    final connectivity =
        container.read(isOnlineProvider.notifier) as _Connectivity;
    connectivity.setOnline(false);
    connectivity.setOnline(true);
    await tester.pumpAndSettle();
    expect(repository.checks, 3);
    expect(find.text('Update required'), findsOneWidget);
  });

  for (final language in ['en', 'fil']) {
    testWidgets('required prompt fits $language on a small phone at 2x text', (
      tester,
    ) async {
      tester.view.physicalSize = const Size(320, 568);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await pumpApp(
        tester,
        FakeAppUpdateRepository()..latest = AppVersion('1.0.0', 1005),
        language: language,
        textScale: 2,
      );
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('app-update-download')), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  }

  const previewDirectory = String.fromEnvironment('UPDATE_UI_PREVIEW_DIR');
  if (previewDirectory.isNotEmpty) {
    testWidgets('captures required-update phone preview', (tester) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);
      await tester.runAsync(() async {
        final font = FontLoader('UpdatePreview')
          ..addFont(
            File(
              'C:/Windows/Fonts/segoeui.ttf',
            ).readAsBytes().then((bytes) => ByteData.sublistView(bytes)),
          );
        await font.load();
        final icons = FontLoader('MaterialIcons')
          ..addFont(rootBundle.load('fonts/MaterialIcons-Regular.otf'));
        await icons.load();
      });
      await pumpApp(
        tester,
        FakeAppUpdateRepository()..latest = AppVersion('1.0.0', 213456789),
        theme: AppTheme.light.copyWith(
          textTheme: AppTheme.light.textTheme.apply(
            fontFamily: 'UpdatePreview',
          ),
          primaryTextTheme: AppTheme.light.primaryTextTheme.apply(
            fontFamily: 'UpdatePreview',
          ),
          appBarTheme: AppTheme.light.appBarTheme.copyWith(
            titleTextStyle: AppTheme.light.appBarTheme.titleTextStyle?.copyWith(
              fontFamily: 'UpdatePreview',
            ),
          ),
          filledButtonTheme: FilledButtonThemeData(
            style: AppTheme.light.filledButtonTheme.style?.copyWith(
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontFamily: 'UpdatePreview', fontSize: 16),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: AppTheme.light.textButtonTheme.style?.copyWith(
              textStyle: const WidgetStatePropertyAll(
                TextStyle(fontFamily: 'UpdatePreview', fontSize: 14),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      final boundary = tester.renderObject<RenderRepaintBoundary>(
        find.byKey(const Key('update-preview')),
      );
      await tester.runAsync(() async {
        final image = await boundary.toImage(pixelRatio: 2);
        final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
        final file = File('$previewDirectory/update-required.png');
        await file.parent.create(recursive: true);
        await file.writeAsBytes(bytes!.buffer.asUint8List());
        image.dispose();
      });
      expect(tester.takeException(), isNull);
    });
  }
}

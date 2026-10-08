import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/navigation/main_navigation_shell.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

class _CountingScreen extends StatefulWidget {
  const _CountingScreen({required this.onInit});

  final VoidCallback onInit;

  @override
  State<_CountingScreen> createState() => _CountingScreenState();
}

class _CountingScreenState extends State<_CountingScreen> {
  @override
  void initState() {
    super.initState();
    widget.onInit();
  }

  @override
  Widget build(BuildContext context) => const SizedBox.shrink();
}

void main() {
  testWidgets('center report FAB keeps the curved bottom navigation surface', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
          sharedPrefsProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: const MainNavigationShell(screens: [SizedBox.shrink()]),
        ),
      ),
    );
    await tester.pump();

    final bottomBar = tester.widget<BottomAppBar>(find.byType(BottomAppBar));
    final fab = tester.widget<FloatingActionButton>(
      find.byType(FloatingActionButton),
    );
    final shell = tester.widget<Scaffold>(find.byType(Scaffold).first);

    expect(shell.resizeToAvoidBottomInset, isFalse);
    expect(bottomBar.shape, isA<CircularNotchedRectangle>());
    expect(bottomBar.notchMargin, 7);
    expect(bottomBar.color, AppTheme.light.colorScheme.surface);
    expect(fab.elevation, 4);
  });

  testWidgets(
    'center report FAB keeps the curved surface treatment in dark mode',
    (tester) async {
      SharedPreferences.setMockInitialValues({});
      final preferences = await SharedPreferences.getInstance();
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            sharedPrefsProvider.overrideWithValue(preferences),
          ],
          child: MaterialApp(
            theme: AppTheme.dark,
            supportedLocales: AppLocalizations.supportedLocales,
            localizationsDelegates: AppLocalizations.localizationsDelegates,
            home: const MainNavigationShell(screens: [SizedBox.shrink()]),
          ),
        ),
      );
      await tester.pump();

      final bottomBar = tester.widget<BottomAppBar>(find.byType(BottomAppBar));
      final fab = tester.widget<FloatingActionButton>(
        find.byType(FloatingActionButton),
      );

      expect(bottomBar.shape, isA<CircularNotchedRectangle>());
      expect(bottomBar.notchMargin, 7);
      expect(bottomBar.color, AppTheme.dark.colorScheme.surface);
      expect(fab.elevation, 4);
    },
  );

  testWidgets('defers hidden tab initialization until first visit', (
    tester,
  ) async {
    SharedPreferences.setMockInitialValues({});
    final preferences = await SharedPreferences.getInstance();
    final initCounts = List<int>.filled(4, 0);
    final screens = [
      for (var index = 0; index < initCounts.length; index++)
        _CountingScreen(onInit: () => initCounts[index]++),
    ];

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
          sharedPrefsProvider.overrideWithValue(preferences),
        ],
        child: MaterialApp(
          theme: AppTheme.light,
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          home: MainNavigationShell(screens: screens),
        ),
      ),
    );
    await tester.pump();

    expect(initCounts, [1, 0, 0, 0]);
    await tester.tap(find.text('Notifications'));
    await tester.pump();
    expect(initCounts, [1, 0, 1, 0]);
  });
}

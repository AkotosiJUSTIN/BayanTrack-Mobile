import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/navigation/main_navigation_shell.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
}

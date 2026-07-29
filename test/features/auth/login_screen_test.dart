import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:bayantrack_mobile/features/auth/presentation/login_screen.dart';
import 'package:bayantrack_mobile/features/auth/presentation/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

const _brandBlue = Color(0xFF064BEE);
const _mascotAsset = 'assets/images/auth/login_mascot.webp';

void main() {
  testWidgets('shows Login-only Bantay layout in required order', (
    tester,
  ) async {
    await _pumpLogin(tester, const Size(390, 844));

    final illustration = tester.widget<Image>(
      find.byKey(const ValueKey('login-illustration')),
    );
    expect((illustration.image as AssetImage).assetName, _mascotAsset);
    expect(illustration.semanticLabel, 'Bantay waving');
    expect(illustration.fit, BoxFit.contain);

    expect(find.text('Welcome Back!'), findsOneWidget);
    expect(find.text('Sign in to continue'), findsOneWidget);
    expect(find.text('Welcome Back'), findsNothing);
    expect(find.text('Sign in to continue reporting'), findsNothing);
    expect(find.text('BayanTrack'), findsNothing);
    expect(
      find.text('Watching over communities, supporting local action.'),
      findsNothing,
    );

    final orderedFinders = [
      find.byKey(const ValueKey('login-illustration')),
      find.byKey(const ValueKey('login-welcome')),
      find.byKey(const ValueKey('login-subtitle')),
      find.byKey(const ValueKey('login-email-field')),
      find.byKey(const ValueKey('login-password-field')),
      find.byKey(const ValueKey('login-forgot-button')),
      find.byKey(const ValueKey('login-submit-button')),
      find.byKey(const ValueKey('login-register-button')),
    ];
    final verticalCenters = orderedFinders
        .map((finder) => tester.getCenter(finder).dy)
        .toList();
    expect(verticalCenters, orderedEquals([...verticalCenters]..sort()));

    final submit = tester.widget<ElevatedButton>(
      find.byKey(const ValueKey('login-submit-button')),
    );
    expect(submit.style?.backgroundColor?.resolve({}), _brandBlue);
    expect(
      tester
          .widget<Scaffold>(find.byKey(const ValueKey('login-scaffold')))
          .backgroundColor,
      AppColors.lightBackground,
    );
    expect(tester.takeException(), isNull);
  });

  for (final configuration in [
    for (final brightness in [Brightness.light, Brightness.dark])
      for (final size in [const Size(320, 568), const Size(390, 844)])
        for (final textScale in [1.0, 2.0])
          (brightness: brightness, size: size, textScale: textScale),
  ]) {
    testWidgets('scrolls without overflow at '
        '${configuration.size.width.toInt()}x'
        '${configuration.size.height.toInt()}, '
        '${configuration.textScale}x, '
        '${configuration.brightness.name}', (tester) async {
      await _pumpLogin(
        tester,
        configuration.size,
        brightness: configuration.brightness,
        textScale: configuration.textScale,
      );

      expect(tester.takeException(), isNull);
      await tester.ensureVisible(
        find.byKey(const ValueKey('login-register-button')),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      final expectedBackground = configuration.brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground;
      expect(
        tester
            .widget<Scaffold>(find.byKey(const ValueKey('login-scaffold')))
            .backgroundColor,
        expectedBackground,
      );
    });
  }

  testWidgets('stays scrollable when keyboard reduces viewport', (
    tester,
  ) async {
    await _pumpLogin(tester, const Size(320, 568), viewInset: 260);

    final scrollView = tester.widget<SingleChildScrollView>(
      find.byKey(const ValueKey('login-scroll')),
    );
    expect(
      scrollView.keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
    await tester.ensureVisible(
      find.byKey(const ValueKey('login-register-button')),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('keeps labels, touch targets, validation, and password toggle', (
    tester,
  ) async {
    await _pumpLogin(tester, const Size(390, 844));

    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel('Bantay waving'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Email')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('Password')), findsWidgets);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('login-password-toggle')),
          )
          .tooltip,
      'Show password',
    );

    for (final key in [
      'login-password-toggle',
      'login-forgot-button',
      'login-submit-button',
      'login-register-button',
    ]) {
      expect(
        tester.getSize(find.byKey(ValueKey(key))).height,
        greaterThanOrEqualTo(44),
      );
    }

    final passwordField = find.byKey(const ValueKey('login-password-field'));
    final passwordInput = find.descendant(
      of: passwordField,
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);
    await tester.tap(find.byKey(const ValueKey('login-password-toggle')));
    await tester.pump();
    expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);
    expect(
      tester
          .widget<IconButton>(
            find.byKey(const ValueKey('login-password-toggle')),
          )
          .tooltip,
      'Hide password',
    );

    await tester.tap(find.byKey(const ValueKey('login-submit-button')));
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);
    expect(find.text('Password is required'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('preserves Forgot Password and Register navigation', (
    tester,
  ) async {
    final observer = _RecordingNavigatorObserver();
    await _pumpLogin(tester, const Size(390, 844), navigatorObserver: observer);

    tester
        .widget<TextButton>(find.byKey(const ValueKey('login-forgot-button')))
        .onPressed!();
    expect(
      (observer.lastPushed as MaterialPageRoute).builder(
        tester.element(find.byType(LoginScreen)),
      ),
      isA<ForgotPasswordScreen>(),
    );

    Navigator.of(tester.element(find.byType(LoginScreen))).pop();
    tester
        .widget<TextButton>(find.byKey(const ValueKey('login-register-button')))
        .onPressed!();
    expect(
      (observer.lastPushed as MaterialPageRoute).builder(
        tester.element(find.byType(LoginScreen)),
      ),
      isA<RegisterScreen>(),
    );
  });

  testWidgets('keeps loading state inside disabled Login controls', (
    tester,
  ) async {
    await _pumpLogin(
      tester,
      const Size(390, 844),
      authState: const AuthLoading(),
    );

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('login-email-field')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('login-password-field')),
          )
          .enabled,
      isFalse,
    );
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const ValueKey('login-submit-button')),
          )
          .onPressed,
      isNull,
    );
    expect(find.bySemanticsLabel('Logging in'), findsOneWidget);
  });
}

Future<void> _pumpLogin(
  WidgetTester tester,
  Size size, {
  AuthState authState = const AuthIdle(),
  Brightness brightness = Brightness.light,
  double textScale = 1,
  double viewInset = 0,
  NavigatorObserver? navigatorObserver,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

  await tester.pumpWidget(
    ProviderScope(
      overrides: [authControllerProvider.overrideWithValue(authState)],
      child: MaterialApp(
        navigatorObservers: [?navigatorObserver],
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              textScaler: TextScaler.linear(textScale),
              viewInsets: EdgeInsets.only(bottom: viewInset),
            ),
            child: child!,
          );
        },
        home: const LoginScreen(),
      ),
    ),
  );
  await tester.pump();
}

class _RecordingNavigatorObserver extends NavigatorObserver {
  Route<dynamic>? lastPushed;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    lastPushed = route;
    super.didPush(route, previousRoute);
  }
}

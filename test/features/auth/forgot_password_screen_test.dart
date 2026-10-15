import 'dart:async';

import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/providers/theme_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/forgot_password_screen.dart';
import 'package:bayantrack_mobile/features/auth/presentation/login_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _mascotAsset = 'assets/images/auth/forgot_password_mascot.webp';
const _otpMascotAsset = 'assets/images/auth/check_otp_mascot.webp';
const _passwordMascotAsset = 'assets/images/auth/change_password_mascot.webp';

class _AuthRepositoryMock extends Mock implements AuthRepository {}

void main() {
  testWidgets('shows the Forgot Password layout in required order', (
    tester,
  ) async {
    await _pumpForgot(tester);

    final illustration = tester.widget<Image>(
      find.byKey(const ValueKey('forgot-password-illustration')),
    );
    expect((illustration.image as AssetImage).assetName, _mascotAsset);
    expect(illustration.fit, BoxFit.contain);
    expect(illustration.excludeFromSemantics, isTrue);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('forgot-password-illustration')))
          .height,
      190,
    );

    expect(find.text('Reset Password'), findsNothing);
    expect(find.text('Forgot Password'), findsOneWidget);
    expect(
      find.text('Enter your email to receive a verification code.'),
      findsOneWidget,
    );
    expect(find.text('Remember your password?'), findsOneWidget);

    final orderedFinders = [
      find.byKey(const ValueKey('forgot-password-back-button')),
      find.byKey(const ValueKey('forgot-password-illustration')),
      find.byKey(const ValueKey('forgot-password-title')),
      find.byKey(const ValueKey('forgot-password-subtitle')),
      find.byKey(const ValueKey('forgot-password-email-field')),
      find.byKey(const ValueKey('forgot-password-submit-button')),
      find.byKey(const ValueKey('forgot-password-login-button')),
    ];
    final verticalCenters = orderedFinders
        .map((finder) => tester.getCenter(finder).dy)
        .toList();
    expect(verticalCenters, orderedEquals([...verticalCenters]..sort()));

    for (final key in [
      'forgot-password-back-button',
      'forgot-password-email-field',
      'forgot-password-submit-button',
      'forgot-password-login-button',
    ]) {
      expect(
        tester.getSize(find.byKey(ValueKey(key))).height,
        greaterThanOrEqualTo(44),
      );
    }
    expect(tester.takeException(), isNull);
  });

  for (final configuration in [
    for (final brightness in [Brightness.light, Brightness.dark])
      for (final size in [const Size(320, 568), const Size(390, 844)])
        (brightness: brightness, size: size),
  ]) {
    testWidgets('does not overflow at ${configuration.size.width.toInt()}x'
        '${configuration.size.height.toInt()}, 1.5x, '
        '${configuration.brightness.name}', (tester) async {
      await _pumpForgot(
        tester,
        size: configuration.size,
        brightness: configuration.brightness,
        textScale: 1.5,
      );

      await tester.ensureVisible(
        find.byKey(const ValueKey('forgot-password-login-button')),
      );
      await tester.pump();
      expect(tester.takeException(), isNull);

      final expectedBackground = configuration.brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground;
      expect(
        tester
            .widget<Scaffold>(
              find.byKey(const ValueKey('forgot-password-scaffold')),
            )
            .backgroundColor,
        expectedBackground,
      );
    });
  }

  testWidgets('stays scrollable with keyboard and preserves accessibility', (
    tester,
  ) async {
    await _pumpForgot(
      tester,
      size: const Size(320, 568),
      textScale: 1.5,
      viewInset: 260,
    );

    expect(
      tester
          .widget<SingleChildScrollView>(
            find.byKey(const ValueKey('forgot-password-scroll')),
          )
          .keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
    final semantics = tester.ensureSemantics();
    expect(find.bySemanticsLabel(RegExp('Email')), findsWidgets);
    expect(find.bySemanticsLabel(RegExp('Bantay')), findsNothing);
    await tester.ensureVisible(
      find.byKey(const ValueKey('forgot-password-login-button')),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
    semantics.dispose();
  });

  testWidgets('keeps email validation and loading state', (tester) async {
    await _pumpForgot(tester);
    await tester.tap(
      find.byKey(const ValueKey('forgot-password-submit-button')),
    );
    await tester.pump();
    expect(find.text('Email is required'), findsOneWidget);

    await _pumpForgot(tester, authState: const AuthLoading());
    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('forgot-password-email-field')),
          )
          .enabled,
      isFalse,
    );
    expect(find.bySemanticsLabel('Sending…'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('forgot-password-submit-button')),
      findsNothing,
    );
  });

  testWidgets('Back and Login return through the existing auth wrapper', (
    tester,
  ) async {
    await _pumpForgot(tester, pushFromRoot: true);
    await tester.tap(find.byKey(const ValueKey('forgot-password-back-button')));
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);

    await _pumpForgot(tester, pushFromRoot: true);
    await tester.ensureVisible(
      find.byKey(const ValueKey('forgot-password-login-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('forgot-password-login-button')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });

  testWidgets('Send OTP uses the existing controller flow', (tester) async {
    final repository = _AuthRepositoryMock();
    when(
      () => repository.forgotPassword(any()),
    ).thenAnswer((_) async => const Success<void>(null));

    await _pumpForgot(
      tester,
      size: const Size(520, 844),
      repository: repository,
    );
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-email-field')),
      'ada@example.com',
    );
    await tester.tap(
      find.byKey(const ValueKey('forgot-password-submit-button')),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(() => repository.forgotPassword('ada@example.com')).called(1);
    expect(find.text('Enter verification code'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('forgot-password-illustration')),
      findsNothing,
    );
    await _drainToast(tester);
  });

  testWidgets('shows OTP verification layout in required order', (
    tester,
  ) async {
    final repository = _AuthRepositoryMock();
    await _pumpForgot(tester, repository: repository);
    await _advanceToOtp(tester, repository);

    final illustration = tester.widget<Image>(
      find.byKey(const ValueKey('forgot-password-otp-illustration')),
    );
    expect((illustration.image as AssetImage).assetName, _otpMascotAsset);
    expect(illustration.fit, BoxFit.contain);
    expect(illustration.excludeFromSemantics, isTrue);
    expect(
      tester
          .getSize(
            find.byKey(const ValueKey('forgot-password-otp-illustration')),
          )
          .height,
      190,
    );
    expect(find.text('Enter verification code'), findsOneWidget);
    expect(
      find.text('Enter the verification code sent to ada@example.com'),
      findsOneWidget,
    );

    _expectVerticalOrder(tester, [
      'forgot-password-recovery-back-button',
      'forgot-password-otp-illustration',
      'forgot-password-otp-title',
      'forgot-password-otp-subtitle',
      'forgot-password-otp-field',
      'forgot-password-verify-button',
      'forgot-password-resend-button',
      'forgot-password-recovery-login-button',
    ]);
    _expectMinimumTouchTargets(tester, [
      'forgot-password-recovery-back-button',
      'forgot-password-otp-field',
      'forgot-password-verify-button',
      'forgot-password-resend-button',
      'forgot-password-recovery-login-button',
    ]);
    expect(tester.takeException(), isNull);
  });

  testWidgets('shows Change Password layout and visibility controls', (
    tester,
  ) async {
    final repository = _AuthRepositoryMock();
    await _pumpForgot(tester, repository: repository);
    await _advanceToPassword(tester, repository);

    final illustration = tester.widget<Image>(
      find.byKey(const ValueKey('forgot-password-password-illustration')),
    );
    expect((illustration.image as AssetImage).assetName, _passwordMascotAsset);
    expect(illustration.fit, BoxFit.contain);
    expect(illustration.excludeFromSemantics, isTrue);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('forgot-password-password-title')),
          )
          .data,
      'Reset Password',
    );
    expect(find.text('Create your new password.'), findsOneWidget);

    _expectVerticalOrder(tester, [
      'forgot-password-recovery-back-button',
      'forgot-password-password-illustration',
      'forgot-password-password-title',
      'forgot-password-password-subtitle',
      'forgot-password-new-password-field',
      'forgot-password-confirm-password-field',
      'forgot-password-reset-button',
      'forgot-password-recovery-login-button',
    ]);
    _expectMinimumTouchTargets(tester, [
      'forgot-password-recovery-back-button',
      'forgot-password-new-password-field',
      'forgot-password-new-password-toggle',
      'forgot-password-confirm-password-field',
      'forgot-password-confirm-password-toggle',
      'forgot-password-reset-button',
      'forgot-password-recovery-login-button',
    ]);

    final passwordInput = find.descendant(
      of: find.byKey(const ValueKey('forgot-password-new-password-field')),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);
    await tester.tap(
      find.byKey(const ValueKey('forgot-password-new-password-toggle')),
    );
    await tester.pump();
    expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);
    expect(tester.takeException(), isNull);
  });

  for (final passwordStep in [false, true]) {
    for (final brightness in [Brightness.light, Brightness.dark]) {
      testWidgets(
        '${passwordStep ? 'Change Password' : 'OTP'} stays scrollable at '
        '320x568, 1.5x, ${brightness.name}',
        (tester) async {
          final repository = _AuthRepositoryMock();
          await _pumpForgot(
            tester,
            size: const Size(320, 568),
            brightness: brightness,
            textScale: 1.5,
            viewInset: 260,
            repository: repository,
          );
          if (passwordStep) {
            await _advanceToPassword(tester, repository);
            expect(tester.takeException(), isNull);
            await tester.enterText(
              find.byKey(const ValueKey('forgot-password-new-password-field')),
              'Strong1!',
            );
            expect(tester.takeException(), isNull);
          } else {
            await _advanceToOtp(tester, repository);
          }

          final scrollKey = passwordStep
              ? 'forgot-password-password-scroll'
              : 'forgot-password-otp-scroll';
          expect(
            tester
                .widget<SingleChildScrollView>(find.byKey(ValueKey(scrollKey)))
                .keyboardDismissBehavior,
            ScrollViewKeyboardDismissBehavior.onDrag,
          );
          await tester.ensureVisible(
            find.byKey(const ValueKey('forgot-password-recovery-login-button')),
          );
          await tester.pump();
          expect(tester.takeException(), isNull);

          final expectedBackground = brightness == Brightness.dark
              ? AppColors.darkBackground
              : AppColors.lightBackground;
          expect(
            tester
                .widget<Scaffold>(
                  find.byKey(
                    const ValueKey('forgot-password-recovery-scaffold'),
                  ),
                )
                .backgroundColor,
            expectedBackground,
          );
        },
      );
    }
  }

  testWidgets('OTP validation, resend, and verification stay intact', (
    tester,
  ) async {
    final repository = _AuthRepositoryMock();
    when(
      () => repository.verifyResetOtp(
        email: any(named: 'email'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer((_) async => const Success<String>('reset-token'));
    await _pumpForgot(tester, repository: repository);
    await _advanceToOtp(tester, repository);

    await _tapVisible(tester, 'forgot-password-verify-button');
    await tester.pump();
    expect(
      find.text('Enter the verification code from your email.'),
      findsOneWidget,
    );

    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-otp-field')),
      '123',
    );
    await _tapVisible(tester, 'forgot-password-verify-button');
    await tester.pump();
    expect(find.text('Enter the 6-digit verification code.'), findsOneWidget);

    await _tapVisible(tester, 'forgot-password-resend-button');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    verify(() => repository.forgotPassword('ada@example.com')).called(2);
    await _drainToast(tester);

    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-otp-field')),
      '123456',
    );
    await _tapVisible(tester, 'forgot-password-verify-button');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(
      () => repository.verifyResetOtp(email: 'ada@example.com', otp: '123456'),
    ).called(1);
    expect(
      tester
          .widget<Text>(
            find.byKey(const ValueKey('forgot-password-password-title')),
          )
          .data,
      'Reset Password',
    );
  });

  testWidgets('OTP loading disables input and actions', (tester) async {
    final repository = _AuthRepositoryMock();
    final verification = Completer<Result<String>>();
    when(
      () => repository.verifyResetOtp(
        email: any(named: 'email'),
        otp: any(named: 'otp'),
      ),
    ).thenAnswer((_) => verification.future);
    await _pumpForgot(tester, repository: repository);
    await _advanceToOtp(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-otp-field')),
      '123456',
    );
    await _tapVisible(tester, 'forgot-password-verify-button');
    await tester.pump();

    expect(
      tester
          .widget<TextFormField>(
            find.byKey(const ValueKey('forgot-password-otp-field')),
          )
          .enabled,
      isFalse,
    );
    expect(find.bySemanticsLabel('Verify Code'), findsOneWidget);
    expect(
      find.byKey(const ValueKey('forgot-password-verify-button')),
      findsNothing,
    );
    expect(
      find.byKey(const ValueKey('forgot-password-resend-button')),
      findsNothing,
    );

    verification.complete(const Success<String>('reset-token'));
    await tester.pump();
  });

  testWidgets('password validation and reset submission stay intact', (
    tester,
  ) async {
    final repository = _AuthRepositoryMock();
    when(
      () => repository.resetPassword(
        resetToken: any(named: 'resetToken'),
        newPassword: any(named: 'newPassword'),
        newPasswordConfirm: any(named: 'newPasswordConfirm'),
      ),
    ).thenAnswer((_) async => const Success<void>(null));
    await _pumpForgot(tester, repository: repository);
    await _advanceToPassword(tester, repository);

    await _tapVisible(tester, 'forgot-password-reset-button');
    await tester.pump();
    expect(find.text('Password is required'), findsOneWidget);

    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-new-password-field')),
      'Strong1!',
    );
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirm-password-field')),
      'Strong1!',
    );
    await _tapVisible(tester, 'forgot-password-reset-button');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    verify(
      () => repository.resetPassword(
        resetToken: 'reset-token',
        newPassword: 'Strong1!',
        newPasswordConfirm: 'Strong1!',
      ),
    ).called(1);
    expect(find.byType(LoginScreen), findsOneWidget);
    await _drainToast(tester);
  });

  testWidgets('password loading disables fields and toggles', (tester) async {
    final repository = _AuthRepositoryMock();
    final reset = Completer<Result<void>>();
    when(
      () => repository.resetPassword(
        resetToken: any(named: 'resetToken'),
        newPassword: any(named: 'newPassword'),
        newPasswordConfirm: any(named: 'newPasswordConfirm'),
      ),
    ).thenAnswer((_) => reset.future);
    await _pumpForgot(tester, repository: repository);
    await _advanceToPassword(tester, repository);
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-new-password-field')),
      'Strong1!',
    );
    await tester.enterText(
      find.byKey(const ValueKey('forgot-password-confirm-password-field')),
      'Strong1!',
    );
    await _tapVisible(tester, 'forgot-password-reset-button');
    await tester.pump();

    for (final key in [
      'forgot-password-new-password-field',
      'forgot-password-confirm-password-field',
    ]) {
      expect(
        tester.widget<TextFormField>(find.byKey(ValueKey(key))).enabled,
        isFalse,
      );
    }
    for (final key in [
      'forgot-password-new-password-toggle',
      'forgot-password-confirm-password-toggle',
    ]) {
      expect(
        tester.widget<IconButton>(find.byKey(ValueKey(key))).onPressed,
        isNull,
      );
    }
    expect(find.bySemanticsLabel('Change Password'), findsOneWidget);

    reset.complete(const Success<void>(null));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await _drainToast(tester);
  });

  testWidgets('recovery Back and Login navigation stay intact', (tester) async {
    final repository = _AuthRepositoryMock();
    await _pumpForgot(tester, repository: repository, pushFromRoot: true);
    await _advanceToPassword(tester, repository);

    await tester.tap(
      find.byKey(const ValueKey('forgot-password-recovery-back-button')),
    );
    await tester.pump();
    expect(find.text('Enter verification code'), findsOneWidget);

    await tester.tap(
      find.byKey(const ValueKey('forgot-password-recovery-back-button')),
    );
    await tester.pump();
    expect(find.text('Forgot Password'), findsOneWidget);

    await _advanceToOtp(tester, repository);
    await tester.ensureVisible(
      find.byKey(const ValueKey('forgot-password-recovery-login-button')),
    );
    await tester.tap(
      find.byKey(const ValueKey('forgot-password-recovery-login-button')),
    );
    await tester.pumpAndSettle();
    expect(find.byType(LoginScreen), findsOneWidget);
  });
}

Future<void> _advanceToOtp(
  WidgetTester tester,
  _AuthRepositoryMock repository,
) async {
  when(
    () => repository.forgotPassword(any()),
  ).thenAnswer((_) async => const Success<void>(null));
  await tester.enterText(
    find.byKey(const ValueKey('forgot-password-email-field')),
    'ada@example.com',
  );
  tester
      .widget<ElevatedButton>(
        find.byKey(const ValueKey('forgot-password-submit-button')),
      )
      .onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
  await _drainToast(tester);
}

Future<void> _advanceToPassword(
  WidgetTester tester,
  _AuthRepositoryMock repository,
) async {
  when(
    () => repository.verifyResetOtp(
      email: any(named: 'email'),
      otp: any(named: 'otp'),
    ),
  ).thenAnswer((_) async => const Success<String>('reset-token'));
  await _advanceToOtp(tester, repository);
  await tester.enterText(
    find.byKey(const ValueKey('forgot-password-otp-field')),
    '123456',
  );
  tester
      .widget<ElevatedButton>(
        find.byKey(const ValueKey('forgot-password-verify-button')),
      )
      .onPressed!();
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

Future<void> _tapVisible(WidgetTester tester, String key) async {
  final finder = find.byKey(ValueKey(key));
  await tester.ensureVisible(finder);
  await tester.pump();
  await tester.tap(finder);
}

Future<void> _drainToast(WidgetTester tester) async {
  await tester.pump(const Duration(seconds: 4));
  await tester.pump(const Duration(milliseconds: 300));
}

void _expectVerticalOrder(WidgetTester tester, List<String> keys) {
  final verticalCenters = keys
      .map((key) => tester.getCenter(find.byKey(ValueKey(key))).dy)
      .toList();
  expect(verticalCenters, orderedEquals([...verticalCenters]..sort()));
}

void _expectMinimumTouchTargets(WidgetTester tester, List<String> keys) {
  for (final key in keys) {
    expect(
      tester.getSize(find.byKey(ValueKey(key))).height,
      greaterThanOrEqualTo(44),
    );
  }
}

Future<void> _pumpForgot(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  double textScale = 1,
  double viewInset = 0,
  AuthState authState = const AuthIdle(),
  bool pushFromRoot = false,
  AuthRepository? repository,
}) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        sharedPrefsProvider.overrideWithValue(prefs),
        if (repository == null)
          authControllerProvider.overrideWithValue(authState)
        else
          authRepositoryProvider.overrideWithValue(repository),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        theme: AppTheme.light,
        darkTheme: AppTheme.dark,
        themeMode: brightness == Brightness.dark
            ? ThemeMode.dark
            : ThemeMode.light,
        builder: (context, child) => MediaQuery(
          data: MediaQuery.of(context).copyWith(
            textScaler: TextScaler.linear(textScale),
            viewInsets: EdgeInsets.only(bottom: viewInset),
          ),
          child: child!,
        ),
        home: pushFromRoot
            ? const Scaffold(body: Text('Login origin'))
            : const ForgotPasswordScreen(),
      ),
    ),
  );
  if (pushFromRoot) {
    unawaited(
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const ForgotPasswordScreen()),
      ),
    );
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

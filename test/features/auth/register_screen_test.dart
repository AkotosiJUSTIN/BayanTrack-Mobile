import 'dart:async';

import 'package:bayantrack_mobile/core/constants/urdaneta_barangays.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/domain/usecases/register_usecase.dart';
import 'package:bayantrack_mobile/features/auth/presentation/auth_controller.dart';
import 'package:bayantrack_mobile/features/auth/presentation/barangays_provider.dart';
import 'package:bayantrack_mobile/features/auth/presentation/register_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

const _brandBlue = Color(0xFF064BEE);
const _brandOrange = Color(0xFFF86A05);
const _mascotAsset = 'assets/images/Mascot4_waving_register.png';

class _TestBarangays extends Barangays {
  @override
  FutureOr<List<BarangayModel>> build() => bundledUrdanetaBarangays;
}

class _LoadingBarangays extends Barangays {
  @override
  Future<List<BarangayModel>> build() =>
      Completer<List<BarangayModel>>().future;
}

class _RegisterUseCaseMock extends Mock implements RegisterUseCase {}

const _user = User(
  id: 'USR-1',
  email: 'ada@example.com',
  firstName: 'Ada',
  lastName: 'Lovelace',
  role: UserRole.citizen,
);

void main() {
  testWidgets('shows compact Register layout in required order', (
    tester,
  ) async {
    await _pumpRegister(tester);

    final illustration = tester.widget<Image>(
      find.byKey(const ValueKey('register-illustration')),
    );
    expect((illustration.image as AssetImage).assetName, _mascotAsset);
    expect(illustration.semanticLabel, 'Bantay waving');
    expect(illustration.fit, BoxFit.contain);
    expect(
      tester
          .getSize(find.byKey(const ValueKey('register-illustration')))
          .height,
      inInclusiveRange(110, 150),
    );

    final orderedFinders = [
      find.byKey(const ValueKey('register-back-button')),
      find.byKey(const ValueKey('register-illustration')),
      find.byKey(const ValueKey('register-title')),
      find.byKey(const ValueKey('register-subtitle')),
      find.byKey(const ValueKey('register-first-name-field')),
      find.byKey(const ValueKey('register-last-name-field')),
      find.byKey(const ValueKey('register-email-field')),
      find.byKey(const ValueKey('register-password-field')),
      find.byKey(const ValueKey('register-confirm-password-field')),
      find.byKey(const ValueKey('register-barangay-field')),
      find.byKey(const ValueKey('register-terms-row')),
      find.byKey(const ValueKey('register-submit-button')),
      find.byKey(const ValueKey('register-login-button')),
    ];
    final verticalCenters = orderedFinders
        .map((finder) => tester.getCenter(finder).dy)
        .toList();
    expect(verticalCenters, orderedEquals([...verticalCenters]..sort()));

    expect(find.text('Create Account'), findsNWidgets(2));
    expect(find.text('Join the community of civic reporters'), findsOneWidget);
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const ValueKey('register-submit-button')),
          )
          .style
          ?.backgroundColor
          ?.resolve({}),
      _brandBlue,
    );
    expect(
      (tester
                  .widget<Container>(
                    find.byKey(const ValueKey('register-accent')),
                  )
                  .decoration
              as BoxDecoration)
          .color,
      _brandOrange,
    );
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
      await _pumpRegister(
        tester,
        size: configuration.size,
        brightness: configuration.brightness,
        textScale: 1.5,
      );

      for (final key in [
        'register-confirm-password-field',
        'register-terms-row',
        'register-submit-button',
        'register-login-button',
      ]) {
        await tester.ensureVisible(find.byKey(ValueKey(key)));
        await tester.pump();
        expect(tester.takeException(), isNull);
      }

      final expectedBackground = configuration.brightness == Brightness.dark
          ? AppColors.darkBackground
          : AppColors.lightBackground;
      expect(
        tester
            .widget<Scaffold>(find.byKey(const ValueKey('register-scaffold')))
            .backgroundColor,
        expectedBackground,
      );
    });
  }

  testWidgets('stays scrollable with keyboard and keeps 44px controls', (
    tester,
  ) async {
    await _pumpRegister(
      tester,
      size: const Size(320, 568),
      textScale: 1.5,
      viewInset: 260,
    );

    expect(
      tester
          .widget<SingleChildScrollView>(
            find.byKey(const ValueKey('register-scroll')),
          )
          .keyboardDismissBehavior,
      ScrollViewKeyboardDismissBehavior.onDrag,
    );
    for (final key in [
      'register-back-button',
      'register-password-toggle',
      'register-confirm-password-toggle',
      'register-terms-checkbox',
      'register-terms-button',
      'register-submit-button',
      'register-login-button',
    ]) {
      expect(
        tester.getSize(find.byKey(ValueKey(key))).height,
        greaterThanOrEqualTo(44),
      );
    }
    await tester.ensureVisible(
      find.byKey(const ValueKey('register-login-button')),
    );
    await tester.pump();
    expect(tester.takeException(), isNull);
  });

  testWidgets('preserves password toggles and loading states', (tester) async {
    await _pumpRegister(tester);

    final passwordInput = find.descendant(
      of: find.byKey(const ValueKey('register-password-field')),
      matching: find.byType(EditableText),
    );
    expect(tester.widget<EditableText>(passwordInput).obscureText, isTrue);
    await tester.tap(
      find.byKey(const ValueKey('register-password-toggle')),
      warnIfMissed: false,
    );
    await tester.pump();
    expect(tester.widget<EditableText>(passwordInput).obscureText, isFalse);

    await _pumpRegister(
      tester,
      authState: const AuthLoading(),
      loadingBarangays: true,
    );
    expect(find.byType(LinearProgressIndicator), findsOneWidget);
    expect(
      tester
          .widget<ElevatedButton>(
            find.byKey(const ValueKey('register-submit-button')),
          )
          .onPressed,
      isNull,
    );
    expect(find.bySemanticsLabel('Creating account'), findsOneWidget);
  });

  testWidgets('Back and Login return to the existing screen', (tester) async {
    await _pumpRegister(tester, pushFromRoot: true);
    await tester.tap(find.byKey(const ValueKey('register-back-button')));
    await tester.pumpAndSettle();
    expect(find.text('Login origin'), findsOneWidget);

    await _pumpRegister(tester, pushFromRoot: true);
    await tester.ensureVisible(
      find.byKey(const ValueKey('register-login-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-login-button')));
    await tester.pumpAndSettle();
    expect(find.text('Login origin'), findsOneWidget);
  });

  testWidgets('Create Account submits through the existing controller flow', (
    tester,
  ) async {
    final registerUseCase = _RegisterUseCaseMock();
    when(
      () => registerUseCase(
        email: any(named: 'email'),
        password: any(named: 'password'),
        passwordConfirm: any(named: 'passwordConfirm'),
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        barangayId: any(named: 'barangayId'),
      ),
    ).thenAnswer((_) async => const Success(_user));

    await _pumpRegister(
      tester,
      pushFromRoot: true,
      registerUseCase: registerUseCase,
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-first-name-field')),
      'Ada',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-last-name-field')),
      'Lovelace',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-email-field')),
      'ada@example.com',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-password-field')),
      'Strong1!',
    );
    await tester.enterText(
      find.byKey(const ValueKey('register-confirm-password-field')),
      'Strong1!',
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-barangay-field')),
    );
    await tester.tap(find.byKey(const ValueKey('register-barangay-field')));
    await tester.pumpAndSettle();
    final barangay = bundledUrdanetaBarangays.first;
    await tester.tap(find.text(barangay.name).last);
    await tester.pumpAndSettle();

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-terms-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-terms-button')));
    await tester.pumpAndSettle();
    final policyScroll = find.descendant(
      of: find.byType(AlertDialog),
      matching: find.byType(Scrollable),
    );
    final position = tester.state<ScrollableState>(policyScroll).position;
    position.jumpTo(position.maxScrollExtent);
    await tester.pump();
    await tester.tap(find.text('Accept'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<Checkbox>(
            find.byKey(const ValueKey('register-terms-checkbox')),
          )
          .value,
      isTrue,
    );

    await tester.ensureVisible(
      find.byKey(const ValueKey('register-submit-button')),
    );
    await tester.tap(find.byKey(const ValueKey('register-submit-button')));
    await tester.pumpAndSettle();

    verify(
      () => registerUseCase(
        email: 'ada@example.com',
        password: 'Strong1!',
        passwordConfirm: 'Strong1!',
        firstName: 'Ada',
        lastName: 'Lovelace',
        barangayId: barangay.id,
      ),
    ).called(1);
    expect(find.text('Login origin'), findsOneWidget);
  });
}

Future<void> _pumpRegister(
  WidgetTester tester, {
  Size size = const Size(390, 844),
  Brightness brightness = Brightness.light,
  double textScale = 1,
  double viewInset = 0,
  AuthState authState = const AuthIdle(),
  bool loadingBarangays = false,
  bool pushFromRoot = false,
  RegisterUseCase? registerUseCase,
}) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  final navigatorKey = GlobalKey<NavigatorState>();
  await tester.pumpWidget(
    ProviderScope(
      key: UniqueKey(),
      overrides: [
        if (registerUseCase == null)
          authControllerProvider.overrideWithValue(authState)
        else
          registerUseCaseProvider.overrideWithValue(registerUseCase),
        barangaysProvider.overrideWith(
          loadingBarangays ? _LoadingBarangays.new : _TestBarangays.new,
        ),
      ],
      child: MaterialApp(
        navigatorKey: navigatorKey,
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
            : const RegisterScreen(),
      ),
    ),
  );
  if (pushFromRoot) {
    unawaited(
      navigatorKey.currentState!.push(
        MaterialPageRoute<void>(builder: (_) => const RegisterScreen()),
      ),
    );
  }
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 1));
}

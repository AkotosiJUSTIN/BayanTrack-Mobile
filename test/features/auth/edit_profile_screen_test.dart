import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/auth_di.dart';
import 'package:bayantrack_mobile/features/auth/domain/auth_repository.dart';
import 'package:bayantrack_mobile/features/auth/domain/entities/user.dart';
import 'package:bayantrack_mobile/features/auth/presentation/edit_profile_screen.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mocktail/mocktail.dart';

class _AuthRepositoryMock extends Mock implements AuthRepository {}

class _FileFake extends Fake implements File {}

final _syntheticPng = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk'
  'YAAAAAYAAjCB0C8AAAAASUVORK5CYII=',
);

User _user({
  String firstName = 'Synthetic',
  String lastName = 'Citizen',
  String? avatarUrl,
  String? phone = '+639123456789',
  int profileRevision = 4,
  int avatarRevision = 0,
}) => User(
  id: 'USR-1',
  email: 'synthetic@example.test',
  firstName: firstName,
  lastName: lastName,
  phone: phone,
  avatarUrl: avatarUrl,
  profileRevision: profileRevision,
  avatarRevision: avatarRevision,
  role: UserRole.citizen,
);

Widget _app(
  AuthRepository repository, {
  required Future<XFile?> Function(ImageSource source) pickImage,
}) => ProviderScope(
  overrides: [authRepositoryProvider.overrideWithValue(repository)],
  child: MaterialApp(
    supportedLocales: AppLocalizations.supportedLocales,
    localizationsDelegates: AppLocalizations.localizationsDelegates,
    home: EditProfileScreen(pickImage: pickImage),
  ),
);

void main() {
  late Directory temporaryDirectory;
  late File syntheticAvatar;

  setUpAll(() => registerFallbackValue(_FileFake()));
  setUp(() async {
    temporaryDirectory = await Directory.systemTemp.createTemp(
      'bayantrack-avatar-widget-',
    );
    syntheticAvatar = File(
      '${temporaryDirectory.path}${Platform.pathSeparator}picked.png',
    );
    await syntheticAvatar.writeAsBytes(_syntheticPng);
  });
  tearDown(() async {
    if (await temporaryDirectory.exists()) {
      await temporaryDirectory.delete(recursive: true);
    }
  });

  testWidgets(
    'initial profile failure renders retry instead of endless loading',
    (tester) async {
      final repository = _AuthRepositoryMock();
      when(
        repository.getProfile,
      ).thenAnswer((_) async => const Err(ServerFailure('Unavailable')));

      await tester.pumpWidget(_app(repository, pickImage: (_) async => null));
      await tester.pumpAndSettle();

      expect(find.text('Unable to load profile.'), findsOneWidget);
      expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
    },
  );

  testWidgets('profile saves a backend-valid international phone number', (
    tester,
  ) async {
    final repository = _AuthRepositoryMock();
    when(repository.getProfile).thenAnswer((_) async => Success(_user()));
    when(
      () => repository.updateProfile(
        firstName: 'Synthetic',
        lastName: 'Citizen',
        phone: '+12025550123',
        expectedRevision: 4,
      ),
    ).thenAnswer((_) async => Success(_user(phone: '+12025550123')));

    await tester.pumpWidget(_app(repository, pickImage: (_) async => null));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '+12025550123');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
    await tester.pumpAndSettle();

    verify(
      () => repository.updateProfile(
        firstName: 'Synthetic',
        lastName: 'Citizen',
        phone: '+12025550123',
        expectedRevision: 4,
      ),
    ).called(1);
  });

  testWidgets(
    'profile can update phone when backend-optional names are blank',
    (tester) async {
      final repository = _AuthRepositoryMock();
      when(repository.getProfile).thenAnswer(
        (_) async => Success(_user(firstName: '', lastName: '', phone: null)),
      );
      when(
        () => repository.updateProfile(
          firstName: null,
          lastName: null,
          phone: '+12025550123',
          expectedRevision: 4,
        ),
      ).thenAnswer(
        (_) async =>
            Success(_user(firstName: '', lastName: '', phone: '+12025550123')),
      );

      await tester.pumpWidget(_app(repository, pickImage: (_) async => null));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextFormField).at(2), '+12025550123');
      await tester.pump();
      await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
      await tester.pumpAndSettle();

      verify(
        () => repository.updateProfile(
          firstName: null,
          lastName: null,
          phone: '+12025550123',
          expectedRevision: 4,
        ),
      ).called(1);
    },
  );

  testWidgets('profile blocks phone number backend rejects', (tester) async {
    final repository = _AuthRepositoryMock();
    when(repository.getProfile).thenAnswer((_) async => Success(_user()));

    await tester.pumpWidget(_app(repository, pickImage: (_) async => null));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextFormField).at(2), '09171234567');
    await tester.pump();
    await tester.tap(find.widgetWithText(FilledButton, 'Save Changes'));
    await tester.pumpAndSettle();

    verifyNever(
      () => repository.updateProfile(
        firstName: any(named: 'firstName'),
        lastName: any(named: 'lastName'),
        phone: any(named: 'phone'),
        expectedRevision: any(named: 'expectedRevision'),
      ),
    );
  });

  testWidgets(
    'avatar failure preserves preview, blocks concurrent save, shows removal, and cleans file',
    (tester) async {
      final repository = _AuthRepositoryMock();
      final upload = Completer<Result<User>>();
      final removal = Completer<Result<User>>();
      when(repository.getProfile).thenAnswer((_) async => Success(_user()));
      when(
        () => repository.uploadAvatar(
          any<File>(),
          onSendProgress: any<dynamic>(named: 'onSendProgress'),
        ),
      ).thenAnswer((invocation) {
        final progress =
            invocation.namedArguments[#onSendProgress]
                as void Function(int, int)?;
        progress?.call(5, 10);
        return upload.future;
      });
      when(repository.removeAvatar).thenAnswer((_) => removal.future);

      await tester.pumpWidget(
        _app(repository, pickImage: (_) async => XFile(syntheticAvatar.path)),
      );
      await tester.pump();
      await tester.pump();
      await tester.enterText(find.byType(TextFormField).first, 'Changed');
      await tester.tap(find.text('Add picture'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.tap(find.text('Choose from Gallery'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump();

      expect(find.text('Uploading 50%'), findsOneWidget);
      final save = tester.widget<FilledButton>(
        find.widgetWithText(FilledButton, 'Save Changes'),
      );
      expect(save.onPressed, isNull);

      await tester.tap(find.byType(TextFormField).at(2));
      await tester.showKeyboard(find.byType(TextFormField).at(2));
      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();
      verifyNever(
        () => repository.updateProfile(
          firstName: any<dynamic>(named: 'firstName'),
          lastName: any<dynamic>(named: 'lastName'),
          phone: any<dynamic>(named: 'phone'),
          expectedRevision: any<dynamic>(named: 'expectedRevision'),
        ),
      );

      upload.complete(const Err(ServerFailure('Unavailable')));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 300));
      expect(
        find.text('Upload failed. Keep this preview and tap Retry when ready.'),
        findsOneWidget,
      );
      expect(find.widgetWithText(OutlinedButton, 'Retry'), findsOneWidget);
      expect(await tester.runAsync(syntheticAvatar.exists), isTrue);

      await tester.tap(find.text('Remove'));
      await tester.pump();
      expect(find.text('Removing profile picture…'), findsOneWidget);

      removal.complete(Success(_user(profileRevision: 5, avatarRevision: 1)));
      await tester.pump();
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 100)),
      );
      await tester.pump(const Duration(milliseconds: 300));

      expect(await tester.runAsync(syntheticAvatar.exists), isFalse);
    },
  );

  testWidgets('disposal during upload deletes picker file without setState', (
    tester,
  ) async {
    final repository = _AuthRepositoryMock();
    final upload = Completer<Result<User>>();
    when(repository.getProfile).thenAnswer((_) async => Success(_user()));
    when(
      () => repository.uploadAvatar(
        any<File>(),
        onSendProgress: any<dynamic>(named: 'onSendProgress'),
      ),
    ).thenAnswer((_) => upload.future);

    await tester.pumpWidget(
      _app(repository, pickImage: (_) async => XFile(syntheticAvatar.path)),
    );
    await tester.pump();
    await tester.pump();
    await tester.tap(find.text('Add picture'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.tap(find.text('Choose from Gallery'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    await tester.pump();

    await tester.pumpWidget(const MaterialApp(home: SizedBox()));
    await tester.pump();
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 100)),
    );
    expect(await tester.runAsync(syntheticAvatar.exists), isFalse);

    upload.complete(const Err(ServerFailure('Unavailable')));
    await tester.pump();
    expect(tester.takeException(), isNull);
  });
}

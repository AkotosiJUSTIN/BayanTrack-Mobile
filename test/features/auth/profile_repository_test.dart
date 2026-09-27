import 'dart:io';

import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _DioMock extends Mock implements Dio {}

Map<String, dynamic> _profileJson({
  String? avatarUrl,
  int profileRevision = 4,
  int avatarRevision = 0,
}) => {
  'id': 'USR-1',
  'email': 'synthetic@example.test',
  'first_name': 'Synthetic',
  'last_name': 'Citizen',
  'phone': '+639123456789',
  'avatar_url': avatarUrl,
  'avatar_revision': avatarRevision,
  'profile_revision': profileRevision,
  'role': 'citizen',
  'is_active': true,
};

Response<dynamic> _response(String path, Map<String, dynamic> user) => Response(
  data: {'user': user},
  statusCode: 200,
  requestOptions: RequestOptions(path: path),
);

void main() {
  late _DioMock dio;
  late AuthRepositoryImpl repository;

  setUp(() {
    dio = _DioMock();
    repository = AuthRepositoryImpl(dio);
  });

  test('profile update sends canonical phone and expected revision', () async {
    when(
      () => dio.put(
        ApiConstants.profileUpdate,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _response(
        ApiConstants.profileUpdate,
        _profileJson(profileRevision: 5),
      ),
    );

    final result = await repository.updateProfile(
      firstName: 'Synthetic',
      lastName: 'Citizen',
      phone: '+639123456789',
      expectedRevision: 4,
    );

    final body =
        verify(
              () => dio.put(
                ApiConstants.profileUpdate,
                data: captureAny<dynamic>(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(body, {
      'first_name': 'Synthetic',
      'last_name': 'Citizen',
      'phone': '+639123456789',
      'expected_revision': 4,
    });
    expect(result.dataOrNull?.profileRevision, 5);
  });

  test('profile update omits blank backend-optional names', () async {
    when(
      () => dio.put(
        ApiConstants.profileUpdate,
        data: any<dynamic>(named: 'data'),
      ),
    ).thenAnswer(
      (_) async => _response(
        ApiConstants.profileUpdate,
        _profileJson(profileRevision: 5),
      ),
    );

    await repository.updateProfile(phone: '+12025550123', expectedRevision: 4);

    final body =
        verify(
              () => dio.put(
                ApiConstants.profileUpdate,
                data: captureAny<dynamic>(named: 'data'),
              ),
            ).captured.single
            as Map<String, dynamic>;
    expect(body, {'phone': '+12025550123', 'expected_revision': 4});
  });

  test(
    'avatar upload uses fixed filename, no provider fields, and maps revisions',
    () async {
      final directory = await Directory.systemTemp.createTemp(
        'bayantrack-avatar-repository-',
      );
      addTearDown(() => directory.delete(recursive: true));
      final file = File('${directory.path}${Platform.pathSeparator}picked.png');
      await file.writeAsBytes([0xFF, 0xD8, 0xFF, 0xD9]);

      when(
        () => dio.post(
          ApiConstants.profileAvatar,
          data: any<dynamic>(named: 'data'),
          onSendProgress: any<dynamic>(named: 'onSendProgress'),
        ),
      ).thenAnswer(
        (_) async => _response(
          ApiConstants.profileAvatar,
          _profileJson(
            avatarUrl: '/api/auth/avatars/media-1/?v=2',
            profileRevision: 6,
            avatarRevision: 2,
          ),
        ),
      );

      final result = await repository.uploadAvatar(file);

      final formData =
          verify(
                () => dio.post(
                  ApiConstants.profileAvatar,
                  data: captureAny<dynamic>(named: 'data'),
                  onSendProgress: any<dynamic>(named: 'onSendProgress'),
                ),
              ).captured.single
              as FormData;
      expect(formData.files, hasLength(1));
      expect(formData.files.single.key, 'avatar');
      expect(formData.files.single.value.filename, 'avatar.jpg');
      expect(formData.files.single.value.contentType.toString(), 'image/jpeg');
      expect(formData.fields, isEmpty);
      expect(result.dataOrNull?.avatarRevision, 2);
      expect(result.dataOrNull?.profileRevision, 6);
      expect(result.dataOrNull?.avatarUrl, '/api/auth/avatars/media-1/?v=2');
    },
  );

  test(
    'avatar removal uses dedicated endpoint and maps cleared avatar',
    () async {
      when(() => dio.delete(ApiConstants.profileAvatar)).thenAnswer(
        (_) async => _response(
          ApiConstants.profileAvatar,
          _profileJson(profileRevision: 7, avatarRevision: 3),
        ),
      );

      final result = await repository.removeAvatar();

      verify(() => dio.delete(ApiConstants.profileAvatar)).called(1);
      expect(result.dataOrNull?.avatarUrl, isNull);
      expect(result.dataOrNull?.avatarRevision, 3);
      expect(result.dataOrNull?.profileRevision, 7);
    },
  );
}

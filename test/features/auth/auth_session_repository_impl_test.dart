import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:bayantrack_mobile/features/auth/data/repositories/auth_session_repository_impl.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _StorageMock extends Mock implements FlutterSecureStorage {}

void main() {
  test(
    'conditional session writes and clears preserve switched account',
    () async {
      final storage = _StorageMock();
      final values = <String, String>{
        ApiConstants.accessTokenKey: 'access-b',
        ApiConstants.refreshTokenKey: 'refresh-b',
      };
      when(() => storage.read(key: any(named: 'key'))).thenAnswer(
        (invocation) async => values[invocation.namedArguments[#key]],
      );
      when(
        () => storage.write(
          key: any(named: 'key'),
          value: any(named: 'value'),
        ),
      ).thenAnswer((invocation) async {
        values[invocation.namedArguments[#key] as String] =
            invocation.namedArguments[#value] as String;
      });
      when(() => storage.delete(key: any(named: 'key'))).thenAnswer((
        invocation,
      ) async {
        values.remove(invocation.namedArguments[#key] as String);
      });
      final repository = AuthSessionRepositoryImpl(storage);

      expect(
        await repository.saveTokensIfRefreshTokenMatches(
          expectedRefreshToken: 'refresh-a',
          accessToken: 'access-a2',
          refreshToken: 'refresh-a2',
        ),
        isFalse,
      );
      expect(values[ApiConstants.accessTokenKey], 'access-b');
      expect(values[ApiConstants.refreshTokenKey], 'refresh-b');
      expect(
        await repository.clearSessionIfRefreshTokenMatches('refresh-a'),
        isFalse,
      );
      expect(values[ApiConstants.refreshTokenKey], 'refresh-b');

      expect(
        await repository.clearSessionIfRefreshTokenMatches('refresh-b'),
        isTrue,
      );
      expect(values, isEmpty);
      repository.dispose();
    },
  );
}

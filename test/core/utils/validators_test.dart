import 'package:bayantrack_mobile/core/utils/validators.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('registration email validation', () {
    test('accepts backend-valid email and rejects missing domain dot', () {
      expect(Validators.registrationEmail('Citizen+1@example.test'), isNull);
      expect(Validators.registrationEmail('a@b'), isNotNull);
    });

    test('enforces backend email length while KYC allows local domains', () {
      expect(
        Validators.registrationEmail('a@b${List.filled(253, 'x').join()}'),
        isNotNull,
      );
      expect(Validators.email('user@localhost'), isNull);
      expect(
        Validators.email('${List.filled(250, 'a').join()}@example.test'),
        isNotNull,
      );
    });
  });

  group('password validation', () {
    test('accepts password without special character', () {
      expect(Validators.password('Password123'), isNull);
    });

    test('rejects password over backend maximum', () {
      expect(
        Validators.password('A${List.filled(127, 'b').join()}1'),
        isNotNull,
      );
    });
  });

  group('account phone validation', () {
    test('accepts E.164 values accepted by backend', () {
      expect(Validators.phoneNumber('+639123456789'), isNull);
      expect(Validators.phoneNumber('+12025550123'), isNull);
    });

    test('allows an empty optional phone and rejects local-only input', () {
      expect(Validators.phoneNumber(''), isNull);
      expect(Validators.phoneNumber('09171234567'), isNotNull);
      expect(Validators.phoneNumber('+123'), isNotNull);
    });
  });

  group('registration names', () {
    test('allows omitted backend-optional names', () {
      expect(Validators.lettersOnly('', required: false), isNull);
      expect(Validators.lettersOnly('   ', required: false), isNull);
      expect(Validators.lettersOnly('Juan'), isNull);
      expect(Validators.lettersOnly('Juan2'), isNotNull);
    });
  });

  group('report text validation', () {
    test('accepts every non-empty text within backend length', () {
      expect(Validators.reportText('short'), isNull);
      expect(Validators.reportText('n/a'), isNull);
      expect(Validators.reportText(List.filled(5000, 'a').join()), isNull);
    });

    test('enforces required and backend maximum length', () {
      expect(Validators.reportText(''), isNotNull);
      expect(Validators.reportText('   ', isRequired: false), isNull);
      expect(Validators.reportText(List.filled(5001, 'a').join()), isNotNull);
      expect(
        Validators.reportText(
          List.filled(201, 'a').join(),
          maxLength: 200,
          isRequired: false,
        ),
        isNotNull,
      );
    });
  });
}

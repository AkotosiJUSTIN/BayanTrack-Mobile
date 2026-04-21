import 'package:flutter_test/flutter_test.dart';
import 'package:bayantrack_mobile/core/utils/validators.dart';

void main() {
  group('Validators.reportText - Gibberish Detection', () {
    test('should accept valid report descriptions', () {
      // Valid descriptions should return null (no error)
      expect(
        Validators.reportText(
          'There is a broken streetlight on Main Street that needs repair',
        ),
        isNull,
      );
      expect(
        Validators.reportText(
          'Flooding issue near the market area during heavy rain',
        ),
        isNull,
      );
      expect(
        Validators.reportText(
          'May nakaharang na basura sa daanan, kailangan po ng linis',
        ),
        isNull,
      );
    });

    test('should reject empty or too short descriptions', () {
      expect(Validators.reportText(''), isNotNull);
      expect(Validators.reportText('   '), isNotNull);
      expect(Validators.reportText('short'), isNotNull);
      expect(
        Validators.reportText('too short'),
        contains('at least 10 characters'),
      );
    });

    test('should reject common placeholder text', () {
      expect(
        Validators.reportText('n/a'),
        contains('meaningful description'),
      );
      expect(
        Validators.reportText('N/A'),
        contains('meaningful description'),
      );
      expect(
        Validators.reportText('na'),
        contains('meaningful description'),
      );
      expect(
        Validators.reportText('none'),
        contains('meaningful description'),
      );
      expect(
        Validators.reportText('test'),
        contains('meaningful description'),
      );
      expect(
        Validators.reportText('tbd'),
        contains('meaningful description'),
      );
      expect(
        Validators.reportText('todo'),
        contains('meaningful description'),
      );
    });

    test('should reject excessive character repetition', () {
      expect(
        Validators.reportText('aaaaaaaaaa test test'),
        contains('excessive repetition'),
      );
      expect(
        Validators.reportText('hahahahaha test test'),
        contains('excessive repetition'),
      );
      expect(
        Validators.reportText('lalalalala test test'),
        contains('excessive repetition'),
      );
    });

    test('should reject keyboard mashing patterns', () {
      expect(
        Validators.reportText('qwertyuiop asdfghjkl'),
        contains('keyboard mashing'),
      );
      expect(
        Validators.reportText('asdfghjkl please help'),
        contains('keyboard mashing'),
      );
      expect(
        Validators.reportText('test 123456789 issue'),
        contains('keyboard mashing'),
      );
    });

    test('should reject excessive consonants or vowels', () {
      expect(
        Validators.reportText('bcdfghjklm test test'),
        contains('coherent description'),
      );
      expect(
        Validators.reportText('aeiouaeiou test test'),
        contains('coherent description'),
      );
    });

    test('should reject text with poor word structure', () {
      expect(
        Validators.reportText('a b c d e f g h i j k l m n o'),
        isNotNull,
      );
      expect(
        Validators.reportText('!!!@@@###\$\$\$%%%^^^&&&***'),
        isNotNull,
      );
    });

    test('should reject excessive special characters', () {
      expect(
        Validators.reportText('!@#\$%^&*()!@#\$%^&*()!@#\$%^&*()'),
        isNotNull,
      );
      // Text with too many special characters will be caught by word structure check
      expect(
        Validators.reportText('test ###\$\$\$%%%^^^&&&*** test'),
        isNotNull,
      );
    });

    test('should allow optional empty text when isRequired is false', () {
      expect(
        Validators.reportText('', isRequired: false),
        isNull,
      );
      expect(
        Validators.reportText('   ', isRequired: false),
        isNull,
      );
    });

    test('should still validate gibberish even when isRequired is false', () {
      expect(
        Validators.reportText('qwertyuiop', isRequired: false),
        isNotNull,
      );
      expect(
        Validators.reportText('aaaaaaaaaa', isRequired: false),
        isNotNull,
      );
    });

    test('edge cases with numbers and special chars in valid text', () {
      // Valid use of numbers and special chars
      expect(
        Validators.reportText(
          'Report #123: Broken streetlight at 10:30 PM on Baker St.',
        ),
        isNull,
      );
      expect(
        Validators.reportText(
          'Issue with water supply (low pressure) in Phase 1, Block 5',
        ),
        isNull,
      );
    });

    test('Filipino language support', () {
      expect(
        Validators.reportText(
          'Sira ang ilaw sa kalye, kailangan ng ayos agad',
        ),
        isNull,
      );
      expect(
        Validators.reportText(
          'May butas sa kalsada malapit sa simbahan ng Urdaneta',
        ),
        isNull,
      );
    });
  });
}

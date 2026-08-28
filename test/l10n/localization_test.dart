import 'dart:convert';
import 'dart:io';

import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('English and Filipino ARB keys stay in parity', () {
    final english = _translationKeys('app_en.arb');
    final filipino = _translationKeys('app_fil.arb');

    expect(filipino, equals(english));
    expect(english, hasLength(greaterThan(500)));
  });

  test('both delegates load representative translated screens', () async {
    final english = await AppLocalizations.delegate.load(const Locale('en'));
    final filipino = await AppLocalizations.delegate.load(const Locale('fil'));

    expect(english.login, 'Login');
    expect(filipino.login, 'Mag-login');
    expect(english.home, 'Home');
    expect(filipino.home, 'Home');
    expect(english.chooseLanguage, isNotEmpty);
    expect(filipino.chooseLanguage, isNot(english.chooseLanguage));
    expect(english.categoryEngineeringInfrastructure, isNotEmpty);
    expect(filipino.categoryEngineeringInfrastructure, isNotEmpty);
    expect(english.reportCount(1), '1 report');
    expect(english.reportCount(2), '2 reports');
    expect(filipino.reportCount(2), '2 ulat');
    expect(
      english.evidenceUploadsPending(1),
      contains('1 evidence upload pending'),
    );
    expect(
      english.evidenceUploadsPending(2),
      contains('2 evidence uploads pending'),
    );
    expect(
      filipino.evidenceUploadsPending(2),
      contains('2 pag-upload ng ebidensya'),
    );
  });
}

Set<String> _translationKeys(String name) {
  final values = jsonDecode(File('lib/l10n/$name').readAsStringSync())
      as Map<String, dynamic>;
  return values.keys.where((key) => !key.startsWith('@')).toSet();
}

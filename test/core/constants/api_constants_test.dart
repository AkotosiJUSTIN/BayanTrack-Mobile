import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('public reports path stays relative to configured API host', () {
    expect(ApiConstants.reports, '/reports/');
  });

  test('Dart-defined API URLs keep API and media roots separate', () {
    expect(ApiConstants.baseUrl, startsWith('http'));
    expect(ApiConstants.baseUrl, endsWith('/api'));
    expect(ApiConstants.mediaBaseUrl, startsWith('http'));
    expect(ApiConstants.mediaBaseUrl, isNot(endsWith('/api')));
  });
}

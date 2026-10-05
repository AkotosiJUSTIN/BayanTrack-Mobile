import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('emulator defaults and explicit build-time overrides', () {
    const expectedApi = String.fromEnvironment(
      'QA_EXPECTED_API',
      defaultValue: 'http://10.0.2.2:8000/api',
    );
    const expectedMedia = String.fromEnvironment(
      'QA_EXPECTED_MEDIA',
      defaultValue: 'http://10.0.2.2:8000',
    );
    expect(ApiConstants.baseUrl, expectedApi);
    expect(ApiConstants.mediaBaseUrl, expectedMedia);
    expect(
      ApiConstants.getImageUrl('/media/test.jpg'),
      '$expectedMedia/media/test.jpg',
    );
    expect(
      ApiConstants.getImageUrl('https://example.org/test.jpg'),
      'https://example.org/test.jpg',
    );
  });
}

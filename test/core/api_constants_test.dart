import 'package:bayantrack_mobile/core/constants/api_constants.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test('deployed defaults and explicit build-time overrides', () {
    const expectedApi = String.fromEnvironment(
      'QA_EXPECTED_API',
      defaultValue: 'https://api.bayantrack.app/api',
    );
    const expectedMedia = String.fromEnvironment(
      'QA_EXPECTED_MEDIA',
      defaultValue: 'https://api.bayantrack.app',
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

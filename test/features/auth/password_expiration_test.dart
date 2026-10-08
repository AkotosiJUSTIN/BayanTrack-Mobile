import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:bayantrack_mobile/features/auth/data/auth_models.dart';
import 'package:bayantrack_mobile/features/auth/data/mappers/auth_mapper.dart';

void main() {
  tearDownAll(() => debugPrint('MOBILE_PASSWORD_EXPIRATION_TESTS_PASSED'));

  test('maps the backend forced-change state into the mobile user', () {
    final user = AuthMapper.userFromProfile(
      UserProfile.fromJson({
        'id': 'user-1',
        'email': 'citizen@example.com',
        'role': 'citizen',
        'password_changed_at': '2026-01-01T00:00:00Z',
        'password_expires_at': '2026-04-01T00:00:00Z',
        'password_expired': true,
        'password_days_remaining': 0,
        'password_warning_level': 'expired',
        'password_change_required': true,
      }),
    );

    expect(user.passwordChangedAt, DateTime.parse('2026-01-01T00:00:00Z'));
    expect(user.passwordExpiresAt, DateTime.parse('2026-04-01T00:00:00Z'));
    expect(user.passwordDaysRemaining, 0);
    expect(user.passwordWarningLevel, 'expired');
    expect(user.requiresPasswordChange, isTrue);
  });
}

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/presentation/failure_message.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  for (final language in ['en', 'fil']) {
    group(language, () {
      late AppLocalizations l10n;

      setUp(() async {
        l10n = await AppLocalizations.delegate.load(Locale(language));
      });

      test('uses localized guidance instead of technical failure text', () {
        const diagnostics = 'DioException: backend unavailable at /api/users';
        final cases = <Failure, String>{
          const NetworkFailure(diagnostics): l10n.requestNetworkError,
          const ServerFailure(diagnostics): l10n.requestServiceError,
          const AuthFailure(diagnostics): l10n.requestSignInAgain,
          const NotFoundFailure(diagnostics): l10n.requestNotFound,
          const CacheFailure(diagnostics): l10n.requestStorageError,
          const ValidationFailure(diagnostics): l10n.requestValidationError,
          const UnknownFailure(diagnostics): l10n.unknownError,
        };

        for (final entry in cases.entries) {
          final message = localizedFailureMessage(entry.key, l10n);
          expect(message, entry.value);
          expect(message, isNot(contains(diagnostics)));
        }
      });

      test('explains rate limits and system restrictions', () {
        expect(
          localizedFailureMessage(
            const UnknownFailure.withStatus('rate_limited', 429),
            l10n,
          ),
          l10n.requestTooManyAttempts,
        );
        for (final code in [
          'terms_acceptance_required',
          'terms_version_stale',
        ]) {
          expect(
            localizedFailureMessage(
              SystemRestrictionFailure(code, 'internal detail'),
              l10n,
            ),
            l10n.governanceTermsChanged,
          );
        }
        expect(
          localizedFailureMessage(
            const SystemRestrictionFailure(
              'maintenance_read_only',
              'internal detail',
            ),
            l10n,
          ),
          l10n.governanceReadOnly,
        );
      });

      test('keeps contextual fallbacks without exposing unknown errors', () {
        expect(
          localizedFailureMessage(
            StateError('private implementation detail'),
            l10n,
            fallback: l10n.withdrawalFailed,
          ),
          l10n.withdrawalFailed,
        );
        expect(
          localizedFailureMessage(
            const AuthFailure('invalid_credentials'),
            l10n,
            authMessage: l10n.authDetailsNotAccepted,
          ),
          l10n.authDetailsNotAccepted,
        );
        expect(
          localizedFailureMessage(
            const ServerFailure('stack trace'),
            l10n,
            fallback: l10n.withdrawalFailed,
          ),
          l10n.requestServiceError,
        );
      });
    });
  }
}

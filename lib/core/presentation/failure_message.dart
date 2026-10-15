import '../../l10n/app_localizations.dart';
import '../domain/failures.dart';

/// Keep service diagnostics out of UI copy. Forms render field errors separately.
String localizedFailureMessage(
  Object error,
  AppLocalizations l10n, {
  String? fallback,
  String? authMessage,
}) {
  if (error is Failure && error.statusCode == 429) {
    return l10n.requestTooManyAttempts;
  }
  return switch (error) {
    NetworkFailure() => l10n.requestNetworkError,
    ServerFailure() => l10n.requestServiceError,
    AuthFailure() => authMessage ?? l10n.requestSignInAgain,
    NotFoundFailure() => l10n.requestNotFound,
    CacheFailure() => l10n.requestStorageError,
    ValidationFailure() => l10n.requestValidationError,
    SystemRestrictionFailure(code: 'terms_acceptance_required') ||
    SystemRestrictionFailure(
      code: 'terms_version_stale',
    ) => l10n.governanceTermsChanged,
    SystemRestrictionFailure(code: 'maintenance_read_only') =>
      l10n.governanceReadOnly,
    _ => fallback ?? l10n.unknownError,
  };
}

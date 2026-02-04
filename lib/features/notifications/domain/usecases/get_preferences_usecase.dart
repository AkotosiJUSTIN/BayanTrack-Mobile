import '../../../../core/domain/result.dart';
import '../entities/notification_preferences.dart';
import '../notifications_repository.dart';

/// Use case to fetch notification preferences.
class GetPreferencesUseCase {
  final NotificationsRepository _repository;

  const GetPreferencesUseCase({required NotificationsRepository repository})
    : _repository = repository;

  /// Fetches the current notification preferences.
  ///
  /// Returns [NotificationPreferences] on success, or a [Failure] on error.
  Future<Result<NotificationPreferences>> call() {
    return _repository.getPreferences();
  }
}

import '../../../../core/domain/result.dart';
import '../entities/notification_preferences.dart';
import '../notifications_repository.dart';

/// Use case to update notification preferences.
class UpdatePreferencesUseCase {
  final NotificationsRepository _repository;

  const UpdatePreferencesUseCase({required NotificationsRepository repository})
    : _repository = repository;

  /// Updates notification preferences.
  ///
  /// Returns updated [NotificationPreferences] on success, or a [Failure] on error.
  Future<Result<NotificationPreferences>> call({
    bool? emailEnabled,
    bool? pushEnabled,
    bool? notifyOnStatusChange,
    bool? notifyOnComment,
    bool? notifyOnAssignment,
  }) {
    return _repository.updatePreferences(
      emailEnabled: emailEnabled,
      pushEnabled: pushEnabled,
      notifyOnStatusChange: notifyOnStatusChange,
      notifyOnComment: notifyOnComment,
      notifyOnAssignment: notifyOnAssignment,
    );
  }
}

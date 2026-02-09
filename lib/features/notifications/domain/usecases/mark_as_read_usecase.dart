import '../../../../core/domain/result.dart';
import '../notifications_repository.dart';

/// Use case to mark a single notification as read.
class MarkAsReadUseCase {
  final NotificationsRepository _repository;

  const MarkAsReadUseCase({required NotificationsRepository repository})
    : _repository = repository;

  /// Marks the notification with [id] as read.
  ///
  /// Returns void on success, or a [Failure] on error.
  Future<Result<void>> call(String id) {
    return _repository.markAsRead(id);
  }
}

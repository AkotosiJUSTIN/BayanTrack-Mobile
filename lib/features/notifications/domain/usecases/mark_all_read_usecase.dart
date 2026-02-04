import '../../../../core/domain/result.dart';
import '../notifications_repository.dart';

/// Use case to mark all notifications as read.
class MarkAllReadUseCase {
  final NotificationsRepository _repository;

  const MarkAllReadUseCase({required NotificationsRepository repository})
    : _repository = repository;

  /// Marks all notifications as read.
  ///
  /// Returns void on success, or a [Failure] on error.
  Future<Result<void>> call() {
    return _repository.markAllAsRead();
  }
}

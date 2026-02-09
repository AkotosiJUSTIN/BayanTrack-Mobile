import '../../../../core/domain/result.dart';
import '../entities/paginated_notifications.dart';
import '../notifications_repository.dart';

/// Use case to fetch paginated notifications.
class GetNotificationsUseCase {
  final NotificationsRepository _repository;

  const GetNotificationsUseCase({required NotificationsRepository repository})
    : _repository = repository;

  /// Fetches paginated notifications.
  ///
  /// Returns [PaginatedNotifications] on success, or a [Failure] on error.
  Future<Result<PaginatedNotifications>> call({
    int page = 1,
    int pageSize = 20,
    bool? unreadOnly,
  }) {
    return _repository.getNotifications(
      page: page,
      pageSize: pageSize,
      unreadOnly: unreadOnly,
    );
  }
}

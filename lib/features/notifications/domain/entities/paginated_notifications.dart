import 'package:equatable/equatable.dart';

import 'notification.dart';

/// Domain entity for paginated notifications list.
class PaginatedNotifications extends Equatable {
  final List<NotificationEntity> results;
  final int count;
  final int unreadCount;
  final String? next;
  final String? previous;

  const PaginatedNotifications({
    this.results = const [],
    this.count = 0,
    this.unreadCount = 0,
    this.next,
    this.previous,
  });

  /// Returns true if there are more pages.
  bool get hasNext => next != null;

  /// Returns true if there are previous pages.
  bool get hasPrevious => previous != null;

  /// Returns true if the list is empty.
  bool get isEmpty => results.isEmpty;

  /// Empty paginated notifications.
  static const empty = PaginatedNotifications();

  @override
  List<Object?> get props => [results, count, unreadCount, next, previous];
}

import 'package:equatable/equatable.dart';

import 'notification_type.dart';

/// Domain entity for a single notification.
class NotificationEntity extends Equatable {
  final String id;
  final String title;
  final String message;
  final NotificationType type;
  final bool isRead;
  final String? reportId;
  final DateTime? createdAt;

  const NotificationEntity({
    required this.id,
    required this.title,
    required this.message,
    this.type = NotificationType.system,
    this.isRead = false,
    this.reportId,
    this.createdAt,
  });

  @override
  List<Object?> get props => [
    id,
    title,
    message,
    type,
    isRead,
    reportId,
    createdAt,
  ];
}

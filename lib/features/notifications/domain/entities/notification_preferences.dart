import 'package:equatable/equatable.dart';

/// Domain entity for notification preferences.
class NotificationPreferences extends Equatable {
  final bool emailEnabled;
  final bool pushEnabled;
  final bool notifyOnStatusChange;
  final bool notifyOnComment;
  final bool notifyOnAssignment;

  const NotificationPreferences({
    this.emailEnabled = true,
    this.pushEnabled = true,
    this.notifyOnStatusChange = true,
    this.notifyOnComment = true,
    this.notifyOnAssignment = true,
  });

  /// Default preferences.
  static const defaults = NotificationPreferences();

  @override
  List<Object?> get props => [
    emailEnabled,
    pushEnabled,
    notifyOnStatusChange,
    notifyOnComment,
    notifyOnAssignment,
  ];
}

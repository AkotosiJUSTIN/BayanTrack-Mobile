/// Domain enum for notification types.
///
/// Pure Dart enum without JSON annotations.
enum NotificationType {
  statusChange,
  comment,
  assignment,
  system;

  String get displayName => switch (this) {
    statusChange => 'Status Change',
    comment => 'Comment',
    assignment => 'Assignment',
    system => 'System',
  };

  static NotificationType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'status_change' => statusChange,
      'comment' => comment,
      'assignment' => assignment,
      'system' => system,
      _ => system,
    };
  }
}

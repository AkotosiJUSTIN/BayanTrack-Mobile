/// Domain enum for notification types.
///
/// Pure Dart enum without JSON annotations.
enum NotificationType {
  reportSubmitted,
  statusChange,
  comment,
  assignment,
  reportUpdated,
  kycUpdate,
  system;

  String get displayName => switch (this) {
    reportSubmitted => 'Report Submitted',
    statusChange => 'Status Change',
    comment => 'Comment',
    assignment => 'Assignment',
    reportUpdated => 'Report Updated',
    kycUpdate => 'KYC Update',
    system => 'System',
  };

  static NotificationType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'report_submitted' => reportSubmitted,
      'status_change' => statusChange,
      'comment' => comment,
      'assignment' => assignment,
      'report_updated' => reportUpdated,
      'kyc_update' => kycUpdate,
      'system' => system,
      _ => system,
    };
  }
}

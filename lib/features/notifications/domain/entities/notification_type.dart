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
  termsUpdated,
  system;

  String get displayName => switch (this) {
    reportSubmitted => 'Report Submitted',
    statusChange => 'Status Change',
    comment => 'Comment',
    assignment => 'Assignment',
    reportUpdated => 'Report Updated',
    kycUpdate => 'Verification Update',
    termsUpdated => 'Terms & Privacy Updated',
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
      'terms_updated' => termsUpdated,
      'system' => system,
      _ => system,
    };
  }
}

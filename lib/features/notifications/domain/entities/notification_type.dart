/// Domain enum for notification types.
///
/// Pure Dart enum without JSON annotations.
enum NotificationType {
  reportSubmitted,
  statusChange,
  comment,
  assignment,
  reportUpdated,
  reportLinked,
  reportUnlinked,
  incidentUpdate,
  kycUpdate,
  termsUpdated,
  system;

  String get displayName => switch (this) {
    reportSubmitted => 'Report Submitted',
    statusChange => 'Status Change',
    comment => 'Comment',
    assignment => 'Assignment',
    reportUpdated => 'Report Updated',
    reportLinked => 'Report Linked',
    reportUnlinked => 'Report Unlinked',
    incidentUpdate => 'Incident Update',
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
      'report_linked' => reportLinked,
      'report_unlinked' => reportUnlinked,
      'incident_update' => incidentUpdate,
      'kyc_update' => kycUpdate,
      'terms_updated' => termsUpdated,
      'system' => system,
      _ => system,
    };
  }
}

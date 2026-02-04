import 'package:equatable/equatable.dart';

/// Domain entity for report statistics.
class ReportStats extends Equatable {
  final int total;
  final Map<String, int> byStatus;
  final Map<String, int> byCategory;
  final Map<String, int> bySeverity;
  final int emergencies;

  // Convenience getters for common status counts
  final int submitted;
  final int underReview;
  final int verified;
  final int assigned;
  final int inProgress;
  final int resolved;
  final int rejected;

  const ReportStats({
    this.total = 0,
    this.byStatus = const {},
    this.byCategory = const {},
    this.bySeverity = const {},
    this.emergencies = 0,
    this.submitted = 0,
    this.underReview = 0,
    this.verified = 0,
    this.assigned = 0,
    this.inProgress = 0,
    this.resolved = 0,
    this.rejected = 0,
  });

  /// Count of pending reports (not resolved or rejected)
  int get pending => total - resolved - rejected;

  /// Empty stats
  static const empty = ReportStats();

  @override
  List<Object?> get props => [
    total,
    byStatus,
    byCategory,
    bySeverity,
    emergencies,
  ];
}

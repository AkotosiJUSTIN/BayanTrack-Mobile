/// Domain enums for Report entities.
///
/// These are pure Dart enums with no JSON annotations.
/// The data layer DTOs retain @JsonValue for serialization.
library;

/// Report category aligned with Mangaldan Municipal Office routing
enum ReportCategory {
  engineeringInfrastructure,
  floodDisaster,
  wasteEnvironment,
  publicSafety,
  publicUtilities;

  String get displayName => switch (this) {
    engineeringInfrastructure => 'Municipal Engineering & Infrastructure',
    floodDisaster => 'Flood & Disaster Response',
    wasteEnvironment => 'Solid Waste & Environmental Management',
    publicSafety => 'Public Safety & Order',
    publicUtilities => 'Public Utilities & Service',
  };

  String get apiValue => switch (this) {
    engineeringInfrastructure => 'Municipal Engineering & Infrastructure',
    floodDisaster => 'Flood & Disaster Response',
    wasteEnvironment => 'Solid Waste & Environmental Management',
    publicSafety => 'Public Safety & Order',
    publicUtilities => 'Public Utilities & Service',
  };

  static ReportCategory? fromString(String? value) {
    return switch (value) {
      'Municipal Engineering & Infrastructure' => ReportCategory.engineeringInfrastructure,
      'Flood & Disaster Response' => ReportCategory.floodDisaster,
      'Solid Waste & Environmental Management' => ReportCategory.wasteEnvironment,
      'Public Safety & Order' => ReportCategory.publicSafety,
      'Public Utilities & Service' => ReportCategory.publicUtilities,
      // Backward compatibility with short names
      'engineering_infrastructure' => ReportCategory.engineeringInfrastructure,
      'flood_disaster' => ReportCategory.floodDisaster,
      'waste_environment' => ReportCategory.wasteEnvironment,
      'public_safety' => ReportCategory.publicSafety,
      'public_utilities' => ReportCategory.publicUtilities,
      _ => null,
    };
  }
}

/// Report status in workflow
enum ReportStatus {
  submitted,
  underReview,
  verified,
  assigned,
  inProgress,
  escalated,
  endorsed,
  resolved,
  closed,
  rejected;

  String get displayName => switch (this) {
    submitted => 'Submitted',
    underReview => 'Under Review',
    verified => 'Verified',
    assigned => 'Assigned',
    inProgress => 'In Progress',
    escalated => 'Escalated',
    endorsed => 'Endorsed',
    resolved => 'Resolved',
    closed => 'Closed',
    rejected => 'Rejected',
  };

  String get apiValue => switch (this) {
    submitted => 'submitted',
    underReview => 'under_review',
    verified => 'verified',
    assigned => 'assigned',
    inProgress => 'in_progress',
    escalated => 'escalated',
    endorsed => 'endorsed',
    resolved => 'resolved',
    closed => 'closed',
    rejected => 'rejected',
  };

  static ReportStatus fromString(String? value) {
    return switch (value) {
      'submitted' => ReportStatus.submitted,
      'under_review' => ReportStatus.underReview,
      'verified' => ReportStatus.verified,
      'assigned' => ReportStatus.assigned,
      'in_progress' => ReportStatus.inProgress,
      'escalated' => ReportStatus.escalated,
      'endorsed' => ReportStatus.endorsed,
      'resolved' => ReportStatus.resolved,
      'closed' => ReportStatus.closed,
      'rejected' => ReportStatus.rejected,
      _ => ReportStatus.submitted,
    };
  }
}

/// Severity level of the report
enum SeverityLevel {
  low,
  medium,
  high,
  critical;

  String get displayName => switch (this) {
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get apiValue => name;

  static SeverityLevel fromString(String? value) {
    return switch (value) {
      'low' => SeverityLevel.low,
      'medium' => SeverityLevel.medium,
      'high' => SeverityLevel.high,
      'critical' => SeverityLevel.critical,
      _ => SeverityLevel.medium,
    };
  }
}

/// Location accuracy type
enum LocationAccuracy {
  exact,
  approximate;

  String get displayName => switch (this) {
    exact => 'Exact',
    approximate => 'Approximate',
  };

  static LocationAccuracy fromString(String? value) {
    return switch (value) {
      'exact' => LocationAccuracy.exact,
      _ => LocationAccuracy.approximate,
    };
  }
}

/// Duplicate detection state
enum DuplicateState {
  newReport,
  potentialDuplicate,
  confirmedDuplicate,
  unique;

  String get apiValue => switch (this) {
    newReport => 'new',
    potentialDuplicate => 'potential_duplicate',
    confirmedDuplicate => 'confirmed_duplicate',
    unique => 'unique',
  };

  static DuplicateState fromString(String? value) {
    return switch (value) {
      'new' => DuplicateState.newReport,
      'potential_duplicate' => DuplicateState.potentialDuplicate,
      'confirmed_duplicate' => DuplicateState.confirmedDuplicate,
      'unique' => DuplicateState.unique,
      _ => DuplicateState.newReport,
    };
  }
}

/// Priority level from AI prioritization
enum PriorityLevel {
  low,
  medium,
  high,
  critical;

  String get displayName => switch (this) {
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get apiValue => switch (this) {
    low => 'LOW',
    medium => 'MEDIUM',
    high => 'HIGH',
    critical => 'CRITICAL',
  };

  static PriorityLevel fromString(String? value) {
    return switch (value?.toUpperCase()) {
      'LOW' => PriorityLevel.low,
      'MEDIUM' => PriorityLevel.medium,
      'HIGH' => PriorityLevel.high,
      'CRITICAL' => PriorityLevel.critical,
      _ => PriorityLevel.medium,
    };
  }
}

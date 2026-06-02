/// Domain enums for Report entities.
///
/// These are pure Dart enums with no JSON annotations.
/// The data layer DTOs retain @JsonValue for serialization.
library;

/// Report category aligned with Urdaneta City office routing
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
    verified => 'Under Review',
    assigned => 'Under Review',
    inProgress => 'In Progress',
    escalated => 'Under Review',
    endorsed => 'Under Review',
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
    final normalized = value
        ?.trim()
        .toLowerCase()
        .replaceAll('-', '_')
        .replaceAll(' ', '_');

    return switch (normalized) {
      'submitted' || 'pending' => ReportStatus.submitted,
      'under_review' => ReportStatus.underReview,
      'verified' => ReportStatus.verified,
      'assigned' => ReportStatus.assigned,
      'in_progress' => ReportStatus.inProgress,
      'escalated' => ReportStatus.escalated,
      'endorsed' => ReportStatus.endorsed,
      'resolved' => ReportStatus.resolved,
      'closed' || 'citizen_closed' => ReportStatus.closed,
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

// Duplicate detection retired; routing metadata is used instead.

/// Priority level from AI prioritization
enum PriorityLevel {
  veryLow,
  low,
  medium,
  high,
  critical;

  String get displayName => switch (this) {
    veryLow => 'Very Low',
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };

  String get apiValue => switch (this) {
    veryLow => 'VERY_LOW',
    low => 'LOW',
    medium => 'MEDIUM',
    high => 'HIGH',
    critical => 'CRITICAL',
  };

  /// Map AI integer level (1-5) to PriorityLevel
  static PriorityLevel fromInt(int? value) {
    return switch (value) {
      1 => PriorityLevel.veryLow,
      2 => PriorityLevel.low,
      3 => PriorityLevel.medium,
      4 => PriorityLevel.high,
      5 => PriorityLevel.critical,
      _ => PriorityLevel.medium,
    };
  }

  static PriorityLevel? fromString(String? value) {
    return switch (value?.toUpperCase()) {
      'VERY_LOW' => PriorityLevel.veryLow,
      'LOW' => PriorityLevel.low,
      'MEDIUM' => PriorityLevel.medium,
      'HIGH' => PriorityLevel.high,
      'CRITICAL' => PriorityLevel.critical,
      _ => null,
    };
  }
}

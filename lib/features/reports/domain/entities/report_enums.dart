/// Domain enums for Report entities.
///
/// These are pure Dart enums with no JSON annotations.
/// The data layer DTOs retain @JsonValue for serialization.

/// Report category aligned with AI classifier
enum ReportCategory {
  roadTraffic,
  floodingDrainage,
  wasteEnvironment,
  publicSafetyUtilities,
  communityConcerns;

  String get displayName => switch (this) {
    roadTraffic => 'Road & Traffic Issues',
    floodingDrainage => 'Flooding & Drainage',
    wasteEnvironment => 'Waste & Environment',
    publicSafetyUtilities => 'Public Safety & Utilities',
    communityConcerns => 'Community Concerns',
  };

  String get apiValue => switch (this) {
    roadTraffic => 'road_traffic',
    floodingDrainage => 'flooding_drainage',
    wasteEnvironment => 'waste_environment',
    publicSafetyUtilities => 'public_safety_utilities',
    communityConcerns => 'community_concerns',
  };

  static ReportCategory? fromString(String? value) {
    return switch (value) {
      'road_traffic' => ReportCategory.roadTraffic,
      'flooding_drainage' => ReportCategory.floodingDrainage,
      'waste_environment' => ReportCategory.wasteEnvironment,
      'public_safety_utilities' => ReportCategory.publicSafetyUtilities,
      'community_concerns' => ReportCategory.communityConcerns,
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
  resolved,
  rejected;

  String get displayName => switch (this) {
    submitted => 'Submitted',
    underReview => 'Under Review',
    verified => 'Verified',
    assigned => 'Assigned',
    inProgress => 'In Progress',
    resolved => 'Resolved',
    rejected => 'Rejected',
  };

  String get apiValue => switch (this) {
    submitted => 'submitted',
    underReview => 'under_review',
    verified => 'verified',
    assigned => 'assigned',
    inProgress => 'in_progress',
    resolved => 'resolved',
    rejected => 'rejected',
  };

  static ReportStatus fromString(String? value) {
    return switch (value) {
      'submitted' => ReportStatus.submitted,
      'under_review' => ReportStatus.underReview,
      'verified' => ReportStatus.verified,
      'assigned' => ReportStatus.assigned,
      'in_progress' => ReportStatus.inProgress,
      'resolved' => ReportStatus.resolved,
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

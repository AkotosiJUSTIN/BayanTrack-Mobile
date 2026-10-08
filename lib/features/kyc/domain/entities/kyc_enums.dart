/// KYC Domain Enums
///
/// Pure Dart enums for the KYC feature domain layer.
/// No JSON annotations - those stay in data layer DTOs.
library;

// ==================== KYC STATUS ====================

/// Status of a user's KYC verification.
enum KycVerificationStatus {
  unverified,
  pending,
  verified,
  rejected,
  resubmitRequested,
  suspended;

  String get displayName => switch (this) {
    unverified => 'Unverified',
    pending => 'Pending Review',
    verified => 'Verified',
    rejected => 'Rejected',
    resubmitRequested => 'Resubmit Requested',
    suspended => 'Suspended',
  };

  bool get canResubmit => this == rejected || this == resubmitRequested;

  bool get isVerified => this == verified;

  bool get isPending => this == pending;

  /// Parse from string value (API response).
  static KycVerificationStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'unverified' => unverified,
      'pending' => pending,
      'verified' => verified,
      'rejected' => rejected,
      'resubmit_requested' => resubmitRequested,
      'suspended' => suspended,
      _ => unverified,
    };
  }
}

// ==================== PRECHECK STATUS ====================

/// Status of automated pre-verification checks.
enum PrecheckStatus {
  passed,
  failed,
  pending;

  static PrecheckStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'passed' => passed,
      'failed' => failed,
      'pending' => pending,
      _ => pending,
    };
  }
}

// ==================== ID TYPE ====================

/// Types of valid government-issued IDs.
enum IdType {
  passport,
  nationalId,
  driversLicense,
  philsys,
  sss,
  umid,
  postal,
  voters,
  gsisECard,
  philHealth,
  prcProfessionalId;

  String get displayName => switch (this) {
    passport => 'Passport',
    nationalId => 'National ID',
    driversLicense => "Driver's License",
    philsys => 'PhilSys ID',
    sss => 'SSS ID',
    umid => 'UMID',
    postal => 'Postal ID',
    voters => "Voter's ID",
    gsisECard => 'GSIS eCard',
    philHealth => 'PhilHealth ID',
    prcProfessionalId => 'PRC Professional ID',
  };

  /// API value for submission.
  String get apiValue => switch (this) {
    passport => 'passport',
    nationalId => 'national_id',
    driversLicense => 'drivers_license',
    philsys => 'philsys',
    sss => 'sss',
    umid => 'umid',
    postal => 'postal',
    voters => 'voters',
    gsisECard => 'gsis_ecard',
    philHealth => 'philhealth',
    prcProfessionalId => 'prc',
  };

  /// Whether this ID type requires a back image.
  bool get requiresBackImage => switch (this) {
    nationalId || driversLicense || philsys || umid => true,
    _ => false,
  };

  static IdType fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'passport' => passport,
      'national_id' => nationalId,
      'drivers_license' => driversLicense,
      'philsys' => philsys,
      'sss' => sss,
      'umid' => umid,
      'postal' => postal,
      'voters' => voters,
      'gsis_ecard' => gsisECard,
      'philhealth' => philHealth,
      'prc' => prcProfessionalId,
      _ => nationalId,
    };
  }
}

// ==================== SEX ====================

/// Biological sex for identification purposes.
enum Sex {
  male,
  female;

  String get displayName => switch (this) {
    male => 'Male',
    female => 'Female',
  };

  String get apiValue => switch (this) {
    male => 'male',
    female => 'female',
  };

  static Sex fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'male' => male,
      'female' => female,
      _ => male,
    };
  }
}

// ==================== CIVIL STATUS ====================

/// Civil/marital status.
enum CivilStatus {
  single,
  married,
  widowed,
  separated,
  divorced;

  String get displayName => switch (this) {
    single => 'Single',
    married => 'Married',
    widowed => 'Widowed',
    separated => 'Separated',
    divorced => 'Divorced',
  };

  String get apiValue => switch (this) {
    single => 'single',
    married => 'married',
    widowed => 'widowed',
    separated => 'separated',
    divorced => 'divorced',
  };

  static CivilStatus fromString(String? value) {
    return switch (value?.toLowerCase()) {
      'single' => single,
      'married' => married,
      'widowed' => widowed,
      'separated' => separated,
      'divorced' => divorced,
      _ => single,
    };
  }
}

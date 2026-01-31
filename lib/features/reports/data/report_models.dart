import 'package:freezed_annotation/freezed_annotation.dart';

part 'report_models.freezed.dart';
part 'report_models.g.dart';

// ==================== REPORT CATEGORIES ====================

enum ReportCategory {
  @JsonValue('road_infrastructure')
  roadInfrastructure,
  @JsonValue('flooding_drainage')
  floodingDrainage,
  @JsonValue('waste_management')
  wasteManagement,
  @JsonValue('public_safety_hazards')
  publicSafetyHazards,
  @JsonValue('street_lighting_utilities')
  streetLightingUtilities,
  @JsonValue('traffic_obstructions')
  trafficObstructions,
  @JsonValue('environmental')
  environmental,
  @JsonValue('others')
  others;

  String get displayName => switch (this) {
    roadInfrastructure => 'Road & Infrastructure Issues',
    floodingDrainage => 'Flooding & Drainage Problems',
    wasteManagement => 'Waste Management Concerns',
    publicSafetyHazards => 'Public Safety & Hazards',
    streetLightingUtilities => 'Street Lighting & Utilities',
    trafficObstructions => 'Traffic & Road Obstructions',
    environmental => 'Environmental Issues',
    others => 'Others / Miscellaneous',
  };
  
  String get value => switch (this) {
    roadInfrastructure => 'road_infrastructure',
    floodingDrainage => 'flooding_drainage',
    wasteManagement => 'waste_management',
    publicSafetyHazards => 'public_safety_hazards',
    streetLightingUtilities => 'street_lighting_utilities',
    trafficObstructions => 'traffic_obstructions',
    environmental => 'environmental',
    others => 'others',
  };
}

// ==================== INCIDENT TYPES BY CATEGORY ====================

enum IncidentType {
  // Road & Infrastructure Issues
  @JsonValue('pothole') pothole,
  @JsonValue('broken_sidewalk') brokenSidewalk,
  @JsonValue('collapsed_bridge') collapsedBridge,
  @JsonValue('damaged_street_sign') damagedStreetSign,
  @JsonValue('road_crack') roadCrack,
  @JsonValue('pavement_damage') pavementDamage,
  @JsonValue('guardrail_damage') guardrailDamage,
  @JsonValue('other_road_infrastructure') otherRoadInfrastructure,
  
  // Flooding & Drainage Problems
  @JsonValue('flooded_street') floodedStreet,
  @JsonValue('clogged_drainage') cloggedDrainage,
  @JsonValue('overflowing_canal') overflowingCanal,
  @JsonValue('stagnant_water') stagnantWater,
  @JsonValue('drainage_damage') drainageDamage,
  @JsonValue('flood_risk_area') floodRiskArea,
  @JsonValue('other_flooding_drainage') otherFloodingDrainage,
  
  // Waste Management Concerns
  @JsonValue('uncollected_trash') uncollectedTrash,
  @JsonValue('illegal_dumping') illegalDumping,
  @JsonValue('overflowing_bin') overflowingBin,
  @JsonValue('garbage_accumulation') garbageAccumulation,
  @JsonValue('hazardous_waste') hazardousWaste,
  @JsonValue('litter_problem') litterProblem,
  @JsonValue('other_waste_management') otherWasteManagement,
  
  // Public Safety & Hazards
  @JsonValue('exposed_electrical_wire') exposedElectricalWire,
  @JsonValue('open_manhole') openManhole,
  @JsonValue('fallen_tree') fallenTree,
  @JsonValue('unstable_structure') unstableStructure,
  @JsonValue('fire_hazard') fireHazard,
  @JsonValue('sharp_debris') sharpDebris,
  @JsonValue('construction_hazard') constructionHazard,
  @JsonValue('other_safety_hazard') otherSafetyHazard,
  
  // Street Lighting & Utilities
  @JsonValue('broken_streetlight') brokenStreetlight,
  @JsonValue('power_line_issue') powerLineIssue,
  @JsonValue('water_leakage') waterLeakage,
  @JsonValue('damaged_utility_pole') damagedUtilityPole,
  @JsonValue('flickering_light') flickeringLight,
  @JsonValue('dark_area') darkArea,
  @JsonValue('other_lighting_utility') otherLightingUtility,
  
  // Traffic & Road Obstructions
  @JsonValue('illegal_parking') illegalParking,
  @JsonValue('road_blockage') roadBlockage,
  @JsonValue('non_functioning_traffic_light') nonFunctioningTrafficLight,
  @JsonValue('missing_traffic_sign') missingTrafficSign,
  @JsonValue('obstruction_on_road') obstructionOnRoad,
  @JsonValue('traffic_congestion_area') trafficCongestionArea,
  @JsonValue('other_traffic_obstruction') otherTrafficObstruction,
  
  // Environmental Issues
  @JsonValue('smoke_burning') smokeBurning,
  @JsonValue('water_pollution') waterPollution,
  @JsonValue('bad_odor') badOdor,
  @JsonValue('air_pollution') airPollution,
  @JsonValue('noise_pollution') noisePollution,
  @JsonValue('chemical_spill') chemicalSpill,
  @JsonValue('other_environmental') otherEnvironmental,
  
  // Others / Miscellaneous
  @JsonValue('noise_complaint') noiseComplaint,
  @JsonValue('stray_animal') strayAnimal,
  @JsonValue('vandalism') vandalism,
  @JsonValue('public_nuisance') publicNuisance,
  @JsonValue('community_concern') communityConcern,
  @JsonValue('other') other;
  
  String get displayName => switch (this) {
    // Road & Infrastructure
    pothole => 'Pothole',
    brokenSidewalk => 'Broken Sidewalk',
    collapsedBridge => 'Collapsed Bridge',
    damagedStreetSign => 'Damaged Street Sign',
    roadCrack => 'Road Crack',
    pavementDamage => 'Pavement Damage',
    guardrailDamage => 'Guardrail Damage',
    otherRoadInfrastructure => 'Other Road/Infrastructure Issue',
    // Flooding & Drainage
    floodedStreet => 'Flooded Street',
    cloggedDrainage => 'Clogged Drainage',
    overflowingCanal => 'Overflowing Canal',
    stagnantWater => 'Stagnant Water',
    drainageDamage => 'Drainage Damage',
    floodRiskArea => 'Flood Risk Area',
    otherFloodingDrainage => 'Other Flooding/Drainage Issue',
    // Waste Management
    uncollectedTrash => 'Uncollected Trash',
    illegalDumping => 'Illegal Dumping',
    overflowingBin => 'Overflowing Bin',
    garbageAccumulation => 'Garbage Accumulation',
    hazardousWaste => 'Hazardous Waste',
    litterProblem => 'Litter Problem',
    otherWasteManagement => 'Other Waste Management Issue',
    // Public Safety & Hazards
    exposedElectricalWire => 'Exposed Electrical Wire',
    openManhole => 'Open Manhole',
    fallenTree => 'Fallen Tree',
    unstableStructure => 'Unstable Structure',
    fireHazard => 'Fire Hazard',
    sharpDebris => 'Sharp Debris',
    constructionHazard => 'Construction Hazard',
    otherSafetyHazard => 'Other Safety Hazard',
    // Street Lighting & Utilities
    brokenStreetlight => 'Broken Streetlight',
    powerLineIssue => 'Power Line Issue',
    waterLeakage => 'Water Leakage',
    damagedUtilityPole => 'Damaged Utility Pole',
    flickeringLight => 'Flickering Light',
    darkArea => 'Dark Area',
    otherLightingUtility => 'Other Lighting/Utility Issue',
    // Traffic & Road Obstructions
    illegalParking => 'Illegal Parking',
    roadBlockage => 'Road Blockage',
    nonFunctioningTrafficLight => 'Non-functioning Traffic Light',
    missingTrafficSign => 'Missing Traffic Sign',
    obstructionOnRoad => 'Obstruction on Road',
    trafficCongestionArea => 'Traffic Congestion Area',
    otherTrafficObstruction => 'Other Traffic Obstruction',
    // Environmental
    smokeBurning => 'Smoke/Burning',
    waterPollution => 'Water Pollution',
    badOdor => 'Bad Odor',
    airPollution => 'Air Pollution',
    noisePollution => 'Noise Pollution',
    chemicalSpill => 'Chemical Spill',
    otherEnvironmental => 'Other Environmental Issue',
    // Others
    noiseComplaint => 'Noise Complaint',
    strayAnimal => 'Stray Animal',
    vandalism => 'Vandalism',
    publicNuisance => 'Public Nuisance',
    communityConcern => 'Community Concern',
    other => 'Other',
  };
  
  /// Returns the snake_case value for API serialization
  String get value => switch (this) {
    pothole => 'pothole',
    brokenSidewalk => 'broken_sidewalk',
    collapsedBridge => 'collapsed_bridge',
    damagedStreetSign => 'damaged_street_sign',
    roadCrack => 'road_crack',
    pavementDamage => 'pavement_damage',
    guardrailDamage => 'guardrail_damage',
    otherRoadInfrastructure => 'other_road_infrastructure',
    floodedStreet => 'flooded_street',
    cloggedDrainage => 'clogged_drainage',
    overflowingCanal => 'overflowing_canal',
    stagnantWater => 'stagnant_water',
    drainageDamage => 'drainage_damage',
    floodRiskArea => 'flood_risk_area',
    otherFloodingDrainage => 'other_flooding_drainage',
    uncollectedTrash => 'uncollected_trash',
    illegalDumping => 'illegal_dumping',
    overflowingBin => 'overflowing_bin',
    garbageAccumulation => 'garbage_accumulation',
    hazardousWaste => 'hazardous_waste',
    litterProblem => 'litter_problem',
    otherWasteManagement => 'other_waste_management',
    exposedElectricalWire => 'exposed_electrical_wire',
    openManhole => 'open_manhole',
    fallenTree => 'fallen_tree',
    unstableStructure => 'unstable_structure',
    fireHazard => 'fire_hazard',
    sharpDebris => 'sharp_debris',
    constructionHazard => 'construction_hazard',
    otherSafetyHazard => 'other_safety_hazard',
    brokenStreetlight => 'broken_streetlight',
    powerLineIssue => 'power_line_issue',
    waterLeakage => 'water_leakage',
    damagedUtilityPole => 'damaged_utility_pole',
    flickeringLight => 'flickering_light',
    darkArea => 'dark_area',
    otherLightingUtility => 'other_lighting_utility',
    illegalParking => 'illegal_parking',
    roadBlockage => 'road_blockage',
    nonFunctioningTrafficLight => 'non_functioning_traffic_light',
    missingTrafficSign => 'missing_traffic_sign',
    obstructionOnRoad => 'obstruction_on_road',
    trafficCongestionArea => 'traffic_congestion_area',
    otherTrafficObstruction => 'other_traffic_obstruction',
    smokeBurning => 'smoke_burning',
    waterPollution => 'water_pollution',
    badOdor => 'bad_odor',
    airPollution => 'air_pollution',
    noisePollution => 'noise_pollution',
    chemicalSpill => 'chemical_spill',
    otherEnvironmental => 'other_environmental',
    noiseComplaint => 'noise_complaint',
    strayAnimal => 'stray_animal',
    vandalism => 'vandalism',
    publicNuisance => 'public_nuisance',
    communityConcern => 'community_concern',
    other => 'other',
  };
  
  ReportCategory get category => switch (this) {
    pothole || brokenSidewalk || collapsedBridge || damagedStreetSign || 
    roadCrack || pavementDamage || guardrailDamage || otherRoadInfrastructure => ReportCategory.roadInfrastructure,
    
    floodedStreet || cloggedDrainage || overflowingCanal || stagnantWater || 
    drainageDamage || floodRiskArea || otherFloodingDrainage => ReportCategory.floodingDrainage,
    
    uncollectedTrash || illegalDumping || overflowingBin || garbageAccumulation || 
    hazardousWaste || litterProblem || otherWasteManagement => ReportCategory.wasteManagement,
    
    exposedElectricalWire || openManhole || fallenTree || unstableStructure || 
    fireHazard || sharpDebris || constructionHazard || otherSafetyHazard => ReportCategory.publicSafetyHazards,
    
    brokenStreetlight || powerLineIssue || waterLeakage || damagedUtilityPole || 
    flickeringLight || darkArea || otherLightingUtility => ReportCategory.streetLightingUtilities,
    
    illegalParking || roadBlockage || nonFunctioningTrafficLight || missingTrafficSign || 
    obstructionOnRoad || trafficCongestionArea || otherTrafficObstruction => ReportCategory.trafficObstructions,
    
    smokeBurning || waterPollution || badOdor || airPollution || 
    noisePollution || chemicalSpill || otherEnvironmental => ReportCategory.environmental,
    
    _ => ReportCategory.others,
  };
}

/// Get incident types for a category
List<IncidentType> getIncidentTypesForCategory(ReportCategory category) {
  return switch (category) {
    ReportCategory.roadInfrastructure => [
      IncidentType.pothole, IncidentType.brokenSidewalk, IncidentType.collapsedBridge,
      IncidentType.damagedStreetSign, IncidentType.roadCrack, IncidentType.pavementDamage,
      IncidentType.guardrailDamage, IncidentType.otherRoadInfrastructure,
    ],
    ReportCategory.floodingDrainage => [
      IncidentType.floodedStreet, IncidentType.cloggedDrainage, IncidentType.overflowingCanal,
      IncidentType.stagnantWater, IncidentType.drainageDamage, IncidentType.floodRiskArea,
      IncidentType.otherFloodingDrainage,
    ],
    ReportCategory.wasteManagement => [
      IncidentType.uncollectedTrash, IncidentType.illegalDumping, IncidentType.overflowingBin,
      IncidentType.garbageAccumulation, IncidentType.hazardousWaste, IncidentType.litterProblem,
      IncidentType.otherWasteManagement,
    ],
    ReportCategory.publicSafetyHazards => [
      IncidentType.exposedElectricalWire, IncidentType.openManhole, IncidentType.fallenTree,
      IncidentType.unstableStructure, IncidentType.fireHazard, IncidentType.sharpDebris,
      IncidentType.constructionHazard, IncidentType.otherSafetyHazard,
    ],
    ReportCategory.streetLightingUtilities => [
      IncidentType.brokenStreetlight, IncidentType.powerLineIssue, IncidentType.waterLeakage,
      IncidentType.damagedUtilityPole, IncidentType.flickeringLight, IncidentType.darkArea,
      IncidentType.otherLightingUtility,
    ],
    ReportCategory.trafficObstructions => [
      IncidentType.illegalParking, IncidentType.roadBlockage, IncidentType.nonFunctioningTrafficLight,
      IncidentType.missingTrafficSign, IncidentType.obstructionOnRoad, IncidentType.trafficCongestionArea,
      IncidentType.otherTrafficObstruction,
    ],
    ReportCategory.environmental => [
      IncidentType.smokeBurning, IncidentType.waterPollution, IncidentType.badOdor,
      IncidentType.airPollution, IncidentType.noisePollution, IncidentType.chemicalSpill,
      IncidentType.otherEnvironmental,
    ],
    ReportCategory.others => [
      IncidentType.noiseComplaint, IncidentType.strayAnimal, IncidentType.vandalism,
      IncidentType.publicNuisance, IncidentType.communityConcern, IncidentType.other,
    ],
  };
}

// ==================== REPORT STATUS ====================

enum ReportStatus {
  @JsonValue('submitted')
  submitted,
  @JsonValue('under_review')
  underReview,
  @JsonValue('verified')
  verified,
  @JsonValue('assigned')
  assigned,
  @JsonValue('in_progress')
  inProgress,
  @JsonValue('resolved')
  resolved,
  @JsonValue('rejected')
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
  
  String get value => switch (this) {
    submitted => 'submitted',
    underReview => 'under_review',
    verified => 'verified',
    assigned => 'assigned',
    inProgress => 'in_progress',
    resolved => 'resolved',
    rejected => 'rejected',
  };
}

// ==================== SEVERITY LEVELS ====================

enum SeverityLevel {
  @JsonValue('low')
  low,
  @JsonValue('medium')
  medium,
  @JsonValue('high')
  high,
  @JsonValue('critical')
  critical;

  String get displayName => switch (this) {
    low => 'Low',
    medium => 'Medium',
    high => 'High',
    critical => 'Critical',
  };
  
  String get value => switch (this) {
    low => 'low',
    medium => 'medium',
    high => 'high',
    critical => 'critical',
  };
}

// ==================== LOCATION ACCURACY ====================

enum LocationAccuracy {
  @JsonValue('exact')
  exact,
  @JsonValue('approximate')
  approximate;

  String get displayName => switch (this) {
    exact => 'Exact',
    approximate => 'Approximate',
  };
}

// ==================== DUPLICATE STATE ====================

enum DuplicateState {
  @JsonValue('new')
  newReport,
  @JsonValue('potential_duplicate')
  potentialDuplicate,
  @JsonValue('confirmed_duplicate')
  confirmedDuplicate,
  @JsonValue('unique')
  unique;
}

// ==================== REPORT IMAGE ====================

@freezed
sealed class ReportImage with _$ReportImage {
  const factory ReportImage({
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,
    required String url,
    @JsonKey(name: 's3_key') String? s3Key,
    String? filename,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    int? width,
    int? height,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
  }) = _ReportImage;

  factory ReportImage.fromJson(Map<String, dynamic> json) =>
      _$ReportImageFromJson(json);
}

// ==================== REPORT ====================

@freezed
sealed class Report with _$Report {
  const factory Report({
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,
    
    // Report Details
    String? category,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? title,
    required String description,
    @JsonKey(name: 'incident_datetime') String? incidentDatetime,
    @JsonKey(name: 'is_happening_now') @Default(false) bool isHappeningNow,
    
    // Location Information
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    @JsonKey(name: 'location_accuracy') @Default('approximate') String locationAccuracy,
    // Legacy fields
    String? location,
    String? barangay,
    
    // Severity & Impact
    @Default('medium') String severity,
    @JsonKey(name: 'people_affected') int? peopleAffected,
    @JsonKey(name: 'is_emergency') @Default(false) bool isEmergency,
    
    // System Fields
    @Default('submitted') String status,
    @JsonKey(name: 'assigned_department') String? assignedDepartment,
    @JsonKey(name: 'admin_remarks') String? adminRemarks,
    
    // AI Fields
    @JsonKey(name: 'category_confidence') double? categoryConfidence,
    String? priority,
    @JsonKey(name: 'priority_score') int? priorityScore,
    @JsonKey(name: 'urgency_score') double? urgencyScore,
    @JsonKey(name: 'duplicate_state') String? duplicateState,
    @JsonKey(name: 'related_report_id') String? relatedReportId,
    @JsonKey(name: 'related_issue_id') String? relatedIssueId,
    @JsonKey(name: 'sentiment_score') double? sentimentScore,
    @JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion,
    
    // Images
    @Default([]) List<ReportImage> images,
    
    // Timestamps
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
    @JsonKey(name: 'submitted_at') String? submittedAt,
    @JsonKey(name: 'verified_at') String? verifiedAt,
    @JsonKey(name: 'resolved_at') String? resolvedAt,
  }) = _Report;

  factory Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);
}

// ==================== CREATE REPORT REQUEST ====================

@freezed
sealed class CreateReportRequest with _$CreateReportRequest {
  const factory CreateReportRequest({
    // Report Details (Section A)
    String? category,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? title,
    required String description,
    @JsonKey(name: 'incident_datetime') String? incidentDatetime,
    @JsonKey(name: 'is_happening_now') @Default(false) bool isHappeningNow,
    
    // Location Information (Section B)
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    @JsonKey(name: 'location_accuracy') @Default('approximate') String locationAccuracy,
    // Legacy fields for backwards compatibility
    String? location,
    String? barangay,
    
    // Severity & Impact (Section C)
    @Default('medium') String severity,
    @JsonKey(name: 'people_affected') int? peopleAffected,
    @JsonKey(name: 'is_emergency') @Default(false) bool isEmergency,
    
    // Consent & Declaration (Section D)
    @JsonKey(name: 'declaration_confirmed') @Default(true) bool declarationConfirmed,
    @JsonKey(name: 'data_processing_consent') @Default(true) bool dataProcessingConsent,
  }) = _CreateReportRequest;

  factory CreateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$CreateReportRequestFromJson(json);
}

// ==================== UPDATE REPORT REQUEST ====================

@freezed
sealed class UpdateReportRequest with _$UpdateReportRequest {
  const factory UpdateReportRequest({
    String? title,
    String? description,
    String? category,
    @JsonKey(name: 'incident_type') String? incidentType,
    String? severity,
    @JsonKey(name: 'people_affected') int? peopleAffected,
    @JsonKey(name: 'is_emergency') bool? isEmergency,
    String? zone,
    @JsonKey(name: 'street_landmark') String? streetLandmark,
    @JsonKey(name: 'city_municipality') String? cityMunicipality,
    String? province,
    // Legacy
    String? barangay,
  }) = _UpdateReportRequest;

  factory UpdateReportRequest.fromJson(Map<String, dynamic> json) =>
      _$UpdateReportRequestFromJson(json);
}

// ==================== STATUS UPDATE REQUEST ====================

@freezed
sealed class ReportStatusUpdateRequest with _$ReportStatusUpdateRequest {
  const factory ReportStatusUpdateRequest({
    required String status,
    @JsonKey(name: 'admin_remarks') String? adminRemarks,
    @JsonKey(name: 'assigned_department') String? assignedDepartment,
  }) = _ReportStatusUpdateRequest;

  factory ReportStatusUpdateRequest.fromJson(Map<String, dynamic> json) =>
      _$ReportStatusUpdateRequestFromJson(json);
}

// ==================== PAGINATED RESPONSE ====================

@freezed
sealed class PaginatedReports with _$PaginatedReports {
  const factory PaginatedReports({
    required List<Report> results,
    @Default(0) int count,
    @Default(0) int total,
    @Default(1) int page,
    @JsonKey(name: 'page_size') @Default(20) int pageSize,
    @JsonKey(name: 'total_pages') @Default(1) int totalPages,
  }) = _PaginatedReports;

  factory PaginatedReports.fromJson(Map<String, dynamic> json) =>
      _$PaginatedReportsFromJson(json);
}

// ==================== REPORT STATISTICS ====================

@freezed
sealed class ReportStats with _$ReportStats {
  const factory ReportStats({
    @Default(0) int total,
    @JsonKey(name: 'by_status') Map<String, int>? byStatus,
    @JsonKey(name: 'by_category') Map<String, int>? byCategory,
    @JsonKey(name: 'by_severity') Map<String, int>? bySeverity,
    @Default(0) int emergencies,
    // Legacy flat fields
    @Default(0) int submitted,
    @JsonKey(name: 'under_review') @Default(0) int underReview,
    @Default(0) int verified,
    @Default(0) int assigned,
    @JsonKey(name: 'in_progress') @Default(0) int inProgress,
    @Default(0) int resolved,
    @Default(0) int rejected,
  }) = _ReportStats;

  factory ReportStats.fromJson(Map<String, dynamic> json) =>
      _$ReportStatsFromJson(json);
}

// ==================== FORM OPTIONS ====================

@freezed
sealed class ReportFormOptions with _$ReportFormOptions {
  const factory ReportFormOptions({
    required List<Map<String, dynamic>> categories,
    @JsonKey(name: 'incident_types') required Map<String, List<Map<String, dynamic>>> incidentTypes,
    required List<Map<String, dynamic>> statuses,
    @JsonKey(name: 'severity_levels') required List<Map<String, dynamic>> severityLevels,
  }) = _ReportFormOptions;

  factory ReportFormOptions.fromJson(Map<String, dynamic> json) =>
      _$ReportFormOptionsFromJson(json);
}

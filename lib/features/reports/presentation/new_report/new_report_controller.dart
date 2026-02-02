import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../data/report_models.dart';

part 'new_report_controller.g.dart';

/// State for the new report flow - comprehensive fields matching backend
class NewReportState {
  // Images
  final List<File> selectedImages;
  
  // Section A: Report Details
  final ReportCategory? category;
  final String? title;
  final String description;
  final DateTime? incidentDatetime;
  final bool isHappeningNow;
  
  // Section B: Location Information
  final String? zone;
  final String? streetLandmark;
  final String? cityMunicipality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final LocationAccuracy locationAccuracy;
  final String? location; // Human-readable full address
  
  // Section C: Severity & Impact
  final SeverityLevel severity;
  final int? peopleAffected;
  final bool isEmergency;
  
  // Section D: Consent & Declaration
  final bool declarationConfirmed;
  final bool dataProcessingConsent;
  
  // Form state
  final bool isSubmitting;
  final String? error;

  const NewReportState({
    this.selectedImages = const [],
    this.category,
    this.title,
    this.description = '',
    this.incidentDatetime,
    this.isHappeningNow = false,
    this.zone,
    this.streetLandmark,
    this.cityMunicipality,
    this.province,
    this.latitude,
    this.longitude,
    this.locationAccuracy = LocationAccuracy.approximate,
    this.location,
    this.severity = SeverityLevel.medium,
    this.peopleAffected,
    this.isEmergency = false,
    this.declarationConfirmed = false,
    this.dataProcessingConsent = false,
    this.isSubmitting = false,
    this.error,
  });

  NewReportState copyWith({
    List<File>? selectedImages,
    ReportCategory? category,
    String? title,
    String? description,
    DateTime? incidentDatetime,
    bool? isHappeningNow,
    String? zone,
    String? streetLandmark,
    String? cityMunicipality,
    String? province,
    double? latitude,
    double? longitude,
    LocationAccuracy? locationAccuracy,
    String? location,
    SeverityLevel? severity,
    int? peopleAffected,
    bool? isEmergency,
    bool? declarationConfirmed,
    bool? dataProcessingConsent,
    bool? isSubmitting,
    String? error,
  }) {
    return NewReportState(
      selectedImages: selectedImages ?? this.selectedImages,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      incidentDatetime: incidentDatetime ?? this.incidentDatetime,
      isHappeningNow: isHappeningNow ?? this.isHappeningNow,
      zone: zone ?? this.zone,
      streetLandmark: streetLandmark ?? this.streetLandmark,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      province: province ?? this.province,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      location: location ?? this.location,
      severity: severity ?? this.severity,
      peopleAffected: peopleAffected ?? this.peopleAffected,
      isEmergency: isEmergency ?? this.isEmergency,
      declarationConfirmed: declarationConfirmed ?? this.declarationConfirmed,
      dataProcessingConsent: dataProcessingConsent ?? this.dataProcessingConsent,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  /// Check if we have everything needed to submit
  bool get canSubmit =>
      selectedImages.isNotEmpty &&
      hasLocation &&
      hasDetails &&
      declarationConfirmed &&
      dataProcessingConsent;

  /// Section validations
  bool get hasPhotos => selectedImages.isNotEmpty;
  
  bool get hasLocation => 
      (zone != null && zone!.isNotEmpty) ||
      (streetLandmark != null && streetLandmark!.isNotEmpty) ||
      (latitude != null && longitude != null);
  
  bool get hasDetails => 
      description.trim().isNotEmpty;
  
  bool get hasCategory => category != null;
  
  bool get hasConsent => declarationConfirmed && dataProcessingConsent;

  /// Build CreateReportRequest from current state
  CreateReportRequest toCreateRequest() {
    return CreateReportRequest(
      category: category?.value,
      title: title,
      description: description,
      incidentDatetime: incidentDatetime?.toIso8601String(),
      isHappeningNow: isHappeningNow,
      zone: zone,
      streetLandmark: streetLandmark,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: latitude?.toString(),
      longitude: longitude?.toString(),
      locationAccuracy: locationAccuracy.name,
      location: streetLandmark ?? location,
      severity: severity.value,
      peopleAffected: peopleAffected,
      isEmergency: isEmergency,
      declarationConfirmed: declarationConfirmed,
      dataProcessingConsent: dataProcessingConsent,
    );
  }
}

/// Controller for managing new report flow state
@riverpod
class NewReportController extends _$NewReportController {
  static const int maxImages = 5;

  @override
  NewReportState build() => const NewReportState();

  // ==================== IMAGES ====================

  void addImage(File image) {
    if (state.selectedImages.length >= maxImages) return;
    state = state.copyWith(selectedImages: [...state.selectedImages, image]);
  }

  void addImages(List<File> images) {
    final remaining = maxImages - state.selectedImages.length;
    final toAdd = images.take(remaining).toList();
    state = state.copyWith(selectedImages: [...state.selectedImages, ...toAdd]);
  }

  void removeImage(int index) {
    if (index < 0 || index >= state.selectedImages.length) return;
    final updated = List<File>.from(state.selectedImages)..removeAt(index);
    state = state.copyWith(selectedImages: updated);
  }

  void clearImages() {
    state = state.copyWith(selectedImages: []);
  }

  // ==================== REPORT DETAILS (Section A) ====================

  void setCategory(ReportCategory? category) {
    state = state.copyWith(category: category);
  }

  void setTitle(String? title) {
    state = state.copyWith(title: title);
  }

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setIncidentDatetime(DateTime? datetime) {
    state = state.copyWith(incidentDatetime: datetime);
  }

  void setIsHappeningNow(bool value) {
    state = state.copyWith(
      isHappeningNow: value,
      incidentDatetime: value ? DateTime.now() : state.incidentDatetime,
    );
  }

  // ==================== LOCATION (Section B) ====================

  void setLocation({
    required double latitude,
    required double longitude,
    String? location,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      location: location,
    );
  }

  void setZone(String? zone) {
    state = state.copyWith(zone: zone);
  }

  void setStreetLandmark(String? streetLandmark) {
    state = state.copyWith(streetLandmark: streetLandmark);
  }

  void setCityMunicipality(String? cityMunicipality) {
    state = state.copyWith(cityMunicipality: cityMunicipality);
  }

  void setProvince(String? province) {
    state = state.copyWith(province: province);
  }

  void setLocationAccuracy(LocationAccuracy accuracy) {
    state = state.copyWith(locationAccuracy: accuracy);
  }

  void clearLocation() {
    state = state.copyWith(
      latitude: null,
      longitude: null,
      location: null,
      zone: null,
      streetLandmark: null,
    );
  }

  // ==================== SEVERITY & IMPACT (Section C) ====================

  void setSeverity(SeverityLevel severity) {
    state = state.copyWith(severity: severity);
  }

  void setPeopleAffected(int? count) {
    state = state.copyWith(peopleAffected: count);
  }

  void setIsEmergency(bool value) {
    state = state.copyWith(
      isEmergency: value,
      severity: value ? SeverityLevel.critical : state.severity,
    );
  }

  // ==================== CONSENT (Section D) ====================

  void setDeclarationConfirmed(bool value) {
    state = state.copyWith(declarationConfirmed: value);
  }

  void setDataProcessingConsent(bool value) {
    state = state.copyWith(dataProcessingConsent: value);
  }

  // ==================== FORM STATE ====================

  void setSubmitting(bool isSubmitting) {
    state = state.copyWith(isSubmitting: isSubmitting);
  }

  void setError(String? error) {
    state = state.copyWith(error: error);
  }

  /// Reset the entire form
  void reset() {
    state = const NewReportState();
  }
}

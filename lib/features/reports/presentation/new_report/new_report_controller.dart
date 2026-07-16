import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/urdaneta_geo.dart';
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
  final String municipalityId;
  final String? barangayId;
  final String? barangay;
  final String? cityMunicipality;
  final String? province;
  final double? latitude;
  final double? longitude;
  final LocationAccuracy locationAccuracy;
  final String? location; // Human-readable full address

  // Section C: Consent & Declaration
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
    this.municipalityId = 'urdaneta',
    this.barangayId,
    this.barangay,
    this.cityMunicipality = UrdanetaGeo.defaultCityMunicipality,
    this.province = UrdanetaGeo.defaultProvince,
    this.latitude,
    this.longitude,
    this.locationAccuracy = LocationAccuracy.approximate,
    this.location,
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
    String? municipalityId,
    String? barangayId,
    String? barangay,
    String? cityMunicipality,
    String? province,
    double? latitude,
    double? longitude,
    LocationAccuracy? locationAccuracy,
    String? location,
    bool? declarationConfirmed,
    bool? dataProcessingConsent,
    bool? isSubmitting,
    String? error,
    bool clearLocation = false,
    bool clearBarangay = false,
  }) {
    return NewReportState(
      selectedImages: selectedImages ?? this.selectedImages,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      incidentDatetime: incidentDatetime ?? this.incidentDatetime,
      isHappeningNow: isHappeningNow ?? this.isHappeningNow,
      zone: clearLocation || clearBarangay ? null : zone ?? this.zone,
      streetLandmark: clearLocation
          ? null
          : streetLandmark ?? this.streetLandmark,
      municipalityId: municipalityId ?? this.municipalityId,
      barangayId: clearBarangay ? null : barangayId ?? this.barangayId,
      barangay: clearBarangay ? null : barangay ?? this.barangay,
      cityMunicipality: cityMunicipality ?? this.cityMunicipality,
      province: province ?? this.province,
      latitude: clearLocation ? null : latitude ?? this.latitude,
      longitude: clearLocation ? null : longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      location: clearLocation ? null : location ?? this.location,
      declarationConfirmed: declarationConfirmed ?? this.declarationConfirmed,
      dataProcessingConsent:
          dataProcessingConsent ?? this.dataProcessingConsent,
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

  bool get hasDetails => description.trim().isNotEmpty;

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
      municipalityId: municipalityId,
      barangayId: barangayId,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: _formatCoordinate(latitude),
      longitude: _formatCoordinate(longitude),
      locationAccuracy: locationAccuracy.name,
      location: streetLandmark ?? location,
      barangay: barangay ?? zone,
      declarationConfirmed: declarationConfirmed,
      dataProcessingConsent: dataProcessingConsent,
    );
  }

  String? _formatCoordinate(double? value) {
    if (value == null) return null;
    // Backend expects up to 10 decimal places for coordinates.
    return value.toStringAsFixed(10);
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

  void setMunicipality({
    required String id,
    required String name,
    required String province,
  }) {
    if (state.municipalityId == id) return;
    state = state.copyWith(
      municipalityId: id,
      cityMunicipality: name,
      province: province,
      clearLocation: true,
      clearBarangay: true,
    );
  }

  void setBarangay({required String id, required String name}) {
    state = state.copyWith(barangayId: id, barangay: name, zone: name);
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
    state = state.copyWith(clearLocation: true, clearBarangay: true);
  }

  // ==================== CONSENT (Section C) ====================

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

import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../../core/constants/urdaneta_geo.dart';
import '../../../auth/data/auth_models.dart';
import '../../data/report_models.dart';
import '../../domain/entities/report.dart' as domain;
import '../../reports_di.dart';
import 'quick_report_geo.dart';

part 'new_report_controller.g.dart';

class ReportSubmissionFailure implements Exception {
  const ReportSubmissionFailure(this.message);

  final String message;
}

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
  final bool isResolvingBarangay;
  final bool isResolvingLandmark;
  final List<String> nearbyLandmarkSuggestions;
  final String? landmarkLookupError;
  final bool landmarkManuallyEdited;

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
    this.isResolvingBarangay = false,
    this.isResolvingLandmark = false,
    this.nearbyLandmarkSuggestions = const [],
    this.landmarkLookupError,
    this.landmarkManuallyEdited = false,
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
    bool? isResolvingBarangay,
    bool? isResolvingLandmark,
    List<String>? nearbyLandmarkSuggestions,
    String? landmarkLookupError,
    bool? landmarkManuallyEdited,
    bool? declarationConfirmed,
    bool? dataProcessingConsent,
    bool? isSubmitting,
    String? error,
    bool clearLocation = false,
    bool clearBarangay = false,
    bool clearStreetLandmark = false,
    bool clearLandmarkSuggestions = false,
  }) {
    return NewReportState(
      selectedImages: selectedImages ?? this.selectedImages,
      category: category ?? this.category,
      title: title ?? this.title,
      description: description ?? this.description,
      incidentDatetime: incidentDatetime ?? this.incidentDatetime,
      isHappeningNow: isHappeningNow ?? this.isHappeningNow,
      zone: clearLocation || clearBarangay ? null : zone ?? this.zone,
      streetLandmark: clearLocation || clearStreetLandmark
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
      isResolvingBarangay: isResolvingBarangay ?? this.isResolvingBarangay,
      isResolvingLandmark: isResolvingLandmark ?? this.isResolvingLandmark,
      nearbyLandmarkSuggestions: clearLocation || clearLandmarkSuggestions
          ? const []
          : nearbyLandmarkSuggestions ?? this.nearbyLandmarkSuggestions,
      landmarkLookupError: landmarkLookupError,
      landmarkManuallyEdited: clearLocation
          ? false
          : landmarkManuallyEdited ?? this.landmarkManuallyEdited,
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

  void beginBarangayResolution() {
    state = state.copyWith(isResolvingBarangay: true, clearBarangay: true);
  }

  void completeBarangayResolution(BarangayModel? barangay) {
    if (barangay == null) {
      state = state.copyWith(isResolvingBarangay: false, clearBarangay: true);
      return;
    }
    state = state.copyWith(
      isResolvingBarangay: false,
      barangayId: barangay.id,
      barangay: barangay.name,
      zone: barangay.name,
    );
  }

  void beginLandmarkLookup() {
    state = state.copyWith(
      isResolvingLandmark: true,
      clearStreetLandmark: !state.landmarkManuallyEdited,
      clearLandmarkSuggestions: true,
      landmarkLookupError: null,
    );
  }

  void completeLandmarkLookup(NearbyLandmarkSuggestion suggestion) {
    state = state.copyWith(
      isResolvingLandmark: false,
      clearStreetLandmark:
          !state.landmarkManuallyEdited && suggestion.prefill == null,
      streetLandmark: state.landmarkManuallyEdited
          ? state.streetLandmark
          : suggestion.prefill,
      nearbyLandmarkSuggestions: suggestion.choices,
      landmarkLookupError: null,
    );
  }

  void failLandmarkLookup() {
    state = state.copyWith(
      isResolvingLandmark: false,
      clearLandmarkSuggestions: true,
      landmarkLookupError: 'Nearby landmark suggestions unavailable.',
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
    state = state.copyWith(
      streetLandmark: streetLandmark,
      landmarkManuallyEdited: true,
      landmarkLookupError: null,
    );
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
      clearLocation: true,
      clearBarangay: true,
      clearLandmarkSuggestions: true,
      landmarkManuallyEdited: false,
    );
  }

  // ==================== CONSENT (Section C) ====================

  void setDeclarationConfirmed(bool value) {
    state = state.copyWith(declarationConfirmed: value);
  }

  void setDataProcessingConsent(bool value) {
    state = state.copyWith(dataProcessingConsent: value);
  }

  Future<domain.Report> submit() async {
    if (!state.canSubmit) {
      throw const ReportSubmissionFailure(
        'Please complete all required report fields.',
      );
    }
    state = state.copyWith(isSubmitting: true, error: null);
    try {
      final useCase = ref.read(createReportUseCaseProvider);
      final result = await useCase(
        category: state.category?.value,
        title: state.title,
        description: state.description,
        incidentDatetime: state.incidentDatetime?.toIso8601String(),
        isHappeningNow: state.isHappeningNow,
        zone: state.zone,
        streetLandmark: state.streetLandmark,
        municipalityId: state.municipalityId,
        barangayId: state.barangayId,
        cityMunicipality: state.cityMunicipality,
        province: state.province,
        latitude: _formatCoordinate(state.latitude),
        longitude: _formatCoordinate(state.longitude),
        locationAccuracy: state.locationAccuracy.name,
        // Coordinates are authoritative; do not turn a coordinate label into
        // a persisted landmark when the optional field is blank.
        location: state.streetLandmark,
        barangay: state.barangay ?? state.zone,
        declarationConfirmed: state.declarationConfirmed,
        dataProcessingConsent: state.dataProcessingConsent,
      );
      return result.when(
        success: (report) => report,
        failure: (failure) => throw ReportSubmissionFailure(failure.message),
      );
    } on ReportSubmissionFailure catch (error) {
      if (ref.mounted) state = state.copyWith(error: error.message);
      rethrow;
    } finally {
      if (ref.mounted) state = state.copyWith(isSubmitting: false);
    }
  }

  Future<domain.Report> submitQuickReport({
    required String description,
    required String municipalityId,
    String? barangayId,
    String? barangay,
    required String cityMunicipality,
    required String province,
    required double latitude,
    required double longitude,
    String? location,
  }) async {
    final useCase = ref.read(createReportUseCaseProvider);
    final result = await useCase(
      description: description,
      isHappeningNow: true,
      zone: barangay,
      municipalityId: municipalityId,
      barangayId: barangayId,
      barangay: barangay,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: _formatCoordinate(latitude),
      longitude: _formatCoordinate(longitude),
      locationAccuracy: LocationAccuracy.exact.name,
      location: location,
      declarationConfirmed: true,
      dataProcessingConsent: true,
      isQuickReport: true,
    );
    return result.when(
      success: (report) => report,
      failure: (failure) => throw ReportSubmissionFailure(failure.message),
    );
  }

  Future<domain.Report> submitEmergencyReport({
    required String category,
    required String municipalityId,
    String? barangayId,
    String? barangay,
    required String cityMunicipality,
    required String province,
    required double latitude,
    required double longitude,
    String? idempotencyKey,
  }) async {
    final useCase = ref.read(createReportUseCaseProvider);
    final result = await useCase(
      category: category,
      description: '',
      isHappeningNow: true,
      municipalityId: municipalityId,
      barangayId: barangayId,
      barangay: barangay,
      zone: barangay,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: _formatCoordinate(latitude),
      longitude: _formatCoordinate(longitude),
      locationAccuracy: LocationAccuracy.exact.name,
      declarationConfirmed: true,
      dataProcessingConsent: true,
      isQuickReport: true,
      isEmergency: true,
      idempotencyKey: idempotencyKey,
    );
    return result.when(
      success: (report) => report,
      failure: (failure) => throw ReportSubmissionFailure(failure.message),
    );
  }

  String? _formatCoordinate(double? value) {
    if (value == null) return null;
    return value.toStringAsFixed(10);
  }

  /// Reset the entire form
  void reset() {
    state = const NewReportState();
  }
}

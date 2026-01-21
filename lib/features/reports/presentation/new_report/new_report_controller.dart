import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'new_report_controller.g.dart';

/// State for the new report flow
class NewReportState {
  final List<File> selectedImages;
  final double? latitude;
  final double? longitude;
  final String? location; // Human-readable address
  final String description;
  final String? category;
  final String barangay;
  final String? imageBase64; // Base64 encoded image for API
  final bool isSubmitting;
  final String? error;

  const NewReportState({
    this.selectedImages = const [],
    this.latitude,
    this.longitude,
    this.location,
    this.description = '',
    this.category,
    this.barangay = '',
    this.imageBase64,
    this.isSubmitting = false,
    this.error,
  });

  NewReportState copyWith({
    List<File>? selectedImages,
    double? latitude,
    double? longitude,
    String? location,
    String? description,
    String? category,
    String? barangay,
    String? imageBase64,
    bool? isSubmitting,
    String? error,
  }) {
    return NewReportState(
      selectedImages: selectedImages ?? this.selectedImages,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      location: location ?? this.location,
      description: description ?? this.description,
      category: category ?? this.category,
      barangay: barangay ?? this.barangay,
      imageBase64: imageBase64 ?? this.imageBase64,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      error: error,
    );
  }

  /// Check if we have everything needed to submit
  bool get canSubmit =>
      selectedImages.isNotEmpty &&
      location != null &&
      location!.isNotEmpty &&
      barangay.isNotEmpty &&
      description.trim().isNotEmpty;

  /// Current step validation
  bool get hasPhotos => selectedImages.isNotEmpty;
  bool get hasLocation => location != null && location!.isNotEmpty;
  bool get hasDetails => description.trim().isNotEmpty && barangay.isNotEmpty;
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

  // ==================== LOCATION ====================

  void setLocation({
    required double latitude,
    required double longitude,
    required String location,
  }) {
    state = state.copyWith(
      latitude: latitude,
      longitude: longitude,
      location: location,
    );
  }

  void clearLocation() {
    state = NewReportState(
      selectedImages: state.selectedImages,
      description: state.description,
      category: state.category,
      barangay: state.barangay,
    );
  }

  // ==================== IMAGE BASE64 ====================

  void setImageBase64(String? base64) {
    state = state.copyWith(imageBase64: base64);
  }

  // ==================== DETAILS ====================

  void setDescription(String description) {
    state = state.copyWith(description: description);
  }

  void setCategory(String? category) {
    state = state.copyWith(category: category);
  }

  void setBarangay(String? barangay) {
    state = state.copyWith(barangay: barangay);
  }

  // ==================== SUBMIT ====================

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

/// Available report categories
const List<String> reportCategories = [
  'Road Damage',
  'Garbage/Sanitation',
  'Electrical',
  'Flooding',
  'Infrastructure',
  'Public Safety',
  'Environmental',
  'Other',
];

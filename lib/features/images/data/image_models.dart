import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_models.freezed.dart';
part 'image_models.g.dart';

// ==================== UPLOADED IMAGE ====================

@freezed
sealed class UploadedImage with _$UploadedImage {
  const factory UploadedImage({
    @JsonKey(name: '_id') required String id,
    @JsonKey(name: 'report_id') required String reportId,
    @JsonKey(name: 'image_url') required String imageUrl,
    @JsonKey(name: 'thumbnail_url') String? thumbnailUrl,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'uploaded_by') String? uploadedBy,
    @JsonKey(name: 'created_at') String? createdAt,
  }) = _UploadedImage;

  factory UploadedImage.fromJson(Map<String, dynamic> json) =>
      _$UploadedImageFromJson(json);
}

// ==================== IMAGE UPLOAD RESPONSE ====================

@freezed
sealed class ImageUploadResponse with _$ImageUploadResponse {
  const factory ImageUploadResponse({
    required String message,
    UploadedImage? image,
    List<UploadedImage>? images,
  }) = _ImageUploadResponse;

  factory ImageUploadResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageUploadResponseFromJson(json);
}

// ==================== IMAGE LIST RESPONSE ====================

@freezed
sealed class ImageListResponse with _$ImageListResponse {
  const factory ImageListResponse({
    @Default([]) List<UploadedImage> results,
    @Default(0) int count,
  }) = _ImageListResponse;

  factory ImageListResponse.fromJson(Map<String, dynamic> json) =>
      _$ImageListResponseFromJson(json);
}

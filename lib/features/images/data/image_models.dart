import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_models.freezed.dart';
part 'image_models.g.dart';

// ==================== UPLOADED IMAGE ====================

@freezed
sealed class UploadedImage with _$UploadedImage {
  const factory UploadedImage({
    required String id,
    @JsonKey(name: 'report_id') String? reportId,
    @JsonKey(name: 'user_id') String? userId,
    required String url,  // Backend returns 'url' not 'image_url'
    @JsonKey(name: 's3_key') String? s3Key,
    String? filename,
    @JsonKey(name: 'file_size') int? fileSize,
    @JsonKey(name: 'mime_type') String? mimeType,
    int? width,
    int? height,
    @JsonKey(name: 'is_primary') @Default(false) bool isPrimary,
    @JsonKey(name: 'created_at') String? createdAt,
    @JsonKey(name: 'updated_at') String? updatedAt,
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

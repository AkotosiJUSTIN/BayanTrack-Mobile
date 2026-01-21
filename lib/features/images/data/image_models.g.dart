// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadedImage _$UploadedImageFromJson(Map<String, dynamic> json) =>
    _UploadedImage(
      id: json['id'] as String,
      reportId: json['report_id'] as String?,
      userId: json['user_id'] as String?,
      url: json['url'] as String,
      s3Key: json['s3_key'] as String?,
      filename: json['filename'] as String?,
      fileSize: (json['file_size'] as num?)?.toInt(),
      mimeType: json['mime_type'] as String?,
      width: (json['width'] as num?)?.toInt(),
      height: (json['height'] as num?)?.toInt(),
      isPrimary: json['is_primary'] as bool? ?? false,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );

Map<String, dynamic> _$UploadedImageToJson(_UploadedImage instance) =>
    <String, dynamic>{
      'id': instance.id,
      'report_id': instance.reportId,
      'user_id': instance.userId,
      'url': instance.url,
      's3_key': instance.s3Key,
      'filename': instance.filename,
      'file_size': instance.fileSize,
      'mime_type': instance.mimeType,
      'width': instance.width,
      'height': instance.height,
      'is_primary': instance.isPrimary,
      'created_at': instance.createdAt,
      'updated_at': instance.updatedAt,
    };

_ImageUploadResponse _$ImageUploadResponseFromJson(Map<String, dynamic> json) =>
    _ImageUploadResponse(
      message: json['message'] as String,
      image: json['image'] == null
          ? null
          : UploadedImage.fromJson(json['image'] as Map<String, dynamic>),
      images: (json['images'] as List<dynamic>?)
          ?.map((e) => UploadedImage.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$ImageUploadResponseToJson(
  _ImageUploadResponse instance,
) => <String, dynamic>{
  'message': instance.message,
  'image': instance.image,
  'images': instance.images,
};

_ImageListResponse _$ImageListResponseFromJson(Map<String, dynamic> json) =>
    _ImageListResponse(
      results:
          (json['results'] as List<dynamic>?)
              ?.map((e) => UploadedImage.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      count: (json['count'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$ImageListResponseToJson(_ImageListResponse instance) =>
    <String, dynamic>{'results': instance.results, 'count': instance.count};

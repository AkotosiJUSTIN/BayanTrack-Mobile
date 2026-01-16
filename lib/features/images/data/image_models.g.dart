// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_models.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_UploadedImage _$UploadedImageFromJson(Map<String, dynamic> json) =>
    _UploadedImage(
      id: json['_id'] as String,
      reportId: json['report_id'] as String,
      imageUrl: json['image_url'] as String,
      thumbnailUrl: json['thumbnail_url'] as String?,
      isPrimary: json['is_primary'] as bool? ?? false,
      uploadedBy: json['uploaded_by'] as String?,
      createdAt: json['created_at'] as String?,
    );

Map<String, dynamic> _$UploadedImageToJson(_UploadedImage instance) =>
    <String, dynamic>{
      '_id': instance.id,
      'report_id': instance.reportId,
      'image_url': instance.imageUrl,
      'thumbnail_url': instance.thumbnailUrl,
      'is_primary': instance.isPrimary,
      'uploaded_by': instance.uploadedBy,
      'created_at': instance.createdAt,
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

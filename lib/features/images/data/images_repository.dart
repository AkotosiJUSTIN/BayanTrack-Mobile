import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'image_models.dart';

part 'images_repository.g.dart';

@riverpod
ImagesRepository imagesRepository(Ref ref) {
  final dio = ref.watch(dioProvider);
  return ImagesRepository(dio);
}

class ImagesRepository {
  final Dio _dio;

  ImagesRepository(this._dio);

  // ==================== UPLOAD ====================

  /// Upload a single image for a report
  Future<UploadedImage> uploadImage({
    required File imageFile,
    required String reportId,
    bool isPrimary = false,
  }) async {
    debugPrint('=== UPLOADING IMAGE ===');
    debugPrint('File path: ${imageFile.path}');
    debugPrint('File exists: ${await imageFile.exists()}');
    debugPrint('Report ID: $reportId');
    debugPrint('Is Primary: $isPrimary');
    
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.path.split('/').last,
      ),
      'report_id': reportId,
      'is_primary': isPrimary.toString(),
    });

    try {
      final response = await _dio.post(
        ApiConstants.imageUpload,
        data: formData,
      );

      debugPrint('=== UPLOAD SUCCESS ===');
      debugPrint('Response: ${response.data}');

      // Backend returns the image directly or wrapped in response
      if (response.data is Map && response.data.containsKey('image')) {
        return UploadedImage.fromJson(response.data['image']);
      }
      return UploadedImage.fromJson(response.data);
    } on DioException catch (e) {
      debugPrint('Single image upload error: ${e.response?.statusCode}');
      debugPrint('Error data: ${e.response?.data}');
      rethrow;
    }
  }

  /// Bulk upload multiple images for a report
  Future<List<UploadedImage>> bulkUploadImages({
    required List<File> imageFiles,
    required String reportId,
  }) async {
    final formData = FormData();

    for (final file in imageFiles) {
      formData.files.add(
        MapEntry(
          'images',
          await MultipartFile.fromFile(
            file.path,
            filename: file.path.split('/').last,
          ),
        ),
      );
    }
    formData.fields.add(MapEntry('report_id', reportId));

    try {
      final response = await _dio.post(
        ApiConstants.imageBulkUpload,
        data: formData,
        // Don't set contentType manually - Dio handles multipart/form-data automatically
      );

      final List<dynamic> imagesJson = response.data['images'] ?? [];
      return imagesJson.map((json) => UploadedImage.fromJson(json)).toList();
    } on DioException catch (e) {
      // Log only the error response for debugging (remove in production)
      debugPrint('Image upload error: ${e.response?.statusCode}');
      debugPrint('Error data: ${e.response?.data}');
      rethrow;
    }
  }

  // ==================== LIST ====================

  /// Get all images for a specific report
  Future<List<UploadedImage>> getImagesForReport(String reportId) async {
    final response = await _dio.get(
      ApiConstants.images,
      queryParameters: {'report_id': reportId},
    );

    // Handle both array and paginated response
    if (response.data is List) {
      return (response.data as List)
          .map((json) => UploadedImage.fromJson(json))
          .toList();
    } else if (response.data is Map) {
      final results = response.data['results'] ?? response.data['images'] ?? [];
      return (results as List)
          .map((json) => UploadedImage.fromJson(json))
          .toList();
    }
    return [];
  }

  // ==================== GET / DELETE ====================

  /// Get a single image by ID
  Future<UploadedImage> getImage(String imageId) async {
    final response = await _dio.get(ApiConstants.imageById(imageId));
    return UploadedImage.fromJson(response.data);
  }

  /// Delete an image
  Future<void> deleteImage(String imageId) async {
    await _dio.delete(ApiConstants.imageById(imageId));
  }
}

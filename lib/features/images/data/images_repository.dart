import 'dart:io';
import 'package:dio/dio.dart';
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

  /// Upload a single image for a report.
  ///
  /// [purpose] categorises the image:
  ///   - `'evidence'` (default) — report photo submitted by the citizen.
  ///   - `'signature'` — citizen e-signature drawn on the closure screen.
  ///   - `'document'` — scanned closure document.
  Future<UploadedImage> uploadImage({
    required File imageFile,
    required String reportId,
    bool isPrimary = false,
    String purpose = 'evidence',
    String? idempotencyKey,
    CancelToken? cancelToken,
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      'image': await MultipartFile.fromFile(
        imageFile.path,
        filename: imageFile.uri.pathSegments.last,
      ),
      'report_id': reportId,
      'is_primary': isPrimary.toString(),
      'purpose': purpose,
      'idempotency_key': ?idempotencyKey,
    });

    final response = await _dio.post(
      ApiConstants.imageUpload,
      data: formData,
      cancelToken: cancelToken,
      onSendProgress: onSendProgress,
    );

    // Backend returns the image directly or wrapped in response.
    if (response.data is Map && response.data.containsKey('image')) {
      return UploadedImage.fromJson(response.data['image']);
    }
    return UploadedImage.fromJson(response.data);
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

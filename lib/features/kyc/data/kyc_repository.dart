import 'dart:io';
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/network/dio_provider.dart';
import 'kyc_models.dart';

final kycRepositoryProvider = Provider<KycRepository>((ref) {
  final dio = ref.watch(dioProvider);
  return KycRepository(dio);
});

class KycRepository {
  final Dio _dio;

  KycRepository(this._dio);

  // ==================== GET ID TYPES ====================

  /// Get list of valid ID types
  Future<List<String>> getIdTypes() async {
    final response = await _dio.get(ApiConstants.kycIdTypes);
    final idTypesResponse = IdTypesResponse.fromJson(response.data);
    return idTypesResponse.idTypes;
  }

  // ==================== GET KYC STATUS ====================

  /// Get current KYC status for the authenticated user
  Future<KycStatusResponse> getKycStatus() async {
    final response = await _dio.get(ApiConstants.kycStatus);
    return KycStatusResponse.fromJson(response.data);
  }

  // ==================== SUBMIT KYC ====================

  /// Submit KYC documents for verification
  /// Uses multipart/form-data for file uploads
  Future<KycStatusResponse> submitKyc(KycSubmitRequest request) async {
    final formData = FormData.fromMap({
      'id_type': request.idTypeValue,
      if (request.idNumber != null && request.idNumber!.isNotEmpty)
        'id_number': request.idNumber,
      'full_name': request.fullName,
      if (request.dateOfBirth != null && request.dateOfBirth!.isNotEmpty)
        'date_of_birth': request.dateOfBirth,
      'id_image': await MultipartFile.fromFile(
        request.idImagePath,
        filename: request.idImagePath.split('/').last,
      ),
      if (request.idBackImagePath != null)
        'id_back_image': await MultipartFile.fromFile(
          request.idBackImagePath!,
          filename: request.idBackImagePath!.split('/').last,
        ),
      'selfie_image': await MultipartFile.fromFile(
        request.selfieImagePath,
        filename: request.selfieImagePath.split('/').last,
      ),
    });

    final response = await _dio.post(
      ApiConstants.kycSubmit,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    return KycStatusResponse.fromJson(response.data);
  }

  // ==================== RESUBMIT KYC ====================

  /// Resubmit KYC documents after rejection
  /// Uses multipart/form-data for file uploads
  Future<KycStatusResponse> resubmitKyc(KycSubmitRequest request) async {
    final formData = FormData.fromMap({
      'id_type': request.idTypeValue,
      if (request.idNumber != null && request.idNumber!.isNotEmpty)
        'id_number': request.idNumber,
      'full_name': request.fullName,
      if (request.dateOfBirth != null && request.dateOfBirth!.isNotEmpty)
        'date_of_birth': request.dateOfBirth,
      'id_image': await MultipartFile.fromFile(
        request.idImagePath,
        filename: request.idImagePath.split('/').last,
      ),
      if (request.idBackImagePath != null)
        'id_back_image': await MultipartFile.fromFile(
          request.idBackImagePath!,
          filename: request.idBackImagePath!.split('/').last,
        ),
      'selfie_image': await MultipartFile.fromFile(
        request.selfieImagePath,
        filename: request.selfieImagePath.split('/').last,
      ),
    });

    final response = await _dio.post(
      ApiConstants.kycResubmit,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    return KycStatusResponse.fromJson(response.data);
  }

  // ==================== VALIDATE IMAGE SIZE ====================

  /// Check if image file is within the 10MB limit
  bool isValidImageSize(String filePath) {
    final file = File(filePath);
    final fileSizeInBytes = file.lengthSync();
    final fileSizeInMB = fileSizeInBytes / (1024 * 1024);
    return fileSizeInMB <= 10;
  }

  /// Validate all images in the request
  List<String> validateImages(KycSubmitRequest request) {
    final errors = <String>[];

    if (!isValidImageSize(request.idImagePath)) {
      errors.add('ID front image must be less than 10MB');
    }

    if (request.idBackImagePath != null &&
        !isValidImageSize(request.idBackImagePath!)) {
      errors.add('ID back image must be less than 10MB');
    }

    if (!isValidImageSize(request.selfieImagePath)) {
      errors.add('Selfie image must be less than 10MB');
    }

    return errors;
  }
}

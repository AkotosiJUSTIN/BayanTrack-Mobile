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

  // ==================== GET FORM OPTIONS ====================

  /// Get all form options (ID types, sex options, civil statuses)
  Future<KycFormOptionsResponse> getFormOptions() async {
    final response = await _dio.get(ApiConstants.kycFormOptions);
    return KycFormOptionsResponse.fromJson(response.data);
  }

  // ==================== GET KYC STATUS ====================

  /// Get current KYC status for the authenticated user
  Future<KycStatusResponse> getKycStatus() async {
    final response = await _dio.get(ApiConstants.kycStatus);
    final data = response.data as Map<String, dynamic>;
    
    // Backend returns different structures:
    // - No KYC: {'kyc_status': 'unverified', 'message': '...'}
    // - Has KYC: {'kyc': {...kyc data...}}
    if (data.containsKey('kyc')) {
      return KycStatusResponse.fromJson(data['kyc'] as Map<String, dynamic>);
    } else {
      // No KYC submitted yet - create minimal response
      return KycStatusResponse.fromJson(data);
    }
  }

  // ==================== SUBMIT KYC ====================

  /// Submit KYC documents for verification
  /// Uses multipart/form-data for file uploads
  Future<KycStatusResponse> submitKyc(KycSubmitRequest request) async {
    // Build form data with all text fields
    final formDataMap = <String, dynamic>{
      ...request.toFormDataMap(),
    };

    // Add ID front image (required)
    formDataMap['id_front_image'] = await MultipartFile.fromFile(
      request.idFrontImagePath,
      filename: request.idFrontImagePath.split('/').last,
    );

    // Add ID back image (optional)
    if (request.idBackImagePath != null && request.idBackImagePath!.isNotEmpty) {
      formDataMap['id_back_image'] = await MultipartFile.fromFile(
        request.idBackImagePath!,
        filename: request.idBackImagePath!.split('/').last,
      );
    }

    // Add selfie image (required)
    formDataMap['selfie_image'] = await MultipartFile.fromFile(
      request.selfieImagePath,
      filename: request.selfieImagePath.split('/').last,
    );

    // Add selfie with ID image (optional)
    if (request.selfieWithIdImagePath != null && request.selfieWithIdImagePath!.isNotEmpty) {
      formDataMap['selfie_with_id_image'] = await MultipartFile.fromFile(
        request.selfieWithIdImagePath!,
        filename: request.selfieWithIdImagePath!.split('/').last,
      );
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _dio.post(
      ApiConstants.kycSubmit,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    // Backend returns {'message': '...', 'kyc': {...}, ...}
    return KycStatusResponse.fromJson(data['kyc'] as Map<String, dynamic>);
  }

  // ==================== RESUBMIT KYC ====================

  /// Resubmit KYC documents after rejection
  /// Uses multipart/form-data for file uploads
  Future<KycStatusResponse> resubmitKyc(KycSubmitRequest request) async {
    // Build form data with all text fields
    final formDataMap = <String, dynamic>{
      ...request.toFormDataMap(),
    };

    // Add ID front image (required)
    formDataMap['id_front_image'] = await MultipartFile.fromFile(
      request.idFrontImagePath,
      filename: request.idFrontImagePath.split('/').last,
    );

    // Add ID back image (optional)
    if (request.idBackImagePath != null && request.idBackImagePath!.isNotEmpty) {
      formDataMap['id_back_image'] = await MultipartFile.fromFile(
        request.idBackImagePath!,
        filename: request.idBackImagePath!.split('/').last,
      );
    }

    // Add selfie image (required)
    formDataMap['selfie_image'] = await MultipartFile.fromFile(
      request.selfieImagePath,
      filename: request.selfieImagePath.split('/').last,
    );

    // Add selfie with ID image (optional)
    if (request.selfieWithIdImagePath != null && request.selfieWithIdImagePath!.isNotEmpty) {
      formDataMap['selfie_with_id_image'] = await MultipartFile.fromFile(
        request.selfieWithIdImagePath!,
        filename: request.selfieWithIdImagePath!.split('/').last,
      );
    }

    final formData = FormData.fromMap(formDataMap);

    final response = await _dio.post(
      ApiConstants.kycResubmit,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
    );

    final data = response.data as Map<String, dynamic>;
    // Backend returns {'message': '...', 'kyc': {...}, ...}
    return KycStatusResponse.fromJson(data['kyc'] as Map<String, dynamic>);
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

    if (!isValidImageSize(request.idFrontImagePath)) {
      errors.add('ID front image must be less than 10MB');
    }

    if (request.idBackImagePath != null &&
        request.idBackImagePath!.isNotEmpty &&
        !isValidImageSize(request.idBackImagePath!)) {
      errors.add('ID back image must be less than 10MB');
    }

    if (!isValidImageSize(request.selfieImagePath)) {
      errors.add('Selfie image must be less than 10MB');
    }

    if (request.selfieWithIdImagePath != null &&
        request.selfieWithIdImagePath!.isNotEmpty &&
        !isValidImageSize(request.selfieWithIdImagePath!)) {
      errors.add('Selfie with ID image must be less than 10MB');
    }

    return errors;
  }
}

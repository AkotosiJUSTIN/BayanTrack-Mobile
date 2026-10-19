import 'package:dio/dio.dart';

import '../../../../core/domain/result.dart';
import '../entities/report.dart';
import '../reports_repository.dart';

/// Use case for creating a new report.
class CreateReportUseCase {
  final ReportsRepository _repository;

  CreateReportUseCase({required ReportsRepository repository})
    : _repository = repository;

  Future<Result<Report>> call({
    String? category,
    String? incidentType,
    String? incidentTypeKey,
    String? incidentCatalogVersion,
    String? title,
    String description = '',
    String? incidentDatetime,
    bool isHappeningNow = false,
    String? zone,
    String? streetLandmark,
    String municipalityId = 'urdaneta',
    String? barangayId,
    String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    String locationAccuracy = 'approximate',
    String? location,
    String? barangay,
    bool declarationConfirmed = true,
    bool dataProcessingConsent = true,
    bool isQuickReport = false,
    bool isEmergency = false,
    Map<String, dynamic>? emergencyContext,
    String? idempotencyKey,
    CancelToken? cancelToken,
  }) {
    return _repository.createReport(
      category: category,
      incidentType: incidentType,
      incidentTypeKey: incidentTypeKey,
      incidentCatalogVersion: incidentCatalogVersion,
      title: title,
      description: description,
      incidentDatetime: incidentDatetime,
      isHappeningNow: isHappeningNow,
      zone: zone,
      streetLandmark: streetLandmark,
      municipalityId: municipalityId,
      barangayId: barangayId,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: latitude,
      longitude: longitude,
      locationAccuracy: locationAccuracy,
      location: location,
      barangay: barangay,
      declarationConfirmed: declarationConfirmed,
      dataProcessingConsent: dataProcessingConsent,
      isQuickReport: isQuickReport,
      isEmergency: isEmergency,
      emergencyContext: emergencyContext,
      idempotencyKey: idempotencyKey,
      cancelToken: cancelToken,
    );
  }
}

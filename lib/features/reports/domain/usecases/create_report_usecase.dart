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
    String? title,
    required String description,
    String? incidentDatetime,
    bool isHappeningNow = false,
    String? zone,
    String? streetLandmark,
    String? cityMunicipality,
    String? province,
    String? latitude,
    String? longitude,
    String locationAccuracy = 'approximate',
    String? location,
    bool declarationConfirmed = true,
    bool dataProcessingConsent = true,
  }) {
    return _repository.createReport(
      category: category,
      incidentType: incidentType,
      title: title,
      description: description,
      incidentDatetime: incidentDatetime,
      isHappeningNow: isHappeningNow,
      zone: zone,
      streetLandmark: streetLandmark,
      cityMunicipality: cityMunicipality,
      province: province,
      latitude: latitude,
      longitude: longitude,
      locationAccuracy: locationAccuracy,
      location: location,
      declarationConfirmed: declarationConfirmed,
      dataProcessingConsent: dataProcessingConsent,
    );
  }
}

import '../../../core/domain/result.dart';
import 'entities/kyc_form_options.dart';
import 'entities/kyc_status.dart';

/// Repository interface for KYC operations.
///
/// All methods return [Result<T>] for explicit error handling.
/// Implementations should use [ErrorMapper] for Dio exception conversion.
abstract class KycRepository {
  /// Get list of valid ID types as strings.
  Future<Result<List<String>>> getIdTypes();

  /// Get all form options (ID types, sex options, civil statuses).
  Future<Result<KycFormOptions>> getFormOptions();

  /// Get current KYC status for the authenticated user.
  Future<Result<KycStatusEntity>> getKycStatus();

  /// Withdraw a pending submission back to editable, unsubmitted state.
  Future<Result<KycStatusEntity>> withdrawKyc();

  /// Submit KYC documents for verification.
  ///
  /// [firstName], [lastName], [nationality] are required.
  /// [idFrontImagePath], [selfieImagePath] are required file paths.
  Future<Result<KycStatusEntity>> submitKyc({
    // Basic Identity
    required String firstName,
    String? middleName,
    required String lastName,
    String? dateOfBirth,
    String? sex,
    required String nationality,
    String? civilStatus,
    // Contact
    required String email,
    required String mobileNumber,
    // Address
    required String streetBarangay,
    required String cityMunicipality,
    required String province,
    String? zipCode,
    // ID Details
    required String idType,
    required String idNumber,
    String? idExpiryDate,
    // Images (file paths)
    required String idFrontImagePath,
    String? idBackImagePath,
    required String selfieImagePath,
    String? selfieWithIdImagePath,
    // Declaration
    bool declarationAccepted = true,
  });

  /// Resubmit KYC documents after rejection.
  ///
  /// Same parameters as [submitKyc].
  Future<Result<KycStatusEntity>> resubmitKyc({
    // Basic Identity
    required String firstName,
    String? middleName,
    required String lastName,
    String? dateOfBirth,
    String? sex,
    required String nationality,
    String? civilStatus,
    // Contact
    required String email,
    required String mobileNumber,
    // Address
    required String streetBarangay,
    required String cityMunicipality,
    required String province,
    String? zipCode,
    // ID Details
    required String idType,
    required String idNumber,
    String? idExpiryDate,
    // Images (file paths)
    required String idFrontImagePath,
    String? idBackImagePath,
    required String selfieImagePath,
    String? selfieWithIdImagePath,
    // Declaration
    bool declarationAccepted = true,
  });

  /// Validate all images in the request.
  ///
  /// Returns a list of error messages if validation fails.
  List<String> validateImages({
    required String idFrontImagePath,
    String? idBackImagePath,
    required String selfieImagePath,
    String? selfieWithIdImagePath,
  });
}

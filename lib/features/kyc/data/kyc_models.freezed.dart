// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'kyc_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$KycStatusResponse {

 String? get id;@JsonKey(name: 'user_id') String? get userId;@JsonKey(name: 'kyc_status') KycStatus get kycStatus;// Basic Identity Information
@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'first_name') String? get firstName;@JsonKey(name: 'middle_name') String? get middleName;@JsonKey(name: 'last_name') String? get lastName;@JsonKey(name: 'date_of_birth') String? get dateOfBirth; Sex? get sex; String? get nationality;@JsonKey(name: 'civil_status') CivilStatus? get civilStatus;// Contact Information
 String? get email;@JsonKey(name: 'mobile_number') String? get mobileNumber;// Address Information
@JsonKey(name: 'street_barangay') String? get streetBarangay;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province;@JsonKey(name: 'zip_code') String? get zipCode;// Government ID Details
@JsonKey(name: 'id_type') IdType? get idType;@JsonKey(name: 'id_number') String? get idNumber;@JsonKey(name: 'id_expiry_date') String? get idExpiryDate;// ID Images
@JsonKey(name: 'id_front_image_url') String? get idFrontImageUrl;@JsonKey(name: 'id_back_image_url') String? get idBackImageUrl;@JsonKey(name: 'id_image_url') String? get idImageUrl;// Legacy
// Selfie Images
@JsonKey(name: 'selfie_image_url') String? get selfieImageUrl;@JsonKey(name: 'selfie_with_id_image_url') String? get selfieWithIdImageUrl;// Declaration
@JsonKey(name: 'declaration_accepted') bool get declarationAccepted;// Verification Status
@JsonKey(name: 'precheck_status') PrecheckStatus? get precheckStatus;@JsonKey(name: 'precheck_notes') String? get precheckNotes;@JsonKey(name: 'rejection_reason') String? get rejectionReason;@JsonKey(name: 'admin_notes') String? get adminNotes;@JsonKey(name: 'verified_by') String? get verifiedBy;@JsonKey(name: 'verified_by_role') String? get verifiedByRole;@JsonKey(name: 'resubmission_count') int get resubmissionCount;// Timestamps
@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycStatusResponseCopyWith<KycStatusResponse> get copyWith => _$KycStatusResponseCopyWithImpl<KycStatusResponse>(this as KycStatusResponse, _$identity);

  /// Serializes this KycStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycStatusResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.streetBarangay, streetBarangay) || other.streetBarangay == streetBarangay)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.idExpiryDate, idExpiryDate) || other.idExpiryDate == idExpiryDate)&&(identical(other.idFrontImageUrl, idFrontImageUrl) || other.idFrontImageUrl == idFrontImageUrl)&&(identical(other.idBackImageUrl, idBackImageUrl) || other.idBackImageUrl == idBackImageUrl)&&(identical(other.idImageUrl, idImageUrl) || other.idImageUrl == idImageUrl)&&(identical(other.selfieImageUrl, selfieImageUrl) || other.selfieImageUrl == selfieImageUrl)&&(identical(other.selfieWithIdImageUrl, selfieWithIdImageUrl) || other.selfieWithIdImageUrl == selfieWithIdImageUrl)&&(identical(other.declarationAccepted, declarationAccepted) || other.declarationAccepted == declarationAccepted)&&(identical(other.precheckStatus, precheckStatus) || other.precheckStatus == precheckStatus)&&(identical(other.precheckNotes, precheckNotes) || other.precheckNotes == precheckNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.verifiedByRole, verifiedByRole) || other.verifiedByRole == verifiedByRole)&&(identical(other.resubmissionCount, resubmissionCount) || other.resubmissionCount == resubmissionCount)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,kycStatus,fullName,firstName,middleName,lastName,dateOfBirth,sex,nationality,civilStatus,email,mobileNumber,streetBarangay,cityMunicipality,province,zipCode,idType,idNumber,idExpiryDate,idFrontImageUrl,idBackImageUrl,idImageUrl,selfieImageUrl,selfieWithIdImageUrl,declarationAccepted,precheckStatus,precheckNotes,rejectionReason,adminNotes,verifiedBy,verifiedByRole,resubmissionCount,submittedAt,verifiedAt,createdAt]);

@override
String toString() {
  return 'KycStatusResponse(id: $id, userId: $userId, kycStatus: $kycStatus, fullName: $fullName, firstName: $firstName, middleName: $middleName, lastName: $lastName, dateOfBirth: $dateOfBirth, sex: $sex, nationality: $nationality, civilStatus: $civilStatus, email: $email, mobileNumber: $mobileNumber, streetBarangay: $streetBarangay, cityMunicipality: $cityMunicipality, province: $province, zipCode: $zipCode, idType: $idType, idNumber: $idNumber, idExpiryDate: $idExpiryDate, idFrontImageUrl: $idFrontImageUrl, idBackImageUrl: $idBackImageUrl, idImageUrl: $idImageUrl, selfieImageUrl: $selfieImageUrl, selfieWithIdImageUrl: $selfieWithIdImageUrl, declarationAccepted: $declarationAccepted, precheckStatus: $precheckStatus, precheckNotes: $precheckNotes, rejectionReason: $rejectionReason, adminNotes: $adminNotes, verifiedBy: $verifiedBy, verifiedByRole: $verifiedByRole, resubmissionCount: $resubmissionCount, submittedAt: $submittedAt, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $KycStatusResponseCopyWith<$Res>  {
  factory $KycStatusResponseCopyWith(KycStatusResponse value, $Res Function(KycStatusResponse) _then) = _$KycStatusResponseCopyWithImpl;
@useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'kyc_status') KycStatus kycStatus,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'middle_name') String? middleName,@JsonKey(name: 'last_name') String? lastName,@JsonKey(name: 'date_of_birth') String? dateOfBirth, Sex? sex, String? nationality,@JsonKey(name: 'civil_status') CivilStatus? civilStatus, String? email,@JsonKey(name: 'mobile_number') String? mobileNumber,@JsonKey(name: 'street_barangay') String? streetBarangay,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province,@JsonKey(name: 'zip_code') String? zipCode,@JsonKey(name: 'id_type') IdType? idType,@JsonKey(name: 'id_number') String? idNumber,@JsonKey(name: 'id_expiry_date') String? idExpiryDate,@JsonKey(name: 'id_front_image_url') String? idFrontImageUrl,@JsonKey(name: 'id_back_image_url') String? idBackImageUrl,@JsonKey(name: 'id_image_url') String? idImageUrl,@JsonKey(name: 'selfie_image_url') String? selfieImageUrl,@JsonKey(name: 'selfie_with_id_image_url') String? selfieWithIdImageUrl,@JsonKey(name: 'declaration_accepted') bool declarationAccepted,@JsonKey(name: 'precheck_status') PrecheckStatus? precheckStatus,@JsonKey(name: 'precheck_notes') String? precheckNotes,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'admin_notes') String? adminNotes,@JsonKey(name: 'verified_by') String? verifiedBy,@JsonKey(name: 'verified_by_role') String? verifiedByRole,@JsonKey(name: 'resubmission_count') int resubmissionCount,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$KycStatusResponseCopyWithImpl<$Res>
    implements $KycStatusResponseCopyWith<$Res> {
  _$KycStatusResponseCopyWithImpl(this._self, this._then);

  final KycStatusResponse _self;
  final $Res Function(KycStatusResponse) _then;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = freezed,Object? userId = freezed,Object? kycStatus = null,Object? fullName = null,Object? firstName = freezed,Object? middleName = freezed,Object? lastName = freezed,Object? dateOfBirth = freezed,Object? sex = freezed,Object? nationality = freezed,Object? civilStatus = freezed,Object? email = freezed,Object? mobileNumber = freezed,Object? streetBarangay = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? zipCode = freezed,Object? idType = freezed,Object? idNumber = freezed,Object? idExpiryDate = freezed,Object? idFrontImageUrl = freezed,Object? idBackImageUrl = freezed,Object? idImageUrl = freezed,Object? selfieImageUrl = freezed,Object? selfieWithIdImageUrl = freezed,Object? declarationAccepted = null,Object? precheckStatus = freezed,Object? precheckNotes = freezed,Object? rejectionReason = freezed,Object? adminNotes = freezed,Object? verifiedBy = freezed,Object? verifiedByRole = freezed,Object? resubmissionCount = null,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as KycStatus,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,civilStatus: freezed == civilStatus ? _self.civilStatus : civilStatus // ignore: cast_nullable_to_non_nullable
as CivilStatus?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,streetBarangay: freezed == streetBarangay ? _self.streetBarangay : streetBarangay // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,idType: freezed == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as IdType?,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,idExpiryDate: freezed == idExpiryDate ? _self.idExpiryDate : idExpiryDate // ignore: cast_nullable_to_non_nullable
as String?,idFrontImageUrl: freezed == idFrontImageUrl ? _self.idFrontImageUrl : idFrontImageUrl // ignore: cast_nullable_to_non_nullable
as String?,idBackImageUrl: freezed == idBackImageUrl ? _self.idBackImageUrl : idBackImageUrl // ignore: cast_nullable_to_non_nullable
as String?,idImageUrl: freezed == idImageUrl ? _self.idImageUrl : idImageUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieImageUrl: freezed == selfieImageUrl ? _self.selfieImageUrl : selfieImageUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieWithIdImageUrl: freezed == selfieWithIdImageUrl ? _self.selfieWithIdImageUrl : selfieWithIdImageUrl // ignore: cast_nullable_to_non_nullable
as String?,declarationAccepted: null == declarationAccepted ? _self.declarationAccepted : declarationAccepted // ignore: cast_nullable_to_non_nullable
as bool,precheckStatus: freezed == precheckStatus ? _self.precheckStatus : precheckStatus // ignore: cast_nullable_to_non_nullable
as PrecheckStatus?,precheckNotes: freezed == precheckNotes ? _self.precheckNotes : precheckNotes // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,verifiedByRole: freezed == verifiedByRole ? _self.verifiedByRole : verifiedByRole // ignore: cast_nullable_to_non_nullable
as String?,resubmissionCount: null == resubmissionCount ? _self.resubmissionCount : resubmissionCount // ignore: cast_nullable_to_non_nullable
as int,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycStatusResponse].
extension KycStatusResponsePatterns on KycStatusResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycStatusResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycStatusResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycStatusResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycStatusResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'kyc_status')  KycStatus kycStatus, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'middle_name')  String? middleName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  Sex? sex,  String? nationality, @JsonKey(name: 'civil_status')  CivilStatus? civilStatus,  String? email, @JsonKey(name: 'mobile_number')  String? mobileNumber, @JsonKey(name: 'street_barangay')  String? streetBarangay, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province, @JsonKey(name: 'zip_code')  String? zipCode, @JsonKey(name: 'id_type')  IdType? idType, @JsonKey(name: 'id_number')  String? idNumber, @JsonKey(name: 'id_expiry_date')  String? idExpiryDate, @JsonKey(name: 'id_front_image_url')  String? idFrontImageUrl, @JsonKey(name: 'id_back_image_url')  String? idBackImageUrl, @JsonKey(name: 'id_image_url')  String? idImageUrl, @JsonKey(name: 'selfie_image_url')  String? selfieImageUrl, @JsonKey(name: 'selfie_with_id_image_url')  String? selfieWithIdImageUrl, @JsonKey(name: 'declaration_accepted')  bool declarationAccepted, @JsonKey(name: 'precheck_status')  PrecheckStatus? precheckStatus, @JsonKey(name: 'precheck_notes')  String? precheckNotes, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'admin_notes')  String? adminNotes, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'verified_by_role')  String? verifiedByRole, @JsonKey(name: 'resubmission_count')  int resubmissionCount, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.id,_that.userId,_that.kycStatus,_that.fullName,_that.firstName,_that.middleName,_that.lastName,_that.dateOfBirth,_that.sex,_that.nationality,_that.civilStatus,_that.email,_that.mobileNumber,_that.streetBarangay,_that.cityMunicipality,_that.province,_that.zipCode,_that.idType,_that.idNumber,_that.idExpiryDate,_that.idFrontImageUrl,_that.idBackImageUrl,_that.idImageUrl,_that.selfieImageUrl,_that.selfieWithIdImageUrl,_that.declarationAccepted,_that.precheckStatus,_that.precheckNotes,_that.rejectionReason,_that.adminNotes,_that.verifiedBy,_that.verifiedByRole,_that.resubmissionCount,_that.submittedAt,_that.verifiedAt,_that.createdAt);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'kyc_status')  KycStatus kycStatus, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'middle_name')  String? middleName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  Sex? sex,  String? nationality, @JsonKey(name: 'civil_status')  CivilStatus? civilStatus,  String? email, @JsonKey(name: 'mobile_number')  String? mobileNumber, @JsonKey(name: 'street_barangay')  String? streetBarangay, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province, @JsonKey(name: 'zip_code')  String? zipCode, @JsonKey(name: 'id_type')  IdType? idType, @JsonKey(name: 'id_number')  String? idNumber, @JsonKey(name: 'id_expiry_date')  String? idExpiryDate, @JsonKey(name: 'id_front_image_url')  String? idFrontImageUrl, @JsonKey(name: 'id_back_image_url')  String? idBackImageUrl, @JsonKey(name: 'id_image_url')  String? idImageUrl, @JsonKey(name: 'selfie_image_url')  String? selfieImageUrl, @JsonKey(name: 'selfie_with_id_image_url')  String? selfieWithIdImageUrl, @JsonKey(name: 'declaration_accepted')  bool declarationAccepted, @JsonKey(name: 'precheck_status')  PrecheckStatus? precheckStatus, @JsonKey(name: 'precheck_notes')  String? precheckNotes, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'admin_notes')  String? adminNotes, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'verified_by_role')  String? verifiedByRole, @JsonKey(name: 'resubmission_count')  int resubmissionCount, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse():
return $default(_that.id,_that.userId,_that.kycStatus,_that.fullName,_that.firstName,_that.middleName,_that.lastName,_that.dateOfBirth,_that.sex,_that.nationality,_that.civilStatus,_that.email,_that.mobileNumber,_that.streetBarangay,_that.cityMunicipality,_that.province,_that.zipCode,_that.idType,_that.idNumber,_that.idExpiryDate,_that.idFrontImageUrl,_that.idBackImageUrl,_that.idImageUrl,_that.selfieImageUrl,_that.selfieWithIdImageUrl,_that.declarationAccepted,_that.precheckStatus,_that.precheckNotes,_that.rejectionReason,_that.adminNotes,_that.verifiedBy,_that.verifiedByRole,_that.resubmissionCount,_that.submittedAt,_that.verifiedAt,_that.createdAt);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? id, @JsonKey(name: 'user_id')  String? userId, @JsonKey(name: 'kyc_status')  KycStatus kycStatus, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'first_name')  String? firstName, @JsonKey(name: 'middle_name')  String? middleName, @JsonKey(name: 'last_name')  String? lastName, @JsonKey(name: 'date_of_birth')  String? dateOfBirth,  Sex? sex,  String? nationality, @JsonKey(name: 'civil_status')  CivilStatus? civilStatus,  String? email, @JsonKey(name: 'mobile_number')  String? mobileNumber, @JsonKey(name: 'street_barangay')  String? streetBarangay, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province, @JsonKey(name: 'zip_code')  String? zipCode, @JsonKey(name: 'id_type')  IdType? idType, @JsonKey(name: 'id_number')  String? idNumber, @JsonKey(name: 'id_expiry_date')  String? idExpiryDate, @JsonKey(name: 'id_front_image_url')  String? idFrontImageUrl, @JsonKey(name: 'id_back_image_url')  String? idBackImageUrl, @JsonKey(name: 'id_image_url')  String? idImageUrl, @JsonKey(name: 'selfie_image_url')  String? selfieImageUrl, @JsonKey(name: 'selfie_with_id_image_url')  String? selfieWithIdImageUrl, @JsonKey(name: 'declaration_accepted')  bool declarationAccepted, @JsonKey(name: 'precheck_status')  PrecheckStatus? precheckStatus, @JsonKey(name: 'precheck_notes')  String? precheckNotes, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'admin_notes')  String? adminNotes, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'verified_by_role')  String? verifiedByRole, @JsonKey(name: 'resubmission_count')  int resubmissionCount, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.id,_that.userId,_that.kycStatus,_that.fullName,_that.firstName,_that.middleName,_that.lastName,_that.dateOfBirth,_that.sex,_that.nationality,_that.civilStatus,_that.email,_that.mobileNumber,_that.streetBarangay,_that.cityMunicipality,_that.province,_that.zipCode,_that.idType,_that.idNumber,_that.idExpiryDate,_that.idFrontImageUrl,_that.idBackImageUrl,_that.idImageUrl,_that.selfieImageUrl,_that.selfieWithIdImageUrl,_that.declarationAccepted,_that.precheckStatus,_that.precheckNotes,_that.rejectionReason,_that.adminNotes,_that.verifiedBy,_that.verifiedByRole,_that.resubmissionCount,_that.submittedAt,_that.verifiedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycStatusResponse implements KycStatusResponse {
  const _KycStatusResponse({this.id, @JsonKey(name: 'user_id') this.userId, @JsonKey(name: 'kyc_status') required this.kycStatus, @JsonKey(name: 'full_name') this.fullName = '', @JsonKey(name: 'first_name') this.firstName, @JsonKey(name: 'middle_name') this.middleName, @JsonKey(name: 'last_name') this.lastName, @JsonKey(name: 'date_of_birth') this.dateOfBirth, this.sex, this.nationality, @JsonKey(name: 'civil_status') this.civilStatus, this.email, @JsonKey(name: 'mobile_number') this.mobileNumber, @JsonKey(name: 'street_barangay') this.streetBarangay, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, @JsonKey(name: 'zip_code') this.zipCode, @JsonKey(name: 'id_type') this.idType, @JsonKey(name: 'id_number') this.idNumber, @JsonKey(name: 'id_expiry_date') this.idExpiryDate, @JsonKey(name: 'id_front_image_url') this.idFrontImageUrl, @JsonKey(name: 'id_back_image_url') this.idBackImageUrl, @JsonKey(name: 'id_image_url') this.idImageUrl, @JsonKey(name: 'selfie_image_url') this.selfieImageUrl, @JsonKey(name: 'selfie_with_id_image_url') this.selfieWithIdImageUrl, @JsonKey(name: 'declaration_accepted') this.declarationAccepted = false, @JsonKey(name: 'precheck_status') this.precheckStatus, @JsonKey(name: 'precheck_notes') this.precheckNotes, @JsonKey(name: 'rejection_reason') this.rejectionReason, @JsonKey(name: 'admin_notes') this.adminNotes, @JsonKey(name: 'verified_by') this.verifiedBy, @JsonKey(name: 'verified_by_role') this.verifiedByRole, @JsonKey(name: 'resubmission_count') this.resubmissionCount = 0, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'created_at') this.createdAt});
  factory _KycStatusResponse.fromJson(Map<String, dynamic> json) => _$KycStatusResponseFromJson(json);

@override final  String? id;
@override@JsonKey(name: 'user_id') final  String? userId;
@override@JsonKey(name: 'kyc_status') final  KycStatus kycStatus;
// Basic Identity Information
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'first_name') final  String? firstName;
@override@JsonKey(name: 'middle_name') final  String? middleName;
@override@JsonKey(name: 'last_name') final  String? lastName;
@override@JsonKey(name: 'date_of_birth') final  String? dateOfBirth;
@override final  Sex? sex;
@override final  String? nationality;
@override@JsonKey(name: 'civil_status') final  CivilStatus? civilStatus;
// Contact Information
@override final  String? email;
@override@JsonKey(name: 'mobile_number') final  String? mobileNumber;
// Address Information
@override@JsonKey(name: 'street_barangay') final  String? streetBarangay;
@override@JsonKey(name: 'city_municipality') final  String? cityMunicipality;
@override final  String? province;
@override@JsonKey(name: 'zip_code') final  String? zipCode;
// Government ID Details
@override@JsonKey(name: 'id_type') final  IdType? idType;
@override@JsonKey(name: 'id_number') final  String? idNumber;
@override@JsonKey(name: 'id_expiry_date') final  String? idExpiryDate;
// ID Images
@override@JsonKey(name: 'id_front_image_url') final  String? idFrontImageUrl;
@override@JsonKey(name: 'id_back_image_url') final  String? idBackImageUrl;
@override@JsonKey(name: 'id_image_url') final  String? idImageUrl;
// Legacy
// Selfie Images
@override@JsonKey(name: 'selfie_image_url') final  String? selfieImageUrl;
@override@JsonKey(name: 'selfie_with_id_image_url') final  String? selfieWithIdImageUrl;
// Declaration
@override@JsonKey(name: 'declaration_accepted') final  bool declarationAccepted;
// Verification Status
@override@JsonKey(name: 'precheck_status') final  PrecheckStatus? precheckStatus;
@override@JsonKey(name: 'precheck_notes') final  String? precheckNotes;
@override@JsonKey(name: 'rejection_reason') final  String? rejectionReason;
@override@JsonKey(name: 'admin_notes') final  String? adminNotes;
@override@JsonKey(name: 'verified_by') final  String? verifiedBy;
@override@JsonKey(name: 'verified_by_role') final  String? verifiedByRole;
@override@JsonKey(name: 'resubmission_count') final  int resubmissionCount;
// Timestamps
@override@JsonKey(name: 'submitted_at') final  String? submittedAt;
@override@JsonKey(name: 'verified_at') final  String? verifiedAt;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycStatusResponseCopyWith<_KycStatusResponse> get copyWith => __$KycStatusResponseCopyWithImpl<_KycStatusResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycStatusResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycStatusResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.firstName, firstName) || other.firstName == firstName)&&(identical(other.middleName, middleName) || other.middleName == middleName)&&(identical(other.lastName, lastName) || other.lastName == lastName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.sex, sex) || other.sex == sex)&&(identical(other.nationality, nationality) || other.nationality == nationality)&&(identical(other.civilStatus, civilStatus) || other.civilStatus == civilStatus)&&(identical(other.email, email) || other.email == email)&&(identical(other.mobileNumber, mobileNumber) || other.mobileNumber == mobileNumber)&&(identical(other.streetBarangay, streetBarangay) || other.streetBarangay == streetBarangay)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.zipCode, zipCode) || other.zipCode == zipCode)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.idExpiryDate, idExpiryDate) || other.idExpiryDate == idExpiryDate)&&(identical(other.idFrontImageUrl, idFrontImageUrl) || other.idFrontImageUrl == idFrontImageUrl)&&(identical(other.idBackImageUrl, idBackImageUrl) || other.idBackImageUrl == idBackImageUrl)&&(identical(other.idImageUrl, idImageUrl) || other.idImageUrl == idImageUrl)&&(identical(other.selfieImageUrl, selfieImageUrl) || other.selfieImageUrl == selfieImageUrl)&&(identical(other.selfieWithIdImageUrl, selfieWithIdImageUrl) || other.selfieWithIdImageUrl == selfieWithIdImageUrl)&&(identical(other.declarationAccepted, declarationAccepted) || other.declarationAccepted == declarationAccepted)&&(identical(other.precheckStatus, precheckStatus) || other.precheckStatus == precheckStatus)&&(identical(other.precheckNotes, precheckNotes) || other.precheckNotes == precheckNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.verifiedByRole, verifiedByRole) || other.verifiedByRole == verifiedByRole)&&(identical(other.resubmissionCount, resubmissionCount) || other.resubmissionCount == resubmissionCount)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,kycStatus,fullName,firstName,middleName,lastName,dateOfBirth,sex,nationality,civilStatus,email,mobileNumber,streetBarangay,cityMunicipality,province,zipCode,idType,idNumber,idExpiryDate,idFrontImageUrl,idBackImageUrl,idImageUrl,selfieImageUrl,selfieWithIdImageUrl,declarationAccepted,precheckStatus,precheckNotes,rejectionReason,adminNotes,verifiedBy,verifiedByRole,resubmissionCount,submittedAt,verifiedAt,createdAt]);

@override
String toString() {
  return 'KycStatusResponse(id: $id, userId: $userId, kycStatus: $kycStatus, fullName: $fullName, firstName: $firstName, middleName: $middleName, lastName: $lastName, dateOfBirth: $dateOfBirth, sex: $sex, nationality: $nationality, civilStatus: $civilStatus, email: $email, mobileNumber: $mobileNumber, streetBarangay: $streetBarangay, cityMunicipality: $cityMunicipality, province: $province, zipCode: $zipCode, idType: $idType, idNumber: $idNumber, idExpiryDate: $idExpiryDate, idFrontImageUrl: $idFrontImageUrl, idBackImageUrl: $idBackImageUrl, idImageUrl: $idImageUrl, selfieImageUrl: $selfieImageUrl, selfieWithIdImageUrl: $selfieWithIdImageUrl, declarationAccepted: $declarationAccepted, precheckStatus: $precheckStatus, precheckNotes: $precheckNotes, rejectionReason: $rejectionReason, adminNotes: $adminNotes, verifiedBy: $verifiedBy, verifiedByRole: $verifiedByRole, resubmissionCount: $resubmissionCount, submittedAt: $submittedAt, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$KycStatusResponseCopyWith<$Res> implements $KycStatusResponseCopyWith<$Res> {
  factory _$KycStatusResponseCopyWith(_KycStatusResponse value, $Res Function(_KycStatusResponse) _then) = __$KycStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 String? id,@JsonKey(name: 'user_id') String? userId,@JsonKey(name: 'kyc_status') KycStatus kycStatus,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'first_name') String? firstName,@JsonKey(name: 'middle_name') String? middleName,@JsonKey(name: 'last_name') String? lastName,@JsonKey(name: 'date_of_birth') String? dateOfBirth, Sex? sex, String? nationality,@JsonKey(name: 'civil_status') CivilStatus? civilStatus, String? email,@JsonKey(name: 'mobile_number') String? mobileNumber,@JsonKey(name: 'street_barangay') String? streetBarangay,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province,@JsonKey(name: 'zip_code') String? zipCode,@JsonKey(name: 'id_type') IdType? idType,@JsonKey(name: 'id_number') String? idNumber,@JsonKey(name: 'id_expiry_date') String? idExpiryDate,@JsonKey(name: 'id_front_image_url') String? idFrontImageUrl,@JsonKey(name: 'id_back_image_url') String? idBackImageUrl,@JsonKey(name: 'id_image_url') String? idImageUrl,@JsonKey(name: 'selfie_image_url') String? selfieImageUrl,@JsonKey(name: 'selfie_with_id_image_url') String? selfieWithIdImageUrl,@JsonKey(name: 'declaration_accepted') bool declarationAccepted,@JsonKey(name: 'precheck_status') PrecheckStatus? precheckStatus,@JsonKey(name: 'precheck_notes') String? precheckNotes,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'admin_notes') String? adminNotes,@JsonKey(name: 'verified_by') String? verifiedBy,@JsonKey(name: 'verified_by_role') String? verifiedByRole,@JsonKey(name: 'resubmission_count') int resubmissionCount,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$KycStatusResponseCopyWithImpl<$Res>
    implements _$KycStatusResponseCopyWith<$Res> {
  __$KycStatusResponseCopyWithImpl(this._self, this._then);

  final _KycStatusResponse _self;
  final $Res Function(_KycStatusResponse) _then;

/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = freezed,Object? userId = freezed,Object? kycStatus = null,Object? fullName = null,Object? firstName = freezed,Object? middleName = freezed,Object? lastName = freezed,Object? dateOfBirth = freezed,Object? sex = freezed,Object? nationality = freezed,Object? civilStatus = freezed,Object? email = freezed,Object? mobileNumber = freezed,Object? streetBarangay = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? zipCode = freezed,Object? idType = freezed,Object? idNumber = freezed,Object? idExpiryDate = freezed,Object? idFrontImageUrl = freezed,Object? idBackImageUrl = freezed,Object? idImageUrl = freezed,Object? selfieImageUrl = freezed,Object? selfieWithIdImageUrl = freezed,Object? declarationAccepted = null,Object? precheckStatus = freezed,Object? precheckNotes = freezed,Object? rejectionReason = freezed,Object? adminNotes = freezed,Object? verifiedBy = freezed,Object? verifiedByRole = freezed,Object? resubmissionCount = null,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_KycStatusResponse(
id: freezed == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as KycStatus,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,firstName: freezed == firstName ? _self.firstName : firstName // ignore: cast_nullable_to_non_nullable
as String?,middleName: freezed == middleName ? _self.middleName : middleName // ignore: cast_nullable_to_non_nullable
as String?,lastName: freezed == lastName ? _self.lastName : lastName // ignore: cast_nullable_to_non_nullable
as String?,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,sex: freezed == sex ? _self.sex : sex // ignore: cast_nullable_to_non_nullable
as Sex?,nationality: freezed == nationality ? _self.nationality : nationality // ignore: cast_nullable_to_non_nullable
as String?,civilStatus: freezed == civilStatus ? _self.civilStatus : civilStatus // ignore: cast_nullable_to_non_nullable
as CivilStatus?,email: freezed == email ? _self.email : email // ignore: cast_nullable_to_non_nullable
as String?,mobileNumber: freezed == mobileNumber ? _self.mobileNumber : mobileNumber // ignore: cast_nullable_to_non_nullable
as String?,streetBarangay: freezed == streetBarangay ? _self.streetBarangay : streetBarangay // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,zipCode: freezed == zipCode ? _self.zipCode : zipCode // ignore: cast_nullable_to_non_nullable
as String?,idType: freezed == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as IdType?,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,idExpiryDate: freezed == idExpiryDate ? _self.idExpiryDate : idExpiryDate // ignore: cast_nullable_to_non_nullable
as String?,idFrontImageUrl: freezed == idFrontImageUrl ? _self.idFrontImageUrl : idFrontImageUrl // ignore: cast_nullable_to_non_nullable
as String?,idBackImageUrl: freezed == idBackImageUrl ? _self.idBackImageUrl : idBackImageUrl // ignore: cast_nullable_to_non_nullable
as String?,idImageUrl: freezed == idImageUrl ? _self.idImageUrl : idImageUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieImageUrl: freezed == selfieImageUrl ? _self.selfieImageUrl : selfieImageUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieWithIdImageUrl: freezed == selfieWithIdImageUrl ? _self.selfieWithIdImageUrl : selfieWithIdImageUrl // ignore: cast_nullable_to_non_nullable
as String?,declarationAccepted: null == declarationAccepted ? _self.declarationAccepted : declarationAccepted // ignore: cast_nullable_to_non_nullable
as bool,precheckStatus: freezed == precheckStatus ? _self.precheckStatus : precheckStatus // ignore: cast_nullable_to_non_nullable
as PrecheckStatus?,precheckNotes: freezed == precheckNotes ? _self.precheckNotes : precheckNotes // ignore: cast_nullable_to_non_nullable
as String?,rejectionReason: freezed == rejectionReason ? _self.rejectionReason : rejectionReason // ignore: cast_nullable_to_non_nullable
as String?,adminNotes: freezed == adminNotes ? _self.adminNotes : adminNotes // ignore: cast_nullable_to_non_nullable
as String?,verifiedBy: freezed == verifiedBy ? _self.verifiedBy : verifiedBy // ignore: cast_nullable_to_non_nullable
as String?,verifiedByRole: freezed == verifiedByRole ? _self.verifiedByRole : verifiedByRole // ignore: cast_nullable_to_non_nullable
as String?,resubmissionCount: null == resubmissionCount ? _self.resubmissionCount : resubmissionCount // ignore: cast_nullable_to_non_nullable
as int,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$IdTypesResponse {

@JsonKey(name: 'id_types') List<String> get idTypes;
/// Create a copy of IdTypesResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$IdTypesResponseCopyWith<IdTypesResponse> get copyWith => _$IdTypesResponseCopyWithImpl<IdTypesResponse>(this as IdTypesResponse, _$identity);

  /// Serializes this IdTypesResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is IdTypesResponse&&const DeepCollectionEquality().equals(other.idTypes, idTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(idTypes));

@override
String toString() {
  return 'IdTypesResponse(idTypes: $idTypes)';
}


}

/// @nodoc
abstract mixin class $IdTypesResponseCopyWith<$Res>  {
  factory $IdTypesResponseCopyWith(IdTypesResponse value, $Res Function(IdTypesResponse) _then) = _$IdTypesResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_types') List<String> idTypes
});




}
/// @nodoc
class _$IdTypesResponseCopyWithImpl<$Res>
    implements $IdTypesResponseCopyWith<$Res> {
  _$IdTypesResponseCopyWithImpl(this._self, this._then);

  final IdTypesResponse _self;
  final $Res Function(IdTypesResponse) _then;

/// Create a copy of IdTypesResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idTypes = null,}) {
  return _then(_self.copyWith(
idTypes: null == idTypes ? _self.idTypes : idTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}

}


/// Adds pattern-matching-related methods to [IdTypesResponse].
extension IdTypesResponsePatterns on IdTypesResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _IdTypesResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _IdTypesResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _IdTypesResponse value)  $default,){
final _that = this;
switch (_that) {
case _IdTypesResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _IdTypesResponse value)?  $default,){
final _that = this;
switch (_that) {
case _IdTypesResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_types')  List<String> idTypes)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _IdTypesResponse() when $default != null:
return $default(_that.idTypes);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_types')  List<String> idTypes)  $default,) {final _that = this;
switch (_that) {
case _IdTypesResponse():
return $default(_that.idTypes);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_types')  List<String> idTypes)?  $default,) {final _that = this;
switch (_that) {
case _IdTypesResponse() when $default != null:
return $default(_that.idTypes);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _IdTypesResponse implements IdTypesResponse {
  const _IdTypesResponse({@JsonKey(name: 'id_types') final  List<String> idTypes = const []}): _idTypes = idTypes;
  factory _IdTypesResponse.fromJson(Map<String, dynamic> json) => _$IdTypesResponseFromJson(json);

 final  List<String> _idTypes;
@override@JsonKey(name: 'id_types') List<String> get idTypes {
  if (_idTypes is EqualUnmodifiableListView) return _idTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_idTypes);
}


/// Create a copy of IdTypesResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$IdTypesResponseCopyWith<_IdTypesResponse> get copyWith => __$IdTypesResponseCopyWithImpl<_IdTypesResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$IdTypesResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _IdTypesResponse&&const DeepCollectionEquality().equals(other._idTypes, _idTypes));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_idTypes));

@override
String toString() {
  return 'IdTypesResponse(idTypes: $idTypes)';
}


}

/// @nodoc
abstract mixin class _$IdTypesResponseCopyWith<$Res> implements $IdTypesResponseCopyWith<$Res> {
  factory _$IdTypesResponseCopyWith(_IdTypesResponse value, $Res Function(_IdTypesResponse) _then) = __$IdTypesResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_types') List<String> idTypes
});




}
/// @nodoc
class __$IdTypesResponseCopyWithImpl<$Res>
    implements _$IdTypesResponseCopyWith<$Res> {
  __$IdTypesResponseCopyWithImpl(this._self, this._then);

  final _IdTypesResponse _self;
  final $Res Function(_IdTypesResponse) _then;

/// Create a copy of IdTypesResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idTypes = null,}) {
  return _then(_IdTypesResponse(
idTypes: null == idTypes ? _self._idTypes : idTypes // ignore: cast_nullable_to_non_nullable
as List<String>,
  ));
}


}


/// @nodoc
mixin _$KycFormOptionsResponse {

@JsonKey(name: 'id_types') List<KycOptionItem> get idTypes;@JsonKey(name: 'sex_options') List<KycOptionItem> get sexOptions;@JsonKey(name: 'civil_statuses') List<KycOptionItem> get civilStatuses;
/// Create a copy of KycFormOptionsResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycFormOptionsResponseCopyWith<KycFormOptionsResponse> get copyWith => _$KycFormOptionsResponseCopyWithImpl<KycFormOptionsResponse>(this as KycFormOptionsResponse, _$identity);

  /// Serializes this KycFormOptionsResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycFormOptionsResponse&&const DeepCollectionEquality().equals(other.idTypes, idTypes)&&const DeepCollectionEquality().equals(other.sexOptions, sexOptions)&&const DeepCollectionEquality().equals(other.civilStatuses, civilStatuses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(idTypes),const DeepCollectionEquality().hash(sexOptions),const DeepCollectionEquality().hash(civilStatuses));

@override
String toString() {
  return 'KycFormOptionsResponse(idTypes: $idTypes, sexOptions: $sexOptions, civilStatuses: $civilStatuses)';
}


}

/// @nodoc
abstract mixin class $KycFormOptionsResponseCopyWith<$Res>  {
  factory $KycFormOptionsResponseCopyWith(KycFormOptionsResponse value, $Res Function(KycFormOptionsResponse) _then) = _$KycFormOptionsResponseCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id_types') List<KycOptionItem> idTypes,@JsonKey(name: 'sex_options') List<KycOptionItem> sexOptions,@JsonKey(name: 'civil_statuses') List<KycOptionItem> civilStatuses
});




}
/// @nodoc
class _$KycFormOptionsResponseCopyWithImpl<$Res>
    implements $KycFormOptionsResponseCopyWith<$Res> {
  _$KycFormOptionsResponseCopyWithImpl(this._self, this._then);

  final KycFormOptionsResponse _self;
  final $Res Function(KycFormOptionsResponse) _then;

/// Create a copy of KycFormOptionsResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? idTypes = null,Object? sexOptions = null,Object? civilStatuses = null,}) {
  return _then(_self.copyWith(
idTypes: null == idTypes ? _self.idTypes : idTypes // ignore: cast_nullable_to_non_nullable
as List<KycOptionItem>,sexOptions: null == sexOptions ? _self.sexOptions : sexOptions // ignore: cast_nullable_to_non_nullable
as List<KycOptionItem>,civilStatuses: null == civilStatuses ? _self.civilStatuses : civilStatuses // ignore: cast_nullable_to_non_nullable
as List<KycOptionItem>,
  ));
}

}


/// Adds pattern-matching-related methods to [KycFormOptionsResponse].
extension KycFormOptionsResponsePatterns on KycFormOptionsResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycFormOptionsResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycFormOptionsResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycFormOptionsResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycFormOptionsResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycFormOptionsResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycFormOptionsResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_types')  List<KycOptionItem> idTypes, @JsonKey(name: 'sex_options')  List<KycOptionItem> sexOptions, @JsonKey(name: 'civil_statuses')  List<KycOptionItem> civilStatuses)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycFormOptionsResponse() when $default != null:
return $default(_that.idTypes,_that.sexOptions,_that.civilStatuses);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id_types')  List<KycOptionItem> idTypes, @JsonKey(name: 'sex_options')  List<KycOptionItem> sexOptions, @JsonKey(name: 'civil_statuses')  List<KycOptionItem> civilStatuses)  $default,) {final _that = this;
switch (_that) {
case _KycFormOptionsResponse():
return $default(_that.idTypes,_that.sexOptions,_that.civilStatuses);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id_types')  List<KycOptionItem> idTypes, @JsonKey(name: 'sex_options')  List<KycOptionItem> sexOptions, @JsonKey(name: 'civil_statuses')  List<KycOptionItem> civilStatuses)?  $default,) {final _that = this;
switch (_that) {
case _KycFormOptionsResponse() when $default != null:
return $default(_that.idTypes,_that.sexOptions,_that.civilStatuses);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycFormOptionsResponse implements KycFormOptionsResponse {
  const _KycFormOptionsResponse({@JsonKey(name: 'id_types') final  List<KycOptionItem> idTypes = const [], @JsonKey(name: 'sex_options') final  List<KycOptionItem> sexOptions = const [], @JsonKey(name: 'civil_statuses') final  List<KycOptionItem> civilStatuses = const []}): _idTypes = idTypes,_sexOptions = sexOptions,_civilStatuses = civilStatuses;
  factory _KycFormOptionsResponse.fromJson(Map<String, dynamic> json) => _$KycFormOptionsResponseFromJson(json);

 final  List<KycOptionItem> _idTypes;
@override@JsonKey(name: 'id_types') List<KycOptionItem> get idTypes {
  if (_idTypes is EqualUnmodifiableListView) return _idTypes;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_idTypes);
}

 final  List<KycOptionItem> _sexOptions;
@override@JsonKey(name: 'sex_options') List<KycOptionItem> get sexOptions {
  if (_sexOptions is EqualUnmodifiableListView) return _sexOptions;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_sexOptions);
}

 final  List<KycOptionItem> _civilStatuses;
@override@JsonKey(name: 'civil_statuses') List<KycOptionItem> get civilStatuses {
  if (_civilStatuses is EqualUnmodifiableListView) return _civilStatuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_civilStatuses);
}


/// Create a copy of KycFormOptionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycFormOptionsResponseCopyWith<_KycFormOptionsResponse> get copyWith => __$KycFormOptionsResponseCopyWithImpl<_KycFormOptionsResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycFormOptionsResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycFormOptionsResponse&&const DeepCollectionEquality().equals(other._idTypes, _idTypes)&&const DeepCollectionEquality().equals(other._sexOptions, _sexOptions)&&const DeepCollectionEquality().equals(other._civilStatuses, _civilStatuses));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_idTypes),const DeepCollectionEquality().hash(_sexOptions),const DeepCollectionEquality().hash(_civilStatuses));

@override
String toString() {
  return 'KycFormOptionsResponse(idTypes: $idTypes, sexOptions: $sexOptions, civilStatuses: $civilStatuses)';
}


}

/// @nodoc
abstract mixin class _$KycFormOptionsResponseCopyWith<$Res> implements $KycFormOptionsResponseCopyWith<$Res> {
  factory _$KycFormOptionsResponseCopyWith(_KycFormOptionsResponse value, $Res Function(_KycFormOptionsResponse) _then) = __$KycFormOptionsResponseCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id_types') List<KycOptionItem> idTypes,@JsonKey(name: 'sex_options') List<KycOptionItem> sexOptions,@JsonKey(name: 'civil_statuses') List<KycOptionItem> civilStatuses
});




}
/// @nodoc
class __$KycFormOptionsResponseCopyWithImpl<$Res>
    implements _$KycFormOptionsResponseCopyWith<$Res> {
  __$KycFormOptionsResponseCopyWithImpl(this._self, this._then);

  final _KycFormOptionsResponse _self;
  final $Res Function(_KycFormOptionsResponse) _then;

/// Create a copy of KycFormOptionsResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? idTypes = null,Object? sexOptions = null,Object? civilStatuses = null,}) {
  return _then(_KycFormOptionsResponse(
idTypes: null == idTypes ? _self._idTypes : idTypes // ignore: cast_nullable_to_non_nullable
as List<KycOptionItem>,sexOptions: null == sexOptions ? _self._sexOptions : sexOptions // ignore: cast_nullable_to_non_nullable
as List<KycOptionItem>,civilStatuses: null == civilStatuses ? _self._civilStatuses : civilStatuses // ignore: cast_nullable_to_non_nullable
as List<KycOptionItem>,
  ));
}


}


/// @nodoc
mixin _$KycOptionItem {

 String get value; String get label;
/// Create a copy of KycOptionItem
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycOptionItemCopyWith<KycOptionItem> get copyWith => _$KycOptionItemCopyWithImpl<KycOptionItem>(this as KycOptionItem, _$identity);

  /// Serializes this KycOptionItem to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycOptionItem&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'KycOptionItem(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class $KycOptionItemCopyWith<$Res>  {
  factory $KycOptionItemCopyWith(KycOptionItem value, $Res Function(KycOptionItem) _then) = _$KycOptionItemCopyWithImpl;
@useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class _$KycOptionItemCopyWithImpl<$Res>
    implements $KycOptionItemCopyWith<$Res> {
  _$KycOptionItemCopyWithImpl(this._self, this._then);

  final KycOptionItem _self;
  final $Res Function(KycOptionItem) _then;

/// Create a copy of KycOptionItem
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? value = null,Object? label = null,}) {
  return _then(_self.copyWith(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}

}


/// Adds pattern-matching-related methods to [KycOptionItem].
extension KycOptionItemPatterns on KycOptionItem {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycOptionItem value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycOptionItem() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycOptionItem value)  $default,){
final _that = this;
switch (_that) {
case _KycOptionItem():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycOptionItem value)?  $default,){
final _that = this;
switch (_that) {
case _KycOptionItem() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String value,  String label)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycOptionItem() when $default != null:
return $default(_that.value,_that.label);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String value,  String label)  $default,) {final _that = this;
switch (_that) {
case _KycOptionItem():
return $default(_that.value,_that.label);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String value,  String label)?  $default,) {final _that = this;
switch (_that) {
case _KycOptionItem() when $default != null:
return $default(_that.value,_that.label);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycOptionItem implements KycOptionItem {
  const _KycOptionItem({required this.value, required this.label});
  factory _KycOptionItem.fromJson(Map<String, dynamic> json) => _$KycOptionItemFromJson(json);

@override final  String value;
@override final  String label;

/// Create a copy of KycOptionItem
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycOptionItemCopyWith<_KycOptionItem> get copyWith => __$KycOptionItemCopyWithImpl<_KycOptionItem>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycOptionItemToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycOptionItem&&(identical(other.value, value) || other.value == value)&&(identical(other.label, label) || other.label == label));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,value,label);

@override
String toString() {
  return 'KycOptionItem(value: $value, label: $label)';
}


}

/// @nodoc
abstract mixin class _$KycOptionItemCopyWith<$Res> implements $KycOptionItemCopyWith<$Res> {
  factory _$KycOptionItemCopyWith(_KycOptionItem value, $Res Function(_KycOptionItem) _then) = __$KycOptionItemCopyWithImpl;
@override @useResult
$Res call({
 String value, String label
});




}
/// @nodoc
class __$KycOptionItemCopyWithImpl<$Res>
    implements _$KycOptionItemCopyWith<$Res> {
  __$KycOptionItemCopyWithImpl(this._self, this._then);

  final _KycOptionItem _self;
  final $Res Function(_KycOptionItem) _then;

/// Create a copy of KycOptionItem
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? value = null,Object? label = null,}) {
  return _then(_KycOptionItem(
value: null == value ? _self.value : value // ignore: cast_nullable_to_non_nullable
as String,label: null == label ? _self.label : label // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}


/// @nodoc
mixin _$KycErrorResponse {

 String get error; Map<String, dynamic>? get details;
/// Create a copy of KycErrorResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycErrorResponseCopyWith<KycErrorResponse> get copyWith => _$KycErrorResponseCopyWithImpl<KycErrorResponse>(this as KycErrorResponse, _$identity);

  /// Serializes this KycErrorResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycErrorResponse&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other.details, details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,error,const DeepCollectionEquality().hash(details));

@override
String toString() {
  return 'KycErrorResponse(error: $error, details: $details)';
}


}

/// @nodoc
abstract mixin class $KycErrorResponseCopyWith<$Res>  {
  factory $KycErrorResponseCopyWith(KycErrorResponse value, $Res Function(KycErrorResponse) _then) = _$KycErrorResponseCopyWithImpl;
@useResult
$Res call({
 String error, Map<String, dynamic>? details
});




}
/// @nodoc
class _$KycErrorResponseCopyWithImpl<$Res>
    implements $KycErrorResponseCopyWith<$Res> {
  _$KycErrorResponseCopyWithImpl(this._self, this._then);

  final KycErrorResponse _self;
  final $Res Function(KycErrorResponse) _then;

/// Create a copy of KycErrorResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? error = null,Object? details = freezed,}) {
  return _then(_self.copyWith(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self.details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}

}


/// Adds pattern-matching-related methods to [KycErrorResponse].
extension KycErrorResponsePatterns on KycErrorResponse {
/// A variant of `map` that fallback to returning `orElse`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _KycErrorResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _KycErrorResponse() when $default != null:
return $default(_that);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// Callbacks receives the raw object, upcasted.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case final Subclass2 value:
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _KycErrorResponse value)  $default,){
final _that = this;
switch (_that) {
case _KycErrorResponse():
return $default(_that);}
}
/// A variant of `map` that fallback to returning `null`.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case final Subclass value:
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _KycErrorResponse value)?  $default,){
final _that = this;
switch (_that) {
case _KycErrorResponse() when $default != null:
return $default(_that);case _:
  return null;

}
}
/// A variant of `when` that fallback to an `orElse` callback.
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return orElse();
/// }
/// ```

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String error,  Map<String, dynamic>? details)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycErrorResponse() when $default != null:
return $default(_that.error,_that.details);case _:
  return orElse();

}
}
/// A `switch`-like method, using callbacks.
///
/// As opposed to `map`, this offers destructuring.
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case Subclass2(:final field2):
///     return ...;
/// }
/// ```

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String error,  Map<String, dynamic>? details)  $default,) {final _that = this;
switch (_that) {
case _KycErrorResponse():
return $default(_that.error,_that.details);}
}
/// A variant of `when` that fallback to returning `null`
///
/// It is equivalent to doing:
/// ```dart
/// switch (sealedClass) {
///   case Subclass(:final field):
///     return ...;
///   case _:
///     return null;
/// }
/// ```

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String error,  Map<String, dynamic>? details)?  $default,) {final _that = this;
switch (_that) {
case _KycErrorResponse() when $default != null:
return $default(_that.error,_that.details);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycErrorResponse implements KycErrorResponse {
  const _KycErrorResponse({required this.error, final  Map<String, dynamic>? details}): _details = details;
  factory _KycErrorResponse.fromJson(Map<String, dynamic> json) => _$KycErrorResponseFromJson(json);

@override final  String error;
 final  Map<String, dynamic>? _details;
@override Map<String, dynamic>? get details {
  final value = _details;
  if (value == null) return null;
  if (_details is EqualUnmodifiableMapView) return _details;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}


/// Create a copy of KycErrorResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$KycErrorResponseCopyWith<_KycErrorResponse> get copyWith => __$KycErrorResponseCopyWithImpl<_KycErrorResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$KycErrorResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycErrorResponse&&(identical(other.error, error) || other.error == error)&&const DeepCollectionEquality().equals(other._details, _details));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,error,const DeepCollectionEquality().hash(_details));

@override
String toString() {
  return 'KycErrorResponse(error: $error, details: $details)';
}


}

/// @nodoc
abstract mixin class _$KycErrorResponseCopyWith<$Res> implements $KycErrorResponseCopyWith<$Res> {
  factory _$KycErrorResponseCopyWith(_KycErrorResponse value, $Res Function(_KycErrorResponse) _then) = __$KycErrorResponseCopyWithImpl;
@override @useResult
$Res call({
 String error, Map<String, dynamic>? details
});




}
/// @nodoc
class __$KycErrorResponseCopyWithImpl<$Res>
    implements _$KycErrorResponseCopyWith<$Res> {
  __$KycErrorResponseCopyWithImpl(this._self, this._then);

  final _KycErrorResponse _self;
  final $Res Function(_KycErrorResponse) _then;

/// Create a copy of KycErrorResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? error = null,Object? details = freezed,}) {
  return _then(_KycErrorResponse(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,details: freezed == details ? _self._details : details // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>?,
  ));
}


}

// dart format on

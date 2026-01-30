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

 String get id;@JsonKey(name: 'user_id') String get userId;@JsonKey(name: 'kyc_status') KycStatus get kycStatus;@JsonKey(name: 'id_type') IdType get idType;@JsonKey(name: 'id_number') String? get idNumber;@JsonKey(name: 'full_name') String get fullName;@JsonKey(name: 'date_of_birth') String? get dateOfBirth;@JsonKey(name: 'id_image_url') String? get idImageUrl;@JsonKey(name: 'id_back_image_url') String? get idBackImageUrl;@JsonKey(name: 'selfie_image_url') String? get selfieImageUrl;@JsonKey(name: 'precheck_status') PrecheckStatus? get precheckStatus;@JsonKey(name: 'precheck_notes') String? get precheckNotes;@JsonKey(name: 'rejection_reason') String? get rejectionReason;@JsonKey(name: 'admin_notes') String? get adminNotes;@JsonKey(name: 'verified_by') String? get verifiedBy;@JsonKey(name: 'verified_by_role') String? get verifiedByRole;@JsonKey(name: 'resubmission_count') int get resubmissionCount;@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of KycStatusResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycStatusResponseCopyWith<KycStatusResponse> get copyWith => _$KycStatusResponseCopyWithImpl<KycStatusResponse>(this as KycStatusResponse, _$identity);

  /// Serializes this KycStatusResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycStatusResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.idImageUrl, idImageUrl) || other.idImageUrl == idImageUrl)&&(identical(other.idBackImageUrl, idBackImageUrl) || other.idBackImageUrl == idBackImageUrl)&&(identical(other.selfieImageUrl, selfieImageUrl) || other.selfieImageUrl == selfieImageUrl)&&(identical(other.precheckStatus, precheckStatus) || other.precheckStatus == precheckStatus)&&(identical(other.precheckNotes, precheckNotes) || other.precheckNotes == precheckNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.verifiedByRole, verifiedByRole) || other.verifiedByRole == verifiedByRole)&&(identical(other.resubmissionCount, resubmissionCount) || other.resubmissionCount == resubmissionCount)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,kycStatus,idType,idNumber,fullName,dateOfBirth,idImageUrl,idBackImageUrl,selfieImageUrl,precheckStatus,precheckNotes,rejectionReason,adminNotes,verifiedBy,verifiedByRole,resubmissionCount,submittedAt,verifiedAt,createdAt]);

@override
String toString() {
  return 'KycStatusResponse(id: $id, userId: $userId, kycStatus: $kycStatus, idType: $idType, idNumber: $idNumber, fullName: $fullName, dateOfBirth: $dateOfBirth, idImageUrl: $idImageUrl, idBackImageUrl: $idBackImageUrl, selfieImageUrl: $selfieImageUrl, precheckStatus: $precheckStatus, precheckNotes: $precheckNotes, rejectionReason: $rejectionReason, adminNotes: $adminNotes, verifiedBy: $verifiedBy, verifiedByRole: $verifiedByRole, resubmissionCount: $resubmissionCount, submittedAt: $submittedAt, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $KycStatusResponseCopyWith<$Res>  {
  factory $KycStatusResponseCopyWith(KycStatusResponse value, $Res Function(KycStatusResponse) _then) = _$KycStatusResponseCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'kyc_status') KycStatus kycStatus,@JsonKey(name: 'id_type') IdType idType,@JsonKey(name: 'id_number') String? idNumber,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'date_of_birth') String? dateOfBirth,@JsonKey(name: 'id_image_url') String? idImageUrl,@JsonKey(name: 'id_back_image_url') String? idBackImageUrl,@JsonKey(name: 'selfie_image_url') String? selfieImageUrl,@JsonKey(name: 'precheck_status') PrecheckStatus? precheckStatus,@JsonKey(name: 'precheck_notes') String? precheckNotes,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'admin_notes') String? adminNotes,@JsonKey(name: 'verified_by') String? verifiedBy,@JsonKey(name: 'verified_by_role') String? verifiedByRole,@JsonKey(name: 'resubmission_count') int resubmissionCount,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'created_at') String? createdAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? userId = null,Object? kycStatus = null,Object? idType = null,Object? idNumber = freezed,Object? fullName = null,Object? dateOfBirth = freezed,Object? idImageUrl = freezed,Object? idBackImageUrl = freezed,Object? selfieImageUrl = freezed,Object? precheckStatus = freezed,Object? precheckNotes = freezed,Object? rejectionReason = freezed,Object? adminNotes = freezed,Object? verifiedBy = freezed,Object? verifiedByRole = freezed,Object? resubmissionCount = null,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as KycStatus,idType: null == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as IdType,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,idImageUrl: freezed == idImageUrl ? _self.idImageUrl : idImageUrl // ignore: cast_nullable_to_non_nullable
as String?,idBackImageUrl: freezed == idBackImageUrl ? _self.idBackImageUrl : idBackImageUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieImageUrl: freezed == selfieImageUrl ? _self.selfieImageUrl : selfieImageUrl // ignore: cast_nullable_to_non_nullable
as String?,precheckStatus: freezed == precheckStatus ? _self.precheckStatus : precheckStatus // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'kyc_status')  KycStatus kycStatus, @JsonKey(name: 'id_type')  IdType idType, @JsonKey(name: 'id_number')  String? idNumber, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'date_of_birth')  String? dateOfBirth, @JsonKey(name: 'id_image_url')  String? idImageUrl, @JsonKey(name: 'id_back_image_url')  String? idBackImageUrl, @JsonKey(name: 'selfie_image_url')  String? selfieImageUrl, @JsonKey(name: 'precheck_status')  PrecheckStatus? precheckStatus, @JsonKey(name: 'precheck_notes')  String? precheckNotes, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'admin_notes')  String? adminNotes, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'verified_by_role')  String? verifiedByRole, @JsonKey(name: 'resubmission_count')  int resubmissionCount, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.id,_that.userId,_that.kycStatus,_that.idType,_that.idNumber,_that.fullName,_that.dateOfBirth,_that.idImageUrl,_that.idBackImageUrl,_that.selfieImageUrl,_that.precheckStatus,_that.precheckNotes,_that.rejectionReason,_that.adminNotes,_that.verifiedBy,_that.verifiedByRole,_that.resubmissionCount,_that.submittedAt,_that.verifiedAt,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'kyc_status')  KycStatus kycStatus, @JsonKey(name: 'id_type')  IdType idType, @JsonKey(name: 'id_number')  String? idNumber, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'date_of_birth')  String? dateOfBirth, @JsonKey(name: 'id_image_url')  String? idImageUrl, @JsonKey(name: 'id_back_image_url')  String? idBackImageUrl, @JsonKey(name: 'selfie_image_url')  String? selfieImageUrl, @JsonKey(name: 'precheck_status')  PrecheckStatus? precheckStatus, @JsonKey(name: 'precheck_notes')  String? precheckNotes, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'admin_notes')  String? adminNotes, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'verified_by_role')  String? verifiedByRole, @JsonKey(name: 'resubmission_count')  int resubmissionCount, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse():
return $default(_that.id,_that.userId,_that.kycStatus,_that.idType,_that.idNumber,_that.fullName,_that.dateOfBirth,_that.idImageUrl,_that.idBackImageUrl,_that.selfieImageUrl,_that.precheckStatus,_that.precheckNotes,_that.rejectionReason,_that.adminNotes,_that.verifiedBy,_that.verifiedByRole,_that.resubmissionCount,_that.submittedAt,_that.verifiedAt,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'user_id')  String userId, @JsonKey(name: 'kyc_status')  KycStatus kycStatus, @JsonKey(name: 'id_type')  IdType idType, @JsonKey(name: 'id_number')  String? idNumber, @JsonKey(name: 'full_name')  String fullName, @JsonKey(name: 'date_of_birth')  String? dateOfBirth, @JsonKey(name: 'id_image_url')  String? idImageUrl, @JsonKey(name: 'id_back_image_url')  String? idBackImageUrl, @JsonKey(name: 'selfie_image_url')  String? selfieImageUrl, @JsonKey(name: 'precheck_status')  PrecheckStatus? precheckStatus, @JsonKey(name: 'precheck_notes')  String? precheckNotes, @JsonKey(name: 'rejection_reason')  String? rejectionReason, @JsonKey(name: 'admin_notes')  String? adminNotes, @JsonKey(name: 'verified_by')  String? verifiedBy, @JsonKey(name: 'verified_by_role')  String? verifiedByRole, @JsonKey(name: 'resubmission_count')  int resubmissionCount, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _KycStatusResponse() when $default != null:
return $default(_that.id,_that.userId,_that.kycStatus,_that.idType,_that.idNumber,_that.fullName,_that.dateOfBirth,_that.idImageUrl,_that.idBackImageUrl,_that.selfieImageUrl,_that.precheckStatus,_that.precheckNotes,_that.rejectionReason,_that.adminNotes,_that.verifiedBy,_that.verifiedByRole,_that.resubmissionCount,_that.submittedAt,_that.verifiedAt,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycStatusResponse implements KycStatusResponse {
  const _KycStatusResponse({required this.id, @JsonKey(name: 'user_id') required this.userId, @JsonKey(name: 'kyc_status') required this.kycStatus, @JsonKey(name: 'id_type') required this.idType, @JsonKey(name: 'id_number') this.idNumber, @JsonKey(name: 'full_name') required this.fullName, @JsonKey(name: 'date_of_birth') this.dateOfBirth, @JsonKey(name: 'id_image_url') this.idImageUrl, @JsonKey(name: 'id_back_image_url') this.idBackImageUrl, @JsonKey(name: 'selfie_image_url') this.selfieImageUrl, @JsonKey(name: 'precheck_status') this.precheckStatus, @JsonKey(name: 'precheck_notes') this.precheckNotes, @JsonKey(name: 'rejection_reason') this.rejectionReason, @JsonKey(name: 'admin_notes') this.adminNotes, @JsonKey(name: 'verified_by') this.verifiedBy, @JsonKey(name: 'verified_by_role') this.verifiedByRole, @JsonKey(name: 'resubmission_count') this.resubmissionCount = 0, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'created_at') this.createdAt});
  factory _KycStatusResponse.fromJson(Map<String, dynamic> json) => _$KycStatusResponseFromJson(json);

@override final  String id;
@override@JsonKey(name: 'user_id') final  String userId;
@override@JsonKey(name: 'kyc_status') final  KycStatus kycStatus;
@override@JsonKey(name: 'id_type') final  IdType idType;
@override@JsonKey(name: 'id_number') final  String? idNumber;
@override@JsonKey(name: 'full_name') final  String fullName;
@override@JsonKey(name: 'date_of_birth') final  String? dateOfBirth;
@override@JsonKey(name: 'id_image_url') final  String? idImageUrl;
@override@JsonKey(name: 'id_back_image_url') final  String? idBackImageUrl;
@override@JsonKey(name: 'selfie_image_url') final  String? selfieImageUrl;
@override@JsonKey(name: 'precheck_status') final  PrecheckStatus? precheckStatus;
@override@JsonKey(name: 'precheck_notes') final  String? precheckNotes;
@override@JsonKey(name: 'rejection_reason') final  String? rejectionReason;
@override@JsonKey(name: 'admin_notes') final  String? adminNotes;
@override@JsonKey(name: 'verified_by') final  String? verifiedBy;
@override@JsonKey(name: 'verified_by_role') final  String? verifiedByRole;
@override@JsonKey(name: 'resubmission_count') final  int resubmissionCount;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycStatusResponse&&(identical(other.id, id) || other.id == id)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.kycStatus, kycStatus) || other.kycStatus == kycStatus)&&(identical(other.idType, idType) || other.idType == idType)&&(identical(other.idNumber, idNumber) || other.idNumber == idNumber)&&(identical(other.fullName, fullName) || other.fullName == fullName)&&(identical(other.dateOfBirth, dateOfBirth) || other.dateOfBirth == dateOfBirth)&&(identical(other.idImageUrl, idImageUrl) || other.idImageUrl == idImageUrl)&&(identical(other.idBackImageUrl, idBackImageUrl) || other.idBackImageUrl == idBackImageUrl)&&(identical(other.selfieImageUrl, selfieImageUrl) || other.selfieImageUrl == selfieImageUrl)&&(identical(other.precheckStatus, precheckStatus) || other.precheckStatus == precheckStatus)&&(identical(other.precheckNotes, precheckNotes) || other.precheckNotes == precheckNotes)&&(identical(other.rejectionReason, rejectionReason) || other.rejectionReason == rejectionReason)&&(identical(other.adminNotes, adminNotes) || other.adminNotes == adminNotes)&&(identical(other.verifiedBy, verifiedBy) || other.verifiedBy == verifiedBy)&&(identical(other.verifiedByRole, verifiedByRole) || other.verifiedByRole == verifiedByRole)&&(identical(other.resubmissionCount, resubmissionCount) || other.resubmissionCount == resubmissionCount)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,userId,kycStatus,idType,idNumber,fullName,dateOfBirth,idImageUrl,idBackImageUrl,selfieImageUrl,precheckStatus,precheckNotes,rejectionReason,adminNotes,verifiedBy,verifiedByRole,resubmissionCount,submittedAt,verifiedAt,createdAt]);

@override
String toString() {
  return 'KycStatusResponse(id: $id, userId: $userId, kycStatus: $kycStatus, idType: $idType, idNumber: $idNumber, fullName: $fullName, dateOfBirth: $dateOfBirth, idImageUrl: $idImageUrl, idBackImageUrl: $idBackImageUrl, selfieImageUrl: $selfieImageUrl, precheckStatus: $precheckStatus, precheckNotes: $precheckNotes, rejectionReason: $rejectionReason, adminNotes: $adminNotes, verifiedBy: $verifiedBy, verifiedByRole: $verifiedByRole, resubmissionCount: $resubmissionCount, submittedAt: $submittedAt, verifiedAt: $verifiedAt, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$KycStatusResponseCopyWith<$Res> implements $KycStatusResponseCopyWith<$Res> {
  factory _$KycStatusResponseCopyWith(_KycStatusResponse value, $Res Function(_KycStatusResponse) _then) = __$KycStatusResponseCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'user_id') String userId,@JsonKey(name: 'kyc_status') KycStatus kycStatus,@JsonKey(name: 'id_type') IdType idType,@JsonKey(name: 'id_number') String? idNumber,@JsonKey(name: 'full_name') String fullName,@JsonKey(name: 'date_of_birth') String? dateOfBirth,@JsonKey(name: 'id_image_url') String? idImageUrl,@JsonKey(name: 'id_back_image_url') String? idBackImageUrl,@JsonKey(name: 'selfie_image_url') String? selfieImageUrl,@JsonKey(name: 'precheck_status') PrecheckStatus? precheckStatus,@JsonKey(name: 'precheck_notes') String? precheckNotes,@JsonKey(name: 'rejection_reason') String? rejectionReason,@JsonKey(name: 'admin_notes') String? adminNotes,@JsonKey(name: 'verified_by') String? verifiedBy,@JsonKey(name: 'verified_by_role') String? verifiedByRole,@JsonKey(name: 'resubmission_count') int resubmissionCount,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'created_at') String? createdAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? userId = null,Object? kycStatus = null,Object? idType = null,Object? idNumber = freezed,Object? fullName = null,Object? dateOfBirth = freezed,Object? idImageUrl = freezed,Object? idBackImageUrl = freezed,Object? selfieImageUrl = freezed,Object? precheckStatus = freezed,Object? precheckNotes = freezed,Object? rejectionReason = freezed,Object? adminNotes = freezed,Object? verifiedBy = freezed,Object? verifiedByRole = freezed,Object? resubmissionCount = null,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? createdAt = freezed,}) {
  return _then(_KycStatusResponse(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,userId: null == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String,kycStatus: null == kycStatus ? _self.kycStatus : kycStatus // ignore: cast_nullable_to_non_nullable
as KycStatus,idType: null == idType ? _self.idType : idType // ignore: cast_nullable_to_non_nullable
as IdType,idNumber: freezed == idNumber ? _self.idNumber : idNumber // ignore: cast_nullable_to_non_nullable
as String?,fullName: null == fullName ? _self.fullName : fullName // ignore: cast_nullable_to_non_nullable
as String,dateOfBirth: freezed == dateOfBirth ? _self.dateOfBirth : dateOfBirth // ignore: cast_nullable_to_non_nullable
as String?,idImageUrl: freezed == idImageUrl ? _self.idImageUrl : idImageUrl // ignore: cast_nullable_to_non_nullable
as String?,idBackImageUrl: freezed == idBackImageUrl ? _self.idBackImageUrl : idBackImageUrl // ignore: cast_nullable_to_non_nullable
as String?,selfieImageUrl: freezed == selfieImageUrl ? _self.selfieImageUrl : selfieImageUrl // ignore: cast_nullable_to_non_nullable
as String?,precheckStatus: freezed == precheckStatus ? _self.precheckStatus : precheckStatus // ignore: cast_nullable_to_non_nullable
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

 List<String> get idTypes;
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
 List<String> idTypes
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<String> idTypes)?  $default,{required TResult orElse(),}) {final _that = this;
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<String> idTypes)  $default,) {final _that = this;
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<String> idTypes)?  $default,) {final _that = this;
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
  const _IdTypesResponse({final  List<String> idTypes = const []}): _idTypes = idTypes;
  factory _IdTypesResponse.fromJson(Map<String, dynamic> json) => _$IdTypesResponseFromJson(json);

 final  List<String> _idTypes;
@override@JsonKey() List<String> get idTypes {
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
 List<String> idTypes
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
mixin _$KycErrorResponse {

 String get error; String get message;
/// Create a copy of KycErrorResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$KycErrorResponseCopyWith<KycErrorResponse> get copyWith => _$KycErrorResponseCopyWithImpl<KycErrorResponse>(this as KycErrorResponse, _$identity);

  /// Serializes this KycErrorResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is KycErrorResponse&&(identical(other.error, error) || other.error == error)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,error,message);

@override
String toString() {
  return 'KycErrorResponse(error: $error, message: $message)';
}


}

/// @nodoc
abstract mixin class $KycErrorResponseCopyWith<$Res>  {
  factory $KycErrorResponseCopyWith(KycErrorResponse value, $Res Function(KycErrorResponse) _then) = _$KycErrorResponseCopyWithImpl;
@useResult
$Res call({
 String error, String message
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
@pragma('vm:prefer-inline') @override $Res call({Object? error = null,Object? message = null,}) {
  return _then(_self.copyWith(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String error,  String message)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _KycErrorResponse() when $default != null:
return $default(_that.error,_that.message);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String error,  String message)  $default,) {final _that = this;
switch (_that) {
case _KycErrorResponse():
return $default(_that.error,_that.message);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String error,  String message)?  $default,) {final _that = this;
switch (_that) {
case _KycErrorResponse() when $default != null:
return $default(_that.error,_that.message);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _KycErrorResponse implements KycErrorResponse {
  const _KycErrorResponse({required this.error, required this.message});
  factory _KycErrorResponse.fromJson(Map<String, dynamic> json) => _$KycErrorResponseFromJson(json);

@override final  String error;
@override final  String message;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _KycErrorResponse&&(identical(other.error, error) || other.error == error)&&(identical(other.message, message) || other.message == message));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,error,message);

@override
String toString() {
  return 'KycErrorResponse(error: $error, message: $message)';
}


}

/// @nodoc
abstract mixin class _$KycErrorResponseCopyWith<$Res> implements $KycErrorResponseCopyWith<$Res> {
  factory _$KycErrorResponseCopyWith(_KycErrorResponse value, $Res Function(_KycErrorResponse) _then) = __$KycErrorResponseCopyWithImpl;
@override @useResult
$Res call({
 String error, String message
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
@override @pragma('vm:prefer-inline') $Res call({Object? error = null,Object? message = null,}) {
  return _then(_KycErrorResponse(
error: null == error ? _self.error : error // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,
  ));
}


}

// dart format on

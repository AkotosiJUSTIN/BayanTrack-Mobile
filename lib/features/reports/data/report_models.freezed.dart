// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'report_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$ReportImage {

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId; String get url;@JsonKey(name: 's3_key') String? get s3Key; String? get filename;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'mime_type') String? get mimeType; int? get width; int? get height;@JsonKey(name: 'is_primary') bool get isPrimary;/// 'evidence' | 'signature' | 'document' — null means legacy/pre-field record.
 String? get purpose;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ReportImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportImageCopyWith<ReportImage> get copyWith => _$ReportImageCopyWithImpl<ReportImage>(this as ReportImage, _$identity);

  /// Serializes this ReportImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,url,s3Key,filename,fileSize,mimeType,width,height,isPrimary,purpose,createdAt,updatedAt);

@override
String toString() {
  return 'ReportImage(id: $id, reportId: $reportId, userId: $userId, url: $url, s3Key: $s3Key, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, width: $width, height: $height, isPrimary: $isPrimary, purpose: $purpose, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReportImageCopyWith<$Res>  {
  factory $ReportImageCopyWith(ReportImage value, $Res Function(ReportImage) _then) = _$ReportImageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String url,@JsonKey(name: 's3_key') String? s3Key, String? filename,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, int? width, int? height,@JsonKey(name: 'is_primary') bool isPrimary, String? purpose,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class _$ReportImageCopyWithImpl<$Res>
    implements $ReportImageCopyWith<$Res> {
  _$ReportImageCopyWithImpl(this._self, this._then);

  final ReportImage _self;
  final $Res Function(ReportImage) _then;

/// Create a copy of ReportImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? url = null,Object? s3Key = freezed,Object? filename = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? width = freezed,Object? height = freezed,Object? isPrimary = null,Object? purpose = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,s3Key: freezed == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportImage].
extension ReportImagePatterns on ReportImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportImage value)  $default,){
final _that = this;
switch (_that) {
case _ReportImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportImage value)?  $default,){
final _that = this;
switch (_that) {
case _ReportImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary,  String? purpose, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportImage() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.purpose,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary,  String? purpose, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReportImage():
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.purpose,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary,  String? purpose, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportImage() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.purpose,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportImage implements ReportImage {
  const _ReportImage({required this.id, @JsonKey(name: 'report_id') this.reportId, @JsonKey(name: 'user_id') this.userId, required this.url, @JsonKey(name: 's3_key') this.s3Key, this.filename, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'mime_type') this.mimeType, this.width, this.height, @JsonKey(name: 'is_primary') this.isPrimary = false, this.purpose, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _ReportImage.fromJson(Map<String, dynamic> json) => _$ReportImageFromJson(json);

@override final  String id;
@override@JsonKey(name: 'report_id') final  String? reportId;
@override@JsonKey(name: 'user_id') final  String? userId;
@override final  String url;
@override@JsonKey(name: 's3_key') final  String? s3Key;
@override final  String? filename;
@override@JsonKey(name: 'file_size') final  int? fileSize;
@override@JsonKey(name: 'mime_type') final  String? mimeType;
@override final  int? width;
@override final  int? height;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
/// 'evidence' | 'signature' | 'document' — null means legacy/pre-field record.
@override final  String? purpose;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

/// Create a copy of ReportImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportImageCopyWith<_ReportImage> get copyWith => __$ReportImageCopyWithImpl<_ReportImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,url,s3Key,filename,fileSize,mimeType,width,height,isPrimary,purpose,createdAt,updatedAt);

@override
String toString() {
  return 'ReportImage(id: $id, reportId: $reportId, userId: $userId, url: $url, s3Key: $s3Key, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, width: $width, height: $height, isPrimary: $isPrimary, purpose: $purpose, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportImageCopyWith<$Res> implements $ReportImageCopyWith<$Res> {
  factory _$ReportImageCopyWith(_ReportImage value, $Res Function(_ReportImage) _then) = __$ReportImageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String url,@JsonKey(name: 's3_key') String? s3Key, String? filename,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, int? width, int? height,@JsonKey(name: 'is_primary') bool isPrimary, String? purpose,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
});




}
/// @nodoc
class __$ReportImageCopyWithImpl<$Res>
    implements _$ReportImageCopyWith<$Res> {
  __$ReportImageCopyWithImpl(this._self, this._then);

  final _ReportImage _self;
  final $Res Function(_ReportImage) _then;

/// Create a copy of ReportImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? url = null,Object? s3Key = freezed,Object? filename = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? width = freezed,Object? height = freezed,Object? isPrimary = null,Object? purpose = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_ReportImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,url: null == url ? _self.url : url // ignore: cast_nullable_to_non_nullable
as String,s3Key: freezed == s3Key ? _self.s3Key : s3Key // ignore: cast_nullable_to_non_nullable
as String?,filename: freezed == filename ? _self.filename : filename // ignore: cast_nullable_to_non_nullable
as String?,fileSize: freezed == fileSize ? _self.fileSize : fileSize // ignore: cast_nullable_to_non_nullable
as int?,mimeType: freezed == mimeType ? _self.mimeType : mimeType // ignore: cast_nullable_to_non_nullable
as String?,width: freezed == width ? _self.width : width // ignore: cast_nullable_to_non_nullable
as int?,height: freezed == height ? _self.height : height // ignore: cast_nullable_to_non_nullable
as int?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,purpose: freezed == purpose ? _self.purpose : purpose // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Report {

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId;// Report Details
 String? get category;@JsonKey(name: 'category_key') String? get categoryKey;@JsonKey(name: 'category_display') String? get categoryDisplay;@JsonKey(name: 'category_label_snapshot') String? get categoryLabelSnapshot;@JsonKey(name: 'taxonomy_version') String? get taxonomyVersion;@JsonKey(name: 'incident_type') String? get incidentType; String? get title; String get description;@JsonKey(name: 'incident_datetime') String? get incidentDatetime;@JsonKey(name: 'is_happening_now') bool get isHappeningNow;// Location Information
 String? get zone;@JsonKey(name: 'street_landmark') String? get streetLandmark;@JsonKey(name: 'municipality_id', readValue: _readMunicipalityId) String get municipalityId;@JsonKey(name: 'barangay_id', readValue: _readBarangayId) String? get barangayId;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province; String? get latitude; String? get longitude;@JsonKey(name: 'location_accuracy') String get locationAccuracy;// Legacy fields
 String? get location; String? get barangay;// Severity & Impact
 String get severity;@JsonKey(name: 'people_affected')@NullableIntConverter() int? get peopleAffected;@JsonKey(name: 'is_emergency') bool get isEmergency;// System Fields
 String get status;@JsonKey(name: 'assigned_department') String? get assignedDepartment;@JsonKey(name: 'admin_remarks') String? get adminRemarks;// AI Fields
@JsonKey(name: 'category_confidence') double? get categoryConfidence;@JsonKey(name: 'model_version') String? get modelVersion;@JsonKey(name: 'category_source') String? get categorySource;@JsonKey(name: 'model_probability') double? get modelProbability;@JsonKey(name: 'top2_gap') double? get top2Gap;@JsonKey(name: 'needs_category_review') bool? get needsCategoryReview;@JsonKey(name: 'review_reasons') List<String> get reviewReasons;@JsonKey(name: 'is_multi_issue') bool get isMultiIssue;@JsonKey(name: 'rules_applied') List<String> get rulesApplied; String? get priority;@JsonKey(name: 'priority_score')@NullableIntConverter() int? get priorityScore;@JsonKey(name: 'priority_level') String? get priorityLevel;@JsonKey(name: 'suggested_priority_score') double? get suggestedPriorityScore;@JsonKey(name: 'suggested_priority_level') String? get suggestedPriorityLevel;@JsonKey(name: 'queue_priority_score') double? get queuePriorityScore;@JsonKey(name: 'queue_priority_level') String? get queuePriorityLevel;@JsonKey(name: 'queue_priority_rank')@NullableIntConverter() int? get queuePriorityRank;@JsonKey(name: 'staff_priority_level') String? get staffPriorityLevel;@JsonKey(name: 'priority_source') String? get prioritySource;@JsonKey(name: 'priority_is_advisory') bool get priorityIsAdvisory;@JsonKey(name: 'needs_priority_review') bool get needsPriorityReview;@JsonKey(name: 'priority_review_reasons') List<String> get priorityReviewReasons;@JsonKey(name: 'linked_report_count') int get linkedReportCount;@JsonKey(name: 'linked_urgency_boost') int get linkedUrgencyBoost;@JsonKey(name: 'is_incident_representative') bool get isIncidentRepresentative;@JsonKey(name: 'priority_model_version') String? get priorityModelVersion;@JsonKey(name: 'priority_model_validated') bool get priorityModelValidated;@JsonKey(name: 'priority_calibration_version') String? get priorityCalibrationVersion;@JsonKey(name: 'emergency_probability') double? get emergencyProbability;@JsonKey(name: 'priority_components') Map<String, double> get priorityComponents;@JsonKey(name: 'priority_policy_version') String? get priorityPolicyVersion;@JsonKey(name: 'priority_rules_applied') List<String> get priorityRulesApplied;@JsonKey(name: 'priority_reasons') List<String>? get priorityReasons;@JsonKey(name: 'base_score')@NullableIntConverter() int? get baseScore;@JsonKey(name: 'hotspot_score')@NullableIntConverter() int? get hotspotScore;@JsonKey(name: 'urgency_score') double? get urgencyScore;@JsonKey(name: 'recommended_department') String? get recommendedDepartment;@JsonKey(name: 'department_confidence') double? get departmentConfidence;@JsonKey(name: 'routing_reasons') List<String>? get routingReasons;@JsonKey(name: 'needs_department_review') bool? get needsDepartmentReview;@JsonKey(name: 'credibility_score') double? get credibilityScore;@JsonKey(name: 'incident_group_id') String? get incidentGroupId;@JsonKey(name: 'sentiment_score') double? get sentimentScore;@JsonKey(name: 'auto_category_suggestion') String? get autoCategorySuggestion;// Images
 List<ReportImage> get images;@JsonKey(name: 'resolved_proof_image_ids') List<String> get resolvedProofImageIds;@JsonKey(name: 'closure_signature_image_id') String? get closureSignatureImageId;@JsonKey(name: 'closure_signature_document_ids') List<String> get closureSignatureDocumentIds;// Timestamps
@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'resolved_at') String? get resolvedAt;// Citizen Closure
@JsonKey(name: 'citizen_verified_at') String? get citizenVerifiedAt;@JsonKey(name: 'citizen_satisfaction')@NullableIntConverter() int? get citizenSatisfaction;@JsonKey(name: 'citizen_closure_note') String? get citizenClosureNote;// Blockchain Integration
@JsonKey(name: 'on_chain_id')@NullableIntConverter() int? get onChainId;@JsonKey(name: 'on_chain_hash') String? get onChainHash;@JsonKey(name: 'blockchain_txn_hash') String? get blockchainTxnHash;@JsonKey(name: 'blockchain_synced') bool get blockchainSynced;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryKey, categoryKey) || other.categoryKey == categoryKey)&&(identical(other.categoryDisplay, categoryDisplay) || other.categoryDisplay == categoryDisplay)&&(identical(other.categoryLabelSnapshot, categoryLabelSnapshot) || other.categoryLabelSnapshot == categoryLabelSnapshot)&&(identical(other.taxonomyVersion, taxonomyVersion) || other.taxonomyVersion == taxonomyVersion)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.municipalityId, municipalityId) || other.municipalityId == municipalityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedDepartment, assignedDepartment) || other.assignedDepartment == assignedDepartment)&&(identical(other.adminRemarks, adminRemarks) || other.adminRemarks == adminRemarks)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.categorySource, categorySource) || other.categorySource == categorySource)&&(identical(other.modelProbability, modelProbability) || other.modelProbability == modelProbability)&&(identical(other.top2Gap, top2Gap) || other.top2Gap == top2Gap)&&(identical(other.needsCategoryReview, needsCategoryReview) || other.needsCategoryReview == needsCategoryReview)&&const DeepCollectionEquality().equals(other.reviewReasons, reviewReasons)&&(identical(other.isMultiIssue, isMultiIssue) || other.isMultiIssue == isMultiIssue)&&const DeepCollectionEquality().equals(other.rulesApplied, rulesApplied)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.priorityLevel, priorityLevel) || other.priorityLevel == priorityLevel)&&(identical(other.suggestedPriorityScore, suggestedPriorityScore) || other.suggestedPriorityScore == suggestedPriorityScore)&&(identical(other.suggestedPriorityLevel, suggestedPriorityLevel) || other.suggestedPriorityLevel == suggestedPriorityLevel)&&(identical(other.queuePriorityScore, queuePriorityScore) || other.queuePriorityScore == queuePriorityScore)&&(identical(other.queuePriorityLevel, queuePriorityLevel) || other.queuePriorityLevel == queuePriorityLevel)&&(identical(other.queuePriorityRank, queuePriorityRank) || other.queuePriorityRank == queuePriorityRank)&&(identical(other.staffPriorityLevel, staffPriorityLevel) || other.staffPriorityLevel == staffPriorityLevel)&&(identical(other.prioritySource, prioritySource) || other.prioritySource == prioritySource)&&(identical(other.priorityIsAdvisory, priorityIsAdvisory) || other.priorityIsAdvisory == priorityIsAdvisory)&&(identical(other.needsPriorityReview, needsPriorityReview) || other.needsPriorityReview == needsPriorityReview)&&const DeepCollectionEquality().equals(other.priorityReviewReasons, priorityReviewReasons)&&(identical(other.linkedReportCount, linkedReportCount) || other.linkedReportCount == linkedReportCount)&&(identical(other.linkedUrgencyBoost, linkedUrgencyBoost) || other.linkedUrgencyBoost == linkedUrgencyBoost)&&(identical(other.isIncidentRepresentative, isIncidentRepresentative) || other.isIncidentRepresentative == isIncidentRepresentative)&&(identical(other.priorityModelVersion, priorityModelVersion) || other.priorityModelVersion == priorityModelVersion)&&(identical(other.priorityModelValidated, priorityModelValidated) || other.priorityModelValidated == priorityModelValidated)&&(identical(other.priorityCalibrationVersion, priorityCalibrationVersion) || other.priorityCalibrationVersion == priorityCalibrationVersion)&&(identical(other.emergencyProbability, emergencyProbability) || other.emergencyProbability == emergencyProbability)&&const DeepCollectionEquality().equals(other.priorityComponents, priorityComponents)&&(identical(other.priorityPolicyVersion, priorityPolicyVersion) || other.priorityPolicyVersion == priorityPolicyVersion)&&const DeepCollectionEquality().equals(other.priorityRulesApplied, priorityRulesApplied)&&const DeepCollectionEquality().equals(other.priorityReasons, priorityReasons)&&(identical(other.baseScore, baseScore) || other.baseScore == baseScore)&&(identical(other.hotspotScore, hotspotScore) || other.hotspotScore == hotspotScore)&&(identical(other.urgencyScore, urgencyScore) || other.urgencyScore == urgencyScore)&&(identical(other.recommendedDepartment, recommendedDepartment) || other.recommendedDepartment == recommendedDepartment)&&(identical(other.departmentConfidence, departmentConfidence) || other.departmentConfidence == departmentConfidence)&&const DeepCollectionEquality().equals(other.routingReasons, routingReasons)&&(identical(other.needsDepartmentReview, needsDepartmentReview) || other.needsDepartmentReview == needsDepartmentReview)&&(identical(other.credibilityScore, credibilityScore) || other.credibilityScore == credibilityScore)&&(identical(other.incidentGroupId, incidentGroupId) || other.incidentGroupId == incidentGroupId)&&(identical(other.sentimentScore, sentimentScore) || other.sentimentScore == sentimentScore)&&(identical(other.autoCategorySuggestion, autoCategorySuggestion) || other.autoCategorySuggestion == autoCategorySuggestion)&&const DeepCollectionEquality().equals(other.images, images)&&const DeepCollectionEquality().equals(other.resolvedProofImageIds, resolvedProofImageIds)&&(identical(other.closureSignatureImageId, closureSignatureImageId) || other.closureSignatureImageId == closureSignatureImageId)&&const DeepCollectionEquality().equals(other.closureSignatureDocumentIds, closureSignatureDocumentIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.citizenVerifiedAt, citizenVerifiedAt) || other.citizenVerifiedAt == citizenVerifiedAt)&&(identical(other.citizenSatisfaction, citizenSatisfaction) || other.citizenSatisfaction == citizenSatisfaction)&&(identical(other.citizenClosureNote, citizenClosureNote) || other.citizenClosureNote == citizenClosureNote)&&(identical(other.onChainId, onChainId) || other.onChainId == onChainId)&&(identical(other.onChainHash, onChainHash) || other.onChainHash == onChainHash)&&(identical(other.blockchainTxnHash, blockchainTxnHash) || other.blockchainTxnHash == blockchainTxnHash)&&(identical(other.blockchainSynced, blockchainSynced) || other.blockchainSynced == blockchainSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportId,userId,category,categoryKey,categoryDisplay,categoryLabelSnapshot,taxonomyVersion,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,municipalityId,barangayId,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,severity,peopleAffected,isEmergency,status,assignedDepartment,adminRemarks,categoryConfidence,modelVersion,categorySource,modelProbability,top2Gap,needsCategoryReview,const DeepCollectionEquality().hash(reviewReasons),isMultiIssue,const DeepCollectionEquality().hash(rulesApplied),priority,priorityScore,priorityLevel,suggestedPriorityScore,suggestedPriorityLevel,queuePriorityScore,queuePriorityLevel,queuePriorityRank,staffPriorityLevel,prioritySource,priorityIsAdvisory,needsPriorityReview,const DeepCollectionEquality().hash(priorityReviewReasons),linkedReportCount,linkedUrgencyBoost,isIncidentRepresentative,priorityModelVersion,priorityModelValidated,priorityCalibrationVersion,emergencyProbability,const DeepCollectionEquality().hash(priorityComponents),priorityPolicyVersion,const DeepCollectionEquality().hash(priorityRulesApplied),const DeepCollectionEquality().hash(priorityReasons),baseScore,hotspotScore,urgencyScore,recommendedDepartment,departmentConfidence,const DeepCollectionEquality().hash(routingReasons),needsDepartmentReview,credibilityScore,incidentGroupId,sentimentScore,autoCategorySuggestion,const DeepCollectionEquality().hash(images),const DeepCollectionEquality().hash(resolvedProofImageIds),closureSignatureImageId,const DeepCollectionEquality().hash(closureSignatureDocumentIds),createdAt,updatedAt,submittedAt,verifiedAt,resolvedAt,citizenVerifiedAt,citizenSatisfaction,citizenClosureNote,onChainId,onChainHash,blockchainTxnHash,blockchainSynced]);

@override
String toString() {
  return 'Report(id: $id, reportId: $reportId, userId: $userId, category: $category, categoryKey: $categoryKey, categoryDisplay: $categoryDisplay, categoryLabelSnapshot: $categoryLabelSnapshot, taxonomyVersion: $taxonomyVersion, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, municipalityId: $municipalityId, barangayId: $barangayId, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, status: $status, assignedDepartment: $assignedDepartment, adminRemarks: $adminRemarks, categoryConfidence: $categoryConfidence, modelVersion: $modelVersion, categorySource: $categorySource, modelProbability: $modelProbability, top2Gap: $top2Gap, needsCategoryReview: $needsCategoryReview, reviewReasons: $reviewReasons, isMultiIssue: $isMultiIssue, rulesApplied: $rulesApplied, priority: $priority, priorityScore: $priorityScore, priorityLevel: $priorityLevel, suggestedPriorityScore: $suggestedPriorityScore, suggestedPriorityLevel: $suggestedPriorityLevel, queuePriorityScore: $queuePriorityScore, queuePriorityLevel: $queuePriorityLevel, queuePriorityRank: $queuePriorityRank, staffPriorityLevel: $staffPriorityLevel, prioritySource: $prioritySource, priorityIsAdvisory: $priorityIsAdvisory, needsPriorityReview: $needsPriorityReview, priorityReviewReasons: $priorityReviewReasons, linkedReportCount: $linkedReportCount, linkedUrgencyBoost: $linkedUrgencyBoost, isIncidentRepresentative: $isIncidentRepresentative, priorityModelVersion: $priorityModelVersion, priorityModelValidated: $priorityModelValidated, priorityCalibrationVersion: $priorityCalibrationVersion, emergencyProbability: $emergencyProbability, priorityComponents: $priorityComponents, priorityPolicyVersion: $priorityPolicyVersion, priorityRulesApplied: $priorityRulesApplied, priorityReasons: $priorityReasons, baseScore: $baseScore, hotspotScore: $hotspotScore, urgencyScore: $urgencyScore, recommendedDepartment: $recommendedDepartment, departmentConfidence: $departmentConfidence, routingReasons: $routingReasons, needsDepartmentReview: $needsDepartmentReview, credibilityScore: $credibilityScore, incidentGroupId: $incidentGroupId, sentimentScore: $sentimentScore, autoCategorySuggestion: $autoCategorySuggestion, images: $images, resolvedProofImageIds: $resolvedProofImageIds, closureSignatureImageId: $closureSignatureImageId, closureSignatureDocumentIds: $closureSignatureDocumentIds, createdAt: $createdAt, updatedAt: $updatedAt, submittedAt: $submittedAt, verifiedAt: $verifiedAt, resolvedAt: $resolvedAt, citizenVerifiedAt: $citizenVerifiedAt, citizenSatisfaction: $citizenSatisfaction, citizenClosureNote: $citizenClosureNote, onChainId: $onChainId, onChainHash: $onChainHash, blockchainTxnHash: $blockchainTxnHash, blockchainSynced: $blockchainSynced)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String? category,@JsonKey(name: 'category_key') String? categoryKey,@JsonKey(name: 'category_display') String? categoryDisplay,@JsonKey(name: 'category_label_snapshot') String? categoryLabelSnapshot,@JsonKey(name: 'taxonomy_version') String? taxonomyVersion,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'municipality_id', readValue: _readMunicipalityId) String municipalityId,@JsonKey(name: 'barangay_id', readValue: _readBarangayId) String? barangayId,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay, String severity,@JsonKey(name: 'people_affected')@NullableIntConverter() int? peopleAffected,@JsonKey(name: 'is_emergency') bool isEmergency, String status,@JsonKey(name: 'assigned_department') String? assignedDepartment,@JsonKey(name: 'admin_remarks') String? adminRemarks,@JsonKey(name: 'category_confidence') double? categoryConfidence,@JsonKey(name: 'model_version') String? modelVersion,@JsonKey(name: 'category_source') String? categorySource,@JsonKey(name: 'model_probability') double? modelProbability,@JsonKey(name: 'top2_gap') double? top2Gap,@JsonKey(name: 'needs_category_review') bool? needsCategoryReview,@JsonKey(name: 'review_reasons') List<String> reviewReasons,@JsonKey(name: 'is_multi_issue') bool isMultiIssue,@JsonKey(name: 'rules_applied') List<String> rulesApplied, String? priority,@JsonKey(name: 'priority_score')@NullableIntConverter() int? priorityScore,@JsonKey(name: 'priority_level') String? priorityLevel,@JsonKey(name: 'suggested_priority_score') double? suggestedPriorityScore,@JsonKey(name: 'suggested_priority_level') String? suggestedPriorityLevel,@JsonKey(name: 'queue_priority_score') double? queuePriorityScore,@JsonKey(name: 'queue_priority_level') String? queuePriorityLevel,@JsonKey(name: 'queue_priority_rank')@NullableIntConverter() int? queuePriorityRank,@JsonKey(name: 'staff_priority_level') String? staffPriorityLevel,@JsonKey(name: 'priority_source') String? prioritySource,@JsonKey(name: 'priority_is_advisory') bool priorityIsAdvisory,@JsonKey(name: 'needs_priority_review') bool needsPriorityReview,@JsonKey(name: 'priority_review_reasons') List<String> priorityReviewReasons,@JsonKey(name: 'linked_report_count') int linkedReportCount,@JsonKey(name: 'linked_urgency_boost') int linkedUrgencyBoost,@JsonKey(name: 'is_incident_representative') bool isIncidentRepresentative,@JsonKey(name: 'priority_model_version') String? priorityModelVersion,@JsonKey(name: 'priority_model_validated') bool priorityModelValidated,@JsonKey(name: 'priority_calibration_version') String? priorityCalibrationVersion,@JsonKey(name: 'emergency_probability') double? emergencyProbability,@JsonKey(name: 'priority_components') Map<String, double> priorityComponents,@JsonKey(name: 'priority_policy_version') String? priorityPolicyVersion,@JsonKey(name: 'priority_rules_applied') List<String> priorityRulesApplied,@JsonKey(name: 'priority_reasons') List<String>? priorityReasons,@JsonKey(name: 'base_score')@NullableIntConverter() int? baseScore,@JsonKey(name: 'hotspot_score')@NullableIntConverter() int? hotspotScore,@JsonKey(name: 'urgency_score') double? urgencyScore,@JsonKey(name: 'recommended_department') String? recommendedDepartment,@JsonKey(name: 'department_confidence') double? departmentConfidence,@JsonKey(name: 'routing_reasons') List<String>? routingReasons,@JsonKey(name: 'needs_department_review') bool? needsDepartmentReview,@JsonKey(name: 'credibility_score') double? credibilityScore,@JsonKey(name: 'incident_group_id') String? incidentGroupId,@JsonKey(name: 'sentiment_score') double? sentimentScore,@JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion, List<ReportImage> images,@JsonKey(name: 'resolved_proof_image_ids') List<String> resolvedProofImageIds,@JsonKey(name: 'closure_signature_image_id') String? closureSignatureImageId,@JsonKey(name: 'closure_signature_document_ids') List<String> closureSignatureDocumentIds,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'resolved_at') String? resolvedAt,@JsonKey(name: 'citizen_verified_at') String? citizenVerifiedAt,@JsonKey(name: 'citizen_satisfaction')@NullableIntConverter() int? citizenSatisfaction,@JsonKey(name: 'citizen_closure_note') String? citizenClosureNote,@JsonKey(name: 'on_chain_id')@NullableIntConverter() int? onChainId,@JsonKey(name: 'on_chain_hash') String? onChainHash,@JsonKey(name: 'blockchain_txn_hash') String? blockchainTxnHash,@JsonKey(name: 'blockchain_synced') bool blockchainSynced
});




}
/// @nodoc
class _$ReportCopyWithImpl<$Res>
    implements $ReportCopyWith<$Res> {
  _$ReportCopyWithImpl(this._self, this._then);

  final Report _self;
  final $Res Function(Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? category = freezed,Object? categoryKey = freezed,Object? categoryDisplay = freezed,Object? categoryLabelSnapshot = freezed,Object? taxonomyVersion = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? municipalityId = null,Object? barangayId = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? severity = null,Object? peopleAffected = freezed,Object? isEmergency = null,Object? status = null,Object? assignedDepartment = freezed,Object? adminRemarks = freezed,Object? categoryConfidence = freezed,Object? modelVersion = freezed,Object? categorySource = freezed,Object? modelProbability = freezed,Object? top2Gap = freezed,Object? needsCategoryReview = freezed,Object? reviewReasons = null,Object? isMultiIssue = null,Object? rulesApplied = null,Object? priority = freezed,Object? priorityScore = freezed,Object? priorityLevel = freezed,Object? suggestedPriorityScore = freezed,Object? suggestedPriorityLevel = freezed,Object? queuePriorityScore = freezed,Object? queuePriorityLevel = freezed,Object? queuePriorityRank = freezed,Object? staffPriorityLevel = freezed,Object? prioritySource = freezed,Object? priorityIsAdvisory = null,Object? needsPriorityReview = null,Object? priorityReviewReasons = null,Object? linkedReportCount = null,Object? linkedUrgencyBoost = null,Object? isIncidentRepresentative = null,Object? priorityModelVersion = freezed,Object? priorityModelValidated = null,Object? priorityCalibrationVersion = freezed,Object? emergencyProbability = freezed,Object? priorityComponents = null,Object? priorityPolicyVersion = freezed,Object? priorityRulesApplied = null,Object? priorityReasons = freezed,Object? baseScore = freezed,Object? hotspotScore = freezed,Object? urgencyScore = freezed,Object? recommendedDepartment = freezed,Object? departmentConfidence = freezed,Object? routingReasons = freezed,Object? needsDepartmentReview = freezed,Object? credibilityScore = freezed,Object? incidentGroupId = freezed,Object? sentimentScore = freezed,Object? autoCategorySuggestion = freezed,Object? images = null,Object? resolvedProofImageIds = null,Object? closureSignatureImageId = freezed,Object? closureSignatureDocumentIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? resolvedAt = freezed,Object? citizenVerifiedAt = freezed,Object? citizenSatisfaction = freezed,Object? citizenClosureNote = freezed,Object? onChainId = freezed,Object? onChainHash = freezed,Object? blockchainTxnHash = freezed,Object? blockchainSynced = null,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,categoryKey: freezed == categoryKey ? _self.categoryKey : categoryKey // ignore: cast_nullable_to_non_nullable
as String?,categoryDisplay: freezed == categoryDisplay ? _self.categoryDisplay : categoryDisplay // ignore: cast_nullable_to_non_nullable
as String?,categoryLabelSnapshot: freezed == categoryLabelSnapshot ? _self.categoryLabelSnapshot : categoryLabelSnapshot // ignore: cast_nullable_to_non_nullable
as String?,taxonomyVersion: freezed == taxonomyVersion ? _self.taxonomyVersion : taxonomyVersion // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
as String?,municipalityId: null == municipalityId ? _self.municipalityId : municipalityId // ignore: cast_nullable_to_non_nullable
as String,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,locationAccuracy: null == locationAccuracy ? _self.locationAccuracy : locationAccuracy // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,peopleAffected: freezed == peopleAffected ? _self.peopleAffected : peopleAffected // ignore: cast_nullable_to_non_nullable
as int?,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedDepartment: freezed == assignedDepartment ? _self.assignedDepartment : assignedDepartment // ignore: cast_nullable_to_non_nullable
as String?,adminRemarks: freezed == adminRemarks ? _self.adminRemarks : adminRemarks // ignore: cast_nullable_to_non_nullable
as String?,categoryConfidence: freezed == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double?,modelVersion: freezed == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String?,categorySource: freezed == categorySource ? _self.categorySource : categorySource // ignore: cast_nullable_to_non_nullable
as String?,modelProbability: freezed == modelProbability ? _self.modelProbability : modelProbability // ignore: cast_nullable_to_non_nullable
as double?,top2Gap: freezed == top2Gap ? _self.top2Gap : top2Gap // ignore: cast_nullable_to_non_nullable
as double?,needsCategoryReview: freezed == needsCategoryReview ? _self.needsCategoryReview : needsCategoryReview // ignore: cast_nullable_to_non_nullable
as bool?,reviewReasons: null == reviewReasons ? _self.reviewReasons : reviewReasons // ignore: cast_nullable_to_non_nullable
as List<String>,isMultiIssue: null == isMultiIssue ? _self.isMultiIssue : isMultiIssue // ignore: cast_nullable_to_non_nullable
as bool,rulesApplied: null == rulesApplied ? _self.rulesApplied : rulesApplied // ignore: cast_nullable_to_non_nullable
as List<String>,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,priorityScore: freezed == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int?,priorityLevel: freezed == priorityLevel ? _self.priorityLevel : priorityLevel // ignore: cast_nullable_to_non_nullable
as String?,suggestedPriorityScore: freezed == suggestedPriorityScore ? _self.suggestedPriorityScore : suggestedPriorityScore // ignore: cast_nullable_to_non_nullable
as double?,suggestedPriorityLevel: freezed == suggestedPriorityLevel ? _self.suggestedPriorityLevel : suggestedPriorityLevel // ignore: cast_nullable_to_non_nullable
as String?,queuePriorityScore: freezed == queuePriorityScore ? _self.queuePriorityScore : queuePriorityScore // ignore: cast_nullable_to_non_nullable
as double?,queuePriorityLevel: freezed == queuePriorityLevel ? _self.queuePriorityLevel : queuePriorityLevel // ignore: cast_nullable_to_non_nullable
as String?,queuePriorityRank: freezed == queuePriorityRank ? _self.queuePriorityRank : queuePriorityRank // ignore: cast_nullable_to_non_nullable
as int?,staffPriorityLevel: freezed == staffPriorityLevel ? _self.staffPriorityLevel : staffPriorityLevel // ignore: cast_nullable_to_non_nullable
as String?,prioritySource: freezed == prioritySource ? _self.prioritySource : prioritySource // ignore: cast_nullable_to_non_nullable
as String?,priorityIsAdvisory: null == priorityIsAdvisory ? _self.priorityIsAdvisory : priorityIsAdvisory // ignore: cast_nullable_to_non_nullable
as bool,needsPriorityReview: null == needsPriorityReview ? _self.needsPriorityReview : needsPriorityReview // ignore: cast_nullable_to_non_nullable
as bool,priorityReviewReasons: null == priorityReviewReasons ? _self.priorityReviewReasons : priorityReviewReasons // ignore: cast_nullable_to_non_nullable
as List<String>,linkedReportCount: null == linkedReportCount ? _self.linkedReportCount : linkedReportCount // ignore: cast_nullable_to_non_nullable
as int,linkedUrgencyBoost: null == linkedUrgencyBoost ? _self.linkedUrgencyBoost : linkedUrgencyBoost // ignore: cast_nullable_to_non_nullable
as int,isIncidentRepresentative: null == isIncidentRepresentative ? _self.isIncidentRepresentative : isIncidentRepresentative // ignore: cast_nullable_to_non_nullable
as bool,priorityModelVersion: freezed == priorityModelVersion ? _self.priorityModelVersion : priorityModelVersion // ignore: cast_nullable_to_non_nullable
as String?,priorityModelValidated: null == priorityModelValidated ? _self.priorityModelValidated : priorityModelValidated // ignore: cast_nullable_to_non_nullable
as bool,priorityCalibrationVersion: freezed == priorityCalibrationVersion ? _self.priorityCalibrationVersion : priorityCalibrationVersion // ignore: cast_nullable_to_non_nullable
as String?,emergencyProbability: freezed == emergencyProbability ? _self.emergencyProbability : emergencyProbability // ignore: cast_nullable_to_non_nullable
as double?,priorityComponents: null == priorityComponents ? _self.priorityComponents : priorityComponents // ignore: cast_nullable_to_non_nullable
as Map<String, double>,priorityPolicyVersion: freezed == priorityPolicyVersion ? _self.priorityPolicyVersion : priorityPolicyVersion // ignore: cast_nullable_to_non_nullable
as String?,priorityRulesApplied: null == priorityRulesApplied ? _self.priorityRulesApplied : priorityRulesApplied // ignore: cast_nullable_to_non_nullable
as List<String>,priorityReasons: freezed == priorityReasons ? _self.priorityReasons : priorityReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,baseScore: freezed == baseScore ? _self.baseScore : baseScore // ignore: cast_nullable_to_non_nullable
as int?,hotspotScore: freezed == hotspotScore ? _self.hotspotScore : hotspotScore // ignore: cast_nullable_to_non_nullable
as int?,urgencyScore: freezed == urgencyScore ? _self.urgencyScore : urgencyScore // ignore: cast_nullable_to_non_nullable
as double?,recommendedDepartment: freezed == recommendedDepartment ? _self.recommendedDepartment : recommendedDepartment // ignore: cast_nullable_to_non_nullable
as String?,departmentConfidence: freezed == departmentConfidence ? _self.departmentConfidence : departmentConfidence // ignore: cast_nullable_to_non_nullable
as double?,routingReasons: freezed == routingReasons ? _self.routingReasons : routingReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,needsDepartmentReview: freezed == needsDepartmentReview ? _self.needsDepartmentReview : needsDepartmentReview // ignore: cast_nullable_to_non_nullable
as bool?,credibilityScore: freezed == credibilityScore ? _self.credibilityScore : credibilityScore // ignore: cast_nullable_to_non_nullable
as double?,incidentGroupId: freezed == incidentGroupId ? _self.incidentGroupId : incidentGroupId // ignore: cast_nullable_to_non_nullable
as String?,sentimentScore: freezed == sentimentScore ? _self.sentimentScore : sentimentScore // ignore: cast_nullable_to_non_nullable
as double?,autoCategorySuggestion: freezed == autoCategorySuggestion ? _self.autoCategorySuggestion : autoCategorySuggestion // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ReportImage>,resolvedProofImageIds: null == resolvedProofImageIds ? _self.resolvedProofImageIds : resolvedProofImageIds // ignore: cast_nullable_to_non_nullable
as List<String>,closureSignatureImageId: freezed == closureSignatureImageId ? _self.closureSignatureImageId : closureSignatureImageId // ignore: cast_nullable_to_non_nullable
as String?,closureSignatureDocumentIds: null == closureSignatureDocumentIds ? _self.closureSignatureDocumentIds : closureSignatureDocumentIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,citizenVerifiedAt: freezed == citizenVerifiedAt ? _self.citizenVerifiedAt : citizenVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,citizenSatisfaction: freezed == citizenSatisfaction ? _self.citizenSatisfaction : citizenSatisfaction // ignore: cast_nullable_to_non_nullable
as int?,citizenClosureNote: freezed == citizenClosureNote ? _self.citizenClosureNote : citizenClosureNote // ignore: cast_nullable_to_non_nullable
as String?,onChainId: freezed == onChainId ? _self.onChainId : onChainId // ignore: cast_nullable_to_non_nullable
as int?,onChainHash: freezed == onChainHash ? _self.onChainHash : onChainHash // ignore: cast_nullable_to_non_nullable
as String?,blockchainTxnHash: freezed == blockchainTxnHash ? _self.blockchainTxnHash : blockchainTxnHash // ignore: cast_nullable_to_non_nullable
as String?,blockchainSynced: null == blockchainSynced ? _self.blockchainSynced : blockchainSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [Report].
extension ReportPatterns on Report {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _Report value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _Report value)  $default,){
final _that = this;
switch (_that) {
case _Report():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _Report value)?  $default,){
final _that = this;
switch (_that) {
case _Report() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String? category, @JsonKey(name: 'category_key')  String? categoryKey, @JsonKey(name: 'category_display')  String? categoryDisplay, @JsonKey(name: 'category_label_snapshot')  String? categoryLabelSnapshot, @JsonKey(name: 'taxonomy_version')  String? taxonomyVersion, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id', readValue: _readMunicipalityId)  String municipalityId, @JsonKey(name: 'barangay_id', readValue: _readBarangayId)  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')@NullableIntConverter()  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency,  String status, @JsonKey(name: 'assigned_department')  String? assignedDepartment, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'category_confidence')  double? categoryConfidence, @JsonKey(name: 'model_version')  String? modelVersion, @JsonKey(name: 'category_source')  String? categorySource, @JsonKey(name: 'model_probability')  double? modelProbability, @JsonKey(name: 'top2_gap')  double? top2Gap, @JsonKey(name: 'needs_category_review')  bool? needsCategoryReview, @JsonKey(name: 'review_reasons')  List<String> reviewReasons, @JsonKey(name: 'is_multi_issue')  bool isMultiIssue, @JsonKey(name: 'rules_applied')  List<String> rulesApplied,  String? priority, @JsonKey(name: 'priority_score')@NullableIntConverter()  int? priorityScore, @JsonKey(name: 'priority_level')  String? priorityLevel, @JsonKey(name: 'suggested_priority_score')  double? suggestedPriorityScore, @JsonKey(name: 'suggested_priority_level')  String? suggestedPriorityLevel, @JsonKey(name: 'queue_priority_score')  double? queuePriorityScore, @JsonKey(name: 'queue_priority_level')  String? queuePriorityLevel, @JsonKey(name: 'queue_priority_rank')@NullableIntConverter()  int? queuePriorityRank, @JsonKey(name: 'staff_priority_level')  String? staffPriorityLevel, @JsonKey(name: 'priority_source')  String? prioritySource, @JsonKey(name: 'priority_is_advisory')  bool priorityIsAdvisory, @JsonKey(name: 'needs_priority_review')  bool needsPriorityReview, @JsonKey(name: 'priority_review_reasons')  List<String> priorityReviewReasons, @JsonKey(name: 'linked_report_count')  int linkedReportCount, @JsonKey(name: 'linked_urgency_boost')  int linkedUrgencyBoost, @JsonKey(name: 'is_incident_representative')  bool isIncidentRepresentative, @JsonKey(name: 'priority_model_version')  String? priorityModelVersion, @JsonKey(name: 'priority_model_validated')  bool priorityModelValidated, @JsonKey(name: 'priority_calibration_version')  String? priorityCalibrationVersion, @JsonKey(name: 'emergency_probability')  double? emergencyProbability, @JsonKey(name: 'priority_components')  Map<String, double> priorityComponents, @JsonKey(name: 'priority_policy_version')  String? priorityPolicyVersion, @JsonKey(name: 'priority_rules_applied')  List<String> priorityRulesApplied, @JsonKey(name: 'priority_reasons')  List<String>? priorityReasons, @JsonKey(name: 'base_score')@NullableIntConverter()  int? baseScore, @JsonKey(name: 'hotspot_score')@NullableIntConverter()  int? hotspotScore, @JsonKey(name: 'urgency_score')  double? urgencyScore, @JsonKey(name: 'recommended_department')  String? recommendedDepartment, @JsonKey(name: 'department_confidence')  double? departmentConfidence, @JsonKey(name: 'routing_reasons')  List<String>? routingReasons, @JsonKey(name: 'needs_department_review')  bool? needsDepartmentReview, @JsonKey(name: 'credibility_score')  double? credibilityScore, @JsonKey(name: 'incident_group_id')  String? incidentGroupId, @JsonKey(name: 'sentiment_score')  double? sentimentScore, @JsonKey(name: 'auto_category_suggestion')  String? autoCategorySuggestion,  List<ReportImage> images, @JsonKey(name: 'resolved_proof_image_ids')  List<String> resolvedProofImageIds, @JsonKey(name: 'closure_signature_image_id')  String? closureSignatureImageId, @JsonKey(name: 'closure_signature_document_ids')  List<String> closureSignatureDocumentIds, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'citizen_verified_at')  String? citizenVerifiedAt, @JsonKey(name: 'citizen_satisfaction')@NullableIntConverter()  int? citizenSatisfaction, @JsonKey(name: 'citizen_closure_note')  String? citizenClosureNote, @JsonKey(name: 'on_chain_id')@NullableIntConverter()  int? onChainId, @JsonKey(name: 'on_chain_hash')  String? onChainHash, @JsonKey(name: 'blockchain_txn_hash')  String? blockchainTxnHash, @JsonKey(name: 'blockchain_synced')  bool blockchainSynced)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.category,_that.categoryKey,_that.categoryDisplay,_that.categoryLabelSnapshot,_that.taxonomyVersion,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.status,_that.assignedDepartment,_that.adminRemarks,_that.categoryConfidence,_that.modelVersion,_that.categorySource,_that.modelProbability,_that.top2Gap,_that.needsCategoryReview,_that.reviewReasons,_that.isMultiIssue,_that.rulesApplied,_that.priority,_that.priorityScore,_that.priorityLevel,_that.suggestedPriorityScore,_that.suggestedPriorityLevel,_that.queuePriorityScore,_that.queuePriorityLevel,_that.queuePriorityRank,_that.staffPriorityLevel,_that.prioritySource,_that.priorityIsAdvisory,_that.needsPriorityReview,_that.priorityReviewReasons,_that.linkedReportCount,_that.linkedUrgencyBoost,_that.isIncidentRepresentative,_that.priorityModelVersion,_that.priorityModelValidated,_that.priorityCalibrationVersion,_that.emergencyProbability,_that.priorityComponents,_that.priorityPolicyVersion,_that.priorityRulesApplied,_that.priorityReasons,_that.baseScore,_that.hotspotScore,_that.urgencyScore,_that.recommendedDepartment,_that.departmentConfidence,_that.routingReasons,_that.needsDepartmentReview,_that.credibilityScore,_that.incidentGroupId,_that.sentimentScore,_that.autoCategorySuggestion,_that.images,_that.resolvedProofImageIds,_that.closureSignatureImageId,_that.closureSignatureDocumentIds,_that.createdAt,_that.updatedAt,_that.submittedAt,_that.verifiedAt,_that.resolvedAt,_that.citizenVerifiedAt,_that.citizenSatisfaction,_that.citizenClosureNote,_that.onChainId,_that.onChainHash,_that.blockchainTxnHash,_that.blockchainSynced);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String? category, @JsonKey(name: 'category_key')  String? categoryKey, @JsonKey(name: 'category_display')  String? categoryDisplay, @JsonKey(name: 'category_label_snapshot')  String? categoryLabelSnapshot, @JsonKey(name: 'taxonomy_version')  String? taxonomyVersion, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id', readValue: _readMunicipalityId)  String municipalityId, @JsonKey(name: 'barangay_id', readValue: _readBarangayId)  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')@NullableIntConverter()  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency,  String status, @JsonKey(name: 'assigned_department')  String? assignedDepartment, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'category_confidence')  double? categoryConfidence, @JsonKey(name: 'model_version')  String? modelVersion, @JsonKey(name: 'category_source')  String? categorySource, @JsonKey(name: 'model_probability')  double? modelProbability, @JsonKey(name: 'top2_gap')  double? top2Gap, @JsonKey(name: 'needs_category_review')  bool? needsCategoryReview, @JsonKey(name: 'review_reasons')  List<String> reviewReasons, @JsonKey(name: 'is_multi_issue')  bool isMultiIssue, @JsonKey(name: 'rules_applied')  List<String> rulesApplied,  String? priority, @JsonKey(name: 'priority_score')@NullableIntConverter()  int? priorityScore, @JsonKey(name: 'priority_level')  String? priorityLevel, @JsonKey(name: 'suggested_priority_score')  double? suggestedPriorityScore, @JsonKey(name: 'suggested_priority_level')  String? suggestedPriorityLevel, @JsonKey(name: 'queue_priority_score')  double? queuePriorityScore, @JsonKey(name: 'queue_priority_level')  String? queuePriorityLevel, @JsonKey(name: 'queue_priority_rank')@NullableIntConverter()  int? queuePriorityRank, @JsonKey(name: 'staff_priority_level')  String? staffPriorityLevel, @JsonKey(name: 'priority_source')  String? prioritySource, @JsonKey(name: 'priority_is_advisory')  bool priorityIsAdvisory, @JsonKey(name: 'needs_priority_review')  bool needsPriorityReview, @JsonKey(name: 'priority_review_reasons')  List<String> priorityReviewReasons, @JsonKey(name: 'linked_report_count')  int linkedReportCount, @JsonKey(name: 'linked_urgency_boost')  int linkedUrgencyBoost, @JsonKey(name: 'is_incident_representative')  bool isIncidentRepresentative, @JsonKey(name: 'priority_model_version')  String? priorityModelVersion, @JsonKey(name: 'priority_model_validated')  bool priorityModelValidated, @JsonKey(name: 'priority_calibration_version')  String? priorityCalibrationVersion, @JsonKey(name: 'emergency_probability')  double? emergencyProbability, @JsonKey(name: 'priority_components')  Map<String, double> priorityComponents, @JsonKey(name: 'priority_policy_version')  String? priorityPolicyVersion, @JsonKey(name: 'priority_rules_applied')  List<String> priorityRulesApplied, @JsonKey(name: 'priority_reasons')  List<String>? priorityReasons, @JsonKey(name: 'base_score')@NullableIntConverter()  int? baseScore, @JsonKey(name: 'hotspot_score')@NullableIntConverter()  int? hotspotScore, @JsonKey(name: 'urgency_score')  double? urgencyScore, @JsonKey(name: 'recommended_department')  String? recommendedDepartment, @JsonKey(name: 'department_confidence')  double? departmentConfidence, @JsonKey(name: 'routing_reasons')  List<String>? routingReasons, @JsonKey(name: 'needs_department_review')  bool? needsDepartmentReview, @JsonKey(name: 'credibility_score')  double? credibilityScore, @JsonKey(name: 'incident_group_id')  String? incidentGroupId, @JsonKey(name: 'sentiment_score')  double? sentimentScore, @JsonKey(name: 'auto_category_suggestion')  String? autoCategorySuggestion,  List<ReportImage> images, @JsonKey(name: 'resolved_proof_image_ids')  List<String> resolvedProofImageIds, @JsonKey(name: 'closure_signature_image_id')  String? closureSignatureImageId, @JsonKey(name: 'closure_signature_document_ids')  List<String> closureSignatureDocumentIds, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'citizen_verified_at')  String? citizenVerifiedAt, @JsonKey(name: 'citizen_satisfaction')@NullableIntConverter()  int? citizenSatisfaction, @JsonKey(name: 'citizen_closure_note')  String? citizenClosureNote, @JsonKey(name: 'on_chain_id')@NullableIntConverter()  int? onChainId, @JsonKey(name: 'on_chain_hash')  String? onChainHash, @JsonKey(name: 'blockchain_txn_hash')  String? blockchainTxnHash, @JsonKey(name: 'blockchain_synced')  bool blockchainSynced)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.reportId,_that.userId,_that.category,_that.categoryKey,_that.categoryDisplay,_that.categoryLabelSnapshot,_that.taxonomyVersion,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.status,_that.assignedDepartment,_that.adminRemarks,_that.categoryConfidence,_that.modelVersion,_that.categorySource,_that.modelProbability,_that.top2Gap,_that.needsCategoryReview,_that.reviewReasons,_that.isMultiIssue,_that.rulesApplied,_that.priority,_that.priorityScore,_that.priorityLevel,_that.suggestedPriorityScore,_that.suggestedPriorityLevel,_that.queuePriorityScore,_that.queuePriorityLevel,_that.queuePriorityRank,_that.staffPriorityLevel,_that.prioritySource,_that.priorityIsAdvisory,_that.needsPriorityReview,_that.priorityReviewReasons,_that.linkedReportCount,_that.linkedUrgencyBoost,_that.isIncidentRepresentative,_that.priorityModelVersion,_that.priorityModelValidated,_that.priorityCalibrationVersion,_that.emergencyProbability,_that.priorityComponents,_that.priorityPolicyVersion,_that.priorityRulesApplied,_that.priorityReasons,_that.baseScore,_that.hotspotScore,_that.urgencyScore,_that.recommendedDepartment,_that.departmentConfidence,_that.routingReasons,_that.needsDepartmentReview,_that.credibilityScore,_that.incidentGroupId,_that.sentimentScore,_that.autoCategorySuggestion,_that.images,_that.resolvedProofImageIds,_that.closureSignatureImageId,_that.closureSignatureDocumentIds,_that.createdAt,_that.updatedAt,_that.submittedAt,_that.verifiedAt,_that.resolvedAt,_that.citizenVerifiedAt,_that.citizenSatisfaction,_that.citizenClosureNote,_that.onChainId,_that.onChainHash,_that.blockchainTxnHash,_that.blockchainSynced);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String? category, @JsonKey(name: 'category_key')  String? categoryKey, @JsonKey(name: 'category_display')  String? categoryDisplay, @JsonKey(name: 'category_label_snapshot')  String? categoryLabelSnapshot, @JsonKey(name: 'taxonomy_version')  String? taxonomyVersion, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id', readValue: _readMunicipalityId)  String municipalityId, @JsonKey(name: 'barangay_id', readValue: _readBarangayId)  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')@NullableIntConverter()  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency,  String status, @JsonKey(name: 'assigned_department')  String? assignedDepartment, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'category_confidence')  double? categoryConfidence, @JsonKey(name: 'model_version')  String? modelVersion, @JsonKey(name: 'category_source')  String? categorySource, @JsonKey(name: 'model_probability')  double? modelProbability, @JsonKey(name: 'top2_gap')  double? top2Gap, @JsonKey(name: 'needs_category_review')  bool? needsCategoryReview, @JsonKey(name: 'review_reasons')  List<String> reviewReasons, @JsonKey(name: 'is_multi_issue')  bool isMultiIssue, @JsonKey(name: 'rules_applied')  List<String> rulesApplied,  String? priority, @JsonKey(name: 'priority_score')@NullableIntConverter()  int? priorityScore, @JsonKey(name: 'priority_level')  String? priorityLevel, @JsonKey(name: 'suggested_priority_score')  double? suggestedPriorityScore, @JsonKey(name: 'suggested_priority_level')  String? suggestedPriorityLevel, @JsonKey(name: 'queue_priority_score')  double? queuePriorityScore, @JsonKey(name: 'queue_priority_level')  String? queuePriorityLevel, @JsonKey(name: 'queue_priority_rank')@NullableIntConverter()  int? queuePriorityRank, @JsonKey(name: 'staff_priority_level')  String? staffPriorityLevel, @JsonKey(name: 'priority_source')  String? prioritySource, @JsonKey(name: 'priority_is_advisory')  bool priorityIsAdvisory, @JsonKey(name: 'needs_priority_review')  bool needsPriorityReview, @JsonKey(name: 'priority_review_reasons')  List<String> priorityReviewReasons, @JsonKey(name: 'linked_report_count')  int linkedReportCount, @JsonKey(name: 'linked_urgency_boost')  int linkedUrgencyBoost, @JsonKey(name: 'is_incident_representative')  bool isIncidentRepresentative, @JsonKey(name: 'priority_model_version')  String? priorityModelVersion, @JsonKey(name: 'priority_model_validated')  bool priorityModelValidated, @JsonKey(name: 'priority_calibration_version')  String? priorityCalibrationVersion, @JsonKey(name: 'emergency_probability')  double? emergencyProbability, @JsonKey(name: 'priority_components')  Map<String, double> priorityComponents, @JsonKey(name: 'priority_policy_version')  String? priorityPolicyVersion, @JsonKey(name: 'priority_rules_applied')  List<String> priorityRulesApplied, @JsonKey(name: 'priority_reasons')  List<String>? priorityReasons, @JsonKey(name: 'base_score')@NullableIntConverter()  int? baseScore, @JsonKey(name: 'hotspot_score')@NullableIntConverter()  int? hotspotScore, @JsonKey(name: 'urgency_score')  double? urgencyScore, @JsonKey(name: 'recommended_department')  String? recommendedDepartment, @JsonKey(name: 'department_confidence')  double? departmentConfidence, @JsonKey(name: 'routing_reasons')  List<String>? routingReasons, @JsonKey(name: 'needs_department_review')  bool? needsDepartmentReview, @JsonKey(name: 'credibility_score')  double? credibilityScore, @JsonKey(name: 'incident_group_id')  String? incidentGroupId, @JsonKey(name: 'sentiment_score')  double? sentimentScore, @JsonKey(name: 'auto_category_suggestion')  String? autoCategorySuggestion,  List<ReportImage> images, @JsonKey(name: 'resolved_proof_image_ids')  List<String> resolvedProofImageIds, @JsonKey(name: 'closure_signature_image_id')  String? closureSignatureImageId, @JsonKey(name: 'closure_signature_document_ids')  List<String> closureSignatureDocumentIds, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'resolved_at')  String? resolvedAt, @JsonKey(name: 'citizen_verified_at')  String? citizenVerifiedAt, @JsonKey(name: 'citizen_satisfaction')@NullableIntConverter()  int? citizenSatisfaction, @JsonKey(name: 'citizen_closure_note')  String? citizenClosureNote, @JsonKey(name: 'on_chain_id')@NullableIntConverter()  int? onChainId, @JsonKey(name: 'on_chain_hash')  String? onChainHash, @JsonKey(name: 'blockchain_txn_hash')  String? blockchainTxnHash, @JsonKey(name: 'blockchain_synced')  bool blockchainSynced)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.category,_that.categoryKey,_that.categoryDisplay,_that.categoryLabelSnapshot,_that.taxonomyVersion,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.status,_that.assignedDepartment,_that.adminRemarks,_that.categoryConfidence,_that.modelVersion,_that.categorySource,_that.modelProbability,_that.top2Gap,_that.needsCategoryReview,_that.reviewReasons,_that.isMultiIssue,_that.rulesApplied,_that.priority,_that.priorityScore,_that.priorityLevel,_that.suggestedPriorityScore,_that.suggestedPriorityLevel,_that.queuePriorityScore,_that.queuePriorityLevel,_that.queuePriorityRank,_that.staffPriorityLevel,_that.prioritySource,_that.priorityIsAdvisory,_that.needsPriorityReview,_that.priorityReviewReasons,_that.linkedReportCount,_that.linkedUrgencyBoost,_that.isIncidentRepresentative,_that.priorityModelVersion,_that.priorityModelValidated,_that.priorityCalibrationVersion,_that.emergencyProbability,_that.priorityComponents,_that.priorityPolicyVersion,_that.priorityRulesApplied,_that.priorityReasons,_that.baseScore,_that.hotspotScore,_that.urgencyScore,_that.recommendedDepartment,_that.departmentConfidence,_that.routingReasons,_that.needsDepartmentReview,_that.credibilityScore,_that.incidentGroupId,_that.sentimentScore,_that.autoCategorySuggestion,_that.images,_that.resolvedProofImageIds,_that.closureSignatureImageId,_that.closureSignatureDocumentIds,_that.createdAt,_that.updatedAt,_that.submittedAt,_that.verifiedAt,_that.resolvedAt,_that.citizenVerifiedAt,_that.citizenSatisfaction,_that.citizenClosureNote,_that.onChainId,_that.onChainHash,_that.blockchainTxnHash,_that.blockchainSynced);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.id, @JsonKey(name: 'report_id') this.reportId, @JsonKey(name: 'user_id') this.userId, this.category, @JsonKey(name: 'category_key') this.categoryKey, @JsonKey(name: 'category_display') this.categoryDisplay, @JsonKey(name: 'category_label_snapshot') this.categoryLabelSnapshot, @JsonKey(name: 'taxonomy_version') this.taxonomyVersion, @JsonKey(name: 'incident_type') this.incidentType, this.title, required this.description, @JsonKey(name: 'incident_datetime') this.incidentDatetime, @JsonKey(name: 'is_happening_now') this.isHappeningNow = false, this.zone, @JsonKey(name: 'street_landmark') this.streetLandmark, @JsonKey(name: 'municipality_id', readValue: _readMunicipalityId) this.municipalityId = 'urdaneta', @JsonKey(name: 'barangay_id', readValue: _readBarangayId) this.barangayId, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, this.latitude, this.longitude, @JsonKey(name: 'location_accuracy') this.locationAccuracy = 'approximate', this.location, this.barangay, this.severity = 'medium', @JsonKey(name: 'people_affected')@NullableIntConverter() this.peopleAffected, @JsonKey(name: 'is_emergency') this.isEmergency = false, this.status = 'submitted', @JsonKey(name: 'assigned_department') this.assignedDepartment, @JsonKey(name: 'admin_remarks') this.adminRemarks, @JsonKey(name: 'category_confidence') this.categoryConfidence, @JsonKey(name: 'model_version') this.modelVersion, @JsonKey(name: 'category_source') this.categorySource, @JsonKey(name: 'model_probability') this.modelProbability, @JsonKey(name: 'top2_gap') this.top2Gap, @JsonKey(name: 'needs_category_review') this.needsCategoryReview, @JsonKey(name: 'review_reasons') final  List<String> reviewReasons = const [], @JsonKey(name: 'is_multi_issue') this.isMultiIssue = false, @JsonKey(name: 'rules_applied') final  List<String> rulesApplied = const [], this.priority, @JsonKey(name: 'priority_score')@NullableIntConverter() this.priorityScore, @JsonKey(name: 'priority_level') this.priorityLevel, @JsonKey(name: 'suggested_priority_score') this.suggestedPriorityScore, @JsonKey(name: 'suggested_priority_level') this.suggestedPriorityLevel, @JsonKey(name: 'queue_priority_score') this.queuePriorityScore, @JsonKey(name: 'queue_priority_level') this.queuePriorityLevel, @JsonKey(name: 'queue_priority_rank')@NullableIntConverter() this.queuePriorityRank, @JsonKey(name: 'staff_priority_level') this.staffPriorityLevel, @JsonKey(name: 'priority_source') this.prioritySource, @JsonKey(name: 'priority_is_advisory') this.priorityIsAdvisory = true, @JsonKey(name: 'needs_priority_review') this.needsPriorityReview = true, @JsonKey(name: 'priority_review_reasons') final  List<String> priorityReviewReasons = const [], @JsonKey(name: 'linked_report_count') this.linkedReportCount = 1, @JsonKey(name: 'linked_urgency_boost') this.linkedUrgencyBoost = 0, @JsonKey(name: 'is_incident_representative') this.isIncidentRepresentative = true, @JsonKey(name: 'priority_model_version') this.priorityModelVersion, @JsonKey(name: 'priority_model_validated') this.priorityModelValidated = false, @JsonKey(name: 'priority_calibration_version') this.priorityCalibrationVersion, @JsonKey(name: 'emergency_probability') this.emergencyProbability, @JsonKey(name: 'priority_components') final  Map<String, double> priorityComponents = const {}, @JsonKey(name: 'priority_policy_version') this.priorityPolicyVersion, @JsonKey(name: 'priority_rules_applied') final  List<String> priorityRulesApplied = const [], @JsonKey(name: 'priority_reasons') final  List<String>? priorityReasons, @JsonKey(name: 'base_score')@NullableIntConverter() this.baseScore, @JsonKey(name: 'hotspot_score')@NullableIntConverter() this.hotspotScore, @JsonKey(name: 'urgency_score') this.urgencyScore, @JsonKey(name: 'recommended_department') this.recommendedDepartment, @JsonKey(name: 'department_confidence') this.departmentConfidence, @JsonKey(name: 'routing_reasons') final  List<String>? routingReasons, @JsonKey(name: 'needs_department_review') this.needsDepartmentReview, @JsonKey(name: 'credibility_score') this.credibilityScore, @JsonKey(name: 'incident_group_id') this.incidentGroupId, @JsonKey(name: 'sentiment_score') this.sentimentScore, @JsonKey(name: 'auto_category_suggestion') this.autoCategorySuggestion, final  List<ReportImage> images = const [], @JsonKey(name: 'resolved_proof_image_ids') final  List<String> resolvedProofImageIds = const [], @JsonKey(name: 'closure_signature_image_id') this.closureSignatureImageId, @JsonKey(name: 'closure_signature_document_ids') final  List<String> closureSignatureDocumentIds = const [], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'resolved_at') this.resolvedAt, @JsonKey(name: 'citizen_verified_at') this.citizenVerifiedAt, @JsonKey(name: 'citizen_satisfaction')@NullableIntConverter() this.citizenSatisfaction, @JsonKey(name: 'citizen_closure_note') this.citizenClosureNote, @JsonKey(name: 'on_chain_id')@NullableIntConverter() this.onChainId, @JsonKey(name: 'on_chain_hash') this.onChainHash, @JsonKey(name: 'blockchain_txn_hash') this.blockchainTxnHash, @JsonKey(name: 'blockchain_synced') this.blockchainSynced = false}): _reviewReasons = reviewReasons,_rulesApplied = rulesApplied,_priorityReviewReasons = priorityReviewReasons,_priorityComponents = priorityComponents,_priorityRulesApplied = priorityRulesApplied,_priorityReasons = priorityReasons,_routingReasons = routingReasons,_images = images,_resolvedProofImageIds = resolvedProofImageIds,_closureSignatureDocumentIds = closureSignatureDocumentIds;
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String id;
@override@JsonKey(name: 'report_id') final  String? reportId;
@override@JsonKey(name: 'user_id') final  String? userId;
// Report Details
@override final  String? category;
@override@JsonKey(name: 'category_key') final  String? categoryKey;
@override@JsonKey(name: 'category_display') final  String? categoryDisplay;
@override@JsonKey(name: 'category_label_snapshot') final  String? categoryLabelSnapshot;
@override@JsonKey(name: 'taxonomy_version') final  String? taxonomyVersion;
@override@JsonKey(name: 'incident_type') final  String? incidentType;
@override final  String? title;
@override final  String description;
@override@JsonKey(name: 'incident_datetime') final  String? incidentDatetime;
@override@JsonKey(name: 'is_happening_now') final  bool isHappeningNow;
// Location Information
@override final  String? zone;
@override@JsonKey(name: 'street_landmark') final  String? streetLandmark;
@override@JsonKey(name: 'municipality_id', readValue: _readMunicipalityId) final  String municipalityId;
@override@JsonKey(name: 'barangay_id', readValue: _readBarangayId) final  String? barangayId;
@override@JsonKey(name: 'city_municipality') final  String? cityMunicipality;
@override final  String? province;
@override final  String? latitude;
@override final  String? longitude;
@override@JsonKey(name: 'location_accuracy') final  String locationAccuracy;
// Legacy fields
@override final  String? location;
@override final  String? barangay;
// Severity & Impact
@override@JsonKey() final  String severity;
@override@JsonKey(name: 'people_affected')@NullableIntConverter() final  int? peopleAffected;
@override@JsonKey(name: 'is_emergency') final  bool isEmergency;
// System Fields
@override@JsonKey() final  String status;
@override@JsonKey(name: 'assigned_department') final  String? assignedDepartment;
@override@JsonKey(name: 'admin_remarks') final  String? adminRemarks;
// AI Fields
@override@JsonKey(name: 'category_confidence') final  double? categoryConfidence;
@override@JsonKey(name: 'model_version') final  String? modelVersion;
@override@JsonKey(name: 'category_source') final  String? categorySource;
@override@JsonKey(name: 'model_probability') final  double? modelProbability;
@override@JsonKey(name: 'top2_gap') final  double? top2Gap;
@override@JsonKey(name: 'needs_category_review') final  bool? needsCategoryReview;
 final  List<String> _reviewReasons;
@override@JsonKey(name: 'review_reasons') List<String> get reviewReasons {
  if (_reviewReasons is EqualUnmodifiableListView) return _reviewReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_reviewReasons);
}

@override@JsonKey(name: 'is_multi_issue') final  bool isMultiIssue;
 final  List<String> _rulesApplied;
@override@JsonKey(name: 'rules_applied') List<String> get rulesApplied {
  if (_rulesApplied is EqualUnmodifiableListView) return _rulesApplied;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_rulesApplied);
}

@override final  String? priority;
@override@JsonKey(name: 'priority_score')@NullableIntConverter() final  int? priorityScore;
@override@JsonKey(name: 'priority_level') final  String? priorityLevel;
@override@JsonKey(name: 'suggested_priority_score') final  double? suggestedPriorityScore;
@override@JsonKey(name: 'suggested_priority_level') final  String? suggestedPriorityLevel;
@override@JsonKey(name: 'queue_priority_score') final  double? queuePriorityScore;
@override@JsonKey(name: 'queue_priority_level') final  String? queuePriorityLevel;
@override@JsonKey(name: 'queue_priority_rank')@NullableIntConverter() final  int? queuePriorityRank;
@override@JsonKey(name: 'staff_priority_level') final  String? staffPriorityLevel;
@override@JsonKey(name: 'priority_source') final  String? prioritySource;
@override@JsonKey(name: 'priority_is_advisory') final  bool priorityIsAdvisory;
@override@JsonKey(name: 'needs_priority_review') final  bool needsPriorityReview;
 final  List<String> _priorityReviewReasons;
@override@JsonKey(name: 'priority_review_reasons') List<String> get priorityReviewReasons {
  if (_priorityReviewReasons is EqualUnmodifiableListView) return _priorityReviewReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priorityReviewReasons);
}

@override@JsonKey(name: 'linked_report_count') final  int linkedReportCount;
@override@JsonKey(name: 'linked_urgency_boost') final  int linkedUrgencyBoost;
@override@JsonKey(name: 'is_incident_representative') final  bool isIncidentRepresentative;
@override@JsonKey(name: 'priority_model_version') final  String? priorityModelVersion;
@override@JsonKey(name: 'priority_model_validated') final  bool priorityModelValidated;
@override@JsonKey(name: 'priority_calibration_version') final  String? priorityCalibrationVersion;
@override@JsonKey(name: 'emergency_probability') final  double? emergencyProbability;
 final  Map<String, double> _priorityComponents;
@override@JsonKey(name: 'priority_components') Map<String, double> get priorityComponents {
  if (_priorityComponents is EqualUnmodifiableMapView) return _priorityComponents;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_priorityComponents);
}

@override@JsonKey(name: 'priority_policy_version') final  String? priorityPolicyVersion;
 final  List<String> _priorityRulesApplied;
@override@JsonKey(name: 'priority_rules_applied') List<String> get priorityRulesApplied {
  if (_priorityRulesApplied is EqualUnmodifiableListView) return _priorityRulesApplied;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_priorityRulesApplied);
}

 final  List<String>? _priorityReasons;
@override@JsonKey(name: 'priority_reasons') List<String>? get priorityReasons {
  final value = _priorityReasons;
  if (value == null) return null;
  if (_priorityReasons is EqualUnmodifiableListView) return _priorityReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'base_score')@NullableIntConverter() final  int? baseScore;
@override@JsonKey(name: 'hotspot_score')@NullableIntConverter() final  int? hotspotScore;
@override@JsonKey(name: 'urgency_score') final  double? urgencyScore;
@override@JsonKey(name: 'recommended_department') final  String? recommendedDepartment;
@override@JsonKey(name: 'department_confidence') final  double? departmentConfidence;
 final  List<String>? _routingReasons;
@override@JsonKey(name: 'routing_reasons') List<String>? get routingReasons {
  final value = _routingReasons;
  if (value == null) return null;
  if (_routingReasons is EqualUnmodifiableListView) return _routingReasons;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}

@override@JsonKey(name: 'needs_department_review') final  bool? needsDepartmentReview;
@override@JsonKey(name: 'credibility_score') final  double? credibilityScore;
@override@JsonKey(name: 'incident_group_id') final  String? incidentGroupId;
@override@JsonKey(name: 'sentiment_score') final  double? sentimentScore;
@override@JsonKey(name: 'auto_category_suggestion') final  String? autoCategorySuggestion;
// Images
 final  List<ReportImage> _images;
// Images
@override@JsonKey() List<ReportImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

 final  List<String> _resolvedProofImageIds;
@override@JsonKey(name: 'resolved_proof_image_ids') List<String> get resolvedProofImageIds {
  if (_resolvedProofImageIds is EqualUnmodifiableListView) return _resolvedProofImageIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_resolvedProofImageIds);
}

@override@JsonKey(name: 'closure_signature_image_id') final  String? closureSignatureImageId;
 final  List<String> _closureSignatureDocumentIds;
@override@JsonKey(name: 'closure_signature_document_ids') List<String> get closureSignatureDocumentIds {
  if (_closureSignatureDocumentIds is EqualUnmodifiableListView) return _closureSignatureDocumentIds;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_closureSignatureDocumentIds);
}

// Timestamps
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;
@override@JsonKey(name: 'submitted_at') final  String? submittedAt;
@override@JsonKey(name: 'verified_at') final  String? verifiedAt;
@override@JsonKey(name: 'resolved_at') final  String? resolvedAt;
// Citizen Closure
@override@JsonKey(name: 'citizen_verified_at') final  String? citizenVerifiedAt;
@override@JsonKey(name: 'citizen_satisfaction')@NullableIntConverter() final  int? citizenSatisfaction;
@override@JsonKey(name: 'citizen_closure_note') final  String? citizenClosureNote;
// Blockchain Integration
@override@JsonKey(name: 'on_chain_id')@NullableIntConverter() final  int? onChainId;
@override@JsonKey(name: 'on_chain_hash') final  String? onChainHash;
@override@JsonKey(name: 'blockchain_txn_hash') final  String? blockchainTxnHash;
@override@JsonKey(name: 'blockchain_synced') final  bool blockchainSynced;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportCopyWith<_Report> get copyWith => __$ReportCopyWithImpl<_Report>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryKey, categoryKey) || other.categoryKey == categoryKey)&&(identical(other.categoryDisplay, categoryDisplay) || other.categoryDisplay == categoryDisplay)&&(identical(other.categoryLabelSnapshot, categoryLabelSnapshot) || other.categoryLabelSnapshot == categoryLabelSnapshot)&&(identical(other.taxonomyVersion, taxonomyVersion) || other.taxonomyVersion == taxonomyVersion)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.municipalityId, municipalityId) || other.municipalityId == municipalityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedDepartment, assignedDepartment) || other.assignedDepartment == assignedDepartment)&&(identical(other.adminRemarks, adminRemarks) || other.adminRemarks == adminRemarks)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.modelVersion, modelVersion) || other.modelVersion == modelVersion)&&(identical(other.categorySource, categorySource) || other.categorySource == categorySource)&&(identical(other.modelProbability, modelProbability) || other.modelProbability == modelProbability)&&(identical(other.top2Gap, top2Gap) || other.top2Gap == top2Gap)&&(identical(other.needsCategoryReview, needsCategoryReview) || other.needsCategoryReview == needsCategoryReview)&&const DeepCollectionEquality().equals(other._reviewReasons, _reviewReasons)&&(identical(other.isMultiIssue, isMultiIssue) || other.isMultiIssue == isMultiIssue)&&const DeepCollectionEquality().equals(other._rulesApplied, _rulesApplied)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.priorityLevel, priorityLevel) || other.priorityLevel == priorityLevel)&&(identical(other.suggestedPriorityScore, suggestedPriorityScore) || other.suggestedPriorityScore == suggestedPriorityScore)&&(identical(other.suggestedPriorityLevel, suggestedPriorityLevel) || other.suggestedPriorityLevel == suggestedPriorityLevel)&&(identical(other.queuePriorityScore, queuePriorityScore) || other.queuePriorityScore == queuePriorityScore)&&(identical(other.queuePriorityLevel, queuePriorityLevel) || other.queuePriorityLevel == queuePriorityLevel)&&(identical(other.queuePriorityRank, queuePriorityRank) || other.queuePriorityRank == queuePriorityRank)&&(identical(other.staffPriorityLevel, staffPriorityLevel) || other.staffPriorityLevel == staffPriorityLevel)&&(identical(other.prioritySource, prioritySource) || other.prioritySource == prioritySource)&&(identical(other.priorityIsAdvisory, priorityIsAdvisory) || other.priorityIsAdvisory == priorityIsAdvisory)&&(identical(other.needsPriorityReview, needsPriorityReview) || other.needsPriorityReview == needsPriorityReview)&&const DeepCollectionEquality().equals(other._priorityReviewReasons, _priorityReviewReasons)&&(identical(other.linkedReportCount, linkedReportCount) || other.linkedReportCount == linkedReportCount)&&(identical(other.linkedUrgencyBoost, linkedUrgencyBoost) || other.linkedUrgencyBoost == linkedUrgencyBoost)&&(identical(other.isIncidentRepresentative, isIncidentRepresentative) || other.isIncidentRepresentative == isIncidentRepresentative)&&(identical(other.priorityModelVersion, priorityModelVersion) || other.priorityModelVersion == priorityModelVersion)&&(identical(other.priorityModelValidated, priorityModelValidated) || other.priorityModelValidated == priorityModelValidated)&&(identical(other.priorityCalibrationVersion, priorityCalibrationVersion) || other.priorityCalibrationVersion == priorityCalibrationVersion)&&(identical(other.emergencyProbability, emergencyProbability) || other.emergencyProbability == emergencyProbability)&&const DeepCollectionEquality().equals(other._priorityComponents, _priorityComponents)&&(identical(other.priorityPolicyVersion, priorityPolicyVersion) || other.priorityPolicyVersion == priorityPolicyVersion)&&const DeepCollectionEquality().equals(other._priorityRulesApplied, _priorityRulesApplied)&&const DeepCollectionEquality().equals(other._priorityReasons, _priorityReasons)&&(identical(other.baseScore, baseScore) || other.baseScore == baseScore)&&(identical(other.hotspotScore, hotspotScore) || other.hotspotScore == hotspotScore)&&(identical(other.urgencyScore, urgencyScore) || other.urgencyScore == urgencyScore)&&(identical(other.recommendedDepartment, recommendedDepartment) || other.recommendedDepartment == recommendedDepartment)&&(identical(other.departmentConfidence, departmentConfidence) || other.departmentConfidence == departmentConfidence)&&const DeepCollectionEquality().equals(other._routingReasons, _routingReasons)&&(identical(other.needsDepartmentReview, needsDepartmentReview) || other.needsDepartmentReview == needsDepartmentReview)&&(identical(other.credibilityScore, credibilityScore) || other.credibilityScore == credibilityScore)&&(identical(other.incidentGroupId, incidentGroupId) || other.incidentGroupId == incidentGroupId)&&(identical(other.sentimentScore, sentimentScore) || other.sentimentScore == sentimentScore)&&(identical(other.autoCategorySuggestion, autoCategorySuggestion) || other.autoCategorySuggestion == autoCategorySuggestion)&&const DeepCollectionEquality().equals(other._images, _images)&&const DeepCollectionEquality().equals(other._resolvedProofImageIds, _resolvedProofImageIds)&&(identical(other.closureSignatureImageId, closureSignatureImageId) || other.closureSignatureImageId == closureSignatureImageId)&&const DeepCollectionEquality().equals(other._closureSignatureDocumentIds, _closureSignatureDocumentIds)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt)&&(identical(other.citizenVerifiedAt, citizenVerifiedAt) || other.citizenVerifiedAt == citizenVerifiedAt)&&(identical(other.citizenSatisfaction, citizenSatisfaction) || other.citizenSatisfaction == citizenSatisfaction)&&(identical(other.citizenClosureNote, citizenClosureNote) || other.citizenClosureNote == citizenClosureNote)&&(identical(other.onChainId, onChainId) || other.onChainId == onChainId)&&(identical(other.onChainHash, onChainHash) || other.onChainHash == onChainHash)&&(identical(other.blockchainTxnHash, blockchainTxnHash) || other.blockchainTxnHash == blockchainTxnHash)&&(identical(other.blockchainSynced, blockchainSynced) || other.blockchainSynced == blockchainSynced));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportId,userId,category,categoryKey,categoryDisplay,categoryLabelSnapshot,taxonomyVersion,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,municipalityId,barangayId,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,severity,peopleAffected,isEmergency,status,assignedDepartment,adminRemarks,categoryConfidence,modelVersion,categorySource,modelProbability,top2Gap,needsCategoryReview,const DeepCollectionEquality().hash(_reviewReasons),isMultiIssue,const DeepCollectionEquality().hash(_rulesApplied),priority,priorityScore,priorityLevel,suggestedPriorityScore,suggestedPriorityLevel,queuePriorityScore,queuePriorityLevel,queuePriorityRank,staffPriorityLevel,prioritySource,priorityIsAdvisory,needsPriorityReview,const DeepCollectionEquality().hash(_priorityReviewReasons),linkedReportCount,linkedUrgencyBoost,isIncidentRepresentative,priorityModelVersion,priorityModelValidated,priorityCalibrationVersion,emergencyProbability,const DeepCollectionEquality().hash(_priorityComponents),priorityPolicyVersion,const DeepCollectionEquality().hash(_priorityRulesApplied),const DeepCollectionEquality().hash(_priorityReasons),baseScore,hotspotScore,urgencyScore,recommendedDepartment,departmentConfidence,const DeepCollectionEquality().hash(_routingReasons),needsDepartmentReview,credibilityScore,incidentGroupId,sentimentScore,autoCategorySuggestion,const DeepCollectionEquality().hash(_images),const DeepCollectionEquality().hash(_resolvedProofImageIds),closureSignatureImageId,const DeepCollectionEquality().hash(_closureSignatureDocumentIds),createdAt,updatedAt,submittedAt,verifiedAt,resolvedAt,citizenVerifiedAt,citizenSatisfaction,citizenClosureNote,onChainId,onChainHash,blockchainTxnHash,blockchainSynced]);

@override
String toString() {
  return 'Report(id: $id, reportId: $reportId, userId: $userId, category: $category, categoryKey: $categoryKey, categoryDisplay: $categoryDisplay, categoryLabelSnapshot: $categoryLabelSnapshot, taxonomyVersion: $taxonomyVersion, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, municipalityId: $municipalityId, barangayId: $barangayId, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, status: $status, assignedDepartment: $assignedDepartment, adminRemarks: $adminRemarks, categoryConfidence: $categoryConfidence, modelVersion: $modelVersion, categorySource: $categorySource, modelProbability: $modelProbability, top2Gap: $top2Gap, needsCategoryReview: $needsCategoryReview, reviewReasons: $reviewReasons, isMultiIssue: $isMultiIssue, rulesApplied: $rulesApplied, priority: $priority, priorityScore: $priorityScore, priorityLevel: $priorityLevel, suggestedPriorityScore: $suggestedPriorityScore, suggestedPriorityLevel: $suggestedPriorityLevel, queuePriorityScore: $queuePriorityScore, queuePriorityLevel: $queuePriorityLevel, queuePriorityRank: $queuePriorityRank, staffPriorityLevel: $staffPriorityLevel, prioritySource: $prioritySource, priorityIsAdvisory: $priorityIsAdvisory, needsPriorityReview: $needsPriorityReview, priorityReviewReasons: $priorityReviewReasons, linkedReportCount: $linkedReportCount, linkedUrgencyBoost: $linkedUrgencyBoost, isIncidentRepresentative: $isIncidentRepresentative, priorityModelVersion: $priorityModelVersion, priorityModelValidated: $priorityModelValidated, priorityCalibrationVersion: $priorityCalibrationVersion, emergencyProbability: $emergencyProbability, priorityComponents: $priorityComponents, priorityPolicyVersion: $priorityPolicyVersion, priorityRulesApplied: $priorityRulesApplied, priorityReasons: $priorityReasons, baseScore: $baseScore, hotspotScore: $hotspotScore, urgencyScore: $urgencyScore, recommendedDepartment: $recommendedDepartment, departmentConfidence: $departmentConfidence, routingReasons: $routingReasons, needsDepartmentReview: $needsDepartmentReview, credibilityScore: $credibilityScore, incidentGroupId: $incidentGroupId, sentimentScore: $sentimentScore, autoCategorySuggestion: $autoCategorySuggestion, images: $images, resolvedProofImageIds: $resolvedProofImageIds, closureSignatureImageId: $closureSignatureImageId, closureSignatureDocumentIds: $closureSignatureDocumentIds, createdAt: $createdAt, updatedAt: $updatedAt, submittedAt: $submittedAt, verifiedAt: $verifiedAt, resolvedAt: $resolvedAt, citizenVerifiedAt: $citizenVerifiedAt, citizenSatisfaction: $citizenSatisfaction, citizenClosureNote: $citizenClosureNote, onChainId: $onChainId, onChainHash: $onChainHash, blockchainTxnHash: $blockchainTxnHash, blockchainSynced: $blockchainSynced)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String? category,@JsonKey(name: 'category_key') String? categoryKey,@JsonKey(name: 'category_display') String? categoryDisplay,@JsonKey(name: 'category_label_snapshot') String? categoryLabelSnapshot,@JsonKey(name: 'taxonomy_version') String? taxonomyVersion,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'municipality_id', readValue: _readMunicipalityId) String municipalityId,@JsonKey(name: 'barangay_id', readValue: _readBarangayId) String? barangayId,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay, String severity,@JsonKey(name: 'people_affected')@NullableIntConverter() int? peopleAffected,@JsonKey(name: 'is_emergency') bool isEmergency, String status,@JsonKey(name: 'assigned_department') String? assignedDepartment,@JsonKey(name: 'admin_remarks') String? adminRemarks,@JsonKey(name: 'category_confidence') double? categoryConfidence,@JsonKey(name: 'model_version') String? modelVersion,@JsonKey(name: 'category_source') String? categorySource,@JsonKey(name: 'model_probability') double? modelProbability,@JsonKey(name: 'top2_gap') double? top2Gap,@JsonKey(name: 'needs_category_review') bool? needsCategoryReview,@JsonKey(name: 'review_reasons') List<String> reviewReasons,@JsonKey(name: 'is_multi_issue') bool isMultiIssue,@JsonKey(name: 'rules_applied') List<String> rulesApplied, String? priority,@JsonKey(name: 'priority_score')@NullableIntConverter() int? priorityScore,@JsonKey(name: 'priority_level') String? priorityLevel,@JsonKey(name: 'suggested_priority_score') double? suggestedPriorityScore,@JsonKey(name: 'suggested_priority_level') String? suggestedPriorityLevel,@JsonKey(name: 'queue_priority_score') double? queuePriorityScore,@JsonKey(name: 'queue_priority_level') String? queuePriorityLevel,@JsonKey(name: 'queue_priority_rank')@NullableIntConverter() int? queuePriorityRank,@JsonKey(name: 'staff_priority_level') String? staffPriorityLevel,@JsonKey(name: 'priority_source') String? prioritySource,@JsonKey(name: 'priority_is_advisory') bool priorityIsAdvisory,@JsonKey(name: 'needs_priority_review') bool needsPriorityReview,@JsonKey(name: 'priority_review_reasons') List<String> priorityReviewReasons,@JsonKey(name: 'linked_report_count') int linkedReportCount,@JsonKey(name: 'linked_urgency_boost') int linkedUrgencyBoost,@JsonKey(name: 'is_incident_representative') bool isIncidentRepresentative,@JsonKey(name: 'priority_model_version') String? priorityModelVersion,@JsonKey(name: 'priority_model_validated') bool priorityModelValidated,@JsonKey(name: 'priority_calibration_version') String? priorityCalibrationVersion,@JsonKey(name: 'emergency_probability') double? emergencyProbability,@JsonKey(name: 'priority_components') Map<String, double> priorityComponents,@JsonKey(name: 'priority_policy_version') String? priorityPolicyVersion,@JsonKey(name: 'priority_rules_applied') List<String> priorityRulesApplied,@JsonKey(name: 'priority_reasons') List<String>? priorityReasons,@JsonKey(name: 'base_score')@NullableIntConverter() int? baseScore,@JsonKey(name: 'hotspot_score')@NullableIntConverter() int? hotspotScore,@JsonKey(name: 'urgency_score') double? urgencyScore,@JsonKey(name: 'recommended_department') String? recommendedDepartment,@JsonKey(name: 'department_confidence') double? departmentConfidence,@JsonKey(name: 'routing_reasons') List<String>? routingReasons,@JsonKey(name: 'needs_department_review') bool? needsDepartmentReview,@JsonKey(name: 'credibility_score') double? credibilityScore,@JsonKey(name: 'incident_group_id') String? incidentGroupId,@JsonKey(name: 'sentiment_score') double? sentimentScore,@JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion, List<ReportImage> images,@JsonKey(name: 'resolved_proof_image_ids') List<String> resolvedProofImageIds,@JsonKey(name: 'closure_signature_image_id') String? closureSignatureImageId,@JsonKey(name: 'closure_signature_document_ids') List<String> closureSignatureDocumentIds,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'resolved_at') String? resolvedAt,@JsonKey(name: 'citizen_verified_at') String? citizenVerifiedAt,@JsonKey(name: 'citizen_satisfaction')@NullableIntConverter() int? citizenSatisfaction,@JsonKey(name: 'citizen_closure_note') String? citizenClosureNote,@JsonKey(name: 'on_chain_id')@NullableIntConverter() int? onChainId,@JsonKey(name: 'on_chain_hash') String? onChainHash,@JsonKey(name: 'blockchain_txn_hash') String? blockchainTxnHash,@JsonKey(name: 'blockchain_synced') bool blockchainSynced
});




}
/// @nodoc
class __$ReportCopyWithImpl<$Res>
    implements _$ReportCopyWith<$Res> {
  __$ReportCopyWithImpl(this._self, this._then);

  final _Report _self;
  final $Res Function(_Report) _then;

/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? category = freezed,Object? categoryKey = freezed,Object? categoryDisplay = freezed,Object? categoryLabelSnapshot = freezed,Object? taxonomyVersion = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? municipalityId = null,Object? barangayId = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? severity = null,Object? peopleAffected = freezed,Object? isEmergency = null,Object? status = null,Object? assignedDepartment = freezed,Object? adminRemarks = freezed,Object? categoryConfidence = freezed,Object? modelVersion = freezed,Object? categorySource = freezed,Object? modelProbability = freezed,Object? top2Gap = freezed,Object? needsCategoryReview = freezed,Object? reviewReasons = null,Object? isMultiIssue = null,Object? rulesApplied = null,Object? priority = freezed,Object? priorityScore = freezed,Object? priorityLevel = freezed,Object? suggestedPriorityScore = freezed,Object? suggestedPriorityLevel = freezed,Object? queuePriorityScore = freezed,Object? queuePriorityLevel = freezed,Object? queuePriorityRank = freezed,Object? staffPriorityLevel = freezed,Object? prioritySource = freezed,Object? priorityIsAdvisory = null,Object? needsPriorityReview = null,Object? priorityReviewReasons = null,Object? linkedReportCount = null,Object? linkedUrgencyBoost = null,Object? isIncidentRepresentative = null,Object? priorityModelVersion = freezed,Object? priorityModelValidated = null,Object? priorityCalibrationVersion = freezed,Object? emergencyProbability = freezed,Object? priorityComponents = null,Object? priorityPolicyVersion = freezed,Object? priorityRulesApplied = null,Object? priorityReasons = freezed,Object? baseScore = freezed,Object? hotspotScore = freezed,Object? urgencyScore = freezed,Object? recommendedDepartment = freezed,Object? departmentConfidence = freezed,Object? routingReasons = freezed,Object? needsDepartmentReview = freezed,Object? credibilityScore = freezed,Object? incidentGroupId = freezed,Object? sentimentScore = freezed,Object? autoCategorySuggestion = freezed,Object? images = null,Object? resolvedProofImageIds = null,Object? closureSignatureImageId = freezed,Object? closureSignatureDocumentIds = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? resolvedAt = freezed,Object? citizenVerifiedAt = freezed,Object? citizenSatisfaction = freezed,Object? citizenClosureNote = freezed,Object? onChainId = freezed,Object? onChainHash = freezed,Object? blockchainTxnHash = freezed,Object? blockchainSynced = null,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,categoryKey: freezed == categoryKey ? _self.categoryKey : categoryKey // ignore: cast_nullable_to_non_nullable
as String?,categoryDisplay: freezed == categoryDisplay ? _self.categoryDisplay : categoryDisplay // ignore: cast_nullable_to_non_nullable
as String?,categoryLabelSnapshot: freezed == categoryLabelSnapshot ? _self.categoryLabelSnapshot : categoryLabelSnapshot // ignore: cast_nullable_to_non_nullable
as String?,taxonomyVersion: freezed == taxonomyVersion ? _self.taxonomyVersion : taxonomyVersion // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
as String?,municipalityId: null == municipalityId ? _self.municipalityId : municipalityId // ignore: cast_nullable_to_non_nullable
as String,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,locationAccuracy: null == locationAccuracy ? _self.locationAccuracy : locationAccuracy // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,severity: null == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String,peopleAffected: freezed == peopleAffected ? _self.peopleAffected : peopleAffected // ignore: cast_nullable_to_non_nullable
as int?,isEmergency: null == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,assignedDepartment: freezed == assignedDepartment ? _self.assignedDepartment : assignedDepartment // ignore: cast_nullable_to_non_nullable
as String?,adminRemarks: freezed == adminRemarks ? _self.adminRemarks : adminRemarks // ignore: cast_nullable_to_non_nullable
as String?,categoryConfidence: freezed == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double?,modelVersion: freezed == modelVersion ? _self.modelVersion : modelVersion // ignore: cast_nullable_to_non_nullable
as String?,categorySource: freezed == categorySource ? _self.categorySource : categorySource // ignore: cast_nullable_to_non_nullable
as String?,modelProbability: freezed == modelProbability ? _self.modelProbability : modelProbability // ignore: cast_nullable_to_non_nullable
as double?,top2Gap: freezed == top2Gap ? _self.top2Gap : top2Gap // ignore: cast_nullable_to_non_nullable
as double?,needsCategoryReview: freezed == needsCategoryReview ? _self.needsCategoryReview : needsCategoryReview // ignore: cast_nullable_to_non_nullable
as bool?,reviewReasons: null == reviewReasons ? _self._reviewReasons : reviewReasons // ignore: cast_nullable_to_non_nullable
as List<String>,isMultiIssue: null == isMultiIssue ? _self.isMultiIssue : isMultiIssue // ignore: cast_nullable_to_non_nullable
as bool,rulesApplied: null == rulesApplied ? _self._rulesApplied : rulesApplied // ignore: cast_nullable_to_non_nullable
as List<String>,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,priorityScore: freezed == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int?,priorityLevel: freezed == priorityLevel ? _self.priorityLevel : priorityLevel // ignore: cast_nullable_to_non_nullable
as String?,suggestedPriorityScore: freezed == suggestedPriorityScore ? _self.suggestedPriorityScore : suggestedPriorityScore // ignore: cast_nullable_to_non_nullable
as double?,suggestedPriorityLevel: freezed == suggestedPriorityLevel ? _self.suggestedPriorityLevel : suggestedPriorityLevel // ignore: cast_nullable_to_non_nullable
as String?,queuePriorityScore: freezed == queuePriorityScore ? _self.queuePriorityScore : queuePriorityScore // ignore: cast_nullable_to_non_nullable
as double?,queuePriorityLevel: freezed == queuePriorityLevel ? _self.queuePriorityLevel : queuePriorityLevel // ignore: cast_nullable_to_non_nullable
as String?,queuePriorityRank: freezed == queuePriorityRank ? _self.queuePriorityRank : queuePriorityRank // ignore: cast_nullable_to_non_nullable
as int?,staffPriorityLevel: freezed == staffPriorityLevel ? _self.staffPriorityLevel : staffPriorityLevel // ignore: cast_nullable_to_non_nullable
as String?,prioritySource: freezed == prioritySource ? _self.prioritySource : prioritySource // ignore: cast_nullable_to_non_nullable
as String?,priorityIsAdvisory: null == priorityIsAdvisory ? _self.priorityIsAdvisory : priorityIsAdvisory // ignore: cast_nullable_to_non_nullable
as bool,needsPriorityReview: null == needsPriorityReview ? _self.needsPriorityReview : needsPriorityReview // ignore: cast_nullable_to_non_nullable
as bool,priorityReviewReasons: null == priorityReviewReasons ? _self._priorityReviewReasons : priorityReviewReasons // ignore: cast_nullable_to_non_nullable
as List<String>,linkedReportCount: null == linkedReportCount ? _self.linkedReportCount : linkedReportCount // ignore: cast_nullable_to_non_nullable
as int,linkedUrgencyBoost: null == linkedUrgencyBoost ? _self.linkedUrgencyBoost : linkedUrgencyBoost // ignore: cast_nullable_to_non_nullable
as int,isIncidentRepresentative: null == isIncidentRepresentative ? _self.isIncidentRepresentative : isIncidentRepresentative // ignore: cast_nullable_to_non_nullable
as bool,priorityModelVersion: freezed == priorityModelVersion ? _self.priorityModelVersion : priorityModelVersion // ignore: cast_nullable_to_non_nullable
as String?,priorityModelValidated: null == priorityModelValidated ? _self.priorityModelValidated : priorityModelValidated // ignore: cast_nullable_to_non_nullable
as bool,priorityCalibrationVersion: freezed == priorityCalibrationVersion ? _self.priorityCalibrationVersion : priorityCalibrationVersion // ignore: cast_nullable_to_non_nullable
as String?,emergencyProbability: freezed == emergencyProbability ? _self.emergencyProbability : emergencyProbability // ignore: cast_nullable_to_non_nullable
as double?,priorityComponents: null == priorityComponents ? _self._priorityComponents : priorityComponents // ignore: cast_nullable_to_non_nullable
as Map<String, double>,priorityPolicyVersion: freezed == priorityPolicyVersion ? _self.priorityPolicyVersion : priorityPolicyVersion // ignore: cast_nullable_to_non_nullable
as String?,priorityRulesApplied: null == priorityRulesApplied ? _self._priorityRulesApplied : priorityRulesApplied // ignore: cast_nullable_to_non_nullable
as List<String>,priorityReasons: freezed == priorityReasons ? _self._priorityReasons : priorityReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,baseScore: freezed == baseScore ? _self.baseScore : baseScore // ignore: cast_nullable_to_non_nullable
as int?,hotspotScore: freezed == hotspotScore ? _self.hotspotScore : hotspotScore // ignore: cast_nullable_to_non_nullable
as int?,urgencyScore: freezed == urgencyScore ? _self.urgencyScore : urgencyScore // ignore: cast_nullable_to_non_nullable
as double?,recommendedDepartment: freezed == recommendedDepartment ? _self.recommendedDepartment : recommendedDepartment // ignore: cast_nullable_to_non_nullable
as String?,departmentConfidence: freezed == departmentConfidence ? _self.departmentConfidence : departmentConfidence // ignore: cast_nullable_to_non_nullable
as double?,routingReasons: freezed == routingReasons ? _self._routingReasons : routingReasons // ignore: cast_nullable_to_non_nullable
as List<String>?,needsDepartmentReview: freezed == needsDepartmentReview ? _self.needsDepartmentReview : needsDepartmentReview // ignore: cast_nullable_to_non_nullable
as bool?,credibilityScore: freezed == credibilityScore ? _self.credibilityScore : credibilityScore // ignore: cast_nullable_to_non_nullable
as double?,incidentGroupId: freezed == incidentGroupId ? _self.incidentGroupId : incidentGroupId // ignore: cast_nullable_to_non_nullable
as String?,sentimentScore: freezed == sentimentScore ? _self.sentimentScore : sentimentScore // ignore: cast_nullable_to_non_nullable
as double?,autoCategorySuggestion: freezed == autoCategorySuggestion ? _self.autoCategorySuggestion : autoCategorySuggestion // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ReportImage>,resolvedProofImageIds: null == resolvedProofImageIds ? _self._resolvedProofImageIds : resolvedProofImageIds // ignore: cast_nullable_to_non_nullable
as List<String>,closureSignatureImageId: freezed == closureSignatureImageId ? _self.closureSignatureImageId : closureSignatureImageId // ignore: cast_nullable_to_non_nullable
as String?,closureSignatureDocumentIds: null == closureSignatureDocumentIds ? _self._closureSignatureDocumentIds : closureSignatureDocumentIds // ignore: cast_nullable_to_non_nullable
as List<String>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,citizenVerifiedAt: freezed == citizenVerifiedAt ? _self.citizenVerifiedAt : citizenVerifiedAt // ignore: cast_nullable_to_non_nullable
as String?,citizenSatisfaction: freezed == citizenSatisfaction ? _self.citizenSatisfaction : citizenSatisfaction // ignore: cast_nullable_to_non_nullable
as int?,citizenClosureNote: freezed == citizenClosureNote ? _self.citizenClosureNote : citizenClosureNote // ignore: cast_nullable_to_non_nullable
as String?,onChainId: freezed == onChainId ? _self.onChainId : onChainId // ignore: cast_nullable_to_non_nullable
as int?,onChainHash: freezed == onChainHash ? _self.onChainHash : onChainHash // ignore: cast_nullable_to_non_nullable
as String?,blockchainTxnHash: freezed == blockchainTxnHash ? _self.blockchainTxnHash : blockchainTxnHash // ignore: cast_nullable_to_non_nullable
as String?,blockchainSynced: null == blockchainSynced ? _self.blockchainSynced : blockchainSynced // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$CreateReportRequest {

// Report Details (Section A)
 String? get category;@JsonKey(name: 'incident_type') String? get incidentType; String? get title; String get description;@JsonKey(name: 'incident_datetime') String? get incidentDatetime;@JsonKey(name: 'is_happening_now') bool get isHappeningNow;// Location Information (Section B)
 String? get zone;@JsonKey(name: 'street_landmark') String? get streetLandmark;@JsonKey(name: 'municipality_id') String get municipalityId;@JsonKey(name: 'barangay_id') String? get barangayId;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province; String? get latitude; String? get longitude;@JsonKey(name: 'location_accuracy') String get locationAccuracy;// Legacy fields for backwards compatibility
 String? get location; String? get barangay;// Consent & Declaration
@JsonKey(name: 'declaration_confirmed') bool get declarationConfirmed;@JsonKey(name: 'data_processing_consent') bool get dataProcessingConsent;
/// Create a copy of CreateReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReportRequestCopyWith<CreateReportRequest> get copyWith => _$CreateReportRequestCopyWithImpl<CreateReportRequest>(this as CreateReportRequest, _$identity);

  /// Serializes this CreateReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReportRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.municipalityId, municipalityId) || other.municipalityId == municipalityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.declarationConfirmed, declarationConfirmed) || other.declarationConfirmed == declarationConfirmed)&&(identical(other.dataProcessingConsent, dataProcessingConsent) || other.dataProcessingConsent == dataProcessingConsent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,category,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,municipalityId,barangayId,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,declarationConfirmed,dataProcessingConsent]);

@override
String toString() {
  return 'CreateReportRequest(category: $category, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, municipalityId: $municipalityId, barangayId: $barangayId, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, declarationConfirmed: $declarationConfirmed, dataProcessingConsent: $dataProcessingConsent)';
}


}

/// @nodoc
abstract mixin class $CreateReportRequestCopyWith<$Res>  {
  factory $CreateReportRequestCopyWith(CreateReportRequest value, $Res Function(CreateReportRequest) _then) = _$CreateReportRequestCopyWithImpl;
@useResult
$Res call({
 String? category,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'municipality_id') String municipalityId,@JsonKey(name: 'barangay_id') String? barangayId,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay,@JsonKey(name: 'declaration_confirmed') bool declarationConfirmed,@JsonKey(name: 'data_processing_consent') bool dataProcessingConsent
});




}
/// @nodoc
class _$CreateReportRequestCopyWithImpl<$Res>
    implements $CreateReportRequestCopyWith<$Res> {
  _$CreateReportRequestCopyWithImpl(this._self, this._then);

  final CreateReportRequest _self;
  final $Res Function(CreateReportRequest) _then;

/// Create a copy of CreateReportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? category = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? municipalityId = null,Object? barangayId = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? declarationConfirmed = null,Object? dataProcessingConsent = null,}) {
  return _then(_self.copyWith(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
as String?,municipalityId: null == municipalityId ? _self.municipalityId : municipalityId // ignore: cast_nullable_to_non_nullable
as String,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,locationAccuracy: null == locationAccuracy ? _self.locationAccuracy : locationAccuracy // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,declarationConfirmed: null == declarationConfirmed ? _self.declarationConfirmed : declarationConfirmed // ignore: cast_nullable_to_non_nullable
as bool,dataProcessingConsent: null == dataProcessingConsent ? _self.dataProcessingConsent : dataProcessingConsent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [CreateReportRequest].
extension CreateReportRequestPatterns on CreateReportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _CreateReportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _CreateReportRequest value)  $default,){
final _that = this;
switch (_that) {
case _CreateReportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _CreateReportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id')  String municipalityId, @JsonKey(name: 'barangay_id')  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay, @JsonKey(name: 'declaration_confirmed')  bool declarationConfirmed, @JsonKey(name: 'data_processing_consent')  bool dataProcessingConsent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.declarationConfirmed,_that.dataProcessingConsent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id')  String municipalityId, @JsonKey(name: 'barangay_id')  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay, @JsonKey(name: 'declaration_confirmed')  bool declarationConfirmed, @JsonKey(name: 'data_processing_consent')  bool dataProcessingConsent)  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest():
return $default(_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.declarationConfirmed,_that.dataProcessingConsent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id')  String municipalityId, @JsonKey(name: 'barangay_id')  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay, @JsonKey(name: 'declaration_confirmed')  bool declarationConfirmed, @JsonKey(name: 'data_processing_consent')  bool dataProcessingConsent)?  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.declarationConfirmed,_that.dataProcessingConsent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateReportRequest implements CreateReportRequest {
  const _CreateReportRequest({this.category, @JsonKey(name: 'incident_type') this.incidentType, this.title, required this.description, @JsonKey(name: 'incident_datetime') this.incidentDatetime, @JsonKey(name: 'is_happening_now') this.isHappeningNow = false, this.zone, @JsonKey(name: 'street_landmark') this.streetLandmark, @JsonKey(name: 'municipality_id') this.municipalityId = 'urdaneta', @JsonKey(name: 'barangay_id') this.barangayId, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, this.latitude, this.longitude, @JsonKey(name: 'location_accuracy') this.locationAccuracy = 'approximate', this.location, this.barangay, @JsonKey(name: 'declaration_confirmed') this.declarationConfirmed = true, @JsonKey(name: 'data_processing_consent') this.dataProcessingConsent = true});
  factory _CreateReportRequest.fromJson(Map<String, dynamic> json) => _$CreateReportRequestFromJson(json);

// Report Details (Section A)
@override final  String? category;
@override@JsonKey(name: 'incident_type') final  String? incidentType;
@override final  String? title;
@override final  String description;
@override@JsonKey(name: 'incident_datetime') final  String? incidentDatetime;
@override@JsonKey(name: 'is_happening_now') final  bool isHappeningNow;
// Location Information (Section B)
@override final  String? zone;
@override@JsonKey(name: 'street_landmark') final  String? streetLandmark;
@override@JsonKey(name: 'municipality_id') final  String municipalityId;
@override@JsonKey(name: 'barangay_id') final  String? barangayId;
@override@JsonKey(name: 'city_municipality') final  String? cityMunicipality;
@override final  String? province;
@override final  String? latitude;
@override final  String? longitude;
@override@JsonKey(name: 'location_accuracy') final  String locationAccuracy;
// Legacy fields for backwards compatibility
@override final  String? location;
@override final  String? barangay;
// Consent & Declaration
@override@JsonKey(name: 'declaration_confirmed') final  bool declarationConfirmed;
@override@JsonKey(name: 'data_processing_consent') final  bool dataProcessingConsent;

/// Create a copy of CreateReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$CreateReportRequestCopyWith<_CreateReportRequest> get copyWith => __$CreateReportRequestCopyWithImpl<_CreateReportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$CreateReportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReportRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.municipalityId, municipalityId) || other.municipalityId == municipalityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.declarationConfirmed, declarationConfirmed) || other.declarationConfirmed == declarationConfirmed)&&(identical(other.dataProcessingConsent, dataProcessingConsent) || other.dataProcessingConsent == dataProcessingConsent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,category,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,municipalityId,barangayId,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,declarationConfirmed,dataProcessingConsent]);

@override
String toString() {
  return 'CreateReportRequest(category: $category, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, municipalityId: $municipalityId, barangayId: $barangayId, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, declarationConfirmed: $declarationConfirmed, dataProcessingConsent: $dataProcessingConsent)';
}


}

/// @nodoc
abstract mixin class _$CreateReportRequestCopyWith<$Res> implements $CreateReportRequestCopyWith<$Res> {
  factory _$CreateReportRequestCopyWith(_CreateReportRequest value, $Res Function(_CreateReportRequest) _then) = __$CreateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String? category,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'municipality_id') String municipalityId,@JsonKey(name: 'barangay_id') String? barangayId,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay,@JsonKey(name: 'declaration_confirmed') bool declarationConfirmed,@JsonKey(name: 'data_processing_consent') bool dataProcessingConsent
});




}
/// @nodoc
class __$CreateReportRequestCopyWithImpl<$Res>
    implements _$CreateReportRequestCopyWith<$Res> {
  __$CreateReportRequestCopyWithImpl(this._self, this._then);

  final _CreateReportRequest _self;
  final $Res Function(_CreateReportRequest) _then;

/// Create a copy of CreateReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? category = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? municipalityId = null,Object? barangayId = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? declarationConfirmed = null,Object? dataProcessingConsent = null,}) {
  return _then(_CreateReportRequest(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
as String?,municipalityId: null == municipalityId ? _self.municipalityId : municipalityId // ignore: cast_nullable_to_non_nullable
as String,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,locationAccuracy: null == locationAccuracy ? _self.locationAccuracy : locationAccuracy // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,declarationConfirmed: null == declarationConfirmed ? _self.declarationConfirmed : declarationConfirmed // ignore: cast_nullable_to_non_nullable
as bool,dataProcessingConsent: null == dataProcessingConsent ? _self.dataProcessingConsent : dataProcessingConsent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateReportRequest {

 String? get title; String? get description; String? get category;@JsonKey(name: 'incident_type') String? get incidentType; String? get zone;@JsonKey(name: 'street_landmark') String? get streetLandmark;@JsonKey(name: 'municipality_id') String? get municipalityId;@JsonKey(name: 'barangay_id') String? get barangayId;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province;// Legacy
 String? get barangay;
/// Create a copy of UpdateReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateReportRequestCopyWith<UpdateReportRequest> get copyWith => _$UpdateReportRequestCopyWithImpl<UpdateReportRequest>(this as UpdateReportRequest, _$identity);

  /// Serializes this UpdateReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateReportRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.municipalityId, municipalityId) || other.municipalityId == municipalityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.barangay, barangay) || other.barangay == barangay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,incidentType,zone,streetLandmark,municipalityId,barangayId,cityMunicipality,province,barangay);

@override
String toString() {
  return 'UpdateReportRequest(title: $title, description: $description, category: $category, incidentType: $incidentType, zone: $zone, streetLandmark: $streetLandmark, municipalityId: $municipalityId, barangayId: $barangayId, cityMunicipality: $cityMunicipality, province: $province, barangay: $barangay)';
}


}

/// @nodoc
abstract mixin class $UpdateReportRequestCopyWith<$Res>  {
  factory $UpdateReportRequestCopyWith(UpdateReportRequest value, $Res Function(UpdateReportRequest) _then) = _$UpdateReportRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? description, String? category,@JsonKey(name: 'incident_type') String? incidentType, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'municipality_id') String? municipalityId,@JsonKey(name: 'barangay_id') String? barangayId,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? barangay
});




}
/// @nodoc
class _$UpdateReportRequestCopyWithImpl<$Res>
    implements $UpdateReportRequestCopyWith<$Res> {
  _$UpdateReportRequestCopyWithImpl(this._self, this._then);

  final UpdateReportRequest _self;
  final $Res Function(UpdateReportRequest) _then;

/// Create a copy of UpdateReportRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? category = freezed,Object? incidentType = freezed,Object? zone = freezed,Object? streetLandmark = freezed,Object? municipalityId = freezed,Object? barangayId = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? barangay = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
as String?,municipalityId: freezed == municipalityId ? _self.municipalityId : municipalityId // ignore: cast_nullable_to_non_nullable
as String?,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UpdateReportRequest].
extension UpdateReportRequestPatterns on UpdateReportRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UpdateReportRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UpdateReportRequest value)  $default,){
final _that = this;
switch (_that) {
case _UpdateReportRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UpdateReportRequest value)?  $default,){
final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id')  String? municipalityId, @JsonKey(name: 'barangay_id')  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? barangay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.incidentType,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.barangay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id')  String? municipalityId, @JsonKey(name: 'barangay_id')  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? barangay)  $default,) {final _that = this;
switch (_that) {
case _UpdateReportRequest():
return $default(_that.title,_that.description,_that.category,_that.incidentType,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.barangay);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'municipality_id')  String? municipalityId, @JsonKey(name: 'barangay_id')  String? barangayId, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? barangay)?  $default,) {final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.incidentType,_that.zone,_that.streetLandmark,_that.municipalityId,_that.barangayId,_that.cityMunicipality,_that.province,_that.barangay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateReportRequest implements UpdateReportRequest {
  const _UpdateReportRequest({this.title, this.description, this.category, @JsonKey(name: 'incident_type') this.incidentType, this.zone, @JsonKey(name: 'street_landmark') this.streetLandmark, @JsonKey(name: 'municipality_id') this.municipalityId, @JsonKey(name: 'barangay_id') this.barangayId, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, this.barangay});
  factory _UpdateReportRequest.fromJson(Map<String, dynamic> json) => _$UpdateReportRequestFromJson(json);

@override final  String? title;
@override final  String? description;
@override final  String? category;
@override@JsonKey(name: 'incident_type') final  String? incidentType;
@override final  String? zone;
@override@JsonKey(name: 'street_landmark') final  String? streetLandmark;
@override@JsonKey(name: 'municipality_id') final  String? municipalityId;
@override@JsonKey(name: 'barangay_id') final  String? barangayId;
@override@JsonKey(name: 'city_municipality') final  String? cityMunicipality;
@override final  String? province;
// Legacy
@override final  String? barangay;

/// Create a copy of UpdateReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UpdateReportRequestCopyWith<_UpdateReportRequest> get copyWith => __$UpdateReportRequestCopyWithImpl<_UpdateReportRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UpdateReportRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateReportRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.municipalityId, municipalityId) || other.municipalityId == municipalityId)&&(identical(other.barangayId, barangayId) || other.barangayId == barangayId)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.barangay, barangay) || other.barangay == barangay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,incidentType,zone,streetLandmark,municipalityId,barangayId,cityMunicipality,province,barangay);

@override
String toString() {
  return 'UpdateReportRequest(title: $title, description: $description, category: $category, incidentType: $incidentType, zone: $zone, streetLandmark: $streetLandmark, municipalityId: $municipalityId, barangayId: $barangayId, cityMunicipality: $cityMunicipality, province: $province, barangay: $barangay)';
}


}

/// @nodoc
abstract mixin class _$UpdateReportRequestCopyWith<$Res> implements $UpdateReportRequestCopyWith<$Res> {
  factory _$UpdateReportRequestCopyWith(_UpdateReportRequest value, $Res Function(_UpdateReportRequest) _then) = __$UpdateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description, String? category,@JsonKey(name: 'incident_type') String? incidentType, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'municipality_id') String? municipalityId,@JsonKey(name: 'barangay_id') String? barangayId,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? barangay
});




}
/// @nodoc
class __$UpdateReportRequestCopyWithImpl<$Res>
    implements _$UpdateReportRequestCopyWith<$Res> {
  __$UpdateReportRequestCopyWithImpl(this._self, this._then);

  final _UpdateReportRequest _self;
  final $Res Function(_UpdateReportRequest) _then;

/// Create a copy of UpdateReportRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? category = freezed,Object? incidentType = freezed,Object? zone = freezed,Object? streetLandmark = freezed,Object? municipalityId = freezed,Object? barangayId = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? barangay = freezed,}) {
  return _then(_UpdateReportRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
as String?,municipalityId: freezed == municipalityId ? _self.municipalityId : municipalityId // ignore: cast_nullable_to_non_nullable
as String?,barangayId: freezed == barangayId ? _self.barangayId : barangayId // ignore: cast_nullable_to_non_nullable
as String?,cityMunicipality: freezed == cityMunicipality ? _self.cityMunicipality : cityMunicipality // ignore: cast_nullable_to_non_nullable
as String?,province: freezed == province ? _self.province : province // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ReportStatusUpdateRequest {

 String get status;@JsonKey(name: 'admin_remarks') String? get adminRemarks;@JsonKey(name: 'assigned_department') String? get assignedDepartment;
/// Create a copy of ReportStatusUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportStatusUpdateRequestCopyWith<ReportStatusUpdateRequest> get copyWith => _$ReportStatusUpdateRequestCopyWithImpl<ReportStatusUpdateRequest>(this as ReportStatusUpdateRequest, _$identity);

  /// Serializes this ReportStatusUpdateRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportStatusUpdateRequest&&(identical(other.status, status) || other.status == status)&&(identical(other.adminRemarks, adminRemarks) || other.adminRemarks == adminRemarks)&&(identical(other.assignedDepartment, assignedDepartment) || other.assignedDepartment == assignedDepartment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,adminRemarks,assignedDepartment);

@override
String toString() {
  return 'ReportStatusUpdateRequest(status: $status, adminRemarks: $adminRemarks, assignedDepartment: $assignedDepartment)';
}


}

/// @nodoc
abstract mixin class $ReportStatusUpdateRequestCopyWith<$Res>  {
  factory $ReportStatusUpdateRequestCopyWith(ReportStatusUpdateRequest value, $Res Function(ReportStatusUpdateRequest) _then) = _$ReportStatusUpdateRequestCopyWithImpl;
@useResult
$Res call({
 String status,@JsonKey(name: 'admin_remarks') String? adminRemarks,@JsonKey(name: 'assigned_department') String? assignedDepartment
});




}
/// @nodoc
class _$ReportStatusUpdateRequestCopyWithImpl<$Res>
    implements $ReportStatusUpdateRequestCopyWith<$Res> {
  _$ReportStatusUpdateRequestCopyWithImpl(this._self, this._then);

  final ReportStatusUpdateRequest _self;
  final $Res Function(ReportStatusUpdateRequest) _then;

/// Create a copy of ReportStatusUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? status = null,Object? adminRemarks = freezed,Object? assignedDepartment = freezed,}) {
  return _then(_self.copyWith(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminRemarks: freezed == adminRemarks ? _self.adminRemarks : adminRemarks // ignore: cast_nullable_to_non_nullable
as String?,assignedDepartment: freezed == assignedDepartment ? _self.assignedDepartment : assignedDepartment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportStatusUpdateRequest].
extension ReportStatusUpdateRequestPatterns on ReportStatusUpdateRequest {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportStatusUpdateRequest value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportStatusUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportStatusUpdateRequest value)  $default,){
final _that = this;
switch (_that) {
case _ReportStatusUpdateRequest():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportStatusUpdateRequest value)?  $default,){
final _that = this;
switch (_that) {
case _ReportStatusUpdateRequest() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String status, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'assigned_department')  String? assignedDepartment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportStatusUpdateRequest() when $default != null:
return $default(_that.status,_that.adminRemarks,_that.assignedDepartment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String status, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'assigned_department')  String? assignedDepartment)  $default,) {final _that = this;
switch (_that) {
case _ReportStatusUpdateRequest():
return $default(_that.status,_that.adminRemarks,_that.assignedDepartment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String status, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'assigned_department')  String? assignedDepartment)?  $default,) {final _that = this;
switch (_that) {
case _ReportStatusUpdateRequest() when $default != null:
return $default(_that.status,_that.adminRemarks,_that.assignedDepartment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportStatusUpdateRequest implements ReportStatusUpdateRequest {
  const _ReportStatusUpdateRequest({required this.status, @JsonKey(name: 'admin_remarks') this.adminRemarks, @JsonKey(name: 'assigned_department') this.assignedDepartment});
  factory _ReportStatusUpdateRequest.fromJson(Map<String, dynamic> json) => _$ReportStatusUpdateRequestFromJson(json);

@override final  String status;
@override@JsonKey(name: 'admin_remarks') final  String? adminRemarks;
@override@JsonKey(name: 'assigned_department') final  String? assignedDepartment;

/// Create a copy of ReportStatusUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportStatusUpdateRequestCopyWith<_ReportStatusUpdateRequest> get copyWith => __$ReportStatusUpdateRequestCopyWithImpl<_ReportStatusUpdateRequest>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportStatusUpdateRequestToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportStatusUpdateRequest&&(identical(other.status, status) || other.status == status)&&(identical(other.adminRemarks, adminRemarks) || other.adminRemarks == adminRemarks)&&(identical(other.assignedDepartment, assignedDepartment) || other.assignedDepartment == assignedDepartment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,adminRemarks,assignedDepartment);

@override
String toString() {
  return 'ReportStatusUpdateRequest(status: $status, adminRemarks: $adminRemarks, assignedDepartment: $assignedDepartment)';
}


}

/// @nodoc
abstract mixin class _$ReportStatusUpdateRequestCopyWith<$Res> implements $ReportStatusUpdateRequestCopyWith<$Res> {
  factory _$ReportStatusUpdateRequestCopyWith(_ReportStatusUpdateRequest value, $Res Function(_ReportStatusUpdateRequest) _then) = __$ReportStatusUpdateRequestCopyWithImpl;
@override @useResult
$Res call({
 String status,@JsonKey(name: 'admin_remarks') String? adminRemarks,@JsonKey(name: 'assigned_department') String? assignedDepartment
});




}
/// @nodoc
class __$ReportStatusUpdateRequestCopyWithImpl<$Res>
    implements _$ReportStatusUpdateRequestCopyWith<$Res> {
  __$ReportStatusUpdateRequestCopyWithImpl(this._self, this._then);

  final _ReportStatusUpdateRequest _self;
  final $Res Function(_ReportStatusUpdateRequest) _then;

/// Create a copy of ReportStatusUpdateRequest
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? status = null,Object? adminRemarks = freezed,Object? assignedDepartment = freezed,}) {
  return _then(_ReportStatusUpdateRequest(
status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as String,adminRemarks: freezed == adminRemarks ? _self.adminRemarks : adminRemarks // ignore: cast_nullable_to_non_nullable
as String?,assignedDepartment: freezed == assignedDepartment ? _self.assignedDepartment : assignedDepartment // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PaginatedReports {

 List<Report> get results; int get count; int get total; int get page;@JsonKey(name: 'page_size') int get pageSize;@JsonKey(name: 'total_pages') int get totalPages;
/// Create a copy of PaginatedReports
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedReportsCopyWith<PaginatedReports> get copyWith => _$PaginatedReportsCopyWithImpl<PaginatedReports>(this as PaginatedReports, _$identity);

  /// Serializes this PaginatedReports to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedReports&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.count, count) || other.count == count)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),count,total,page,pageSize,totalPages);

@override
String toString() {
  return 'PaginatedReports(results: $results, count: $count, total: $total, page: $page, pageSize: $pageSize, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class $PaginatedReportsCopyWith<$Res>  {
  factory $PaginatedReportsCopyWith(PaginatedReports value, $Res Function(PaginatedReports) _then) = _$PaginatedReportsCopyWithImpl;
@useResult
$Res call({
 List<Report> results, int count, int total, int page,@JsonKey(name: 'page_size') int pageSize,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class _$PaginatedReportsCopyWithImpl<$Res>
    implements $PaginatedReportsCopyWith<$Res> {
  _$PaginatedReportsCopyWithImpl(this._self, this._then);

  final PaginatedReports _self;
  final $Res Function(PaginatedReports) _then;

/// Create a copy of PaginatedReports
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? count = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? totalPages = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Report>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedReports].
extension PaginatedReportsPatterns on PaginatedReports {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedReports value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedReports() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedReports value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedReports():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedReports value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedReports() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Report> results,  int count,  int total,  int page, @JsonKey(name: 'page_size')  int pageSize, @JsonKey(name: 'total_pages')  int totalPages)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedReports() when $default != null:
return $default(_that.results,_that.count,_that.total,_that.page,_that.pageSize,_that.totalPages);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Report> results,  int count,  int total,  int page, @JsonKey(name: 'page_size')  int pageSize, @JsonKey(name: 'total_pages')  int totalPages)  $default,) {final _that = this;
switch (_that) {
case _PaginatedReports():
return $default(_that.results,_that.count,_that.total,_that.page,_that.pageSize,_that.totalPages);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Report> results,  int count,  int total,  int page, @JsonKey(name: 'page_size')  int pageSize, @JsonKey(name: 'total_pages')  int totalPages)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedReports() when $default != null:
return $default(_that.results,_that.count,_that.total,_that.page,_that.pageSize,_that.totalPages);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedReports implements PaginatedReports {
  const _PaginatedReports({required final  List<Report> results, this.count = 0, this.total = 0, this.page = 1, @JsonKey(name: 'page_size') this.pageSize = 20, @JsonKey(name: 'total_pages') this.totalPages = 1}): _results = results;
  factory _PaginatedReports.fromJson(Map<String, dynamic> json) => _$PaginatedReportsFromJson(json);

 final  List<Report> _results;
@override List<Report> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int count;
@override@JsonKey() final  int total;
@override@JsonKey() final  int page;
@override@JsonKey(name: 'page_size') final  int pageSize;
@override@JsonKey(name: 'total_pages') final  int totalPages;

/// Create a copy of PaginatedReports
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedReportsCopyWith<_PaginatedReports> get copyWith => __$PaginatedReportsCopyWithImpl<_PaginatedReports>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedReportsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedReports&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.count, count) || other.count == count)&&(identical(other.total, total) || other.total == total)&&(identical(other.page, page) || other.page == page)&&(identical(other.pageSize, pageSize) || other.pageSize == pageSize)&&(identical(other.totalPages, totalPages) || other.totalPages == totalPages));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),count,total,page,pageSize,totalPages);

@override
String toString() {
  return 'PaginatedReports(results: $results, count: $count, total: $total, page: $page, pageSize: $pageSize, totalPages: $totalPages)';
}


}

/// @nodoc
abstract mixin class _$PaginatedReportsCopyWith<$Res> implements $PaginatedReportsCopyWith<$Res> {
  factory _$PaginatedReportsCopyWith(_PaginatedReports value, $Res Function(_PaginatedReports) _then) = __$PaginatedReportsCopyWithImpl;
@override @useResult
$Res call({
 List<Report> results, int count, int total, int page,@JsonKey(name: 'page_size') int pageSize,@JsonKey(name: 'total_pages') int totalPages
});




}
/// @nodoc
class __$PaginatedReportsCopyWithImpl<$Res>
    implements _$PaginatedReportsCopyWith<$Res> {
  __$PaginatedReportsCopyWithImpl(this._self, this._then);

  final _PaginatedReports _self;
  final $Res Function(_PaginatedReports) _then;

/// Create a copy of PaginatedReports
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? count = null,Object? total = null,Object? page = null,Object? pageSize = null,Object? totalPages = null,}) {
  return _then(_PaginatedReports(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Report>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,page: null == page ? _self.page : page // ignore: cast_nullable_to_non_nullable
as int,pageSize: null == pageSize ? _self.pageSize : pageSize // ignore: cast_nullable_to_non_nullable
as int,totalPages: null == totalPages ? _self.totalPages : totalPages // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReportStats {

 int get total;@JsonKey(name: 'by_status') Map<String, int>? get byStatus;@JsonKey(name: 'by_category') Map<String, int>? get byCategory;@JsonKey(name: 'by_severity') Map<String, int>? get bySeverity; int get emergencies;// Legacy flat fields
 int get submitted;@JsonKey(name: 'under_review') int get underReview; int get verified; int get assigned;@JsonKey(name: 'in_progress') int get inProgress; int get resolved; int get rejected;
/// Create a copy of ReportStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportStatsCopyWith<ReportStats> get copyWith => _$ReportStatsCopyWithImpl<ReportStats>(this as ReportStats, _$identity);

  /// Serializes this ReportStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportStats&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other.byStatus, byStatus)&&const DeepCollectionEquality().equals(other.byCategory, byCategory)&&const DeepCollectionEquality().equals(other.bySeverity, bySeverity)&&(identical(other.emergencies, emergencies) || other.emergencies == emergencies)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.underReview, underReview) || other.underReview == underReview)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.assigned, assigned) || other.assigned == assigned)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(byStatus),const DeepCollectionEquality().hash(byCategory),const DeepCollectionEquality().hash(bySeverity),emergencies,submitted,underReview,verified,assigned,inProgress,resolved,rejected);

@override
String toString() {
  return 'ReportStats(total: $total, byStatus: $byStatus, byCategory: $byCategory, bySeverity: $bySeverity, emergencies: $emergencies, submitted: $submitted, underReview: $underReview, verified: $verified, assigned: $assigned, inProgress: $inProgress, resolved: $resolved, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class $ReportStatsCopyWith<$Res>  {
  factory $ReportStatsCopyWith(ReportStats value, $Res Function(ReportStats) _then) = _$ReportStatsCopyWithImpl;
@useResult
$Res call({
 int total,@JsonKey(name: 'by_status') Map<String, int>? byStatus,@JsonKey(name: 'by_category') Map<String, int>? byCategory,@JsonKey(name: 'by_severity') Map<String, int>? bySeverity, int emergencies, int submitted,@JsonKey(name: 'under_review') int underReview, int verified, int assigned,@JsonKey(name: 'in_progress') int inProgress, int resolved, int rejected
});




}
/// @nodoc
class _$ReportStatsCopyWithImpl<$Res>
    implements $ReportStatsCopyWith<$Res> {
  _$ReportStatsCopyWithImpl(this._self, this._then);

  final ReportStats _self;
  final $Res Function(ReportStats) _then;

/// Create a copy of ReportStats
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? byStatus = freezed,Object? byCategory = freezed,Object? bySeverity = freezed,Object? emergencies = null,Object? submitted = null,Object? underReview = null,Object? verified = null,Object? assigned = null,Object? inProgress = null,Object? resolved = null,Object? rejected = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,byStatus: freezed == byStatus ? _self.byStatus : byStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,byCategory: freezed == byCategory ? _self.byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,bySeverity: freezed == bySeverity ? _self.bySeverity : bySeverity // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,emergencies: null == emergencies ? _self.emergencies : emergencies // ignore: cast_nullable_to_non_nullable
as int,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as int,underReview: null == underReview ? _self.underReview : underReview // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportStats].
extension ReportStatsPatterns on ReportStats {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportStats value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportStats() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportStats value)  $default,){
final _that = this;
switch (_that) {
case _ReportStats():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportStats value)?  $default,){
final _that = this;
switch (_that) {
case _ReportStats() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total, @JsonKey(name: 'by_status')  Map<String, int>? byStatus, @JsonKey(name: 'by_category')  Map<String, int>? byCategory, @JsonKey(name: 'by_severity')  Map<String, int>? bySeverity,  int emergencies,  int submitted, @JsonKey(name: 'under_review')  int underReview,  int verified,  int assigned, @JsonKey(name: 'in_progress')  int inProgress,  int resolved,  int rejected)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportStats() when $default != null:
return $default(_that.total,_that.byStatus,_that.byCategory,_that.bySeverity,_that.emergencies,_that.submitted,_that.underReview,_that.verified,_that.assigned,_that.inProgress,_that.resolved,_that.rejected);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total, @JsonKey(name: 'by_status')  Map<String, int>? byStatus, @JsonKey(name: 'by_category')  Map<String, int>? byCategory, @JsonKey(name: 'by_severity')  Map<String, int>? bySeverity,  int emergencies,  int submitted, @JsonKey(name: 'under_review')  int underReview,  int verified,  int assigned, @JsonKey(name: 'in_progress')  int inProgress,  int resolved,  int rejected)  $default,) {final _that = this;
switch (_that) {
case _ReportStats():
return $default(_that.total,_that.byStatus,_that.byCategory,_that.bySeverity,_that.emergencies,_that.submitted,_that.underReview,_that.verified,_that.assigned,_that.inProgress,_that.resolved,_that.rejected);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total, @JsonKey(name: 'by_status')  Map<String, int>? byStatus, @JsonKey(name: 'by_category')  Map<String, int>? byCategory, @JsonKey(name: 'by_severity')  Map<String, int>? bySeverity,  int emergencies,  int submitted, @JsonKey(name: 'under_review')  int underReview,  int verified,  int assigned, @JsonKey(name: 'in_progress')  int inProgress,  int resolved,  int rejected)?  $default,) {final _that = this;
switch (_that) {
case _ReportStats() when $default != null:
return $default(_that.total,_that.byStatus,_that.byCategory,_that.bySeverity,_that.emergencies,_that.submitted,_that.underReview,_that.verified,_that.assigned,_that.inProgress,_that.resolved,_that.rejected);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportStats implements ReportStats {
  const _ReportStats({this.total = 0, @JsonKey(name: 'by_status') final  Map<String, int>? byStatus, @JsonKey(name: 'by_category') final  Map<String, int>? byCategory, @JsonKey(name: 'by_severity') final  Map<String, int>? bySeverity, this.emergencies = 0, this.submitted = 0, @JsonKey(name: 'under_review') this.underReview = 0, this.verified = 0, this.assigned = 0, @JsonKey(name: 'in_progress') this.inProgress = 0, this.resolved = 0, this.rejected = 0}): _byStatus = byStatus,_byCategory = byCategory,_bySeverity = bySeverity;
  factory _ReportStats.fromJson(Map<String, dynamic> json) => _$ReportStatsFromJson(json);

@override@JsonKey() final  int total;
 final  Map<String, int>? _byStatus;
@override@JsonKey(name: 'by_status') Map<String, int>? get byStatus {
  final value = _byStatus;
  if (value == null) return null;
  if (_byStatus is EqualUnmodifiableMapView) return _byStatus;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, int>? _byCategory;
@override@JsonKey(name: 'by_category') Map<String, int>? get byCategory {
  final value = _byCategory;
  if (value == null) return null;
  if (_byCategory is EqualUnmodifiableMapView) return _byCategory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

 final  Map<String, int>? _bySeverity;
@override@JsonKey(name: 'by_severity') Map<String, int>? get bySeverity {
  final value = _bySeverity;
  if (value == null) return null;
  if (_bySeverity is EqualUnmodifiableMapView) return _bySeverity;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(value);
}

@override@JsonKey() final  int emergencies;
// Legacy flat fields
@override@JsonKey() final  int submitted;
@override@JsonKey(name: 'under_review') final  int underReview;
@override@JsonKey() final  int verified;
@override@JsonKey() final  int assigned;
@override@JsonKey(name: 'in_progress') final  int inProgress;
@override@JsonKey() final  int resolved;
@override@JsonKey() final  int rejected;

/// Create a copy of ReportStats
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportStatsCopyWith<_ReportStats> get copyWith => __$ReportStatsCopyWithImpl<_ReportStats>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportStatsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportStats&&(identical(other.total, total) || other.total == total)&&const DeepCollectionEquality().equals(other._byStatus, _byStatus)&&const DeepCollectionEquality().equals(other._byCategory, _byCategory)&&const DeepCollectionEquality().equals(other._bySeverity, _bySeverity)&&(identical(other.emergencies, emergencies) || other.emergencies == emergencies)&&(identical(other.submitted, submitted) || other.submitted == submitted)&&(identical(other.underReview, underReview) || other.underReview == underReview)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.assigned, assigned) || other.assigned == assigned)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.rejected, rejected) || other.rejected == rejected));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,const DeepCollectionEquality().hash(_byStatus),const DeepCollectionEquality().hash(_byCategory),const DeepCollectionEquality().hash(_bySeverity),emergencies,submitted,underReview,verified,assigned,inProgress,resolved,rejected);

@override
String toString() {
  return 'ReportStats(total: $total, byStatus: $byStatus, byCategory: $byCategory, bySeverity: $bySeverity, emergencies: $emergencies, submitted: $submitted, underReview: $underReview, verified: $verified, assigned: $assigned, inProgress: $inProgress, resolved: $resolved, rejected: $rejected)';
}


}

/// @nodoc
abstract mixin class _$ReportStatsCopyWith<$Res> implements $ReportStatsCopyWith<$Res> {
  factory _$ReportStatsCopyWith(_ReportStats value, $Res Function(_ReportStats) _then) = __$ReportStatsCopyWithImpl;
@override @useResult
$Res call({
 int total,@JsonKey(name: 'by_status') Map<String, int>? byStatus,@JsonKey(name: 'by_category') Map<String, int>? byCategory,@JsonKey(name: 'by_severity') Map<String, int>? bySeverity, int emergencies, int submitted,@JsonKey(name: 'under_review') int underReview, int verified, int assigned,@JsonKey(name: 'in_progress') int inProgress, int resolved, int rejected
});




}
/// @nodoc
class __$ReportStatsCopyWithImpl<$Res>
    implements _$ReportStatsCopyWith<$Res> {
  __$ReportStatsCopyWithImpl(this._self, this._then);

  final _ReportStats _self;
  final $Res Function(_ReportStats) _then;

/// Create a copy of ReportStats
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? byStatus = freezed,Object? byCategory = freezed,Object? bySeverity = freezed,Object? emergencies = null,Object? submitted = null,Object? underReview = null,Object? verified = null,Object? assigned = null,Object? inProgress = null,Object? resolved = null,Object? rejected = null,}) {
  return _then(_ReportStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,byStatus: freezed == byStatus ? _self._byStatus : byStatus // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,byCategory: freezed == byCategory ? _self._byCategory : byCategory // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,bySeverity: freezed == bySeverity ? _self._bySeverity : bySeverity // ignore: cast_nullable_to_non_nullable
as Map<String, int>?,emergencies: null == emergencies ? _self.emergencies : emergencies // ignore: cast_nullable_to_non_nullable
as int,submitted: null == submitted ? _self.submitted : submitted // ignore: cast_nullable_to_non_nullable
as int,underReview: null == underReview ? _self.underReview : underReview // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$ReportFormOptions {

@JsonKey(name: 'taxonomy_version') String get taxonomyVersion;@JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson) List<ReportCategoryOption> get categories; List<Map<String, dynamic>> get statuses;@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> get severityLevels;
/// Create a copy of ReportFormOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFormOptionsCopyWith<ReportFormOptions> get copyWith => _$ReportFormOptionsCopyWithImpl<ReportFormOptions>(this as ReportFormOptions, _$identity);

  /// Serializes this ReportFormOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFormOptions&&(identical(other.taxonomyVersion, taxonomyVersion) || other.taxonomyVersion == taxonomyVersion)&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.severityLevels, severityLevels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taxonomyVersion,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(severityLevels));

@override
String toString() {
  return 'ReportFormOptions(taxonomyVersion: $taxonomyVersion, categories: $categories, statuses: $statuses, severityLevels: $severityLevels)';
}


}

/// @nodoc
abstract mixin class $ReportFormOptionsCopyWith<$Res>  {
  factory $ReportFormOptionsCopyWith(ReportFormOptions value, $Res Function(ReportFormOptions) _then) = _$ReportFormOptionsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'taxonomy_version') String taxonomyVersion,@JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson) List<ReportCategoryOption> categories, List<Map<String, dynamic>> statuses,@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> severityLevels
});




}
/// @nodoc
class _$ReportFormOptionsCopyWithImpl<$Res>
    implements $ReportFormOptionsCopyWith<$Res> {
  _$ReportFormOptionsCopyWithImpl(this._self, this._then);

  final ReportFormOptions _self;
  final $Res Function(ReportFormOptions) _then;

/// Create a copy of ReportFormOptions
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? taxonomyVersion = null,Object? categories = null,Object? statuses = null,Object? severityLevels = null,}) {
  return _then(_self.copyWith(
taxonomyVersion: null == taxonomyVersion ? _self.taxonomyVersion : taxonomyVersion // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<ReportCategoryOption>,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,severityLevels: null == severityLevels ? _self.severityLevels : severityLevels // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}

}


/// Adds pattern-matching-related methods to [ReportFormOptions].
extension ReportFormOptionsPatterns on ReportFormOptions {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ReportFormOptions value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ReportFormOptions() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ReportFormOptions value)  $default,){
final _that = this;
switch (_that) {
case _ReportFormOptions():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ReportFormOptions value)?  $default,){
final _that = this;
switch (_that) {
case _ReportFormOptions() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'taxonomy_version')  String taxonomyVersion, @JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson)  List<ReportCategoryOption> categories,  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels')  List<Map<String, dynamic>> severityLevels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFormOptions() when $default != null:
return $default(_that.taxonomyVersion,_that.categories,_that.statuses,_that.severityLevels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'taxonomy_version')  String taxonomyVersion, @JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson)  List<ReportCategoryOption> categories,  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels')  List<Map<String, dynamic>> severityLevels)  $default,) {final _that = this;
switch (_that) {
case _ReportFormOptions():
return $default(_that.taxonomyVersion,_that.categories,_that.statuses,_that.severityLevels);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'taxonomy_version')  String taxonomyVersion, @JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson)  List<ReportCategoryOption> categories,  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels')  List<Map<String, dynamic>> severityLevels)?  $default,) {final _that = this;
switch (_that) {
case _ReportFormOptions() when $default != null:
return $default(_that.taxonomyVersion,_that.categories,_that.statuses,_that.severityLevels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportFormOptions implements ReportFormOptions {
  const _ReportFormOptions({@JsonKey(name: 'taxonomy_version') this.taxonomyVersion = 'taxonomy_v1', @JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson) required final  List<ReportCategoryOption> categories, required final  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels') required final  List<Map<String, dynamic>> severityLevels}): _categories = categories,_statuses = statuses,_severityLevels = severityLevels;
  factory _ReportFormOptions.fromJson(Map<String, dynamic> json) => _$ReportFormOptionsFromJson(json);

@override@JsonKey(name: 'taxonomy_version') final  String taxonomyVersion;
 final  List<ReportCategoryOption> _categories;
@override@JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson) List<ReportCategoryOption> get categories {
  if (_categories is EqualUnmodifiableListView) return _categories;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_categories);
}

 final  List<Map<String, dynamic>> _statuses;
@override List<Map<String, dynamic>> get statuses {
  if (_statuses is EqualUnmodifiableListView) return _statuses;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_statuses);
}

 final  List<Map<String, dynamic>> _severityLevels;
@override@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> get severityLevels {
  if (_severityLevels is EqualUnmodifiableListView) return _severityLevels;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_severityLevels);
}


/// Create a copy of ReportFormOptions
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ReportFormOptionsCopyWith<_ReportFormOptions> get copyWith => __$ReportFormOptionsCopyWithImpl<_ReportFormOptions>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ReportFormOptionsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFormOptions&&(identical(other.taxonomyVersion, taxonomyVersion) || other.taxonomyVersion == taxonomyVersion)&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._severityLevels, _severityLevels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,taxonomyVersion,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_severityLevels));

@override
String toString() {
  return 'ReportFormOptions(taxonomyVersion: $taxonomyVersion, categories: $categories, statuses: $statuses, severityLevels: $severityLevels)';
}


}

/// @nodoc
abstract mixin class _$ReportFormOptionsCopyWith<$Res> implements $ReportFormOptionsCopyWith<$Res> {
  factory _$ReportFormOptionsCopyWith(_ReportFormOptions value, $Res Function(_ReportFormOptions) _then) = __$ReportFormOptionsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'taxonomy_version') String taxonomyVersion,@JsonKey(fromJson: _categoryOptionsFromJson, toJson: _categoryOptionsToJson) List<ReportCategoryOption> categories, List<Map<String, dynamic>> statuses,@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> severityLevels
});




}
/// @nodoc
class __$ReportFormOptionsCopyWithImpl<$Res>
    implements _$ReportFormOptionsCopyWith<$Res> {
  __$ReportFormOptionsCopyWithImpl(this._self, this._then);

  final _ReportFormOptions _self;
  final $Res Function(_ReportFormOptions) _then;

/// Create a copy of ReportFormOptions
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? taxonomyVersion = null,Object? categories = null,Object? statuses = null,Object? severityLevels = null,}) {
  return _then(_ReportFormOptions(
taxonomyVersion: null == taxonomyVersion ? _self.taxonomyVersion : taxonomyVersion // ignore: cast_nullable_to_non_nullable
as String,categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<ReportCategoryOption>,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,severityLevels: null == severityLevels ? _self._severityLevels : severityLevels // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on

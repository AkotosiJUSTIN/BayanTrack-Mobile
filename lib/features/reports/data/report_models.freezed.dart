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

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId; String get url;@JsonKey(name: 's3_key') String? get s3Key; String? get filename;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'mime_type') String? get mimeType; int? get width; int? get height;@JsonKey(name: 'is_primary') bool get isPrimary;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of ReportImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportImageCopyWith<ReportImage> get copyWith => _$ReportImageCopyWithImpl<ReportImage>(this as ReportImage, _$identity);

  /// Serializes this ReportImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,url,s3Key,filename,fileSize,mimeType,width,height,isPrimary,createdAt,updatedAt);

@override
String toString() {
  return 'ReportImage(id: $id, reportId: $reportId, userId: $userId, url: $url, s3Key: $s3Key, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, width: $width, height: $height, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReportImageCopyWith<$Res>  {
  factory $ReportImageCopyWith(ReportImage value, $Res Function(ReportImage) _then) = _$ReportImageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String url,@JsonKey(name: 's3_key') String? s3Key, String? filename,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, int? width, int? height,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? url = null,Object? s3Key = freezed,Object? filename = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? width = freezed,Object? height = freezed,Object? isPrimary = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
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
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportImage() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _ReportImage():
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _ReportImage() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportImage implements ReportImage {
  const _ReportImage({required this.id, @JsonKey(name: 'report_id') this.reportId, @JsonKey(name: 'user_id') this.userId, required this.url, @JsonKey(name: 's3_key') this.s3Key, this.filename, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'mime_type') this.mimeType, this.width, this.height, @JsonKey(name: 'is_primary') this.isPrimary = false, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,url,s3Key,filename,fileSize,mimeType,width,height,isPrimary,createdAt,updatedAt);

@override
String toString() {
  return 'ReportImage(id: $id, reportId: $reportId, userId: $userId, url: $url, s3Key: $s3Key, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, width: $width, height: $height, isPrimary: $isPrimary, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportImageCopyWith<$Res> implements $ReportImageCopyWith<$Res> {
  factory _$ReportImageCopyWith(_ReportImage value, $Res Function(_ReportImage) _then) = __$ReportImageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String url,@JsonKey(name: 's3_key') String? s3Key, String? filename,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, int? width, int? height,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? url = null,Object? s3Key = freezed,Object? filename = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? width = freezed,Object? height = freezed,Object? isPrimary = null,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
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
as bool,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$Report {

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId;// Report Details
 String? get category;@JsonKey(name: 'incident_type') String? get incidentType; String? get title; String get description;@JsonKey(name: 'incident_datetime') String? get incidentDatetime;@JsonKey(name: 'is_happening_now') bool get isHappeningNow;// Location Information
 String? get zone;@JsonKey(name: 'street_landmark') String? get streetLandmark;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province; String? get latitude; String? get longitude;@JsonKey(name: 'location_accuracy') String get locationAccuracy;// Legacy fields
 String? get location; String? get barangay;// Severity & Impact
 String get severity;@JsonKey(name: 'people_affected') int? get peopleAffected;@JsonKey(name: 'is_emergency') bool get isEmergency;// System Fields
 String get status;@JsonKey(name: 'assigned_department') String? get assignedDepartment;@JsonKey(name: 'admin_remarks') String? get adminRemarks;// AI Fields
@JsonKey(name: 'category_confidence') double? get categoryConfidence; String? get priority;@JsonKey(name: 'priority_score') int? get priorityScore;@JsonKey(name: 'urgency_score') double? get urgencyScore;@JsonKey(name: 'duplicate_state') String? get duplicateState;@JsonKey(name: 'related_report_id') String? get relatedReportId;@JsonKey(name: 'related_issue_id') String? get relatedIssueId;@JsonKey(name: 'sentiment_score') double? get sentimentScore;@JsonKey(name: 'auto_category_suggestion') String? get autoCategorySuggestion;// Images
 List<ReportImage> get images;// Timestamps
@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;@JsonKey(name: 'submitted_at') String? get submittedAt;@JsonKey(name: 'verified_at') String? get verifiedAt;@JsonKey(name: 'resolved_at') String? get resolvedAt;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedDepartment, assignedDepartment) || other.assignedDepartment == assignedDepartment)&&(identical(other.adminRemarks, adminRemarks) || other.adminRemarks == adminRemarks)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.urgencyScore, urgencyScore) || other.urgencyScore == urgencyScore)&&(identical(other.duplicateState, duplicateState) || other.duplicateState == duplicateState)&&(identical(other.relatedReportId, relatedReportId) || other.relatedReportId == relatedReportId)&&(identical(other.relatedIssueId, relatedIssueId) || other.relatedIssueId == relatedIssueId)&&(identical(other.sentimentScore, sentimentScore) || other.sentimentScore == sentimentScore)&&(identical(other.autoCategorySuggestion, autoCategorySuggestion) || other.autoCategorySuggestion == autoCategorySuggestion)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportId,userId,category,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,severity,peopleAffected,isEmergency,status,assignedDepartment,adminRemarks,categoryConfidence,priority,priorityScore,urgencyScore,duplicateState,relatedReportId,relatedIssueId,sentimentScore,autoCategorySuggestion,const DeepCollectionEquality().hash(images),createdAt,updatedAt,submittedAt,verifiedAt,resolvedAt]);

@override
String toString() {
  return 'Report(id: $id, reportId: $reportId, userId: $userId, category: $category, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, status: $status, assignedDepartment: $assignedDepartment, adminRemarks: $adminRemarks, categoryConfidence: $categoryConfidence, priority: $priority, priorityScore: $priorityScore, urgencyScore: $urgencyScore, duplicateState: $duplicateState, relatedReportId: $relatedReportId, relatedIssueId: $relatedIssueId, sentimentScore: $sentimentScore, autoCategorySuggestion: $autoCategorySuggestion, images: $images, createdAt: $createdAt, updatedAt: $updatedAt, submittedAt: $submittedAt, verifiedAt: $verifiedAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String? category,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay, String severity,@JsonKey(name: 'people_affected') int? peopleAffected,@JsonKey(name: 'is_emergency') bool isEmergency, String status,@JsonKey(name: 'assigned_department') String? assignedDepartment,@JsonKey(name: 'admin_remarks') String? adminRemarks,@JsonKey(name: 'category_confidence') double? categoryConfidence, String? priority,@JsonKey(name: 'priority_score') int? priorityScore,@JsonKey(name: 'urgency_score') double? urgencyScore,@JsonKey(name: 'duplicate_state') String? duplicateState,@JsonKey(name: 'related_report_id') String? relatedReportId,@JsonKey(name: 'related_issue_id') String? relatedIssueId,@JsonKey(name: 'sentiment_score') double? sentimentScore,@JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion, List<ReportImage> images,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'resolved_at') String? resolvedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? category = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? severity = null,Object? peopleAffected = freezed,Object? isEmergency = null,Object? status = null,Object? assignedDepartment = freezed,Object? adminRemarks = freezed,Object? categoryConfidence = freezed,Object? priority = freezed,Object? priorityScore = freezed,Object? urgencyScore = freezed,Object? duplicateState = freezed,Object? relatedReportId = freezed,Object? relatedIssueId = freezed,Object? sentimentScore = freezed,Object? autoCategorySuggestion = freezed,Object? images = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? resolvedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
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
as double?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,priorityScore: freezed == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int?,urgencyScore: freezed == urgencyScore ? _self.urgencyScore : urgencyScore // ignore: cast_nullable_to_non_nullable
as double?,duplicateState: freezed == duplicateState ? _self.duplicateState : duplicateState // ignore: cast_nullable_to_non_nullable
as String?,relatedReportId: freezed == relatedReportId ? _self.relatedReportId : relatedReportId // ignore: cast_nullable_to_non_nullable
as String?,relatedIssueId: freezed == relatedIssueId ? _self.relatedIssueId : relatedIssueId // ignore: cast_nullable_to_non_nullable
as String?,sentimentScore: freezed == sentimentScore ? _self.sentimentScore : sentimentScore // ignore: cast_nullable_to_non_nullable
as double?,autoCategorySuggestion: freezed == autoCategorySuggestion ? _self.autoCategorySuggestion : autoCategorySuggestion // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ReportImage>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency,  String status, @JsonKey(name: 'assigned_department')  String? assignedDepartment, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'category_confidence')  double? categoryConfidence,  String? priority, @JsonKey(name: 'priority_score')  int? priorityScore, @JsonKey(name: 'urgency_score')  double? urgencyScore, @JsonKey(name: 'duplicate_state')  String? duplicateState, @JsonKey(name: 'related_report_id')  String? relatedReportId, @JsonKey(name: 'related_issue_id')  String? relatedIssueId, @JsonKey(name: 'sentiment_score')  double? sentimentScore, @JsonKey(name: 'auto_category_suggestion')  String? autoCategorySuggestion,  List<ReportImage> images, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'resolved_at')  String? resolvedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.status,_that.assignedDepartment,_that.adminRemarks,_that.categoryConfidence,_that.priority,_that.priorityScore,_that.urgencyScore,_that.duplicateState,_that.relatedReportId,_that.relatedIssueId,_that.sentimentScore,_that.autoCategorySuggestion,_that.images,_that.createdAt,_that.updatedAt,_that.submittedAt,_that.verifiedAt,_that.resolvedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency,  String status, @JsonKey(name: 'assigned_department')  String? assignedDepartment, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'category_confidence')  double? categoryConfidence,  String? priority, @JsonKey(name: 'priority_score')  int? priorityScore, @JsonKey(name: 'urgency_score')  double? urgencyScore, @JsonKey(name: 'duplicate_state')  String? duplicateState, @JsonKey(name: 'related_report_id')  String? relatedReportId, @JsonKey(name: 'related_issue_id')  String? relatedIssueId, @JsonKey(name: 'sentiment_score')  double? sentimentScore, @JsonKey(name: 'auto_category_suggestion')  String? autoCategorySuggestion,  List<ReportImage> images, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'resolved_at')  String? resolvedAt)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.reportId,_that.userId,_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.status,_that.assignedDepartment,_that.adminRemarks,_that.categoryConfidence,_that.priority,_that.priorityScore,_that.urgencyScore,_that.duplicateState,_that.relatedReportId,_that.relatedIssueId,_that.sentimentScore,_that.autoCategorySuggestion,_that.images,_that.createdAt,_that.updatedAt,_that.submittedAt,_that.verifiedAt,_that.resolvedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency,  String status, @JsonKey(name: 'assigned_department')  String? assignedDepartment, @JsonKey(name: 'admin_remarks')  String? adminRemarks, @JsonKey(name: 'category_confidence')  double? categoryConfidence,  String? priority, @JsonKey(name: 'priority_score')  int? priorityScore, @JsonKey(name: 'urgency_score')  double? urgencyScore, @JsonKey(name: 'duplicate_state')  String? duplicateState, @JsonKey(name: 'related_report_id')  String? relatedReportId, @JsonKey(name: 'related_issue_id')  String? relatedIssueId, @JsonKey(name: 'sentiment_score')  double? sentimentScore, @JsonKey(name: 'auto_category_suggestion')  String? autoCategorySuggestion,  List<ReportImage> images, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'submitted_at')  String? submittedAt, @JsonKey(name: 'verified_at')  String? verifiedAt, @JsonKey(name: 'resolved_at')  String? resolvedAt)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.status,_that.assignedDepartment,_that.adminRemarks,_that.categoryConfidence,_that.priority,_that.priorityScore,_that.urgencyScore,_that.duplicateState,_that.relatedReportId,_that.relatedIssueId,_that.sentimentScore,_that.autoCategorySuggestion,_that.images,_that.createdAt,_that.updatedAt,_that.submittedAt,_that.verifiedAt,_that.resolvedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.id, @JsonKey(name: 'report_id') this.reportId, @JsonKey(name: 'user_id') this.userId, this.category, @JsonKey(name: 'incident_type') this.incidentType, this.title, required this.description, @JsonKey(name: 'incident_datetime') this.incidentDatetime, @JsonKey(name: 'is_happening_now') this.isHappeningNow = false, this.zone, @JsonKey(name: 'street_landmark') this.streetLandmark, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, this.latitude, this.longitude, @JsonKey(name: 'location_accuracy') this.locationAccuracy = 'approximate', this.location, this.barangay, this.severity = 'medium', @JsonKey(name: 'people_affected') this.peopleAffected, @JsonKey(name: 'is_emergency') this.isEmergency = false, this.status = 'submitted', @JsonKey(name: 'assigned_department') this.assignedDepartment, @JsonKey(name: 'admin_remarks') this.adminRemarks, @JsonKey(name: 'category_confidence') this.categoryConfidence, this.priority, @JsonKey(name: 'priority_score') this.priorityScore, @JsonKey(name: 'urgency_score') this.urgencyScore, @JsonKey(name: 'duplicate_state') this.duplicateState, @JsonKey(name: 'related_report_id') this.relatedReportId, @JsonKey(name: 'related_issue_id') this.relatedIssueId, @JsonKey(name: 'sentiment_score') this.sentimentScore, @JsonKey(name: 'auto_category_suggestion') this.autoCategorySuggestion, final  List<ReportImage> images = const [], @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'submitted_at') this.submittedAt, @JsonKey(name: 'verified_at') this.verifiedAt, @JsonKey(name: 'resolved_at') this.resolvedAt}): _images = images;
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String id;
@override@JsonKey(name: 'report_id') final  String? reportId;
@override@JsonKey(name: 'user_id') final  String? userId;
// Report Details
@override final  String? category;
@override@JsonKey(name: 'incident_type') final  String? incidentType;
@override final  String? title;
@override final  String description;
@override@JsonKey(name: 'incident_datetime') final  String? incidentDatetime;
@override@JsonKey(name: 'is_happening_now') final  bool isHappeningNow;
// Location Information
@override final  String? zone;
@override@JsonKey(name: 'street_landmark') final  String? streetLandmark;
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
@override@JsonKey(name: 'people_affected') final  int? peopleAffected;
@override@JsonKey(name: 'is_emergency') final  bool isEmergency;
// System Fields
@override@JsonKey() final  String status;
@override@JsonKey(name: 'assigned_department') final  String? assignedDepartment;
@override@JsonKey(name: 'admin_remarks') final  String? adminRemarks;
// AI Fields
@override@JsonKey(name: 'category_confidence') final  double? categoryConfidence;
@override final  String? priority;
@override@JsonKey(name: 'priority_score') final  int? priorityScore;
@override@JsonKey(name: 'urgency_score') final  double? urgencyScore;
@override@JsonKey(name: 'duplicate_state') final  String? duplicateState;
@override@JsonKey(name: 'related_report_id') final  String? relatedReportId;
@override@JsonKey(name: 'related_issue_id') final  String? relatedIssueId;
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

// Timestamps
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;
@override@JsonKey(name: 'submitted_at') final  String? submittedAt;
@override@JsonKey(name: 'verified_at') final  String? verifiedAt;
@override@JsonKey(name: 'resolved_at') final  String? resolvedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.status, status) || other.status == status)&&(identical(other.assignedDepartment, assignedDepartment) || other.assignedDepartment == assignedDepartment)&&(identical(other.adminRemarks, adminRemarks) || other.adminRemarks == adminRemarks)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.urgencyScore, urgencyScore) || other.urgencyScore == urgencyScore)&&(identical(other.duplicateState, duplicateState) || other.duplicateState == duplicateState)&&(identical(other.relatedReportId, relatedReportId) || other.relatedReportId == relatedReportId)&&(identical(other.relatedIssueId, relatedIssueId) || other.relatedIssueId == relatedIssueId)&&(identical(other.sentimentScore, sentimentScore) || other.sentimentScore == sentimentScore)&&(identical(other.autoCategorySuggestion, autoCategorySuggestion) || other.autoCategorySuggestion == autoCategorySuggestion)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.submittedAt, submittedAt) || other.submittedAt == submittedAt)&&(identical(other.verifiedAt, verifiedAt) || other.verifiedAt == verifiedAt)&&(identical(other.resolvedAt, resolvedAt) || other.resolvedAt == resolvedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,id,reportId,userId,category,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,severity,peopleAffected,isEmergency,status,assignedDepartment,adminRemarks,categoryConfidence,priority,priorityScore,urgencyScore,duplicateState,relatedReportId,relatedIssueId,sentimentScore,autoCategorySuggestion,const DeepCollectionEquality().hash(_images),createdAt,updatedAt,submittedAt,verifiedAt,resolvedAt]);

@override
String toString() {
  return 'Report(id: $id, reportId: $reportId, userId: $userId, category: $category, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, status: $status, assignedDepartment: $assignedDepartment, adminRemarks: $adminRemarks, categoryConfidence: $categoryConfidence, priority: $priority, priorityScore: $priorityScore, urgencyScore: $urgencyScore, duplicateState: $duplicateState, relatedReportId: $relatedReportId, relatedIssueId: $relatedIssueId, sentimentScore: $sentimentScore, autoCategorySuggestion: $autoCategorySuggestion, images: $images, createdAt: $createdAt, updatedAt: $updatedAt, submittedAt: $submittedAt, verifiedAt: $verifiedAt, resolvedAt: $resolvedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String? category,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay, String severity,@JsonKey(name: 'people_affected') int? peopleAffected,@JsonKey(name: 'is_emergency') bool isEmergency, String status,@JsonKey(name: 'assigned_department') String? assignedDepartment,@JsonKey(name: 'admin_remarks') String? adminRemarks,@JsonKey(name: 'category_confidence') double? categoryConfidence, String? priority,@JsonKey(name: 'priority_score') int? priorityScore,@JsonKey(name: 'urgency_score') double? urgencyScore,@JsonKey(name: 'duplicate_state') String? duplicateState,@JsonKey(name: 'related_report_id') String? relatedReportId,@JsonKey(name: 'related_issue_id') String? relatedIssueId,@JsonKey(name: 'sentiment_score') double? sentimentScore,@JsonKey(name: 'auto_category_suggestion') String? autoCategorySuggestion, List<ReportImage> images,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'submitted_at') String? submittedAt,@JsonKey(name: 'verified_at') String? verifiedAt,@JsonKey(name: 'resolved_at') String? resolvedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? category = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? severity = null,Object? peopleAffected = freezed,Object? isEmergency = null,Object? status = null,Object? assignedDepartment = freezed,Object? adminRemarks = freezed,Object? categoryConfidence = freezed,Object? priority = freezed,Object? priorityScore = freezed,Object? urgencyScore = freezed,Object? duplicateState = freezed,Object? relatedReportId = freezed,Object? relatedIssueId = freezed,Object? sentimentScore = freezed,Object? autoCategorySuggestion = freezed,Object? images = null,Object? createdAt = freezed,Object? updatedAt = freezed,Object? submittedAt = freezed,Object? verifiedAt = freezed,Object? resolvedAt = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
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
as double?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,priorityScore: freezed == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int?,urgencyScore: freezed == urgencyScore ? _self.urgencyScore : urgencyScore // ignore: cast_nullable_to_non_nullable
as double?,duplicateState: freezed == duplicateState ? _self.duplicateState : duplicateState // ignore: cast_nullable_to_non_nullable
as String?,relatedReportId: freezed == relatedReportId ? _self.relatedReportId : relatedReportId // ignore: cast_nullable_to_non_nullable
as String?,relatedIssueId: freezed == relatedIssueId ? _self.relatedIssueId : relatedIssueId // ignore: cast_nullable_to_non_nullable
as String?,sentimentScore: freezed == sentimentScore ? _self.sentimentScore : sentimentScore // ignore: cast_nullable_to_non_nullable
as double?,autoCategorySuggestion: freezed == autoCategorySuggestion ? _self.autoCategorySuggestion : autoCategorySuggestion // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ReportImage>,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,submittedAt: freezed == submittedAt ? _self.submittedAt : submittedAt // ignore: cast_nullable_to_non_nullable
as String?,verifiedAt: freezed == verifiedAt ? _self.verifiedAt : verifiedAt // ignore: cast_nullable_to_non_nullable
as String?,resolvedAt: freezed == resolvedAt ? _self.resolvedAt : resolvedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateReportRequest {

// Report Details (Section A)
 String? get category;@JsonKey(name: 'incident_type') String? get incidentType; String? get title; String get description;@JsonKey(name: 'incident_datetime') String? get incidentDatetime;@JsonKey(name: 'is_happening_now') bool get isHappeningNow;// Location Information (Section B)
 String? get zone;@JsonKey(name: 'street_landmark') String? get streetLandmark;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province; String? get latitude; String? get longitude;@JsonKey(name: 'location_accuracy') String get locationAccuracy;// Legacy fields for backwards compatibility
 String? get location; String? get barangay;// Severity & Impact (Section C)
 String get severity;@JsonKey(name: 'people_affected') int? get peopleAffected;@JsonKey(name: 'is_emergency') bool get isEmergency;// Consent & Declaration (Section D)
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReportRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.declarationConfirmed, declarationConfirmed) || other.declarationConfirmed == declarationConfirmed)&&(identical(other.dataProcessingConsent, dataProcessingConsent) || other.dataProcessingConsent == dataProcessingConsent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,category,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,severity,peopleAffected,isEmergency,declarationConfirmed,dataProcessingConsent]);

@override
String toString() {
  return 'CreateReportRequest(category: $category, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, declarationConfirmed: $declarationConfirmed, dataProcessingConsent: $dataProcessingConsent)';
}


}

/// @nodoc
abstract mixin class $CreateReportRequestCopyWith<$Res>  {
  factory $CreateReportRequestCopyWith(CreateReportRequest value, $Res Function(CreateReportRequest) _then) = _$CreateReportRequestCopyWithImpl;
@useResult
$Res call({
 String? category,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay, String severity,@JsonKey(name: 'people_affected') int? peopleAffected,@JsonKey(name: 'is_emergency') bool isEmergency,@JsonKey(name: 'declaration_confirmed') bool declarationConfirmed,@JsonKey(name: 'data_processing_consent') bool dataProcessingConsent
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
@pragma('vm:prefer-inline') @override $Res call({Object? category = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? severity = null,Object? peopleAffected = freezed,Object? isEmergency = null,Object? declarationConfirmed = null,Object? dataProcessingConsent = null,}) {
  return _then(_self.copyWith(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
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
as bool,declarationConfirmed: null == declarationConfirmed ? _self.declarationConfirmed : declarationConfirmed // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency, @JsonKey(name: 'declaration_confirmed')  bool declarationConfirmed, @JsonKey(name: 'data_processing_consent')  bool dataProcessingConsent)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.declarationConfirmed,_that.dataProcessingConsent);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency, @JsonKey(name: 'declaration_confirmed')  bool declarationConfirmed, @JsonKey(name: 'data_processing_consent')  bool dataProcessingConsent)  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest():
return $default(_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.declarationConfirmed,_that.dataProcessingConsent);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? title,  String description, @JsonKey(name: 'incident_datetime')  String? incidentDatetime, @JsonKey(name: 'is_happening_now')  bool isHappeningNow,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? latitude,  String? longitude, @JsonKey(name: 'location_accuracy')  String locationAccuracy,  String? location,  String? barangay,  String severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool isEmergency, @JsonKey(name: 'declaration_confirmed')  bool declarationConfirmed, @JsonKey(name: 'data_processing_consent')  bool dataProcessingConsent)?  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.category,_that.incidentType,_that.title,_that.description,_that.incidentDatetime,_that.isHappeningNow,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.latitude,_that.longitude,_that.locationAccuracy,_that.location,_that.barangay,_that.severity,_that.peopleAffected,_that.isEmergency,_that.declarationConfirmed,_that.dataProcessingConsent);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateReportRequest implements CreateReportRequest {
  const _CreateReportRequest({this.category, @JsonKey(name: 'incident_type') this.incidentType, this.title, required this.description, @JsonKey(name: 'incident_datetime') this.incidentDatetime, @JsonKey(name: 'is_happening_now') this.isHappeningNow = false, this.zone, @JsonKey(name: 'street_landmark') this.streetLandmark, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, this.latitude, this.longitude, @JsonKey(name: 'location_accuracy') this.locationAccuracy = 'approximate', this.location, this.barangay, this.severity = 'medium', @JsonKey(name: 'people_affected') this.peopleAffected, @JsonKey(name: 'is_emergency') this.isEmergency = false, @JsonKey(name: 'declaration_confirmed') this.declarationConfirmed = true, @JsonKey(name: 'data_processing_consent') this.dataProcessingConsent = true});
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
@override@JsonKey(name: 'city_municipality') final  String? cityMunicipality;
@override final  String? province;
@override final  String? latitude;
@override final  String? longitude;
@override@JsonKey(name: 'location_accuracy') final  String locationAccuracy;
// Legacy fields for backwards compatibility
@override final  String? location;
@override final  String? barangay;
// Severity & Impact (Section C)
@override@JsonKey() final  String severity;
@override@JsonKey(name: 'people_affected') final  int? peopleAffected;
@override@JsonKey(name: 'is_emergency') final  bool isEmergency;
// Consent & Declaration (Section D)
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReportRequest&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.incidentDatetime, incidentDatetime) || other.incidentDatetime == incidentDatetime)&&(identical(other.isHappeningNow, isHappeningNow) || other.isHappeningNow == isHappeningNow)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.locationAccuracy, locationAccuracy) || other.locationAccuracy == locationAccuracy)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.declarationConfirmed, declarationConfirmed) || other.declarationConfirmed == declarationConfirmed)&&(identical(other.dataProcessingConsent, dataProcessingConsent) || other.dataProcessingConsent == dataProcessingConsent));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hashAll([runtimeType,category,incidentType,title,description,incidentDatetime,isHappeningNow,zone,streetLandmark,cityMunicipality,province,latitude,longitude,locationAccuracy,location,barangay,severity,peopleAffected,isEmergency,declarationConfirmed,dataProcessingConsent]);

@override
String toString() {
  return 'CreateReportRequest(category: $category, incidentType: $incidentType, title: $title, description: $description, incidentDatetime: $incidentDatetime, isHappeningNow: $isHappeningNow, zone: $zone, streetLandmark: $streetLandmark, cityMunicipality: $cityMunicipality, province: $province, latitude: $latitude, longitude: $longitude, locationAccuracy: $locationAccuracy, location: $location, barangay: $barangay, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, declarationConfirmed: $declarationConfirmed, dataProcessingConsent: $dataProcessingConsent)';
}


}

/// @nodoc
abstract mixin class _$CreateReportRequestCopyWith<$Res> implements $CreateReportRequestCopyWith<$Res> {
  factory _$CreateReportRequestCopyWith(_CreateReportRequest value, $Res Function(_CreateReportRequest) _then) = __$CreateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String? category,@JsonKey(name: 'incident_type') String? incidentType, String? title, String description,@JsonKey(name: 'incident_datetime') String? incidentDatetime,@JsonKey(name: 'is_happening_now') bool isHappeningNow, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? latitude, String? longitude,@JsonKey(name: 'location_accuracy') String locationAccuracy, String? location, String? barangay, String severity,@JsonKey(name: 'people_affected') int? peopleAffected,@JsonKey(name: 'is_emergency') bool isEmergency,@JsonKey(name: 'declaration_confirmed') bool declarationConfirmed,@JsonKey(name: 'data_processing_consent') bool dataProcessingConsent
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
@override @pragma('vm:prefer-inline') $Res call({Object? category = freezed,Object? incidentType = freezed,Object? title = freezed,Object? description = null,Object? incidentDatetime = freezed,Object? isHappeningNow = null,Object? zone = freezed,Object? streetLandmark = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? locationAccuracy = null,Object? location = freezed,Object? barangay = freezed,Object? severity = null,Object? peopleAffected = freezed,Object? isEmergency = null,Object? declarationConfirmed = null,Object? dataProcessingConsent = null,}) {
  return _then(_CreateReportRequest(
category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,incidentDatetime: freezed == incidentDatetime ? _self.incidentDatetime : incidentDatetime // ignore: cast_nullable_to_non_nullable
as String?,isHappeningNow: null == isHappeningNow ? _self.isHappeningNow : isHappeningNow // ignore: cast_nullable_to_non_nullable
as bool,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
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
as bool,declarationConfirmed: null == declarationConfirmed ? _self.declarationConfirmed : declarationConfirmed // ignore: cast_nullable_to_non_nullable
as bool,dataProcessingConsent: null == dataProcessingConsent ? _self.dataProcessingConsent : dataProcessingConsent // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}


/// @nodoc
mixin _$UpdateReportRequest {

 String? get title; String? get description; String? get category;@JsonKey(name: 'incident_type') String? get incidentType; String? get severity;@JsonKey(name: 'people_affected') int? get peopleAffected;@JsonKey(name: 'is_emergency') bool? get isEmergency; String? get zone;@JsonKey(name: 'street_landmark') String? get streetLandmark;@JsonKey(name: 'city_municipality') String? get cityMunicipality; String? get province;// Legacy
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateReportRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.barangay, barangay) || other.barangay == barangay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,incidentType,severity,peopleAffected,isEmergency,zone,streetLandmark,cityMunicipality,province,barangay);

@override
String toString() {
  return 'UpdateReportRequest(title: $title, description: $description, category: $category, incidentType: $incidentType, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, zone: $zone, streetLandmark: $streetLandmark, cityMunicipality: $cityMunicipality, province: $province, barangay: $barangay)';
}


}

/// @nodoc
abstract mixin class $UpdateReportRequestCopyWith<$Res>  {
  factory $UpdateReportRequestCopyWith(UpdateReportRequest value, $Res Function(UpdateReportRequest) _then) = _$UpdateReportRequestCopyWithImpl;
@useResult
$Res call({
 String? title, String? description, String? category,@JsonKey(name: 'incident_type') String? incidentType, String? severity,@JsonKey(name: 'people_affected') int? peopleAffected,@JsonKey(name: 'is_emergency') bool? isEmergency, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? barangay
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
@pragma('vm:prefer-inline') @override $Res call({Object? title = freezed,Object? description = freezed,Object? category = freezed,Object? incidentType = freezed,Object? severity = freezed,Object? peopleAffected = freezed,Object? isEmergency = freezed,Object? zone = freezed,Object? streetLandmark = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? barangay = freezed,}) {
  return _then(_self.copyWith(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,peopleAffected: freezed == peopleAffected ? _self.peopleAffected : peopleAffected // ignore: cast_nullable_to_non_nullable
as int?,isEmergency: freezed == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String? title,  String? description,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool? isEmergency,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? barangay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.incidentType,_that.severity,_that.peopleAffected,_that.isEmergency,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.barangay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String? title,  String? description,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool? isEmergency,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? barangay)  $default,) {final _that = this;
switch (_that) {
case _UpdateReportRequest():
return $default(_that.title,_that.description,_that.category,_that.incidentType,_that.severity,_that.peopleAffected,_that.isEmergency,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.barangay);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String? title,  String? description,  String? category, @JsonKey(name: 'incident_type')  String? incidentType,  String? severity, @JsonKey(name: 'people_affected')  int? peopleAffected, @JsonKey(name: 'is_emergency')  bool? isEmergency,  String? zone, @JsonKey(name: 'street_landmark')  String? streetLandmark, @JsonKey(name: 'city_municipality')  String? cityMunicipality,  String? province,  String? barangay)?  $default,) {final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
return $default(_that.title,_that.description,_that.category,_that.incidentType,_that.severity,_that.peopleAffected,_that.isEmergency,_that.zone,_that.streetLandmark,_that.cityMunicipality,_that.province,_that.barangay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateReportRequest implements UpdateReportRequest {
  const _UpdateReportRequest({this.title, this.description, this.category, @JsonKey(name: 'incident_type') this.incidentType, this.severity, @JsonKey(name: 'people_affected') this.peopleAffected, @JsonKey(name: 'is_emergency') this.isEmergency, this.zone, @JsonKey(name: 'street_landmark') this.streetLandmark, @JsonKey(name: 'city_municipality') this.cityMunicipality, this.province, this.barangay});
  factory _UpdateReportRequest.fromJson(Map<String, dynamic> json) => _$UpdateReportRequestFromJson(json);

@override final  String? title;
@override final  String? description;
@override final  String? category;
@override@JsonKey(name: 'incident_type') final  String? incidentType;
@override final  String? severity;
@override@JsonKey(name: 'people_affected') final  int? peopleAffected;
@override@JsonKey(name: 'is_emergency') final  bool? isEmergency;
@override final  String? zone;
@override@JsonKey(name: 'street_landmark') final  String? streetLandmark;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateReportRequest&&(identical(other.title, title) || other.title == title)&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.incidentType, incidentType) || other.incidentType == incidentType)&&(identical(other.severity, severity) || other.severity == severity)&&(identical(other.peopleAffected, peopleAffected) || other.peopleAffected == peopleAffected)&&(identical(other.isEmergency, isEmergency) || other.isEmergency == isEmergency)&&(identical(other.zone, zone) || other.zone == zone)&&(identical(other.streetLandmark, streetLandmark) || other.streetLandmark == streetLandmark)&&(identical(other.cityMunicipality, cityMunicipality) || other.cityMunicipality == cityMunicipality)&&(identical(other.province, province) || other.province == province)&&(identical(other.barangay, barangay) || other.barangay == barangay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,title,description,category,incidentType,severity,peopleAffected,isEmergency,zone,streetLandmark,cityMunicipality,province,barangay);

@override
String toString() {
  return 'UpdateReportRequest(title: $title, description: $description, category: $category, incidentType: $incidentType, severity: $severity, peopleAffected: $peopleAffected, isEmergency: $isEmergency, zone: $zone, streetLandmark: $streetLandmark, cityMunicipality: $cityMunicipality, province: $province, barangay: $barangay)';
}


}

/// @nodoc
abstract mixin class _$UpdateReportRequestCopyWith<$Res> implements $UpdateReportRequestCopyWith<$Res> {
  factory _$UpdateReportRequestCopyWith(_UpdateReportRequest value, $Res Function(_UpdateReportRequest) _then) = __$UpdateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String? title, String? description, String? category,@JsonKey(name: 'incident_type') String? incidentType, String? severity,@JsonKey(name: 'people_affected') int? peopleAffected,@JsonKey(name: 'is_emergency') bool? isEmergency, String? zone,@JsonKey(name: 'street_landmark') String? streetLandmark,@JsonKey(name: 'city_municipality') String? cityMunicipality, String? province, String? barangay
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
@override @pragma('vm:prefer-inline') $Res call({Object? title = freezed,Object? description = freezed,Object? category = freezed,Object? incidentType = freezed,Object? severity = freezed,Object? peopleAffected = freezed,Object? isEmergency = freezed,Object? zone = freezed,Object? streetLandmark = freezed,Object? cityMunicipality = freezed,Object? province = freezed,Object? barangay = freezed,}) {
  return _then(_UpdateReportRequest(
title: freezed == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String?,description: freezed == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,incidentType: freezed == incidentType ? _self.incidentType : incidentType // ignore: cast_nullable_to_non_nullable
as String?,severity: freezed == severity ? _self.severity : severity // ignore: cast_nullable_to_non_nullable
as String?,peopleAffected: freezed == peopleAffected ? _self.peopleAffected : peopleAffected // ignore: cast_nullable_to_non_nullable
as int?,isEmergency: freezed == isEmergency ? _self.isEmergency : isEmergency // ignore: cast_nullable_to_non_nullable
as bool?,zone: freezed == zone ? _self.zone : zone // ignore: cast_nullable_to_non_nullable
as String?,streetLandmark: freezed == streetLandmark ? _self.streetLandmark : streetLandmark // ignore: cast_nullable_to_non_nullable
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

 List<Map<String, dynamic>> get categories; List<Map<String, dynamic>> get statuses;@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> get severityLevels;
/// Create a copy of ReportFormOptions
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportFormOptionsCopyWith<ReportFormOptions> get copyWith => _$ReportFormOptionsCopyWithImpl<ReportFormOptions>(this as ReportFormOptions, _$identity);

  /// Serializes this ReportFormOptions to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportFormOptions&&const DeepCollectionEquality().equals(other.categories, categories)&&const DeepCollectionEquality().equals(other.statuses, statuses)&&const DeepCollectionEquality().equals(other.severityLevels, severityLevels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(categories),const DeepCollectionEquality().hash(statuses),const DeepCollectionEquality().hash(severityLevels));

@override
String toString() {
  return 'ReportFormOptions(categories: $categories, statuses: $statuses, severityLevels: $severityLevels)';
}


}

/// @nodoc
abstract mixin class $ReportFormOptionsCopyWith<$Res>  {
  factory $ReportFormOptionsCopyWith(ReportFormOptions value, $Res Function(ReportFormOptions) _then) = _$ReportFormOptionsCopyWithImpl;
@useResult
$Res call({
 List<Map<String, dynamic>> categories, List<Map<String, dynamic>> statuses,@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> severityLevels
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
@pragma('vm:prefer-inline') @override $Res call({Object? categories = null,Object? statuses = null,Object? severityLevels = null,}) {
  return _then(_self.copyWith(
categories: null == categories ? _self.categories : categories // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,statuses: null == statuses ? _self.statuses : statuses // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> categories,  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels')  List<Map<String, dynamic>> severityLevels)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportFormOptions() when $default != null:
return $default(_that.categories,_that.statuses,_that.severityLevels);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Map<String, dynamic>> categories,  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels')  List<Map<String, dynamic>> severityLevels)  $default,) {final _that = this;
switch (_that) {
case _ReportFormOptions():
return $default(_that.categories,_that.statuses,_that.severityLevels);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Map<String, dynamic>> categories,  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels')  List<Map<String, dynamic>> severityLevels)?  $default,) {final _that = this;
switch (_that) {
case _ReportFormOptions() when $default != null:
return $default(_that.categories,_that.statuses,_that.severityLevels);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportFormOptions implements ReportFormOptions {
  const _ReportFormOptions({required final  List<Map<String, dynamic>> categories, required final  List<Map<String, dynamic>> statuses, @JsonKey(name: 'severity_levels') required final  List<Map<String, dynamic>> severityLevels}): _categories = categories,_statuses = statuses,_severityLevels = severityLevels;
  factory _ReportFormOptions.fromJson(Map<String, dynamic> json) => _$ReportFormOptionsFromJson(json);

 final  List<Map<String, dynamic>> _categories;
@override List<Map<String, dynamic>> get categories {
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportFormOptions&&const DeepCollectionEquality().equals(other._categories, _categories)&&const DeepCollectionEquality().equals(other._statuses, _statuses)&&const DeepCollectionEquality().equals(other._severityLevels, _severityLevels));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_categories),const DeepCollectionEquality().hash(_statuses),const DeepCollectionEquality().hash(_severityLevels));

@override
String toString() {
  return 'ReportFormOptions(categories: $categories, statuses: $statuses, severityLevels: $severityLevels)';
}


}

/// @nodoc
abstract mixin class _$ReportFormOptionsCopyWith<$Res> implements $ReportFormOptionsCopyWith<$Res> {
  factory _$ReportFormOptionsCopyWith(_ReportFormOptions value, $Res Function(_ReportFormOptions) _then) = __$ReportFormOptionsCopyWithImpl;
@override @useResult
$Res call({
 List<Map<String, dynamic>> categories, List<Map<String, dynamic>> statuses,@JsonKey(name: 'severity_levels') List<Map<String, dynamic>> severityLevels
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
@override @pragma('vm:prefer-inline') $Res call({Object? categories = null,Object? statuses = null,Object? severityLevels = null,}) {
  return _then(_ReportFormOptions(
categories: null == categories ? _self._categories : categories // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,statuses: null == statuses ? _self._statuses : statuses // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,severityLevels: null == severityLevels ? _self._severityLevels : severityLevels // ignore: cast_nullable_to_non_nullable
as List<Map<String, dynamic>>,
  ));
}


}

// dart format on

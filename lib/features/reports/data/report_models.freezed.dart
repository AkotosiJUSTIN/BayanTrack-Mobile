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

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId; String get url;// Backend returns 'url' not 'image_url'
@JsonKey(name: 's3_key') String? get s3Key; String? get filename;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'mime_type') String? get mimeType; int? get width; int? get height;@JsonKey(name: 'is_primary') bool get isPrimary;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
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
// Backend returns 'url' not 'image_url'
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

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId; String get description; String? get location; String? get barangay; String? get latitude;// Backend returns as string
 String? get longitude;// Backend returns as string
 List<ReportImage> get images;// List of image objects from backend
 ReportStatus get status; String? get category;@JsonKey(name: 'category_confidence') double? get categoryConfidence; String? get priority;@JsonKey(name: 'priority_score') int? get priorityScore;@JsonKey(name: 'duplicate_state') String get duplicateState;@JsonKey(name: 'related_issue_id') String? get relatedIssueId;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.duplicateState, duplicateState) || other.duplicateState == duplicateState)&&(identical(other.relatedIssueId, relatedIssueId) || other.relatedIssueId == relatedIssueId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,description,location,barangay,latitude,longitude,const DeepCollectionEquality().hash(images),status,category,categoryConfidence,priority,priorityScore,duplicateState,relatedIssueId,createdAt,updatedAt);

@override
String toString() {
  return 'Report(id: $id, reportId: $reportId, userId: $userId, description: $description, location: $location, barangay: $barangay, latitude: $latitude, longitude: $longitude, images: $images, status: $status, category: $category, categoryConfidence: $categoryConfidence, priority: $priority, priorityScore: $priorityScore, duplicateState: $duplicateState, relatedIssueId: $relatedIssueId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String description, String? location, String? barangay, String? latitude, String? longitude, List<ReportImage> images, ReportStatus status, String? category,@JsonKey(name: 'category_confidence') double? categoryConfidence, String? priority,@JsonKey(name: 'priority_score') int? priorityScore,@JsonKey(name: 'duplicate_state') String duplicateState,@JsonKey(name: 'related_issue_id') String? relatedIssueId,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? description = null,Object? location = freezed,Object? barangay = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? images = null,Object? status = null,Object? category = freezed,Object? categoryConfidence = freezed,Object? priority = freezed,Object? priorityScore = freezed,Object? duplicateState = null,Object? relatedIssueId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<ReportImage>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,categoryConfidence: freezed == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,priorityScore: freezed == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int?,duplicateState: null == duplicateState ? _self.duplicateState : duplicateState // ignore: cast_nullable_to_non_nullable
as String,relatedIssueId: freezed == relatedIssueId ? _self.relatedIssueId : relatedIssueId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String description,  String? location,  String? barangay,  String? latitude,  String? longitude,  List<ReportImage> images,  ReportStatus status,  String? category, @JsonKey(name: 'category_confidence')  double? categoryConfidence,  String? priority, @JsonKey(name: 'priority_score')  int? priorityScore, @JsonKey(name: 'duplicate_state')  String duplicateState, @JsonKey(name: 'related_issue_id')  String? relatedIssueId, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.description,_that.location,_that.barangay,_that.latitude,_that.longitude,_that.images,_that.status,_that.category,_that.categoryConfidence,_that.priority,_that.priorityScore,_that.duplicateState,_that.relatedIssueId,_that.createdAt,_that.updatedAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String description,  String? location,  String? barangay,  String? latitude,  String? longitude,  List<ReportImage> images,  ReportStatus status,  String? category, @JsonKey(name: 'category_confidence')  double? categoryConfidence,  String? priority, @JsonKey(name: 'priority_score')  int? priorityScore, @JsonKey(name: 'duplicate_state')  String duplicateState, @JsonKey(name: 'related_issue_id')  String? relatedIssueId, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.reportId,_that.userId,_that.description,_that.location,_that.barangay,_that.latitude,_that.longitude,_that.images,_that.status,_that.category,_that.categoryConfidence,_that.priority,_that.priorityScore,_that.duplicateState,_that.relatedIssueId,_that.createdAt,_that.updatedAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String description,  String? location,  String? barangay,  String? latitude,  String? longitude,  List<ReportImage> images,  ReportStatus status,  String? category, @JsonKey(name: 'category_confidence')  double? categoryConfidence,  String? priority, @JsonKey(name: 'priority_score')  int? priorityScore, @JsonKey(name: 'duplicate_state')  String duplicateState, @JsonKey(name: 'related_issue_id')  String? relatedIssueId, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.description,_that.location,_that.barangay,_that.latitude,_that.longitude,_that.images,_that.status,_that.category,_that.categoryConfidence,_that.priority,_that.priorityScore,_that.duplicateState,_that.relatedIssueId,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({required this.id, @JsonKey(name: 'report_id') this.reportId, @JsonKey(name: 'user_id') this.userId, required this.description, this.location, this.barangay, this.latitude, this.longitude, final  List<ReportImage> images = const [], this.status = ReportStatus.pending, this.category, @JsonKey(name: 'category_confidence') this.categoryConfidence, this.priority, @JsonKey(name: 'priority_score') this.priorityScore, @JsonKey(name: 'duplicate_state') this.duplicateState = 'New', @JsonKey(name: 'related_issue_id') this.relatedIssueId, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt}): _images = images;
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override final  String id;
@override@JsonKey(name: 'report_id') final  String? reportId;
@override@JsonKey(name: 'user_id') final  String? userId;
@override final  String description;
@override final  String? location;
@override final  String? barangay;
@override final  String? latitude;
// Backend returns as string
@override final  String? longitude;
// Backend returns as string
 final  List<ReportImage> _images;
// Backend returns as string
@override@JsonKey() List<ReportImage> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

// List of image objects from backend
@override@JsonKey() final  ReportStatus status;
@override final  String? category;
@override@JsonKey(name: 'category_confidence') final  double? categoryConfidence;
@override final  String? priority;
@override@JsonKey(name: 'priority_score') final  int? priorityScore;
@override@JsonKey(name: 'duplicate_state') final  String duplicateState;
@override@JsonKey(name: 'related_issue_id') final  String? relatedIssueId;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.categoryConfidence, categoryConfidence) || other.categoryConfidence == categoryConfidence)&&(identical(other.priority, priority) || other.priority == priority)&&(identical(other.priorityScore, priorityScore) || other.priorityScore == priorityScore)&&(identical(other.duplicateState, duplicateState) || other.duplicateState == duplicateState)&&(identical(other.relatedIssueId, relatedIssueId) || other.relatedIssueId == relatedIssueId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,description,location,barangay,latitude,longitude,const DeepCollectionEquality().hash(_images),status,category,categoryConfidence,priority,priorityScore,duplicateState,relatedIssueId,createdAt,updatedAt);

@override
String toString() {
  return 'Report(id: $id, reportId: $reportId, userId: $userId, description: $description, location: $location, barangay: $barangay, latitude: $latitude, longitude: $longitude, images: $images, status: $status, category: $category, categoryConfidence: $categoryConfidence, priority: $priority, priorityScore: $priorityScore, duplicateState: $duplicateState, relatedIssueId: $relatedIssueId, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String description, String? location, String? barangay, String? latitude, String? longitude, List<ReportImage> images, ReportStatus status, String? category,@JsonKey(name: 'category_confidence') double? categoryConfidence, String? priority,@JsonKey(name: 'priority_score') int? priorityScore,@JsonKey(name: 'duplicate_state') String duplicateState,@JsonKey(name: 'related_issue_id') String? relatedIssueId,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? description = null,Object? location = freezed,Object? barangay = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? images = null,Object? status = null,Object? category = freezed,Object? categoryConfidence = freezed,Object? priority = freezed,Object? priorityScore = freezed,Object? duplicateState = null,Object? relatedIssueId = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,userId: freezed == userId ? _self.userId : userId // ignore: cast_nullable_to_non_nullable
as String?,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: freezed == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<ReportImage>,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,categoryConfidence: freezed == categoryConfidence ? _self.categoryConfidence : categoryConfidence // ignore: cast_nullable_to_non_nullable
as double?,priority: freezed == priority ? _self.priority : priority // ignore: cast_nullable_to_non_nullable
as String?,priorityScore: freezed == priorityScore ? _self.priorityScore : priorityScore // ignore: cast_nullable_to_non_nullable
as int?,duplicateState: null == duplicateState ? _self.duplicateState : duplicateState // ignore: cast_nullable_to_non_nullable
as String,relatedIssueId: freezed == relatedIssueId ? _self.relatedIssueId : relatedIssueId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$CreateReportRequest {

 String get description; String get location; String get barangay; String? get latitude;// Sent as string, backend accepts DecimalField
 String? get longitude;// Sent as string, backend accepts DecimalField
 String? get category;
/// Create a copy of CreateReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReportRequestCopyWith<CreateReportRequest> get copyWith => _$CreateReportRequestCopyWithImpl<CreateReportRequest>(this as CreateReportRequest, _$identity);

  /// Serializes this CreateReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReportRequest&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,location,barangay,latitude,longitude,category);

@override
String toString() {
  return 'CreateReportRequest(description: $description, location: $location, barangay: $barangay, latitude: $latitude, longitude: $longitude, category: $category)';
}


}

/// @nodoc
abstract mixin class $CreateReportRequestCopyWith<$Res>  {
  factory $CreateReportRequestCopyWith(CreateReportRequest value, $Res Function(CreateReportRequest) _then) = _$CreateReportRequestCopyWithImpl;
@useResult
$Res call({
 String description, String location, String barangay, String? latitude, String? longitude, String? category
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
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? location = null,Object? barangay = null,Object? latitude = freezed,Object? longitude = freezed,Object? category = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,barangay: null == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  String location,  String barangay,  String? latitude,  String? longitude,  String? category)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.description,_that.location,_that.barangay,_that.latitude,_that.longitude,_that.category);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  String location,  String barangay,  String? latitude,  String? longitude,  String? category)  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest():
return $default(_that.description,_that.location,_that.barangay,_that.latitude,_that.longitude,_that.category);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  String location,  String barangay,  String? latitude,  String? longitude,  String? category)?  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.description,_that.location,_that.barangay,_that.latitude,_that.longitude,_that.category);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateReportRequest implements CreateReportRequest {
  const _CreateReportRequest({required this.description, required this.location, required this.barangay, this.latitude, this.longitude, this.category});
  factory _CreateReportRequest.fromJson(Map<String, dynamic> json) => _$CreateReportRequestFromJson(json);

@override final  String description;
@override final  String location;
@override final  String barangay;
@override final  String? latitude;
// Sent as string, backend accepts DecimalField
@override final  String? longitude;
// Sent as string, backend accepts DecimalField
@override final  String? category;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReportRequest&&(identical(other.description, description) || other.description == description)&&(identical(other.location, location) || other.location == location)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&(identical(other.category, category) || other.category == category));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,location,barangay,latitude,longitude,category);

@override
String toString() {
  return 'CreateReportRequest(description: $description, location: $location, barangay: $barangay, latitude: $latitude, longitude: $longitude, category: $category)';
}


}

/// @nodoc
abstract mixin class _$CreateReportRequestCopyWith<$Res> implements $CreateReportRequestCopyWith<$Res> {
  factory _$CreateReportRequestCopyWith(_CreateReportRequest value, $Res Function(_CreateReportRequest) _then) = __$CreateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String description, String location, String barangay, String? latitude, String? longitude, String? category
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
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? location = null,Object? barangay = null,Object? latitude = freezed,Object? longitude = freezed,Object? category = freezed,}) {
  return _then(_CreateReportRequest(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,location: null == location ? _self.location : location // ignore: cast_nullable_to_non_nullable
as String,barangay: null == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as String?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as String?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$UpdateReportRequest {

 ReportStatus? get status; String? get category; String? get barangay;
/// Create a copy of UpdateReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UpdateReportRequestCopyWith<UpdateReportRequest> get copyWith => _$UpdateReportRequestCopyWithImpl<UpdateReportRequest>(this as UpdateReportRequest, _$identity);

  /// Serializes this UpdateReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UpdateReportRequest&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.barangay, barangay) || other.barangay == barangay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,category,barangay);

@override
String toString() {
  return 'UpdateReportRequest(status: $status, category: $category, barangay: $barangay)';
}


}

/// @nodoc
abstract mixin class $UpdateReportRequestCopyWith<$Res>  {
  factory $UpdateReportRequestCopyWith(UpdateReportRequest value, $Res Function(UpdateReportRequest) _then) = _$UpdateReportRequestCopyWithImpl;
@useResult
$Res call({
 ReportStatus? status, String? category, String? barangay
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
@pragma('vm:prefer-inline') @override $Res call({Object? status = freezed,Object? category = freezed,Object? barangay = freezed,}) {
  return _then(_self.copyWith(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( ReportStatus? status,  String? category,  String? barangay)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
return $default(_that.status,_that.category,_that.barangay);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( ReportStatus? status,  String? category,  String? barangay)  $default,) {final _that = this;
switch (_that) {
case _UpdateReportRequest():
return $default(_that.status,_that.category,_that.barangay);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( ReportStatus? status,  String? category,  String? barangay)?  $default,) {final _that = this;
switch (_that) {
case _UpdateReportRequest() when $default != null:
return $default(_that.status,_that.category,_that.barangay);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UpdateReportRequest implements UpdateReportRequest {
  const _UpdateReportRequest({this.status, this.category, this.barangay});
  factory _UpdateReportRequest.fromJson(Map<String, dynamic> json) => _$UpdateReportRequestFromJson(json);

@override final  ReportStatus? status;
@override final  String? category;
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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UpdateReportRequest&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.barangay, barangay) || other.barangay == barangay));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,status,category,barangay);

@override
String toString() {
  return 'UpdateReportRequest(status: $status, category: $category, barangay: $barangay)';
}


}

/// @nodoc
abstract mixin class _$UpdateReportRequestCopyWith<$Res> implements $UpdateReportRequestCopyWith<$Res> {
  factory _$UpdateReportRequestCopyWith(_UpdateReportRequest value, $Res Function(_UpdateReportRequest) _then) = __$UpdateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 ReportStatus? status, String? category, String? barangay
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
@override @pragma('vm:prefer-inline') $Res call({Object? status = freezed,Object? category = freezed,Object? barangay = freezed,}) {
  return _then(_UpdateReportRequest(
status: freezed == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus?,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
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

 int get total; int get pending;@JsonKey(name: 'in_progress') int get inProgress; int get resolved; int get rejected; int get verified; int get assigned;
/// Create a copy of ReportStats
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportStatsCopyWith<ReportStats> get copyWith => _$ReportStatsCopyWithImpl<ReportStats>(this as ReportStats, _$identity);

  /// Serializes this ReportStats to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ReportStats&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.assigned, assigned) || other.assigned == assigned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,pending,inProgress,resolved,rejected,verified,assigned);

@override
String toString() {
  return 'ReportStats(total: $total, pending: $pending, inProgress: $inProgress, resolved: $resolved, rejected: $rejected, verified: $verified, assigned: $assigned)';
}


}

/// @nodoc
abstract mixin class $ReportStatsCopyWith<$Res>  {
  factory $ReportStatsCopyWith(ReportStats value, $Res Function(ReportStats) _then) = _$ReportStatsCopyWithImpl;
@useResult
$Res call({
 int total, int pending,@JsonKey(name: 'in_progress') int inProgress, int resolved, int rejected, int verified, int assigned
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
@pragma('vm:prefer-inline') @override $Res call({Object? total = null,Object? pending = null,Object? inProgress = null,Object? resolved = null,Object? rejected = null,Object? verified = null,Object? assigned = null,}) {
  return _then(_self.copyWith(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( int total,  int pending, @JsonKey(name: 'in_progress')  int inProgress,  int resolved,  int rejected,  int verified,  int assigned)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ReportStats() when $default != null:
return $default(_that.total,_that.pending,_that.inProgress,_that.resolved,_that.rejected,_that.verified,_that.assigned);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( int total,  int pending, @JsonKey(name: 'in_progress')  int inProgress,  int resolved,  int rejected,  int verified,  int assigned)  $default,) {final _that = this;
switch (_that) {
case _ReportStats():
return $default(_that.total,_that.pending,_that.inProgress,_that.resolved,_that.rejected,_that.verified,_that.assigned);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( int total,  int pending, @JsonKey(name: 'in_progress')  int inProgress,  int resolved,  int rejected,  int verified,  int assigned)?  $default,) {final _that = this;
switch (_that) {
case _ReportStats() when $default != null:
return $default(_that.total,_that.pending,_that.inProgress,_that.resolved,_that.rejected,_that.verified,_that.assigned);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ReportStats implements ReportStats {
  const _ReportStats({this.total = 0, this.pending = 0, @JsonKey(name: 'in_progress') this.inProgress = 0, this.resolved = 0, this.rejected = 0, this.verified = 0, this.assigned = 0});
  factory _ReportStats.fromJson(Map<String, dynamic> json) => _$ReportStatsFromJson(json);

@override@JsonKey() final  int total;
@override@JsonKey() final  int pending;
@override@JsonKey(name: 'in_progress') final  int inProgress;
@override@JsonKey() final  int resolved;
@override@JsonKey() final  int rejected;
@override@JsonKey() final  int verified;
@override@JsonKey() final  int assigned;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ReportStats&&(identical(other.total, total) || other.total == total)&&(identical(other.pending, pending) || other.pending == pending)&&(identical(other.inProgress, inProgress) || other.inProgress == inProgress)&&(identical(other.resolved, resolved) || other.resolved == resolved)&&(identical(other.rejected, rejected) || other.rejected == rejected)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.assigned, assigned) || other.assigned == assigned));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,total,pending,inProgress,resolved,rejected,verified,assigned);

@override
String toString() {
  return 'ReportStats(total: $total, pending: $pending, inProgress: $inProgress, resolved: $resolved, rejected: $rejected, verified: $verified, assigned: $assigned)';
}


}

/// @nodoc
abstract mixin class _$ReportStatsCopyWith<$Res> implements $ReportStatsCopyWith<$Res> {
  factory _$ReportStatsCopyWith(_ReportStats value, $Res Function(_ReportStats) _then) = __$ReportStatsCopyWithImpl;
@override @useResult
$Res call({
 int total, int pending,@JsonKey(name: 'in_progress') int inProgress, int resolved, int rejected, int verified, int assigned
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
@override @pragma('vm:prefer-inline') $Res call({Object? total = null,Object? pending = null,Object? inProgress = null,Object? resolved = null,Object? rejected = null,Object? verified = null,Object? assigned = null,}) {
  return _then(_ReportStats(
total: null == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int,pending: null == pending ? _self.pending : pending // ignore: cast_nullable_to_non_nullable
as int,inProgress: null == inProgress ? _self.inProgress : inProgress // ignore: cast_nullable_to_non_nullable
as int,resolved: null == resolved ? _self.resolved : resolved // ignore: cast_nullable_to_non_nullable
as int,rejected: null == rejected ? _self.rejected : rejected // ignore: cast_nullable_to_non_nullable
as int,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as int,assigned: null == assigned ? _self.assigned : assigned // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

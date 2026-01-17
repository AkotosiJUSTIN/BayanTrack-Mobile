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
mixin _$Report {

@JsonKey(name: 'id') String get id; String get description; ReportStatus get status; String? get category; String? get barangay; double? get latitude; double? get longitude; List<String> get images;@JsonKey(name: 'created_by') String? get createdBy;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;// AI fields (optional, from backend)
@JsonKey(name: 'ai_category') String? get aiCategory;@JsonKey(name: 'ai_priority') int? get aiPriority;@JsonKey(name: 'ai_confidence') double? get aiConfidence;
/// Create a copy of Report
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ReportCopyWith<Report> get copyWith => _$ReportCopyWithImpl<Report>(this as Report, _$identity);

  /// Serializes this Report to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is Report&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other.images, images)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.aiCategory, aiCategory) || other.aiCategory == aiCategory)&&(identical(other.aiPriority, aiPriority) || other.aiPriority == aiPriority)&&(identical(other.aiConfidence, aiConfidence) || other.aiConfidence == aiConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,status,category,barangay,latitude,longitude,const DeepCollectionEquality().hash(images),createdBy,createdAt,updatedAt,aiCategory,aiPriority,aiConfidence);

@override
String toString() {
  return 'Report(id: $id, description: $description, status: $status, category: $category, barangay: $barangay, latitude: $latitude, longitude: $longitude, images: $images, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, aiCategory: $aiCategory, aiPriority: $aiPriority, aiConfidence: $aiConfidence)';
}


}

/// @nodoc
abstract mixin class $ReportCopyWith<$Res>  {
  factory $ReportCopyWith(Report value, $Res Function(Report) _then) = _$ReportCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id, String description, ReportStatus status, String? category, String? barangay, double? latitude, double? longitude, List<String> images,@JsonKey(name: 'created_by') String? createdBy,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'ai_category') String? aiCategory,@JsonKey(name: 'ai_priority') int? aiPriority,@JsonKey(name: 'ai_confidence') double? aiConfidence
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
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? description = null,Object? status = null,Object? category = freezed,Object? barangay = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? images = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? aiCategory = freezed,Object? aiPriority = freezed,Object? aiConfidence = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,images: null == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<String>,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,aiCategory: freezed == aiCategory ? _self.aiCategory : aiCategory // ignore: cast_nullable_to_non_nullable
as String?,aiPriority: freezed == aiPriority ? _self.aiPriority : aiPriority // ignore: cast_nullable_to_non_nullable
as int?,aiConfidence: freezed == aiConfidence ? _self.aiConfidence : aiConfidence // ignore: cast_nullable_to_non_nullable
as double?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id,  String description,  ReportStatus status,  String? category,  String? barangay,  double? latitude,  double? longitude,  List<String> images, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'ai_category')  String? aiCategory, @JsonKey(name: 'ai_priority')  int? aiPriority, @JsonKey(name: 'ai_confidence')  double? aiConfidence)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.description,_that.status,_that.category,_that.barangay,_that.latitude,_that.longitude,_that.images,_that.createdBy,_that.createdAt,_that.updatedAt,_that.aiCategory,_that.aiPriority,_that.aiConfidence);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id,  String description,  ReportStatus status,  String? category,  String? barangay,  double? latitude,  double? longitude,  List<String> images, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'ai_category')  String? aiCategory, @JsonKey(name: 'ai_priority')  int? aiPriority, @JsonKey(name: 'ai_confidence')  double? aiConfidence)  $default,) {final _that = this;
switch (_that) {
case _Report():
return $default(_that.id,_that.description,_that.status,_that.category,_that.barangay,_that.latitude,_that.longitude,_that.images,_that.createdBy,_that.createdAt,_that.updatedAt,_that.aiCategory,_that.aiPriority,_that.aiConfidence);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id,  String description,  ReportStatus status,  String? category,  String? barangay,  double? latitude,  double? longitude,  List<String> images, @JsonKey(name: 'created_by')  String? createdBy, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt, @JsonKey(name: 'ai_category')  String? aiCategory, @JsonKey(name: 'ai_priority')  int? aiPriority, @JsonKey(name: 'ai_confidence')  double? aiConfidence)?  $default,) {final _that = this;
switch (_that) {
case _Report() when $default != null:
return $default(_that.id,_that.description,_that.status,_that.category,_that.barangay,_that.latitude,_that.longitude,_that.images,_that.createdBy,_that.createdAt,_that.updatedAt,_that.aiCategory,_that.aiPriority,_that.aiConfidence);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _Report implements Report {
  const _Report({@JsonKey(name: 'id') required this.id, required this.description, this.status = ReportStatus.pending, this.category, this.barangay, this.latitude, this.longitude, final  List<String> images = const [], @JsonKey(name: 'created_by') this.createdBy, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt, @JsonKey(name: 'ai_category') this.aiCategory, @JsonKey(name: 'ai_priority') this.aiPriority, @JsonKey(name: 'ai_confidence') this.aiConfidence}): _images = images;
  factory _Report.fromJson(Map<String, dynamic> json) => _$ReportFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override final  String description;
@override@JsonKey() final  ReportStatus status;
@override final  String? category;
@override final  String? barangay;
@override final  double? latitude;
@override final  double? longitude;
 final  List<String> _images;
@override@JsonKey() List<String> get images {
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_images);
}

@override@JsonKey(name: 'created_by') final  String? createdBy;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;
// AI fields (optional, from backend)
@override@JsonKey(name: 'ai_category') final  String? aiCategory;
@override@JsonKey(name: 'ai_priority') final  int? aiPriority;
@override@JsonKey(name: 'ai_confidence') final  double? aiConfidence;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _Report&&(identical(other.id, id) || other.id == id)&&(identical(other.description, description) || other.description == description)&&(identical(other.status, status) || other.status == status)&&(identical(other.category, category) || other.category == category)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude)&&const DeepCollectionEquality().equals(other._images, _images)&&(identical(other.createdBy, createdBy) || other.createdBy == createdBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt)&&(identical(other.aiCategory, aiCategory) || other.aiCategory == aiCategory)&&(identical(other.aiPriority, aiPriority) || other.aiPriority == aiPriority)&&(identical(other.aiConfidence, aiConfidence) || other.aiConfidence == aiConfidence));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,description,status,category,barangay,latitude,longitude,const DeepCollectionEquality().hash(_images),createdBy,createdAt,updatedAt,aiCategory,aiPriority,aiConfidence);

@override
String toString() {
  return 'Report(id: $id, description: $description, status: $status, category: $category, barangay: $barangay, latitude: $latitude, longitude: $longitude, images: $images, createdBy: $createdBy, createdAt: $createdAt, updatedAt: $updatedAt, aiCategory: $aiCategory, aiPriority: $aiPriority, aiConfidence: $aiConfidence)';
}


}

/// @nodoc
abstract mixin class _$ReportCopyWith<$Res> implements $ReportCopyWith<$Res> {
  factory _$ReportCopyWith(_Report value, $Res Function(_Report) _then) = __$ReportCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id, String description, ReportStatus status, String? category, String? barangay, double? latitude, double? longitude, List<String> images,@JsonKey(name: 'created_by') String? createdBy,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt,@JsonKey(name: 'ai_category') String? aiCategory,@JsonKey(name: 'ai_priority') int? aiPriority,@JsonKey(name: 'ai_confidence') double? aiConfidence
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? description = null,Object? status = null,Object? category = freezed,Object? barangay = freezed,Object? latitude = freezed,Object? longitude = freezed,Object? images = null,Object? createdBy = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,Object? aiCategory = freezed,Object? aiPriority = freezed,Object? aiConfidence = freezed,}) {
  return _then(_Report(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,status: null == status ? _self.status : status // ignore: cast_nullable_to_non_nullable
as ReportStatus,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,images: null == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<String>,createdBy: freezed == createdBy ? _self.createdBy : createdBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,updatedAt: freezed == updatedAt ? _self.updatedAt : updatedAt // ignore: cast_nullable_to_non_nullable
as String?,aiCategory: freezed == aiCategory ? _self.aiCategory : aiCategory // ignore: cast_nullable_to_non_nullable
as String?,aiPriority: freezed == aiPriority ? _self.aiPriority : aiPriority // ignore: cast_nullable_to_non_nullable
as int?,aiConfidence: freezed == aiConfidence ? _self.aiConfidence : aiConfidence // ignore: cast_nullable_to_non_nullable
as double?,
  ));
}


}


/// @nodoc
mixin _$CreateReportRequest {

 String get description; String? get category; String? get barangay; double? get latitude; double? get longitude;
/// Create a copy of CreateReportRequest
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$CreateReportRequestCopyWith<CreateReportRequest> get copyWith => _$CreateReportRequestCopyWithImpl<CreateReportRequest>(this as CreateReportRequest, _$identity);

  /// Serializes this CreateReportRequest to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is CreateReportRequest&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,category,barangay,latitude,longitude);

@override
String toString() {
  return 'CreateReportRequest(description: $description, category: $category, barangay: $barangay, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class $CreateReportRequestCopyWith<$Res>  {
  factory $CreateReportRequestCopyWith(CreateReportRequest value, $Res Function(CreateReportRequest) _then) = _$CreateReportRequestCopyWithImpl;
@useResult
$Res call({
 String description, String? category, String? barangay, double? latitude, double? longitude
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
@pragma('vm:prefer-inline') @override $Res call({Object? description = null,Object? category = freezed,Object? barangay = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_self.copyWith(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String description,  String? category,  String? barangay,  double? latitude,  double? longitude)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.description,_that.category,_that.barangay,_that.latitude,_that.longitude);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String description,  String? category,  String? barangay,  double? latitude,  double? longitude)  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest():
return $default(_that.description,_that.category,_that.barangay,_that.latitude,_that.longitude);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String description,  String? category,  String? barangay,  double? latitude,  double? longitude)?  $default,) {final _that = this;
switch (_that) {
case _CreateReportRequest() when $default != null:
return $default(_that.description,_that.category,_that.barangay,_that.latitude,_that.longitude);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _CreateReportRequest implements CreateReportRequest {
  const _CreateReportRequest({required this.description, this.category, this.barangay, this.latitude, this.longitude});
  factory _CreateReportRequest.fromJson(Map<String, dynamic> json) => _$CreateReportRequestFromJson(json);

@override final  String description;
@override final  String? category;
@override final  String? barangay;
@override final  double? latitude;
@override final  double? longitude;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _CreateReportRequest&&(identical(other.description, description) || other.description == description)&&(identical(other.category, category) || other.category == category)&&(identical(other.barangay, barangay) || other.barangay == barangay)&&(identical(other.latitude, latitude) || other.latitude == latitude)&&(identical(other.longitude, longitude) || other.longitude == longitude));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,description,category,barangay,latitude,longitude);

@override
String toString() {
  return 'CreateReportRequest(description: $description, category: $category, barangay: $barangay, latitude: $latitude, longitude: $longitude)';
}


}

/// @nodoc
abstract mixin class _$CreateReportRequestCopyWith<$Res> implements $CreateReportRequestCopyWith<$Res> {
  factory _$CreateReportRequestCopyWith(_CreateReportRequest value, $Res Function(_CreateReportRequest) _then) = __$CreateReportRequestCopyWithImpl;
@override @useResult
$Res call({
 String description, String? category, String? barangay, double? latitude, double? longitude
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
@override @pragma('vm:prefer-inline') $Res call({Object? description = null,Object? category = freezed,Object? barangay = freezed,Object? latitude = freezed,Object? longitude = freezed,}) {
  return _then(_CreateReportRequest(
description: null == description ? _self.description : description // ignore: cast_nullable_to_non_nullable
as String,category: freezed == category ? _self.category : category // ignore: cast_nullable_to_non_nullable
as String?,barangay: freezed == barangay ? _self.barangay : barangay // ignore: cast_nullable_to_non_nullable
as String?,latitude: freezed == latitude ? _self.latitude : latitude // ignore: cast_nullable_to_non_nullable
as double?,longitude: freezed == longitude ? _self.longitude : longitude // ignore: cast_nullable_to_non_nullable
as double?,
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

 List<Report> get results; int get count; String? get next; String? get previous;
/// Create a copy of PaginatedReports
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedReportsCopyWith<PaginatedReports> get copyWith => _$PaginatedReportsCopyWithImpl<PaginatedReports>(this as PaginatedReports, _$identity);

  /// Serializes this PaginatedReports to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedReports&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.count, count) || other.count == count)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),count,next,previous);

@override
String toString() {
  return 'PaginatedReports(results: $results, count: $count, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class $PaginatedReportsCopyWith<$Res>  {
  factory $PaginatedReportsCopyWith(PaginatedReports value, $Res Function(PaginatedReports) _then) = _$PaginatedReportsCopyWithImpl;
@useResult
$Res call({
 List<Report> results, int count, String? next, String? previous
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
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? count = null,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<Report>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<Report> results,  int count,  String? next,  String? previous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedReports() when $default != null:
return $default(_that.results,_that.count,_that.next,_that.previous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<Report> results,  int count,  String? next,  String? previous)  $default,) {final _that = this;
switch (_that) {
case _PaginatedReports():
return $default(_that.results,_that.count,_that.next,_that.previous);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<Report> results,  int count,  String? next,  String? previous)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedReports() when $default != null:
return $default(_that.results,_that.count,_that.next,_that.previous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedReports implements PaginatedReports {
  const _PaginatedReports({required final  List<Report> results, this.count = 0, this.next, this.previous}): _results = results;
  factory _PaginatedReports.fromJson(Map<String, dynamic> json) => _$PaginatedReportsFromJson(json);

 final  List<Report> _results;
@override List<Report> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int count;
@override final  String? next;
@override final  String? previous;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedReports&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.count, count) || other.count == count)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),count,next,previous);

@override
String toString() {
  return 'PaginatedReports(results: $results, count: $count, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class _$PaginatedReportsCopyWith<$Res> implements $PaginatedReportsCopyWith<$Res> {
  factory _$PaginatedReportsCopyWith(_PaginatedReports value, $Res Function(_PaginatedReports) _then) = __$PaginatedReportsCopyWithImpl;
@override @useResult
$Res call({
 List<Report> results, int count, String? next, String? previous
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
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? count = null,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_PaginatedReports(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<Report>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
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

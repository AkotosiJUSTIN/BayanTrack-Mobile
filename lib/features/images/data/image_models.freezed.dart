// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'image_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$UploadedImage {

@JsonKey(name: '_id') String get id;@JsonKey(name: 'report_id') String get reportId;@JsonKey(name: 'image_url') String get imageUrl;@JsonKey(name: 'thumbnail_url') String? get thumbnailUrl;@JsonKey(name: 'is_primary') bool get isPrimary;@JsonKey(name: 'uploaded_by') String? get uploadedBy;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of UploadedImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadedImageCopyWith<UploadedImage> get copyWith => _$UploadedImageCopyWithImpl<UploadedImage>(this as UploadedImage, _$identity);

  /// Serializes this UploadedImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadedImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,imageUrl,thumbnailUrl,isPrimary,uploadedBy,createdAt);

@override
String toString() {
  return 'UploadedImage(id: $id, reportId: $reportId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, isPrimary: $isPrimary, uploadedBy: $uploadedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $UploadedImageCopyWith<$Res>  {
  factory $UploadedImageCopyWith(UploadedImage value, $Res Function(UploadedImage) _then) = _$UploadedImageCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'uploaded_by') String? uploadedBy,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$UploadedImageCopyWithImpl<$Res>
    implements $UploadedImageCopyWith<$Res> {
  _$UploadedImageCopyWithImpl(this._self, this._then);

  final UploadedImage _self;
  final $Res Function(UploadedImage) _then;

/// Create a copy of UploadedImage
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? reportId = null,Object? imageUrl = null,Object? thumbnailUrl = freezed,Object? isPrimary = null,Object? uploadedBy = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [UploadedImage].
extension UploadedImagePatterns on UploadedImage {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _UploadedImage value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _UploadedImage() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _UploadedImage value)  $default,){
final _that = this;
switch (_that) {
case _UploadedImage():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _UploadedImage value)?  $default,){
final _that = this;
switch (_that) {
case _UploadedImage() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'uploaded_by')  String? uploadedBy, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadedImage() when $default != null:
return $default(_that.id,_that.reportId,_that.imageUrl,_that.thumbnailUrl,_that.isPrimary,_that.uploadedBy,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: '_id')  String id, @JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'uploaded_by')  String? uploadedBy, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _UploadedImage():
return $default(_that.id,_that.reportId,_that.imageUrl,_that.thumbnailUrl,_that.isPrimary,_that.uploadedBy,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: '_id')  String id, @JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'image_url')  String imageUrl, @JsonKey(name: 'thumbnail_url')  String? thumbnailUrl, @JsonKey(name: 'is_primary')  bool isPrimary, @JsonKey(name: 'uploaded_by')  String? uploadedBy, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _UploadedImage() when $default != null:
return $default(_that.id,_that.reportId,_that.imageUrl,_that.thumbnailUrl,_that.isPrimary,_that.uploadedBy,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadedImage implements UploadedImage {
  const _UploadedImage({@JsonKey(name: '_id') required this.id, @JsonKey(name: 'report_id') required this.reportId, @JsonKey(name: 'image_url') required this.imageUrl, @JsonKey(name: 'thumbnail_url') this.thumbnailUrl, @JsonKey(name: 'is_primary') this.isPrimary = false, @JsonKey(name: 'uploaded_by') this.uploadedBy, @JsonKey(name: 'created_at') this.createdAt});
  factory _UploadedImage.fromJson(Map<String, dynamic> json) => _$UploadedImageFromJson(json);

@override@JsonKey(name: '_id') final  String id;
@override@JsonKey(name: 'report_id') final  String reportId;
@override@JsonKey(name: 'image_url') final  String imageUrl;
@override@JsonKey(name: 'thumbnail_url') final  String? thumbnailUrl;
@override@JsonKey(name: 'is_primary') final  bool isPrimary;
@override@JsonKey(name: 'uploaded_by') final  String? uploadedBy;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of UploadedImage
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$UploadedImageCopyWith<_UploadedImage> get copyWith => __$UploadedImageCopyWithImpl<_UploadedImage>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$UploadedImageToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadedImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.imageUrl, imageUrl) || other.imageUrl == imageUrl)&&(identical(other.thumbnailUrl, thumbnailUrl) || other.thumbnailUrl == thumbnailUrl)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.uploadedBy, uploadedBy) || other.uploadedBy == uploadedBy)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,imageUrl,thumbnailUrl,isPrimary,uploadedBy,createdAt);

@override
String toString() {
  return 'UploadedImage(id: $id, reportId: $reportId, imageUrl: $imageUrl, thumbnailUrl: $thumbnailUrl, isPrimary: $isPrimary, uploadedBy: $uploadedBy, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$UploadedImageCopyWith<$Res> implements $UploadedImageCopyWith<$Res> {
  factory _$UploadedImageCopyWith(_UploadedImage value, $Res Function(_UploadedImage) _then) = __$UploadedImageCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: '_id') String id,@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'image_url') String imageUrl,@JsonKey(name: 'thumbnail_url') String? thumbnailUrl,@JsonKey(name: 'is_primary') bool isPrimary,@JsonKey(name: 'uploaded_by') String? uploadedBy,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$UploadedImageCopyWithImpl<$Res>
    implements _$UploadedImageCopyWith<$Res> {
  __$UploadedImageCopyWithImpl(this._self, this._then);

  final _UploadedImage _self;
  final $Res Function(_UploadedImage) _then;

/// Create a copy of UploadedImage
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = null,Object? imageUrl = null,Object? thumbnailUrl = freezed,Object? isPrimary = null,Object? uploadedBy = freezed,Object? createdAt = freezed,}) {
  return _then(_UploadedImage(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,imageUrl: null == imageUrl ? _self.imageUrl : imageUrl // ignore: cast_nullable_to_non_nullable
as String,thumbnailUrl: freezed == thumbnailUrl ? _self.thumbnailUrl : thumbnailUrl // ignore: cast_nullable_to_non_nullable
as String?,isPrimary: null == isPrimary ? _self.isPrimary : isPrimary // ignore: cast_nullable_to_non_nullable
as bool,uploadedBy: freezed == uploadedBy ? _self.uploadedBy : uploadedBy // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$ImageUploadResponse {

 String get message; UploadedImage? get image; List<UploadedImage>? get images;
/// Create a copy of ImageUploadResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageUploadResponseCopyWith<ImageUploadResponse> get copyWith => _$ImageUploadResponseCopyWithImpl<ImageUploadResponse>(this as ImageUploadResponse, _$identity);

  /// Serializes this ImageUploadResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageUploadResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.image, image) || other.image == image)&&const DeepCollectionEquality().equals(other.images, images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,image,const DeepCollectionEquality().hash(images));

@override
String toString() {
  return 'ImageUploadResponse(message: $message, image: $image, images: $images)';
}


}

/// @nodoc
abstract mixin class $ImageUploadResponseCopyWith<$Res>  {
  factory $ImageUploadResponseCopyWith(ImageUploadResponse value, $Res Function(ImageUploadResponse) _then) = _$ImageUploadResponseCopyWithImpl;
@useResult
$Res call({
 String message, UploadedImage? image, List<UploadedImage>? images
});


$UploadedImageCopyWith<$Res>? get image;

}
/// @nodoc
class _$ImageUploadResponseCopyWithImpl<$Res>
    implements $ImageUploadResponseCopyWith<$Res> {
  _$ImageUploadResponseCopyWithImpl(this._self, this._then);

  final ImageUploadResponse _self;
  final $Res Function(ImageUploadResponse) _then;

/// Create a copy of ImageUploadResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? message = null,Object? image = freezed,Object? images = freezed,}) {
  return _then(_self.copyWith(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as UploadedImage?,images: freezed == images ? _self.images : images // ignore: cast_nullable_to_non_nullable
as List<UploadedImage>?,
  ));
}
/// Create a copy of ImageUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadedImageCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $UploadedImageCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}


/// Adds pattern-matching-related methods to [ImageUploadResponse].
extension ImageUploadResponsePatterns on ImageUploadResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageUploadResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageUploadResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageUploadResponse value)  $default,){
final _that = this;
switch (_that) {
case _ImageUploadResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageUploadResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ImageUploadResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String message,  UploadedImage? image,  List<UploadedImage>? images)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageUploadResponse() when $default != null:
return $default(_that.message,_that.image,_that.images);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( String message,  UploadedImage? image,  List<UploadedImage>? images)  $default,) {final _that = this;
switch (_that) {
case _ImageUploadResponse():
return $default(_that.message,_that.image,_that.images);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( String message,  UploadedImage? image,  List<UploadedImage>? images)?  $default,) {final _that = this;
switch (_that) {
case _ImageUploadResponse() when $default != null:
return $default(_that.message,_that.image,_that.images);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageUploadResponse implements ImageUploadResponse {
  const _ImageUploadResponse({required this.message, this.image, final  List<UploadedImage>? images}): _images = images;
  factory _ImageUploadResponse.fromJson(Map<String, dynamic> json) => _$ImageUploadResponseFromJson(json);

@override final  String message;
@override final  UploadedImage? image;
 final  List<UploadedImage>? _images;
@override List<UploadedImage>? get images {
  final value = _images;
  if (value == null) return null;
  if (_images is EqualUnmodifiableListView) return _images;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(value);
}


/// Create a copy of ImageUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageUploadResponseCopyWith<_ImageUploadResponse> get copyWith => __$ImageUploadResponseCopyWithImpl<_ImageUploadResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageUploadResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageUploadResponse&&(identical(other.message, message) || other.message == message)&&(identical(other.image, image) || other.image == image)&&const DeepCollectionEquality().equals(other._images, _images));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,message,image,const DeepCollectionEquality().hash(_images));

@override
String toString() {
  return 'ImageUploadResponse(message: $message, image: $image, images: $images)';
}


}

/// @nodoc
abstract mixin class _$ImageUploadResponseCopyWith<$Res> implements $ImageUploadResponseCopyWith<$Res> {
  factory _$ImageUploadResponseCopyWith(_ImageUploadResponse value, $Res Function(_ImageUploadResponse) _then) = __$ImageUploadResponseCopyWithImpl;
@override @useResult
$Res call({
 String message, UploadedImage? image, List<UploadedImage>? images
});


@override $UploadedImageCopyWith<$Res>? get image;

}
/// @nodoc
class __$ImageUploadResponseCopyWithImpl<$Res>
    implements _$ImageUploadResponseCopyWith<$Res> {
  __$ImageUploadResponseCopyWithImpl(this._self, this._then);

  final _ImageUploadResponse _self;
  final $Res Function(_ImageUploadResponse) _then;

/// Create a copy of ImageUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? message = null,Object? image = freezed,Object? images = freezed,}) {
  return _then(_ImageUploadResponse(
message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,image: freezed == image ? _self.image : image // ignore: cast_nullable_to_non_nullable
as UploadedImage?,images: freezed == images ? _self._images : images // ignore: cast_nullable_to_non_nullable
as List<UploadedImage>?,
  ));
}

/// Create a copy of ImageUploadResponse
/// with the given fields replaced by the non-null parameter values.
@override
@pragma('vm:prefer-inline')
$UploadedImageCopyWith<$Res>? get image {
    if (_self.image == null) {
    return null;
  }

  return $UploadedImageCopyWith<$Res>(_self.image!, (value) {
    return _then(_self.copyWith(image: value));
  });
}
}


/// @nodoc
mixin _$ImageListResponse {

 List<UploadedImage> get results; int get count;
/// Create a copy of ImageListResponse
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$ImageListResponseCopyWith<ImageListResponse> get copyWith => _$ImageListResponseCopyWithImpl<ImageListResponse>(this as ImageListResponse, _$identity);

  /// Serializes this ImageListResponse to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is ImageListResponse&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),count);

@override
String toString() {
  return 'ImageListResponse(results: $results, count: $count)';
}


}

/// @nodoc
abstract mixin class $ImageListResponseCopyWith<$Res>  {
  factory $ImageListResponseCopyWith(ImageListResponse value, $Res Function(ImageListResponse) _then) = _$ImageListResponseCopyWithImpl;
@useResult
$Res call({
 List<UploadedImage> results, int count
});




}
/// @nodoc
class _$ImageListResponseCopyWithImpl<$Res>
    implements $ImageListResponseCopyWith<$Res> {
  _$ImageListResponseCopyWithImpl(this._self, this._then);

  final ImageListResponse _self;
  final $Res Function(ImageListResponse) _then;

/// Create a copy of ImageListResponse
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? count = null,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<UploadedImage>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [ImageListResponse].
extension ImageListResponsePatterns on ImageListResponse {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _ImageListResponse value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _ImageListResponse() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _ImageListResponse value)  $default,){
final _that = this;
switch (_that) {
case _ImageListResponse():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _ImageListResponse value)?  $default,){
final _that = this;
switch (_that) {
case _ImageListResponse() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( List<UploadedImage> results,  int count)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _ImageListResponse() when $default != null:
return $default(_that.results,_that.count);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function( List<UploadedImage> results,  int count)  $default,) {final _that = this;
switch (_that) {
case _ImageListResponse():
return $default(_that.results,_that.count);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function( List<UploadedImage> results,  int count)?  $default,) {final _that = this;
switch (_that) {
case _ImageListResponse() when $default != null:
return $default(_that.results,_that.count);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _ImageListResponse implements ImageListResponse {
  const _ImageListResponse({final  List<UploadedImage> results = const [], this.count = 0}): _results = results;
  factory _ImageListResponse.fromJson(Map<String, dynamic> json) => _$ImageListResponseFromJson(json);

 final  List<UploadedImage> _results;
@override@JsonKey() List<UploadedImage> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int count;

/// Create a copy of ImageListResponse
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$ImageListResponseCopyWith<_ImageListResponse> get copyWith => __$ImageListResponseCopyWithImpl<_ImageListResponse>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$ImageListResponseToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _ImageListResponse&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.count, count) || other.count == count));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),count);

@override
String toString() {
  return 'ImageListResponse(results: $results, count: $count)';
}


}

/// @nodoc
abstract mixin class _$ImageListResponseCopyWith<$Res> implements $ImageListResponseCopyWith<$Res> {
  factory _$ImageListResponseCopyWith(_ImageListResponse value, $Res Function(_ImageListResponse) _then) = __$ImageListResponseCopyWithImpl;
@override @useResult
$Res call({
 List<UploadedImage> results, int count
});




}
/// @nodoc
class __$ImageListResponseCopyWithImpl<$Res>
    implements _$ImageListResponseCopyWith<$Res> {
  __$ImageListResponseCopyWithImpl(this._self, this._then);

  final _ImageListResponse _self;
  final $Res Function(_ImageListResponse) _then;

/// Create a copy of ImageListResponse
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? count = null,}) {
  return _then(_ImageListResponse(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<UploadedImage>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}

// dart format on

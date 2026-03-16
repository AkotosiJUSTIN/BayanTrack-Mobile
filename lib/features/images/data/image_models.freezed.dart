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

 String get id;@JsonKey(name: 'report_id') String? get reportId;@JsonKey(name: 'user_id') String? get userId; String get url;// Backend returns 'url' not 'image_url'
@JsonKey(name: 's3_key') String? get s3Key; String? get filename;@JsonKey(name: 'file_size') int? get fileSize;@JsonKey(name: 'mime_type') String? get mimeType; int? get width; int? get height;@JsonKey(name: 'is_primary') bool get isPrimary;/// 'evidence' | 'signature' | 'document' — null means legacy record.
 String? get purpose;@JsonKey(name: 'created_at') String? get createdAt;@JsonKey(name: 'updated_at') String? get updatedAt;
/// Create a copy of UploadedImage
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$UploadedImageCopyWith<UploadedImage> get copyWith => _$UploadedImageCopyWithImpl<UploadedImage>(this as UploadedImage, _$identity);

  /// Serializes this UploadedImage to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is UploadedImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,url,s3Key,filename,fileSize,mimeType,width,height,isPrimary,purpose,createdAt,updatedAt);

@override
String toString() {
  return 'UploadedImage(id: $id, reportId: $reportId, userId: $userId, url: $url, s3Key: $s3Key, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, width: $width, height: $height, isPrimary: $isPrimary, purpose: $purpose, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class $UploadedImageCopyWith<$Res>  {
  factory $UploadedImageCopyWith(UploadedImage value, $Res Function(UploadedImage) _then) = _$UploadedImageCopyWithImpl;
@useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String url,@JsonKey(name: 's3_key') String? s3Key, String? filename,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, int? width, int? height,@JsonKey(name: 'is_primary') bool isPrimary, String? purpose,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function( String id, @JsonKey(name: 'report_id')  String? reportId, @JsonKey(name: 'user_id')  String? userId,  String url, @JsonKey(name: 's3_key')  String? s3Key,  String? filename, @JsonKey(name: 'file_size')  int? fileSize, @JsonKey(name: 'mime_type')  String? mimeType,  int? width,  int? height, @JsonKey(name: 'is_primary')  bool isPrimary,  String? purpose, @JsonKey(name: 'created_at')  String? createdAt, @JsonKey(name: 'updated_at')  String? updatedAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _UploadedImage() when $default != null:
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
case _UploadedImage():
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
case _UploadedImage() when $default != null:
return $default(_that.id,_that.reportId,_that.userId,_that.url,_that.s3Key,_that.filename,_that.fileSize,_that.mimeType,_that.width,_that.height,_that.isPrimary,_that.purpose,_that.createdAt,_that.updatedAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _UploadedImage implements UploadedImage {
  const _UploadedImage({required this.id, @JsonKey(name: 'report_id') this.reportId, @JsonKey(name: 'user_id') this.userId, required this.url, @JsonKey(name: 's3_key') this.s3Key, this.filename, @JsonKey(name: 'file_size') this.fileSize, @JsonKey(name: 'mime_type') this.mimeType, this.width, this.height, @JsonKey(name: 'is_primary') this.isPrimary = false, this.purpose, @JsonKey(name: 'created_at') this.createdAt, @JsonKey(name: 'updated_at') this.updatedAt});
  factory _UploadedImage.fromJson(Map<String, dynamic> json) => _$UploadedImageFromJson(json);

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
/// 'evidence' | 'signature' | 'document' — null means legacy record.
@override final  String? purpose;
@override@JsonKey(name: 'created_at') final  String? createdAt;
@override@JsonKey(name: 'updated_at') final  String? updatedAt;

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
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _UploadedImage&&(identical(other.id, id) || other.id == id)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.userId, userId) || other.userId == userId)&&(identical(other.url, url) || other.url == url)&&(identical(other.s3Key, s3Key) || other.s3Key == s3Key)&&(identical(other.filename, filename) || other.filename == filename)&&(identical(other.fileSize, fileSize) || other.fileSize == fileSize)&&(identical(other.mimeType, mimeType) || other.mimeType == mimeType)&&(identical(other.width, width) || other.width == width)&&(identical(other.height, height) || other.height == height)&&(identical(other.isPrimary, isPrimary) || other.isPrimary == isPrimary)&&(identical(other.purpose, purpose) || other.purpose == purpose)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt)&&(identical(other.updatedAt, updatedAt) || other.updatedAt == updatedAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,reportId,userId,url,s3Key,filename,fileSize,mimeType,width,height,isPrimary,purpose,createdAt,updatedAt);

@override
String toString() {
  return 'UploadedImage(id: $id, reportId: $reportId, userId: $userId, url: $url, s3Key: $s3Key, filename: $filename, fileSize: $fileSize, mimeType: $mimeType, width: $width, height: $height, isPrimary: $isPrimary, purpose: $purpose, createdAt: $createdAt, updatedAt: $updatedAt)';
}


}

/// @nodoc
abstract mixin class _$UploadedImageCopyWith<$Res> implements $UploadedImageCopyWith<$Res> {
  factory _$UploadedImageCopyWith(_UploadedImage value, $Res Function(_UploadedImage) _then) = __$UploadedImageCopyWithImpl;
@override @useResult
$Res call({
 String id,@JsonKey(name: 'report_id') String? reportId,@JsonKey(name: 'user_id') String? userId, String url,@JsonKey(name: 's3_key') String? s3Key, String? filename,@JsonKey(name: 'file_size') int? fileSize,@JsonKey(name: 'mime_type') String? mimeType, int? width, int? height,@JsonKey(name: 'is_primary') bool isPrimary, String? purpose,@JsonKey(name: 'created_at') String? createdAt,@JsonKey(name: 'updated_at') String? updatedAt
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
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? reportId = freezed,Object? userId = freezed,Object? url = null,Object? s3Key = freezed,Object? filename = freezed,Object? fileSize = freezed,Object? mimeType = freezed,Object? width = freezed,Object? height = freezed,Object? isPrimary = null,Object? purpose = freezed,Object? createdAt = freezed,Object? updatedAt = freezed,}) {
  return _then(_UploadedImage(
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

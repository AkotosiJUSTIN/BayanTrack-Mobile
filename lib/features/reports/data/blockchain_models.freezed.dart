// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'blockchain_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$BlockchainAuditEntryDto {

@JsonKey(name: 'reportId')@StringValueConverter() String get reportId;@JsonKey(name: 'actionType')@NullableIntConverter() int get actionType;@JsonKey(name: 'actor') String get actor;@JsonKey(name: 'timestamp')@NullableIntConverter() int get timestamp;@JsonKey(name: 'detailsHash') String get detailsHash;@JsonKey(name: 'oldStatus')@NullableIntConverter() int get oldStatus;@JsonKey(name: 'newStatus')@NullableIntConverter() int get newStatus;
/// Create a copy of BlockchainAuditEntryDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockchainAuditEntryDtoCopyWith<BlockchainAuditEntryDto> get copyWith => _$BlockchainAuditEntryDtoCopyWithImpl<BlockchainAuditEntryDto>(this as BlockchainAuditEntryDto, _$identity);

  /// Serializes this BlockchainAuditEntryDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockchainAuditEntryDto&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.detailsHash, detailsHash) || other.detailsHash == detailsHash)&&(identical(other.oldStatus, oldStatus) || other.oldStatus == oldStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportId,actionType,actor,timestamp,detailsHash,oldStatus,newStatus);

@override
String toString() {
  return 'BlockchainAuditEntryDto(reportId: $reportId, actionType: $actionType, actor: $actor, timestamp: $timestamp, detailsHash: $detailsHash, oldStatus: $oldStatus, newStatus: $newStatus)';
}


}

/// @nodoc
abstract mixin class $BlockchainAuditEntryDtoCopyWith<$Res>  {
  factory $BlockchainAuditEntryDtoCopyWith(BlockchainAuditEntryDto value, $Res Function(BlockchainAuditEntryDto) _then) = _$BlockchainAuditEntryDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'reportId')@StringValueConverter() String reportId,@JsonKey(name: 'actionType')@NullableIntConverter() int actionType,@JsonKey(name: 'actor') String actor,@JsonKey(name: 'timestamp')@NullableIntConverter() int timestamp,@JsonKey(name: 'detailsHash') String detailsHash,@JsonKey(name: 'oldStatus')@NullableIntConverter() int oldStatus,@JsonKey(name: 'newStatus')@NullableIntConverter() int newStatus
});




}
/// @nodoc
class _$BlockchainAuditEntryDtoCopyWithImpl<$Res>
    implements $BlockchainAuditEntryDtoCopyWith<$Res> {
  _$BlockchainAuditEntryDtoCopyWithImpl(this._self, this._then);

  final BlockchainAuditEntryDto _self;
  final $Res Function(BlockchainAuditEntryDto) _then;

/// Create a copy of BlockchainAuditEntryDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportId = null,Object? actionType = null,Object? actor = null,Object? timestamp = null,Object? detailsHash = null,Object? oldStatus = null,Object? newStatus = null,}) {
  return _then(_self.copyWith(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as int,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,detailsHash: null == detailsHash ? _self.detailsHash : detailsHash // ignore: cast_nullable_to_non_nullable
as String,oldStatus: null == oldStatus ? _self.oldStatus : oldStatus // ignore: cast_nullable_to_non_nullable
as int,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockchainAuditEntryDto].
extension BlockchainAuditEntryDtoPatterns on BlockchainAuditEntryDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockchainAuditEntryDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockchainAuditEntryDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockchainAuditEntryDto value)  $default,){
final _that = this;
switch (_that) {
case _BlockchainAuditEntryDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockchainAuditEntryDto value)?  $default,){
final _that = this;
switch (_that) {
case _BlockchainAuditEntryDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'reportId')@StringValueConverter()  String reportId, @JsonKey(name: 'actionType')@NullableIntConverter()  int actionType, @JsonKey(name: 'actor')  String actor, @JsonKey(name: 'timestamp')@NullableIntConverter()  int timestamp, @JsonKey(name: 'detailsHash')  String detailsHash, @JsonKey(name: 'oldStatus')@NullableIntConverter()  int oldStatus, @JsonKey(name: 'newStatus')@NullableIntConverter()  int newStatus)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockchainAuditEntryDto() when $default != null:
return $default(_that.reportId,_that.actionType,_that.actor,_that.timestamp,_that.detailsHash,_that.oldStatus,_that.newStatus);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'reportId')@StringValueConverter()  String reportId, @JsonKey(name: 'actionType')@NullableIntConverter()  int actionType, @JsonKey(name: 'actor')  String actor, @JsonKey(name: 'timestamp')@NullableIntConverter()  int timestamp, @JsonKey(name: 'detailsHash')  String detailsHash, @JsonKey(name: 'oldStatus')@NullableIntConverter()  int oldStatus, @JsonKey(name: 'newStatus')@NullableIntConverter()  int newStatus)  $default,) {final _that = this;
switch (_that) {
case _BlockchainAuditEntryDto():
return $default(_that.reportId,_that.actionType,_that.actor,_that.timestamp,_that.detailsHash,_that.oldStatus,_that.newStatus);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'reportId')@StringValueConverter()  String reportId, @JsonKey(name: 'actionType')@NullableIntConverter()  int actionType, @JsonKey(name: 'actor')  String actor, @JsonKey(name: 'timestamp')@NullableIntConverter()  int timestamp, @JsonKey(name: 'detailsHash')  String detailsHash, @JsonKey(name: 'oldStatus')@NullableIntConverter()  int oldStatus, @JsonKey(name: 'newStatus')@NullableIntConverter()  int newStatus)?  $default,) {final _that = this;
switch (_that) {
case _BlockchainAuditEntryDto() when $default != null:
return $default(_that.reportId,_that.actionType,_that.actor,_that.timestamp,_that.detailsHash,_that.oldStatus,_that.newStatus);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockchainAuditEntryDto implements BlockchainAuditEntryDto {
  const _BlockchainAuditEntryDto({@JsonKey(name: 'reportId')@StringValueConverter() required this.reportId, @JsonKey(name: 'actionType')@NullableIntConverter() required this.actionType, @JsonKey(name: 'actor') required this.actor, @JsonKey(name: 'timestamp')@NullableIntConverter() required this.timestamp, @JsonKey(name: 'detailsHash') required this.detailsHash, @JsonKey(name: 'oldStatus')@NullableIntConverter() required this.oldStatus, @JsonKey(name: 'newStatus')@NullableIntConverter() required this.newStatus});
  factory _BlockchainAuditEntryDto.fromJson(Map<String, dynamic> json) => _$BlockchainAuditEntryDtoFromJson(json);

@override@JsonKey(name: 'reportId')@StringValueConverter() final  String reportId;
@override@JsonKey(name: 'actionType')@NullableIntConverter() final  int actionType;
@override@JsonKey(name: 'actor') final  String actor;
@override@JsonKey(name: 'timestamp')@NullableIntConverter() final  int timestamp;
@override@JsonKey(name: 'detailsHash') final  String detailsHash;
@override@JsonKey(name: 'oldStatus')@NullableIntConverter() final  int oldStatus;
@override@JsonKey(name: 'newStatus')@NullableIntConverter() final  int newStatus;

/// Create a copy of BlockchainAuditEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockchainAuditEntryDtoCopyWith<_BlockchainAuditEntryDto> get copyWith => __$BlockchainAuditEntryDtoCopyWithImpl<_BlockchainAuditEntryDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockchainAuditEntryDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockchainAuditEntryDto&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.actionType, actionType) || other.actionType == actionType)&&(identical(other.actor, actor) || other.actor == actor)&&(identical(other.timestamp, timestamp) || other.timestamp == timestamp)&&(identical(other.detailsHash, detailsHash) || other.detailsHash == detailsHash)&&(identical(other.oldStatus, oldStatus) || other.oldStatus == oldStatus)&&(identical(other.newStatus, newStatus) || other.newStatus == newStatus));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportId,actionType,actor,timestamp,detailsHash,oldStatus,newStatus);

@override
String toString() {
  return 'BlockchainAuditEntryDto(reportId: $reportId, actionType: $actionType, actor: $actor, timestamp: $timestamp, detailsHash: $detailsHash, oldStatus: $oldStatus, newStatus: $newStatus)';
}


}

/// @nodoc
abstract mixin class _$BlockchainAuditEntryDtoCopyWith<$Res> implements $BlockchainAuditEntryDtoCopyWith<$Res> {
  factory _$BlockchainAuditEntryDtoCopyWith(_BlockchainAuditEntryDto value, $Res Function(_BlockchainAuditEntryDto) _then) = __$BlockchainAuditEntryDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'reportId')@StringValueConverter() String reportId,@JsonKey(name: 'actionType')@NullableIntConverter() int actionType,@JsonKey(name: 'actor') String actor,@JsonKey(name: 'timestamp')@NullableIntConverter() int timestamp,@JsonKey(name: 'detailsHash') String detailsHash,@JsonKey(name: 'oldStatus')@NullableIntConverter() int oldStatus,@JsonKey(name: 'newStatus')@NullableIntConverter() int newStatus
});




}
/// @nodoc
class __$BlockchainAuditEntryDtoCopyWithImpl<$Res>
    implements _$BlockchainAuditEntryDtoCopyWith<$Res> {
  __$BlockchainAuditEntryDtoCopyWithImpl(this._self, this._then);

  final _BlockchainAuditEntryDto _self;
  final $Res Function(_BlockchainAuditEntryDto) _then;

/// Create a copy of BlockchainAuditEntryDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportId = null,Object? actionType = null,Object? actor = null,Object? timestamp = null,Object? detailsHash = null,Object? oldStatus = null,Object? newStatus = null,}) {
  return _then(_BlockchainAuditEntryDto(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,actionType: null == actionType ? _self.actionType : actionType // ignore: cast_nullable_to_non_nullable
as int,actor: null == actor ? _self.actor : actor // ignore: cast_nullable_to_non_nullable
as String,timestamp: null == timestamp ? _self.timestamp : timestamp // ignore: cast_nullable_to_non_nullable
as int,detailsHash: null == detailsHash ? _self.detailsHash : detailsHash // ignore: cast_nullable_to_non_nullable
as String,oldStatus: null == oldStatus ? _self.oldStatus : oldStatus // ignore: cast_nullable_to_non_nullable
as int,newStatus: null == newStatus ? _self.newStatus : newStatus // ignore: cast_nullable_to_non_nullable
as int,
  ));
}


}


/// @nodoc
mixin _$BlockchainVerificationResultDto {

@JsonKey(name: 'report_id') String get reportId;@JsonKey(name: 'on_chain_id')@NullableStringConverter() String? get onChainId; bool get verified;@JsonKey(name: 'original_snapshot_verified') bool? get originalSnapshotVerified;@JsonKey(name: 'current_content_verified') bool? get currentContentVerified;@JsonKey(name: 'status_verified') bool? get statusVerified;@JsonKey(name: 'blockchain_data') Map<String, dynamic> get blockchainData;@JsonKey(name: 'audit_history') List<BlockchainAuditEntryDto> get auditHistory; String get message;@JsonKey(name: 'not_found_on_chain') bool get notFoundOnChain;@JsonKey(name: 'connection_error') bool get connectionError;@JsonKey(name: 'is_anchored') bool get isAnchored;
/// Create a copy of BlockchainVerificationResultDto
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$BlockchainVerificationResultDtoCopyWith<BlockchainVerificationResultDto> get copyWith => _$BlockchainVerificationResultDtoCopyWithImpl<BlockchainVerificationResultDto>(this as BlockchainVerificationResultDto, _$identity);

  /// Serializes this BlockchainVerificationResultDto to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is BlockchainVerificationResultDto&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.onChainId, onChainId) || other.onChainId == onChainId)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.originalSnapshotVerified, originalSnapshotVerified) || other.originalSnapshotVerified == originalSnapshotVerified)&&(identical(other.currentContentVerified, currentContentVerified) || other.currentContentVerified == currentContentVerified)&&(identical(other.statusVerified, statusVerified) || other.statusVerified == statusVerified)&&const DeepCollectionEquality().equals(other.blockchainData, blockchainData)&&const DeepCollectionEquality().equals(other.auditHistory, auditHistory)&&(identical(other.message, message) || other.message == message)&&(identical(other.notFoundOnChain, notFoundOnChain) || other.notFoundOnChain == notFoundOnChain)&&(identical(other.connectionError, connectionError) || other.connectionError == connectionError)&&(identical(other.isAnchored, isAnchored) || other.isAnchored == isAnchored));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportId,onChainId,verified,originalSnapshotVerified,currentContentVerified,statusVerified,const DeepCollectionEquality().hash(blockchainData),const DeepCollectionEquality().hash(auditHistory),message,notFoundOnChain,connectionError,isAnchored);

@override
String toString() {
  return 'BlockchainVerificationResultDto(reportId: $reportId, onChainId: $onChainId, verified: $verified, originalSnapshotVerified: $originalSnapshotVerified, currentContentVerified: $currentContentVerified, statusVerified: $statusVerified, blockchainData: $blockchainData, auditHistory: $auditHistory, message: $message, notFoundOnChain: $notFoundOnChain, connectionError: $connectionError, isAnchored: $isAnchored)';
}


}

/// @nodoc
abstract mixin class $BlockchainVerificationResultDtoCopyWith<$Res>  {
  factory $BlockchainVerificationResultDtoCopyWith(BlockchainVerificationResultDto value, $Res Function(BlockchainVerificationResultDto) _then) = _$BlockchainVerificationResultDtoCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'on_chain_id')@NullableStringConverter() String? onChainId, bool verified,@JsonKey(name: 'original_snapshot_verified') bool? originalSnapshotVerified,@JsonKey(name: 'current_content_verified') bool? currentContentVerified,@JsonKey(name: 'status_verified') bool? statusVerified,@JsonKey(name: 'blockchain_data') Map<String, dynamic> blockchainData,@JsonKey(name: 'audit_history') List<BlockchainAuditEntryDto> auditHistory, String message,@JsonKey(name: 'not_found_on_chain') bool notFoundOnChain,@JsonKey(name: 'connection_error') bool connectionError,@JsonKey(name: 'is_anchored') bool isAnchored
});




}
/// @nodoc
class _$BlockchainVerificationResultDtoCopyWithImpl<$Res>
    implements $BlockchainVerificationResultDtoCopyWith<$Res> {
  _$BlockchainVerificationResultDtoCopyWithImpl(this._self, this._then);

  final BlockchainVerificationResultDto _self;
  final $Res Function(BlockchainVerificationResultDto) _then;

/// Create a copy of BlockchainVerificationResultDto
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? reportId = null,Object? onChainId = freezed,Object? verified = null,Object? originalSnapshotVerified = freezed,Object? currentContentVerified = freezed,Object? statusVerified = freezed,Object? blockchainData = null,Object? auditHistory = null,Object? message = null,Object? notFoundOnChain = null,Object? connectionError = null,Object? isAnchored = null,}) {
  return _then(_self.copyWith(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,onChainId: freezed == onChainId ? _self.onChainId : onChainId // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,originalSnapshotVerified: freezed == originalSnapshotVerified ? _self.originalSnapshotVerified : originalSnapshotVerified // ignore: cast_nullable_to_non_nullable
as bool?,currentContentVerified: freezed == currentContentVerified ? _self.currentContentVerified : currentContentVerified // ignore: cast_nullable_to_non_nullable
as bool?,statusVerified: freezed == statusVerified ? _self.statusVerified : statusVerified // ignore: cast_nullable_to_non_nullable
as bool?,blockchainData: null == blockchainData ? _self.blockchainData : blockchainData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,auditHistory: null == auditHistory ? _self.auditHistory : auditHistory // ignore: cast_nullable_to_non_nullable
as List<BlockchainAuditEntryDto>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,notFoundOnChain: null == notFoundOnChain ? _self.notFoundOnChain : notFoundOnChain // ignore: cast_nullable_to_non_nullable
as bool,connectionError: null == connectionError ? _self.connectionError : connectionError // ignore: cast_nullable_to_non_nullable
as bool,isAnchored: null == isAnchored ? _self.isAnchored : isAnchored // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [BlockchainVerificationResultDto].
extension BlockchainVerificationResultDtoPatterns on BlockchainVerificationResultDto {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _BlockchainVerificationResultDto value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _BlockchainVerificationResultDto() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _BlockchainVerificationResultDto value)  $default,){
final _that = this;
switch (_that) {
case _BlockchainVerificationResultDto():
return $default(_that);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _BlockchainVerificationResultDto value)?  $default,){
final _that = this;
switch (_that) {
case _BlockchainVerificationResultDto() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'on_chain_id')@NullableStringConverter()  String? onChainId,  bool verified, @JsonKey(name: 'original_snapshot_verified')  bool? originalSnapshotVerified, @JsonKey(name: 'current_content_verified')  bool? currentContentVerified, @JsonKey(name: 'status_verified')  bool? statusVerified, @JsonKey(name: 'blockchain_data')  Map<String, dynamic> blockchainData, @JsonKey(name: 'audit_history')  List<BlockchainAuditEntryDto> auditHistory,  String message, @JsonKey(name: 'not_found_on_chain')  bool notFoundOnChain, @JsonKey(name: 'connection_error')  bool connectionError, @JsonKey(name: 'is_anchored')  bool isAnchored)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _BlockchainVerificationResultDto() when $default != null:
return $default(_that.reportId,_that.onChainId,_that.verified,_that.originalSnapshotVerified,_that.currentContentVerified,_that.statusVerified,_that.blockchainData,_that.auditHistory,_that.message,_that.notFoundOnChain,_that.connectionError,_that.isAnchored);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'on_chain_id')@NullableStringConverter()  String? onChainId,  bool verified, @JsonKey(name: 'original_snapshot_verified')  bool? originalSnapshotVerified, @JsonKey(name: 'current_content_verified')  bool? currentContentVerified, @JsonKey(name: 'status_verified')  bool? statusVerified, @JsonKey(name: 'blockchain_data')  Map<String, dynamic> blockchainData, @JsonKey(name: 'audit_history')  List<BlockchainAuditEntryDto> auditHistory,  String message, @JsonKey(name: 'not_found_on_chain')  bool notFoundOnChain, @JsonKey(name: 'connection_error')  bool connectionError, @JsonKey(name: 'is_anchored')  bool isAnchored)  $default,) {final _that = this;
switch (_that) {
case _BlockchainVerificationResultDto():
return $default(_that.reportId,_that.onChainId,_that.verified,_that.originalSnapshotVerified,_that.currentContentVerified,_that.statusVerified,_that.blockchainData,_that.auditHistory,_that.message,_that.notFoundOnChain,_that.connectionError,_that.isAnchored);case _:
  throw StateError('Unexpected subclass');

}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'report_id')  String reportId, @JsonKey(name: 'on_chain_id')@NullableStringConverter()  String? onChainId,  bool verified, @JsonKey(name: 'original_snapshot_verified')  bool? originalSnapshotVerified, @JsonKey(name: 'current_content_verified')  bool? currentContentVerified, @JsonKey(name: 'status_verified')  bool? statusVerified, @JsonKey(name: 'blockchain_data')  Map<String, dynamic> blockchainData, @JsonKey(name: 'audit_history')  List<BlockchainAuditEntryDto> auditHistory,  String message, @JsonKey(name: 'not_found_on_chain')  bool notFoundOnChain, @JsonKey(name: 'connection_error')  bool connectionError, @JsonKey(name: 'is_anchored')  bool isAnchored)?  $default,) {final _that = this;
switch (_that) {
case _BlockchainVerificationResultDto() when $default != null:
return $default(_that.reportId,_that.onChainId,_that.verified,_that.originalSnapshotVerified,_that.currentContentVerified,_that.statusVerified,_that.blockchainData,_that.auditHistory,_that.message,_that.notFoundOnChain,_that.connectionError,_that.isAnchored);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _BlockchainVerificationResultDto implements BlockchainVerificationResultDto {
  const _BlockchainVerificationResultDto({@JsonKey(name: 'report_id') required this.reportId, @JsonKey(name: 'on_chain_id')@NullableStringConverter() this.onChainId, required this.verified, @JsonKey(name: 'original_snapshot_verified') this.originalSnapshotVerified, @JsonKey(name: 'current_content_verified') this.currentContentVerified, @JsonKey(name: 'status_verified') this.statusVerified, @JsonKey(name: 'blockchain_data') required final  Map<String, dynamic> blockchainData, @JsonKey(name: 'audit_history') required final  List<BlockchainAuditEntryDto> auditHistory, required this.message, @JsonKey(name: 'not_found_on_chain') this.notFoundOnChain = false, @JsonKey(name: 'connection_error') this.connectionError = false, @JsonKey(name: 'is_anchored') this.isAnchored = true}): _blockchainData = blockchainData,_auditHistory = auditHistory;
  factory _BlockchainVerificationResultDto.fromJson(Map<String, dynamic> json) => _$BlockchainVerificationResultDtoFromJson(json);

@override@JsonKey(name: 'report_id') final  String reportId;
@override@JsonKey(name: 'on_chain_id')@NullableStringConverter() final  String? onChainId;
@override final  bool verified;
@override@JsonKey(name: 'original_snapshot_verified') final  bool? originalSnapshotVerified;
@override@JsonKey(name: 'current_content_verified') final  bool? currentContentVerified;
@override@JsonKey(name: 'status_verified') final  bool? statusVerified;
 final  Map<String, dynamic> _blockchainData;
@override@JsonKey(name: 'blockchain_data') Map<String, dynamic> get blockchainData {
  if (_blockchainData is EqualUnmodifiableMapView) return _blockchainData;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableMapView(_blockchainData);
}

 final  List<BlockchainAuditEntryDto> _auditHistory;
@override@JsonKey(name: 'audit_history') List<BlockchainAuditEntryDto> get auditHistory {
  if (_auditHistory is EqualUnmodifiableListView) return _auditHistory;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_auditHistory);
}

@override final  String message;
@override@JsonKey(name: 'not_found_on_chain') final  bool notFoundOnChain;
@override@JsonKey(name: 'connection_error') final  bool connectionError;
@override@JsonKey(name: 'is_anchored') final  bool isAnchored;

/// Create a copy of BlockchainVerificationResultDto
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$BlockchainVerificationResultDtoCopyWith<_BlockchainVerificationResultDto> get copyWith => __$BlockchainVerificationResultDtoCopyWithImpl<_BlockchainVerificationResultDto>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$BlockchainVerificationResultDtoToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _BlockchainVerificationResultDto&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.onChainId, onChainId) || other.onChainId == onChainId)&&(identical(other.verified, verified) || other.verified == verified)&&(identical(other.originalSnapshotVerified, originalSnapshotVerified) || other.originalSnapshotVerified == originalSnapshotVerified)&&(identical(other.currentContentVerified, currentContentVerified) || other.currentContentVerified == currentContentVerified)&&(identical(other.statusVerified, statusVerified) || other.statusVerified == statusVerified)&&const DeepCollectionEquality().equals(other._blockchainData, _blockchainData)&&const DeepCollectionEquality().equals(other._auditHistory, _auditHistory)&&(identical(other.message, message) || other.message == message)&&(identical(other.notFoundOnChain, notFoundOnChain) || other.notFoundOnChain == notFoundOnChain)&&(identical(other.connectionError, connectionError) || other.connectionError == connectionError)&&(identical(other.isAnchored, isAnchored) || other.isAnchored == isAnchored));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,reportId,onChainId,verified,originalSnapshotVerified,currentContentVerified,statusVerified,const DeepCollectionEquality().hash(_blockchainData),const DeepCollectionEquality().hash(_auditHistory),message,notFoundOnChain,connectionError,isAnchored);

@override
String toString() {
  return 'BlockchainVerificationResultDto(reportId: $reportId, onChainId: $onChainId, verified: $verified, originalSnapshotVerified: $originalSnapshotVerified, currentContentVerified: $currentContentVerified, statusVerified: $statusVerified, blockchainData: $blockchainData, auditHistory: $auditHistory, message: $message, notFoundOnChain: $notFoundOnChain, connectionError: $connectionError, isAnchored: $isAnchored)';
}


}

/// @nodoc
abstract mixin class _$BlockchainVerificationResultDtoCopyWith<$Res> implements $BlockchainVerificationResultDtoCopyWith<$Res> {
  factory _$BlockchainVerificationResultDtoCopyWith(_BlockchainVerificationResultDto value, $Res Function(_BlockchainVerificationResultDto) _then) = __$BlockchainVerificationResultDtoCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'report_id') String reportId,@JsonKey(name: 'on_chain_id')@NullableStringConverter() String? onChainId, bool verified,@JsonKey(name: 'original_snapshot_verified') bool? originalSnapshotVerified,@JsonKey(name: 'current_content_verified') bool? currentContentVerified,@JsonKey(name: 'status_verified') bool? statusVerified,@JsonKey(name: 'blockchain_data') Map<String, dynamic> blockchainData,@JsonKey(name: 'audit_history') List<BlockchainAuditEntryDto> auditHistory, String message,@JsonKey(name: 'not_found_on_chain') bool notFoundOnChain,@JsonKey(name: 'connection_error') bool connectionError,@JsonKey(name: 'is_anchored') bool isAnchored
});




}
/// @nodoc
class __$BlockchainVerificationResultDtoCopyWithImpl<$Res>
    implements _$BlockchainVerificationResultDtoCopyWith<$Res> {
  __$BlockchainVerificationResultDtoCopyWithImpl(this._self, this._then);

  final _BlockchainVerificationResultDto _self;
  final $Res Function(_BlockchainVerificationResultDto) _then;

/// Create a copy of BlockchainVerificationResultDto
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? reportId = null,Object? onChainId = freezed,Object? verified = null,Object? originalSnapshotVerified = freezed,Object? currentContentVerified = freezed,Object? statusVerified = freezed,Object? blockchainData = null,Object? auditHistory = null,Object? message = null,Object? notFoundOnChain = null,Object? connectionError = null,Object? isAnchored = null,}) {
  return _then(_BlockchainVerificationResultDto(
reportId: null == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String,onChainId: freezed == onChainId ? _self.onChainId : onChainId // ignore: cast_nullable_to_non_nullable
as String?,verified: null == verified ? _self.verified : verified // ignore: cast_nullable_to_non_nullable
as bool,originalSnapshotVerified: freezed == originalSnapshotVerified ? _self.originalSnapshotVerified : originalSnapshotVerified // ignore: cast_nullable_to_non_nullable
as bool?,currentContentVerified: freezed == currentContentVerified ? _self.currentContentVerified : currentContentVerified // ignore: cast_nullable_to_non_nullable
as bool?,statusVerified: freezed == statusVerified ? _self.statusVerified : statusVerified // ignore: cast_nullable_to_non_nullable
as bool?,blockchainData: null == blockchainData ? _self._blockchainData : blockchainData // ignore: cast_nullable_to_non_nullable
as Map<String, dynamic>,auditHistory: null == auditHistory ? _self._auditHistory : auditHistory // ignore: cast_nullable_to_non_nullable
as List<BlockchainAuditEntryDto>,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,notFoundOnChain: null == notFoundOnChain ? _self.notFoundOnChain : notFoundOnChain // ignore: cast_nullable_to_non_nullable
as bool,connectionError: null == connectionError ? _self.connectionError : connectionError // ignore: cast_nullable_to_non_nullable
as bool,isAnchored: null == isAnchored ? _self.isAnchored : isAnchored // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

// GENERATED CODE - DO NOT MODIFY BY HAND
// coverage:ignore-file
// ignore_for_file: type=lint
// ignore_for_file: unused_element, deprecated_member_use, deprecated_member_use_from_same_package, use_function_type_syntax_for_parameters, unnecessary_const, avoid_init_to_null, invalid_override_different_default_values_named, prefer_expression_function_bodies, annotate_overrides, invalid_annotation_target, unnecessary_question_mark

part of 'notification_models.dart';

// **************************************************************************
// FreezedGenerator
// **************************************************************************

// dart format off
T _$identity<T>(T value) => value;

/// @nodoc
mixin _$AppNotification {

@JsonKey(name: 'id') String get id; String get title; String get message;@JsonKey(unknownEnumValue: NotificationType.system) NotificationType get type;@JsonKey(name: 'is_read') bool get isRead;@JsonKey(name: 'related_report_id') String? get reportId;@JsonKey(name: 'created_at') String? get createdAt;
/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$AppNotificationCopyWith<AppNotification> get copyWith => _$AppNotificationCopyWithImpl<AppNotification>(this as AppNotification, _$identity);

  /// Serializes this AppNotification to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,message,type,isRead,reportId,createdAt);

@override
String toString() {
  return 'AppNotification(id: $id, title: $title, message: $message, type: $type, isRead: $isRead, reportId: $reportId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class $AppNotificationCopyWith<$Res>  {
  factory $AppNotificationCopyWith(AppNotification value, $Res Function(AppNotification) _then) = _$AppNotificationCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'id') String id, String title, String message,@JsonKey(unknownEnumValue: NotificationType.system) NotificationType type,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'related_report_id') String? reportId,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class _$AppNotificationCopyWithImpl<$Res>
    implements $AppNotificationCopyWith<$Res> {
  _$AppNotificationCopyWithImpl(this._self, this._then);

  final AppNotification _self;
  final $Res Function(AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? id = null,Object? title = null,Object? message = null,Object? type = null,Object? isRead = null,Object? reportId = freezed,Object? createdAt = freezed,}) {
  return _then(_self.copyWith(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [AppNotification].
extension AppNotificationPatterns on AppNotification {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _AppNotification value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _AppNotification value)  $default,){
final _that = this;
switch (_that) {
case _AppNotification():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _AppNotification value)?  $default,){
final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id,  String title,  String message, @JsonKey(unknownEnumValue: NotificationType.system)  NotificationType type, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'related_report_id')  String? reportId, @JsonKey(name: 'created_at')  String? createdAt)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.title,_that.message,_that.type,_that.isRead,_that.reportId,_that.createdAt);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'id')  String id,  String title,  String message, @JsonKey(unknownEnumValue: NotificationType.system)  NotificationType type, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'related_report_id')  String? reportId, @JsonKey(name: 'created_at')  String? createdAt)  $default,) {final _that = this;
switch (_that) {
case _AppNotification():
return $default(_that.id,_that.title,_that.message,_that.type,_that.isRead,_that.reportId,_that.createdAt);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'id')  String id,  String title,  String message, @JsonKey(unknownEnumValue: NotificationType.system)  NotificationType type, @JsonKey(name: 'is_read')  bool isRead, @JsonKey(name: 'related_report_id')  String? reportId, @JsonKey(name: 'created_at')  String? createdAt)?  $default,) {final _that = this;
switch (_that) {
case _AppNotification() when $default != null:
return $default(_that.id,_that.title,_that.message,_that.type,_that.isRead,_that.reportId,_that.createdAt);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _AppNotification implements AppNotification {
  const _AppNotification({@JsonKey(name: 'id') required this.id, required this.title, required this.message, @JsonKey(unknownEnumValue: NotificationType.system) this.type = NotificationType.system, @JsonKey(name: 'is_read') this.isRead = false, @JsonKey(name: 'related_report_id') this.reportId, @JsonKey(name: 'created_at') this.createdAt});
  factory _AppNotification.fromJson(Map<String, dynamic> json) => _$AppNotificationFromJson(json);

@override@JsonKey(name: 'id') final  String id;
@override final  String title;
@override final  String message;
@override@JsonKey(unknownEnumValue: NotificationType.system) final  NotificationType type;
@override@JsonKey(name: 'is_read') final  bool isRead;
@override@JsonKey(name: 'related_report_id') final  String? reportId;
@override@JsonKey(name: 'created_at') final  String? createdAt;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$AppNotificationCopyWith<_AppNotification> get copyWith => __$AppNotificationCopyWithImpl<_AppNotification>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$AppNotificationToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _AppNotification&&(identical(other.id, id) || other.id == id)&&(identical(other.title, title) || other.title == title)&&(identical(other.message, message) || other.message == message)&&(identical(other.type, type) || other.type == type)&&(identical(other.isRead, isRead) || other.isRead == isRead)&&(identical(other.reportId, reportId) || other.reportId == reportId)&&(identical(other.createdAt, createdAt) || other.createdAt == createdAt));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,id,title,message,type,isRead,reportId,createdAt);

@override
String toString() {
  return 'AppNotification(id: $id, title: $title, message: $message, type: $type, isRead: $isRead, reportId: $reportId, createdAt: $createdAt)';
}


}

/// @nodoc
abstract mixin class _$AppNotificationCopyWith<$Res> implements $AppNotificationCopyWith<$Res> {
  factory _$AppNotificationCopyWith(_AppNotification value, $Res Function(_AppNotification) _then) = __$AppNotificationCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'id') String id, String title, String message,@JsonKey(unknownEnumValue: NotificationType.system) NotificationType type,@JsonKey(name: 'is_read') bool isRead,@JsonKey(name: 'related_report_id') String? reportId,@JsonKey(name: 'created_at') String? createdAt
});




}
/// @nodoc
class __$AppNotificationCopyWithImpl<$Res>
    implements _$AppNotificationCopyWith<$Res> {
  __$AppNotificationCopyWithImpl(this._self, this._then);

  final _AppNotification _self;
  final $Res Function(_AppNotification) _then;

/// Create a copy of AppNotification
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? id = null,Object? title = null,Object? message = null,Object? type = null,Object? isRead = null,Object? reportId = freezed,Object? createdAt = freezed,}) {
  return _then(_AppNotification(
id: null == id ? _self.id : id // ignore: cast_nullable_to_non_nullable
as String,title: null == title ? _self.title : title // ignore: cast_nullable_to_non_nullable
as String,message: null == message ? _self.message : message // ignore: cast_nullable_to_non_nullable
as String,type: null == type ? _self.type : type // ignore: cast_nullable_to_non_nullable
as NotificationType,isRead: null == isRead ? _self.isRead : isRead // ignore: cast_nullable_to_non_nullable
as bool,reportId: freezed == reportId ? _self.reportId : reportId // ignore: cast_nullable_to_non_nullable
as String?,createdAt: freezed == createdAt ? _self.createdAt : createdAt // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$PaginatedNotifications {

@JsonKey(name: 'notifications') List<AppNotification> get results; int get count; int? get total;@JsonKey(name: 'unread_count') int get unreadCount; String? get next; String? get previous;
/// Create a copy of PaginatedNotifications
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$PaginatedNotificationsCopyWith<PaginatedNotifications> get copyWith => _$PaginatedNotificationsCopyWithImpl<PaginatedNotifications>(this as PaginatedNotifications, _$identity);

  /// Serializes this PaginatedNotifications to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is PaginatedNotifications&&const DeepCollectionEquality().equals(other.results, results)&&(identical(other.count, count) || other.count == count)&&(identical(other.total, total) || other.total == total)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(results),count,total,unreadCount,next,previous);

@override
String toString() {
  return 'PaginatedNotifications(results: $results, count: $count, total: $total, unreadCount: $unreadCount, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class $PaginatedNotificationsCopyWith<$Res>  {
  factory $PaginatedNotificationsCopyWith(PaginatedNotifications value, $Res Function(PaginatedNotifications) _then) = _$PaginatedNotificationsCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'notifications') List<AppNotification> results, int count, int? total,@JsonKey(name: 'unread_count') int unreadCount, String? next, String? previous
});




}
/// @nodoc
class _$PaginatedNotificationsCopyWithImpl<$Res>
    implements $PaginatedNotificationsCopyWith<$Res> {
  _$PaginatedNotificationsCopyWithImpl(this._self, this._then);

  final PaginatedNotifications _self;
  final $Res Function(PaginatedNotifications) _then;

/// Create a copy of PaginatedNotifications
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? results = null,Object? count = null,Object? total = freezed,Object? unreadCount = null,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_self.copyWith(
results: null == results ? _self.results : results // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}

}


/// Adds pattern-matching-related methods to [PaginatedNotifications].
extension PaginatedNotificationsPatterns on PaginatedNotifications {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _PaginatedNotifications value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _PaginatedNotifications() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _PaginatedNotifications value)  $default,){
final _that = this;
switch (_that) {
case _PaginatedNotifications():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _PaginatedNotifications value)?  $default,){
final _that = this;
switch (_that) {
case _PaginatedNotifications() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'notifications')  List<AppNotification> results,  int count,  int? total, @JsonKey(name: 'unread_count')  int unreadCount,  String? next,  String? previous)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _PaginatedNotifications() when $default != null:
return $default(_that.results,_that.count,_that.total,_that.unreadCount,_that.next,_that.previous);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'notifications')  List<AppNotification> results,  int count,  int? total, @JsonKey(name: 'unread_count')  int unreadCount,  String? next,  String? previous)  $default,) {final _that = this;
switch (_that) {
case _PaginatedNotifications():
return $default(_that.results,_that.count,_that.total,_that.unreadCount,_that.next,_that.previous);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'notifications')  List<AppNotification> results,  int count,  int? total, @JsonKey(name: 'unread_count')  int unreadCount,  String? next,  String? previous)?  $default,) {final _that = this;
switch (_that) {
case _PaginatedNotifications() when $default != null:
return $default(_that.results,_that.count,_that.total,_that.unreadCount,_that.next,_that.previous);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _PaginatedNotifications implements PaginatedNotifications {
  const _PaginatedNotifications({@JsonKey(name: 'notifications') required final  List<AppNotification> results, this.count = 0, this.total, @JsonKey(name: 'unread_count') this.unreadCount = 0, this.next, this.previous}): _results = results;
  factory _PaginatedNotifications.fromJson(Map<String, dynamic> json) => _$PaginatedNotificationsFromJson(json);

 final  List<AppNotification> _results;
@override@JsonKey(name: 'notifications') List<AppNotification> get results {
  if (_results is EqualUnmodifiableListView) return _results;
  // ignore: implicit_dynamic_type
  return EqualUnmodifiableListView(_results);
}

@override@JsonKey() final  int count;
@override final  int? total;
@override@JsonKey(name: 'unread_count') final  int unreadCount;
@override final  String? next;
@override final  String? previous;

/// Create a copy of PaginatedNotifications
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$PaginatedNotificationsCopyWith<_PaginatedNotifications> get copyWith => __$PaginatedNotificationsCopyWithImpl<_PaginatedNotifications>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$PaginatedNotificationsToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _PaginatedNotifications&&const DeepCollectionEquality().equals(other._results, _results)&&(identical(other.count, count) || other.count == count)&&(identical(other.total, total) || other.total == total)&&(identical(other.unreadCount, unreadCount) || other.unreadCount == unreadCount)&&(identical(other.next, next) || other.next == next)&&(identical(other.previous, previous) || other.previous == previous));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,const DeepCollectionEquality().hash(_results),count,total,unreadCount,next,previous);

@override
String toString() {
  return 'PaginatedNotifications(results: $results, count: $count, total: $total, unreadCount: $unreadCount, next: $next, previous: $previous)';
}


}

/// @nodoc
abstract mixin class _$PaginatedNotificationsCopyWith<$Res> implements $PaginatedNotificationsCopyWith<$Res> {
  factory _$PaginatedNotificationsCopyWith(_PaginatedNotifications value, $Res Function(_PaginatedNotifications) _then) = __$PaginatedNotificationsCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'notifications') List<AppNotification> results, int count, int? total,@JsonKey(name: 'unread_count') int unreadCount, String? next, String? previous
});




}
/// @nodoc
class __$PaginatedNotificationsCopyWithImpl<$Res>
    implements _$PaginatedNotificationsCopyWith<$Res> {
  __$PaginatedNotificationsCopyWithImpl(this._self, this._then);

  final _PaginatedNotifications _self;
  final $Res Function(_PaginatedNotifications) _then;

/// Create a copy of PaginatedNotifications
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? results = null,Object? count = null,Object? total = freezed,Object? unreadCount = null,Object? next = freezed,Object? previous = freezed,}) {
  return _then(_PaginatedNotifications(
results: null == results ? _self._results : results // ignore: cast_nullable_to_non_nullable
as List<AppNotification>,count: null == count ? _self.count : count // ignore: cast_nullable_to_non_nullable
as int,total: freezed == total ? _self.total : total // ignore: cast_nullable_to_non_nullable
as int?,unreadCount: null == unreadCount ? _self.unreadCount : unreadCount // ignore: cast_nullable_to_non_nullable
as int,next: freezed == next ? _self.next : next // ignore: cast_nullable_to_non_nullable
as String?,previous: freezed == previous ? _self.previous : previous // ignore: cast_nullable_to_non_nullable
as String?,
  ));
}


}


/// @nodoc
mixin _$NotificationPreferences {

@JsonKey(name: 'email_enabled') bool get emailEnabled;@JsonKey(name: 'push_enabled') bool get pushEnabled;@JsonKey(name: 'notify_on_status_change') bool get notifyOnStatusChange;@JsonKey(name: 'notify_on_comment') bool get notifyOnComment;@JsonKey(name: 'notify_on_assignment') bool get notifyOnAssignment;
/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
$NotificationPreferencesCopyWith<NotificationPreferences> get copyWith => _$NotificationPreferencesCopyWithImpl<NotificationPreferences>(this as NotificationPreferences, _$identity);

  /// Serializes this NotificationPreferences to a JSON map.
  Map<String, dynamic> toJson();


@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is NotificationPreferences&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.notifyOnStatusChange, notifyOnStatusChange) || other.notifyOnStatusChange == notifyOnStatusChange)&&(identical(other.notifyOnComment, notifyOnComment) || other.notifyOnComment == notifyOnComment)&&(identical(other.notifyOnAssignment, notifyOnAssignment) || other.notifyOnAssignment == notifyOnAssignment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emailEnabled,pushEnabled,notifyOnStatusChange,notifyOnComment,notifyOnAssignment);

@override
String toString() {
  return 'NotificationPreferences(emailEnabled: $emailEnabled, pushEnabled: $pushEnabled, notifyOnStatusChange: $notifyOnStatusChange, notifyOnComment: $notifyOnComment, notifyOnAssignment: $notifyOnAssignment)';
}


}

/// @nodoc
abstract mixin class $NotificationPreferencesCopyWith<$Res>  {
  factory $NotificationPreferencesCopyWith(NotificationPreferences value, $Res Function(NotificationPreferences) _then) = _$NotificationPreferencesCopyWithImpl;
@useResult
$Res call({
@JsonKey(name: 'email_enabled') bool emailEnabled,@JsonKey(name: 'push_enabled') bool pushEnabled,@JsonKey(name: 'notify_on_status_change') bool notifyOnStatusChange,@JsonKey(name: 'notify_on_comment') bool notifyOnComment,@JsonKey(name: 'notify_on_assignment') bool notifyOnAssignment
});




}
/// @nodoc
class _$NotificationPreferencesCopyWithImpl<$Res>
    implements $NotificationPreferencesCopyWith<$Res> {
  _$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final NotificationPreferences _self;
  final $Res Function(NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@pragma('vm:prefer-inline') @override $Res call({Object? emailEnabled = null,Object? pushEnabled = null,Object? notifyOnStatusChange = null,Object? notifyOnComment = null,Object? notifyOnAssignment = null,}) {
  return _then(_self.copyWith(
emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,notifyOnStatusChange: null == notifyOnStatusChange ? _self.notifyOnStatusChange : notifyOnStatusChange // ignore: cast_nullable_to_non_nullable
as bool,notifyOnComment: null == notifyOnComment ? _self.notifyOnComment : notifyOnComment // ignore: cast_nullable_to_non_nullable
as bool,notifyOnAssignment: null == notifyOnAssignment ? _self.notifyOnAssignment : notifyOnAssignment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}

}


/// Adds pattern-matching-related methods to [NotificationPreferences].
extension NotificationPreferencesPatterns on NotificationPreferences {
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

@optionalTypeArgs TResult maybeMap<TResult extends Object?>(TResult Function( _NotificationPreferences value)?  $default,{required TResult orElse(),}){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult map<TResult extends Object?>(TResult Function( _NotificationPreferences value)  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences():
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

@optionalTypeArgs TResult? mapOrNull<TResult extends Object?>(TResult? Function( _NotificationPreferences value)?  $default,){
final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
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

@optionalTypeArgs TResult maybeWhen<TResult extends Object?>(TResult Function(@JsonKey(name: 'email_enabled')  bool emailEnabled, @JsonKey(name: 'push_enabled')  bool pushEnabled, @JsonKey(name: 'notify_on_status_change')  bool notifyOnStatusChange, @JsonKey(name: 'notify_on_comment')  bool notifyOnComment, @JsonKey(name: 'notify_on_assignment')  bool notifyOnAssignment)?  $default,{required TResult orElse(),}) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.emailEnabled,_that.pushEnabled,_that.notifyOnStatusChange,_that.notifyOnComment,_that.notifyOnAssignment);case _:
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

@optionalTypeArgs TResult when<TResult extends Object?>(TResult Function(@JsonKey(name: 'email_enabled')  bool emailEnabled, @JsonKey(name: 'push_enabled')  bool pushEnabled, @JsonKey(name: 'notify_on_status_change')  bool notifyOnStatusChange, @JsonKey(name: 'notify_on_comment')  bool notifyOnComment, @JsonKey(name: 'notify_on_assignment')  bool notifyOnAssignment)  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences():
return $default(_that.emailEnabled,_that.pushEnabled,_that.notifyOnStatusChange,_that.notifyOnComment,_that.notifyOnAssignment);}
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

@optionalTypeArgs TResult? whenOrNull<TResult extends Object?>(TResult? Function(@JsonKey(name: 'email_enabled')  bool emailEnabled, @JsonKey(name: 'push_enabled')  bool pushEnabled, @JsonKey(name: 'notify_on_status_change')  bool notifyOnStatusChange, @JsonKey(name: 'notify_on_comment')  bool notifyOnComment, @JsonKey(name: 'notify_on_assignment')  bool notifyOnAssignment)?  $default,) {final _that = this;
switch (_that) {
case _NotificationPreferences() when $default != null:
return $default(_that.emailEnabled,_that.pushEnabled,_that.notifyOnStatusChange,_that.notifyOnComment,_that.notifyOnAssignment);case _:
  return null;

}
}

}

/// @nodoc
@JsonSerializable()

class _NotificationPreferences implements NotificationPreferences {
  const _NotificationPreferences({@JsonKey(name: 'email_enabled') this.emailEnabled = true, @JsonKey(name: 'push_enabled') this.pushEnabled = true, @JsonKey(name: 'notify_on_status_change') this.notifyOnStatusChange = true, @JsonKey(name: 'notify_on_comment') this.notifyOnComment = true, @JsonKey(name: 'notify_on_assignment') this.notifyOnAssignment = true});
  factory _NotificationPreferences.fromJson(Map<String, dynamic> json) => _$NotificationPreferencesFromJson(json);

@override@JsonKey(name: 'email_enabled') final  bool emailEnabled;
@override@JsonKey(name: 'push_enabled') final  bool pushEnabled;
@override@JsonKey(name: 'notify_on_status_change') final  bool notifyOnStatusChange;
@override@JsonKey(name: 'notify_on_comment') final  bool notifyOnComment;
@override@JsonKey(name: 'notify_on_assignment') final  bool notifyOnAssignment;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @JsonKey(includeFromJson: false, includeToJson: false)
@pragma('vm:prefer-inline')
_$NotificationPreferencesCopyWith<_NotificationPreferences> get copyWith => __$NotificationPreferencesCopyWithImpl<_NotificationPreferences>(this, _$identity);

@override
Map<String, dynamic> toJson() {
  return _$NotificationPreferencesToJson(this, );
}

@override
bool operator ==(Object other) {
  return identical(this, other) || (other.runtimeType == runtimeType&&other is _NotificationPreferences&&(identical(other.emailEnabled, emailEnabled) || other.emailEnabled == emailEnabled)&&(identical(other.pushEnabled, pushEnabled) || other.pushEnabled == pushEnabled)&&(identical(other.notifyOnStatusChange, notifyOnStatusChange) || other.notifyOnStatusChange == notifyOnStatusChange)&&(identical(other.notifyOnComment, notifyOnComment) || other.notifyOnComment == notifyOnComment)&&(identical(other.notifyOnAssignment, notifyOnAssignment) || other.notifyOnAssignment == notifyOnAssignment));
}

@JsonKey(includeFromJson: false, includeToJson: false)
@override
int get hashCode => Object.hash(runtimeType,emailEnabled,pushEnabled,notifyOnStatusChange,notifyOnComment,notifyOnAssignment);

@override
String toString() {
  return 'NotificationPreferences(emailEnabled: $emailEnabled, pushEnabled: $pushEnabled, notifyOnStatusChange: $notifyOnStatusChange, notifyOnComment: $notifyOnComment, notifyOnAssignment: $notifyOnAssignment)';
}


}

/// @nodoc
abstract mixin class _$NotificationPreferencesCopyWith<$Res> implements $NotificationPreferencesCopyWith<$Res> {
  factory _$NotificationPreferencesCopyWith(_NotificationPreferences value, $Res Function(_NotificationPreferences) _then) = __$NotificationPreferencesCopyWithImpl;
@override @useResult
$Res call({
@JsonKey(name: 'email_enabled') bool emailEnabled,@JsonKey(name: 'push_enabled') bool pushEnabled,@JsonKey(name: 'notify_on_status_change') bool notifyOnStatusChange,@JsonKey(name: 'notify_on_comment') bool notifyOnComment,@JsonKey(name: 'notify_on_assignment') bool notifyOnAssignment
});




}
/// @nodoc
class __$NotificationPreferencesCopyWithImpl<$Res>
    implements _$NotificationPreferencesCopyWith<$Res> {
  __$NotificationPreferencesCopyWithImpl(this._self, this._then);

  final _NotificationPreferences _self;
  final $Res Function(_NotificationPreferences) _then;

/// Create a copy of NotificationPreferences
/// with the given fields replaced by the non-null parameter values.
@override @pragma('vm:prefer-inline') $Res call({Object? emailEnabled = null,Object? pushEnabled = null,Object? notifyOnStatusChange = null,Object? notifyOnComment = null,Object? notifyOnAssignment = null,}) {
  return _then(_NotificationPreferences(
emailEnabled: null == emailEnabled ? _self.emailEnabled : emailEnabled // ignore: cast_nullable_to_non_nullable
as bool,pushEnabled: null == pushEnabled ? _self.pushEnabled : pushEnabled // ignore: cast_nullable_to_non_nullable
as bool,notifyOnStatusChange: null == notifyOnStatusChange ? _self.notifyOnStatusChange : notifyOnStatusChange // ignore: cast_nullable_to_non_nullable
as bool,notifyOnComment: null == notifyOnComment ? _self.notifyOnComment : notifyOnComment // ignore: cast_nullable_to_non_nullable
as bool,notifyOnAssignment: null == notifyOnAssignment ? _self.notifyOnAssignment : notifyOnAssignment // ignore: cast_nullable_to_non_nullable
as bool,
  ));
}


}

// dart format on

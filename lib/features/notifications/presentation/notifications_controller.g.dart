// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'notifications_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for notifications list - auto-fetches on first access

@ProviderFor(NotificationsController)
final notificationsControllerProvider = NotificationsControllerProvider._();

/// Controller for notifications list - auto-fetches on first access
final class NotificationsControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationsController,
          PaginatedNotifications
        > {
  /// Controller for notifications list - auto-fetches on first access
  NotificationsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$notificationsControllerHash();

  @$internal
  @override
  NotificationsController create() => NotificationsController();
}

String _$notificationsControllerHash() =>
    r'3d7455956ed604eb20609ad3e977fecba5da478d';

/// Controller for notifications list - auto-fetches on first access

abstract class _$NotificationsController
    extends $AsyncNotifier<PaginatedNotifications> {
  FutureOr<PaginatedNotifications> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<AsyncValue<PaginatedNotifications>, PaginatedNotifications>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<PaginatedNotifications>,
                PaginatedNotifications
              >,
              AsyncValue<PaginatedNotifications>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for notification preferences

@ProviderFor(NotificationPreferencesController)
final notificationPreferencesControllerProvider =
    NotificationPreferencesControllerProvider._();

/// Controller for notification preferences
final class NotificationPreferencesControllerProvider
    extends
        $AsyncNotifierProvider<
          NotificationPreferencesController,
          NotificationPreferences
        > {
  /// Controller for notification preferences
  NotificationPreferencesControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'notificationPreferencesControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() =>
      _$notificationPreferencesControllerHash();

  @$internal
  @override
  NotificationPreferencesController create() =>
      NotificationPreferencesController();
}

String _$notificationPreferencesControllerHash() =>
    r'3ac7e9215bc6b8a2e854557d15cf33c784403c03';

/// Controller for notification preferences

abstract class _$NotificationPreferencesController
    extends $AsyncNotifier<NotificationPreferences> {
  FutureOr<NotificationPreferences> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<NotificationPreferences>,
              NotificationPreferences
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<NotificationPreferences>,
                NotificationPreferences
              >,
              AsyncValue<NotificationPreferences>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

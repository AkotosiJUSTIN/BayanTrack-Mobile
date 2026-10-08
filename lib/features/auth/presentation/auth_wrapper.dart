import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../navigation/main_navigation_shell.dart';
import 'auth_controller.dart';
import 'login_screen.dart';
import 'password_expired_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../../core/presentation/widgets/app_toast.dart';
import '../../notifications/push_service.dart';
import '../../notifications/local_notification_service.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../notifications/presentation/notification_navigation.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/providers/backend_reachability_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widget/widget_bridge.dart';
import '../../images/data/evidence_upload_queue_provider.dart';
import '../../reports/presentation/reports_controller.dart';
import '../../reports/reports_di.dart';
import '../../reports/presentation/new_report/quick_report_screen.dart';
import 'auth_realtime_controller.dart';
import 'profile_controller.dart';
import '../../system_governance/system_governance_gate.dart';
import '../../system_governance/system_governance_models.dart';
import '../../system_governance/system_governance_provider.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  String? _evidenceSyncKey;
  String? _reportOutboxSyncKey;
  String? _reportCacheOwnerId;
  late final WidgetBridge _widgetBridge;
  late final StreamSubscription<WidgetDestination>
  _widgetDestinationSubscription;
  bool _widgetNavigationScheduled = false;
  String? _pushUserId;
  String? _governanceOwnerId;
  late final StreamSubscription<Map<String, dynamic>> _localNotificationTaps;
  bool _notificationNavigationScheduled = false;

  @override
  void initState() {
    super.initState();
    _widgetBridge = ref.read(widgetBridgeProvider);
    _localNotificationTaps = LocalNotificationService.taps.listen((_) {
      _maybeOpenLocalNotification();
    });
    _widgetDestinationSubscription = _widgetBridge.destinations.listen((_) {
      _maybeNavigateToWidgetDestination();
    });
    WidgetsBinding.instance.addObserver(this);
    ref.listenManual<AuthState>(
      authControllerProvider,
      (_, next) => _handleAuthState(next),
      fireImmediately: true,
    );
    ref.listenManual<bool>(isOnlineProvider, (_, next) {
      _syncEvidenceForCurrentAuth(next);
      _syncReportOutboxForCurrentAuth(next);
    }, fireImmediately: true);
    ref.listenManual<BackendReachability>(backendReachabilityProvider, (_, _) {
      final isOnline = ref.read(isOnlineProvider);
      _syncEvidenceForCurrentAuth(isOnline);
      _syncReportOutboxForCurrentAuth(isOnline);
    }, fireImmediately: true);
    ref.listenManual<AsyncValue<SystemGovernanceState>>(
      systemGovernanceProvider,
      (_, next) {
        if (next.asData == null) return;
        final state = ref.read(authControllerProvider);
        final userId = state is AuthSuccess ? state.user?.id : null;
        final online = ref.read(isOnlineProvider);
        _syncEvidenceQueue(userId, online, force: true);
        _syncReportOutbox(userId, online, force: true);
      },
    );
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _maybeNavigateToWidgetDestination();
        _maybeOpenLocalNotification();
      }
    });
    debugPrint('[AuthWrapper] Initializing...');

    // Only validate the session on initial startup
    Future.microtask(() {
      final currentState = ref.read(authControllerProvider);
      if (currentState is AuthInitial) {
        debugPrint('[AuthWrapper] Running initial checkAuth()');
        ref.read(authControllerProvider.notifier).checkAuth();
      } else {
        debugPrint(
          '[AuthWrapper] Skipping checkAuth() - state is ${currentState.runtimeType}',
        );
      }
    });
  }

  @override
  void dispose() {
    unawaited(_widgetDestinationSubscription.cancel());
    unawaited(_localNotificationTaps.cancel());
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  void _syncWidgetState(AuthState state) {
    final locale = ref.read(appLocaleProvider);
    unawaited(_widgetBridge.syncLocale(locale));
    if (state is AuthSuccess) {
      unawaited(_widgetBridge.syncAuthenticated(true));
    } else {
      unawaited(_widgetBridge.syncAuthenticated(false));
    }
  }

  void _handleAuthState(AuthState state) {
    _syncWidgetState(state);
    _maybeNavigateToWidgetDestination();
    _maybeOpenLocalNotification();

    final userId = state is AuthSuccess ? state.user?.id : null;
    if (_governanceOwnerId != userId) {
      _governanceOwnerId = userId;
      ref.invalidate(systemGovernanceProvider);
      ref.invalidate(publishedTermsProvider);
    }
    if (userId != _reportCacheOwnerId) {
      final previousOwnerId = _reportCacheOwnerId;
      _reportCacheOwnerId = userId;
      final cache = ref.read(reportCacheStoreProvider);
      if (previousOwnerId != null) {
        unawaited(cache.deleteOwner(previousOwnerId).catchError((_) {}));
      }
      if (userId != null) {
        unawaited(cache.deleteOtherOwners(userId).catchError((_) {}));
      }
    }
    _syncEvidenceQueue(userId, ref.read(isOnlineProvider));
    _syncReportOutbox(userId, ref.read(isOnlineProvider), force: true);

    final realtime = ref.read(authRealtimeControllerProvider);
    if (userId == null) {
      _pushUserId = null;
      realtime.stop();
      return;
    }

    unawaited(Future.microtask(() => realtime.start(userId)));
    if (_pushUserId != userId) {
      _pushUserId = userId;
      unawaited(_initializePush(userId));
    }
  }

  void _syncEvidenceForCurrentAuth(bool isOnline) {
    final state = ref.read(authControllerProvider);
    final userId = state is AuthSuccess ? state.user?.id : null;
    _syncEvidenceQueue(userId, isOnline);
  }

  void _syncReportOutboxForCurrentAuth(bool isOnline) {
    final state = ref.read(authControllerProvider);
    final userId = state is AuthSuccess ? state.user?.id : null;
    _syncReportOutbox(userId, isOnline);
  }

  void _syncReportOutbox(String? userId, bool isOnline, {bool force = false}) {
    final reachable =
        ref.read(backendReachabilityProvider) == BackendReachability.reachable;
    final syncKey = '$userId:$isOnline:$reachable';
    if (!force && _reportOutboxSyncKey == syncKey) return;
    _reportOutboxSyncKey = syncKey;
    final outbox = ref.read(reportCreateOutboxProvider);
    if (userId == null || !isOnline || !reachable) {
      unawaited(outbox.pause());
      return;
    }
    unawaited(() async {
      final synchronized = await outbox.resume(userId);
      if (!mounted || synchronized == 0) return;
      ref.read(myReportsRefreshProvider.notifier).increment();
    }());
  }

  Future<void> _initializePush(String? userId) async {
    try {
      final pushService = ref.read(pushServiceProvider);
      final dio = ref.read(dioProvider);
      if (!mounted) return;
      if (_pushUserId != userId) return;
      pushService.onTokenRefresh((token) async {
        if (!mounted || _pushUserId != userId) return;
        await pushService.registerToken(token, 'android', dio, userId: userId);
      });

      // Foreground message handler: show simple in-app snackbar and persist
      pushService.onMessage((message) async {
        if (!mounted || _pushUserId != userId) return;
        final notificationContext = context;
        final title =
            message.notification?.title ??
            message.data['title']?.toString() ??
            'Notification';
        final body =
            message.notification?.body ??
            message.data['body']?.toString() ??
            '';
        ref.invalidate(notificationsControllerProvider);
        if (message.data['type'] == 'terms_updated' ||
            message.data['type'] == 'maintenance_changed') {
          ref.invalidate(publishedTermsProvider);
          unawaited(ref.read(systemGovernanceProvider.notifier).refresh());
        }
        await LocalNotificationService.showFromRemoteMessage(message);
        if (!notificationContext.mounted) return;
        AppToast.info(notificationContext, '$title: $body');
      });

      // When a user taps a notification and the app is opened from background
      pushService.onMessageOpened((message) {
        if (!mounted || _pushUserId != userId) return;
        openNotificationDestination(context, ref, message.data);
      });

      // If launched from terminated state via notification
      final initial = await FirebaseMessaging.instance.getInitialMessage();
      if (initial != null && mounted && _pushUserId == userId) {
        openNotificationDestination(context, ref, initial.data);
      }
      if (!mounted || _pushUserId != userId) return;
      await pushService.ensureRegistered('android', dio, userId: userId);
    } catch (e) {
      debugPrint('Push initialization failed: $e');
    }
  }

  void _maybeOpenLocalNotification() {
    if (!mounted || _notificationNavigationScheduled) return;
    final state = ref.read(authControllerProvider);
    if (state is! AuthSuccess || !state.mayOpenWidgetDestination) return;
    _notificationNavigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _notificationNavigationScheduled = false;
      if (!mounted) return;
      final current = ref.read(authControllerProvider);
      if (current is! AuthSuccess || !current.mayOpenWidgetDestination) return;
      final data = LocalNotificationService.takePendingTap();
      if (data != null) openNotificationDestination(context, ref, data);
    });
    WidgetsBinding.instance.ensureVisualUpdate();
  }

  void _maybeNavigateToWidgetDestination() {
    if (!mounted || _widgetNavigationScheduled) return;

    final authState = ref.read(authControllerProvider);
    if (authState is! AuthSuccess || !authState.mayOpenWidgetDestination) {
      return;
    }

    final destination = _widgetBridge.takePendingDestination();
    if (destination == null) return;

    _widgetNavigationScheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) {
        _widgetBridge.restoreDestination(destination);
        _widgetNavigationScheduled = false;
        return;
      }

      if (destination == WidgetDestination.openApp) {
        _widgetBridge.finishWidgetDestination();
        _widgetNavigationScheduled = false;
        return;
      }

      final page = const QuickReportScreen(fastReportMode: true);
      final navigation = Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => page));
      unawaited(
        navigation.then<void>((_) {
          _widgetBridge.finishWidgetDestination();
          _widgetNavigationScheduled = false;
          _maybeNavigateToWidgetDestination();
        }),
      );
    });
  }

  void _syncEvidenceQueue(String? userId, bool isOnline, {bool force = false}) {
    final reachable =
        ref.read(backendReachabilityProvider) == BackendReachability.reachable;
    final syncKey = '$userId:$isOnline:$reachable';
    if (!force && _evidenceSyncKey == syncKey) return;
    _evidenceSyncKey = syncKey;
    Future.microtask(() async {
      try {
        final queue = await ref.read(evidenceUploadQueueProvider.future);
        if (!mounted) return;
        if (userId != null && isOnline && reachable) {
          await queue.resume(userId);
        } else {
          await queue.pause();
        }
      } catch (_) {
        // Queue remains durable and retries on the next safe lifecycle signal.
      }
    });
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.hidden) {
      _widgetBridge.clearFinishedDestinations();
    }

    // Refresh KYC status when app comes back to foreground
    // This ensures verified status updates after admin verification
    if (state == AppLifecycleState.resumed) {
      ref.invalidate(publishedTermsProvider);
      unawaited(ref.read(systemGovernanceProvider.notifier).refresh());
      final authState = ref.read(authControllerProvider);
      if (authState is AuthSuccess) {
        final userId = authState.user?.id;
        if (userId != null) {
          Future.microtask(
            () => ref.read(authRealtimeControllerProvider).start(userId),
          );
          Future.microtask(() async {
            if (ref.read(isOnlineProvider)) {
              await ref.read(backendReachabilityProvider.notifier).checkNow();
            }
            if (!mounted) return;
            final isOnline = ref.read(isOnlineProvider);
            _syncEvidenceQueue(userId, isOnline, force: true);
            _syncReportOutbox(userId, isOnline, force: true);
          });
        }
        ref.invalidate(kycStatusControllerProvider);
        ref.invalidate(profileControllerProvider);
        Future.microtask(
          () => ref.read(authControllerProvider.notifier).refreshProfile(),
        );
        Future.microtask(() async {
          try {
            final pushService = ref.read(pushServiceProvider);
            final dio = ref.read(dioProvider);
            await pushService.ensureRegistered('android', dio, userId: userId);
          } catch (e) {
            debugPrint('Push token refresh on resume failed: $e');
          }
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(authControllerProvider);
    ref.watch(appLocaleProvider);
    ref.watch(backendReachabilityProvider);
    debugPrint('[AuthWrapper] AuthState changed: ${state.runtimeType}');

    if (state is AuthSuccess && state.user?.requiresPasswordChange == true) {
      return const PasswordExpiredScreen();
    }

    return switch (state) {
      AuthSuccess() => const SystemGovernanceGate(child: MainNavigationShell()),
      AuthIdle() || AuthError() => const LoginScreen(),
      AuthInitial() || AuthLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

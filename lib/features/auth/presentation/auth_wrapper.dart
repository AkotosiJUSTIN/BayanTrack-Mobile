import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../navigation/main_navigation_shell.dart';
import 'auth_controller.dart';
import 'login_screen.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../notifications/push_service.dart';
import '../../notifications/local_notification_service.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../notifications/presentation/notifications_screen.dart';
import '../../../core/network/dio_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../../core/providers/locale_provider.dart';
import '../../../core/widget/widget_bridge.dart';
import '../../images/data/evidence_upload_queue_provider.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/new_report/quick_report_screen.dart';
import 'auth_realtime_controller.dart';
import 'profile_controller.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  bool _pushInitialized = false;
  String? _evidenceSyncKey;
  late final WidgetBridge _widgetBridge;
  late final StreamSubscription<WidgetDestination>
  _widgetDestinationSubscription;
  bool _widgetNavigationScheduled = false;

  @override
  void initState() {
    super.initState();
    _widgetBridge = ref.read(widgetBridgeProvider);
    _widgetDestinationSubscription = _widgetBridge.destinations.listen((_) {
      _maybeNavigateToWidgetDestination();
    });
    WidgetsBinding.instance.addObserver(this);
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

  void _maybeNavigateToWidgetDestination() {
    if (!mounted ||
        _widgetNavigationScheduled ||
        ref.read(authControllerProvider) is! AuthSuccess) {
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

      final page = switch (destination) {
        WidgetDestination.quickReport => const QuickReportScreen(),
        WidgetDestination.notifications => const NotificationsScreen(),
      };
      final navigation = Navigator.of(
        context,
      ).push(MaterialPageRoute(builder: (_) => page));
      unawaited(
        navigation.then<void>((_) {
          _widgetNavigationScheduled = false;
          _maybeNavigateToWidgetDestination();
        }),
      );
    });
  }

  void _syncEvidenceQueue(String? userId, bool isOnline, {bool force = false}) {
    final syncKey = '$userId:$isOnline';
    if (!force && _evidenceSyncKey == syncKey) return;
    _evidenceSyncKey = syncKey;
    Future.microtask(() async {
      try {
        final queue = await ref.read(evidenceUploadQueueProvider.future);
        if (!mounted) return;
        if (userId != null && isOnline) {
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
    // Refresh KYC status when app comes back to foreground
    // This ensures verified status updates after admin verification
    if (state == AppLifecycleState.resumed) {
      final authState = ref.read(authControllerProvider);
      if (authState is AuthSuccess) {
        final userId = authState.user?.id;
        if (userId != null) {
          Future.microtask(
            () => ref
                .read(authRealtimeControllerProvider)
                .start(userId, force: true),
          );
          _syncEvidenceQueue(userId, ref.read(isOnlineProvider), force: true);
        }
        ref.invalidate(kycStatusControllerProvider);
        ref.invalidate(profileControllerProvider);
        Future.microtask(() async {
          try {
            final pushService = ref.read(pushServiceProvider);
            final dio = ref.read(dioProvider);
            await pushService.ensureRegistered('android', dio);
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
    final isOnline = ref.watch(isOnlineProvider);
    debugPrint('[AuthWrapper] AuthState changed: ${state.runtimeType}');

    _syncWidgetState(state);
    _maybeNavigateToWidgetDestination();

    // Initialize push service once after successful auth
    if (state is AuthSuccess && !_pushInitialized) {
      _pushInitialized = true;
      Future.microtask(() async {
        try {
          final pushService = ref.read(pushServiceProvider);
          await pushService.requestPermission();
          final dio = ref.read(dioProvider);
          await Future.delayed(const Duration(seconds: 2));
          await pushService.ensureRegistered('android', dio);

          pushService.onTokenRefresh((token) async {
            await pushService.registerToken(token, 'android', dio);
          });

          // Foreground message handler: show simple in-app snackbar and persist
          pushService.onMessage((message) async {
            final title = message.notification?.title ?? 'Notification';
            final body = message.notification?.body ?? '';
            ref.invalidate(notificationsControllerProvider);
            await LocalNotificationService.showFromRemoteMessage(message);
            if (!context.mounted) return;
            ScaffoldMessenger.of(
              context,
            ).showSnackBar(SnackBar(content: Text('$title: $body')));
          });

          // When a user taps a notification and app opens from background
          pushService.onMessageOpened((message) {
            final reportId = message.data['report_id'] as String?;
            if (reportId != null) {
              ref.invalidate(notificationsControllerProvider);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(reportId: reportId),
                ),
              );
            }
          });

          // If launched from terminated state via notification
          final initial = await FirebaseMessaging.instance.getInitialMessage();
          if (initial != null) {
            final reportId = initial.data['report_id'] as String?;
            if (reportId != null && context.mounted) {
              ref.invalidate(notificationsControllerProvider);
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => ReportDetailScreen(reportId: reportId),
                ),
              );
            }
          }
        } catch (e) {
          debugPrint('Push initialization failed: $e');
        }
      });
    }

    final authenticatedUserId = state is AuthSuccess ? state.user?.id : null;
    _syncEvidenceQueue(authenticatedUserId, isOnline);
    final realtime = ref.read(authRealtimeControllerProvider);
    if (authenticatedUserId != null) {
      Future.microtask(() => realtime.start(authenticatedUserId));
    } else {
      realtime.stop();
    }

    return switch (state) {
      AuthSuccess() => const MainNavigationShell(),
      AuthIdle() || AuthError() => const LoginScreen(),
      AuthInitial() || AuthLoading() => const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      ),
    };
  }
}

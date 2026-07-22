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
import '../../../core/network/dio_provider.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/realtime/realtime_contract.dart';
import '../../../core/realtime/realtime_service.dart';
import '../auth_di.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/report_detail_controller.dart';
import '../../reports/presentation/reports_controller.dart';
import 'profile_controller.dart';

class AuthWrapper extends ConsumerStatefulWidget {
  const AuthWrapper({super.key});

  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper>
    with WidgetsBindingObserver {
  bool _pushInitialized = false;
  RealtimeService? _realtimeService;
  String? _realtimeUserId;
  bool _realtimeStarting = false;
  @override
  void initState() {
    super.initState();
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
    WidgetsBinding.instance.removeObserver(this);
    _realtimeService?.dispose();
    super.dispose();
  }

  Future<void> _startRealtime(String userId, {bool force = false}) async {
    if (_realtimeStarting || (!force && _realtimeUserId == userId)) return;
    _realtimeStarting = true;
    try {
      final token = await ref
          .read(authSessionRepositoryProvider)
          .getAccessToken();
      final current = ref.read(authControllerProvider);
      if (!mounted ||
          token == null ||
          token.isEmpty ||
          current is! AuthSuccess ||
          current.user?.id != userId) {
        return;
      }
      final service = _realtimeService ??= RealtimeService();
      service.connect(
        serverUrl: ApiConstants.mediaBaseUrl,
        token: token,
        onEvent: _handleRealtimeEvent,
        onConnect: () {
          if (mounted) ref.invalidate(profileControllerProvider);
        },
      );
      _realtimeUserId = userId;
    } finally {
      _realtimeStarting = false;
    }
  }

  void _stopRealtime() {
    _realtimeService?.dispose();
    _realtimeService = null;
    _realtimeUserId = null;
  }

  void _handleRealtimeEvent(RealtimeEvent event) {
    final targets = invalidationTargets(event);
    if (targets.contains(RealtimeTarget.reports)) {
      ref.invalidate(reportsControllerProvider);
      ref.invalidate(myReportsControllerProvider);
      ref.read(myReportsRefreshProvider.notifier).increment();
      if (event.entityKind == 'report') {
        ref.invalidate(reportDetailControllerProvider(event.entityId));
      }
    }
    if (targets.contains(RealtimeTarget.notifications)) {
      ref.invalidate(notificationsControllerProvider);
    }
    if (targets.contains(RealtimeTarget.profile) &&
        event.entityId == _realtimeUserId) {
      ref.invalidate(profileControllerProvider);
    }
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
          Future.microtask(() => _startRealtime(userId, force: true));
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
    debugPrint('[AuthWrapper] AuthState changed: ${state.runtimeType}');

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
    if (authenticatedUserId != null &&
        authenticatedUserId != _realtimeUserId &&
        !_realtimeStarting) {
      Future.microtask(() => _startRealtime(authenticatedUserId));
    } else if (authenticatedUserId == null && _realtimeService != null) {
      _stopRealtime();
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

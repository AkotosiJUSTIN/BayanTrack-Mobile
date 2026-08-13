import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/api_constants.dart';
import '../../../core/realtime/realtime_contract.dart';
import '../../../core/realtime/realtime_service.dart';
import '../../kyc/presentation/kyc_controller.dart';
import '../../notifications/presentation/notifications_controller.dart';
import '../../reports/presentation/report_detail_controller.dart';
import '../../reports/presentation/reports_controller.dart';
import '../auth_di.dart';
import 'auth_controller.dart';
import 'profile_controller.dart';

final authRealtimeControllerProvider = Provider<AuthRealtimeController>((ref) {
  final controller = AuthRealtimeController(ref);
  ref.onDispose(controller.stop);
  return controller;
});

/// Owns the authenticated realtime connection and Riverpod invalidation.
class AuthRealtimeController {
  AuthRealtimeController(this._ref);

  final Ref _ref;
  RealtimeService? _service;
  String? _desiredUserId;
  String? _connectedUserId;
  bool _starting = false;

  Future<void> start(String userId, {bool force = false}) async {
    if (_starting || (!force && _connectedUserId == userId)) return;
    _desiredUserId = userId;
    _starting = true;
    try {
      final token = await _ref
          .read(authSessionRepositoryProvider)
          .getAccessToken();
      final auth = _ref.read(authControllerProvider);
      if (_desiredUserId != userId ||
          token == null ||
          token.isEmpty ||
          auth is! AuthSuccess ||
          auth.user?.id != userId) {
        return;
      }
      final service = _service ??= RealtimeService();
      service.connect(
        serverUrl: ApiConstants.mediaBaseUrl,
        token: token,
        onEvent: _handleEvent,
        onConnect: () => _ref.invalidate(profileControllerProvider),
      );
      _connectedUserId = userId;
    } finally {
      _starting = false;
    }
  }

  void stop() {
    _desiredUserId = null;
    _connectedUserId = null;
    _service?.dispose();
    _service = null;
  }

  void _handleEvent(RealtimeEvent event) {
    final targets = invalidationTargets(event);
    if (targets.contains(RealtimeTarget.reports)) {
      _ref.invalidate(reportsControllerProvider);
      _ref.invalidate(myReportsControllerProvider);
      _ref.read(myReportsRefreshProvider.notifier).increment();
      if (event.entityKind == 'report') {
        _ref.invalidate(reportDetailControllerProvider(event.entityId));
      }
    }
    if (targets.contains(RealtimeTarget.notifications)) {
      _ref.invalidate(notificationsControllerProvider);
    }
    if (targets.contains(RealtimeTarget.verification)) {
      _ref.invalidate(kycStatusControllerProvider);
    }
    if (targets.contains(RealtimeTarget.profile) &&
        event.entityId == _connectedUserId) {
      _ref.invalidate(profileControllerProvider);
    }
  }
}

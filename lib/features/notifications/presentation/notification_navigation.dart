import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/session_content_cache.dart';
import '../../reports/presentation/report_detail_controller.dart';
import '../../reports/presentation/report_detail_screen.dart';
import '../../reports/presentation/reports_controller.dart';
import '../../system_governance/system_governance_gate.dart';
import '../../system_governance/system_governance_provider.dart';
import 'notifications_controller.dart';

void refreshNotificationContent(WidgetRef ref, Map<String, dynamic> data) {
  ref.invalidate(notificationsControllerProvider);
  final reportId = data['report_id'];
  if (reportId is! String || reportId.isEmpty) return;
  ref.read(sessionContentCacheProvider).remove('report:$reportId');
  ref.invalidate(reportDetailControllerProvider(reportId));
  ref.invalidate(reportsControllerProvider);
  ref.invalidate(myReportsControllerProvider);
  ref.read(myReportsRefreshProvider.notifier).increment();
}

void openNotificationDestination(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> data,
) {
  if (!context.mounted) return;
  refreshNotificationContent(ref, data);
  if (data['type'] == 'terms_updated') {
    ref.invalidate(publishedTermsProvider);
    unawaited(ref.read(systemGovernanceProvider.notifier).refresh());
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => const SystemGovernanceGate(
          child: CurrentTermsScreen(readOnly: true),
        ),
      ),
    );
    return;
  }
  if (data['type'] == 'maintenance_changed') {
    unawaited(ref.read(systemGovernanceProvider.notifier).refresh());
    return;
  }
  final reportId = data['report_id'];
  if (reportId is String && reportId.isNotEmpty) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => ReportDetailScreen(reportId: reportId),
      ),
    );
  }
}

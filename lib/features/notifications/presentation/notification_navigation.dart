import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../reports/presentation/report_detail_screen.dart';
import '../../system_governance/system_governance_gate.dart';
import '../../system_governance/system_governance_provider.dart';
import 'notifications_controller.dart';

void openNotificationDestination(
  BuildContext context,
  WidgetRef ref,
  Map<String, dynamic> data,
) {
  if (!context.mounted) return;
  ref.invalidate(notificationsControllerProvider);
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

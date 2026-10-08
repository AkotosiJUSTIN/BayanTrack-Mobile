import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/backend_reachability_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../auth/auth_di.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../reports/data/report_create_outbox.dart';
import '../../reports/data/report_draft_store.dart';
import '../../../core/network/dio_provider.dart';
import '../../system_governance/system_governance_provider.dart';
import 'evidence_upload_queue.dart';
import 'images_repository.dart';

final evidenceUploadQueueProvider = FutureProvider<EvidenceUploadQueue>((
  ref,
) async {
  final images = ref.watch(imagesRepositoryProvider);
  final drafts = ref.watch(reportDraftStoreProvider);
  final outbox = ref.watch(reportCreateOutboxStoreProvider);
  final session = ref.watch(authSessionRepositoryProvider);
  final queue = await EvidenceUploadQueue.open(
    upload:
        ({
          required file,
          required reportId,
          required evidenceKey,
          required isPrimary,
          required cancelToken,
        }) async {
          await images.uploadImage(
            imageFile: file,
            reportId: reportId,
            isPrimary: isPrimary,
            idempotencyKey: evidenceKey,
            cancelToken: cancelToken,
          );
        },
    isAuthenticated: (userId) async {
      final auth = ref.read(authControllerProvider);
      return auth is AuthSuccess &&
          auth.user?.id == userId &&
          auth.user?.isActive == true &&
          auth.user?.requiresPasswordChange != true &&
          await session.isAuthenticated;
    },
    canReachBackend: () =>
        ref.read(isOnlineProvider) &&
        ref.read(backendReachabilityProvider) == BackendReachability.reachable,
    canUpload: (intent) async {
      final status = ref.read(systemGovernanceProvider).asData?.value;
      if (status?.permitsMutation(isEmergency: intent.isEmergency) == true) {
        return true;
      }
      if (intent.isEmergency) return true;
      // Existing evidence intents predate the emergency marker. REST remains
      // authoritative for scoped emergency reports and their allowed evidence.
      try {
        final response = await ref
            .read(dioProvider)
            .get('/reports/${Uri.encodeComponent(intent.reportId)}/');
        final body = response.data;
        final report = body is Map && body['report'] is Map
            ? body['report'] as Map
            : body;
        return report is Map && report['is_emergency'] == true;
      } catch (_) {
        return false;
      }
    },
    readDraftAttachmentReferences: () async => {
      ...await drafts.readAllAttachmentReferences(),
      ...await outbox.readAllAttachmentReferences(),
    },
  );
  ref.onDispose(queue.dispose);
  return queue;
});

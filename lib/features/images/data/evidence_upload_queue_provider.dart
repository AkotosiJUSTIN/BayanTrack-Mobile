import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/providers/backend_reachability_provider.dart';
import '../../../core/providers/connectivity_provider.dart';
import '../../auth/auth_di.dart';
import '../../auth/presentation/auth_controller.dart';
import '../../reports/data/report_create_outbox.dart';
import '../../reports/data/report_draft_store.dart';
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
    readDraftAttachmentReferences: () async => {
      ...await drafts.readAllAttachmentReferences(),
      ...await outbox.readAllAttachmentReferences(),
    },
  );
  ref.onDispose(queue.dispose);
  return queue;
});

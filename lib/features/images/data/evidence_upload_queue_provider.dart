import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/auth_di.dart';
import '../../auth/presentation/auth_controller.dart';
import 'evidence_upload_queue.dart';
import 'images_repository.dart';

final evidenceUploadQueueProvider = FutureProvider<EvidenceUploadQueue>((
  ref,
) async {
  final images = ref.watch(imagesRepositoryProvider);
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
          await session.isAuthenticated;
    },
  );
  ref.onDispose(queue.dispose);
  return queue;
});

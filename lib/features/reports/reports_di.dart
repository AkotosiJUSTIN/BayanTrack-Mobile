import 'dart:async';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart' show Provider;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth/auth_di.dart';
import '../auth/presentation/auth_controller.dart';
import '../../core/network/dio_provider.dart';
import '../../core/providers/backend_reachability_provider.dart';
import '../../core/providers/connectivity_provider.dart';
import '../images/data/evidence_file_stager.dart';
import '../images/data/evidence_upload_queue.dart';
import '../images/data/evidence_upload_queue_provider.dart';
import 'data/report_cache_store.dart';
import 'data/report_create_outbox.dart';
import 'data/report_draft_store.dart';
import 'data/repositories/reports_repository_impl.dart';
import 'domain/reports_repository.dart';
import 'domain/usecases/create_report_usecase.dart';
import 'domain/usecases/update_report_usecase.dart';
import 'domain/usecases/delete_report_usecase.dart';
import 'domain/usecases/get_my_reports_usecase.dart';
import 'domain/usecases/get_report_stats_usecase.dart';
import 'domain/usecases/get_report_usecase.dart';
import 'domain/usecases/get_reports_usecase.dart';
import 'domain/usecases/verify_report_usecase.dart';
import 'domain/usecases/citizen_close_report_usecase.dart';

part 'reports_di.g.dart';

// ==================== REPOSITORY ====================

/// Provides the [ReportsRepository] implementation.
///
/// Returns [ReportsRepositoryImpl] which uses Dio and ErrorMapper
/// for proper result error handling.
@riverpod
ReportsRepository reportsRepositoryDomain(Ref ref) {
  final dio = ref.watch(dioProvider);
  var ownerId = _ownerId(ref.read(authControllerProvider));
  ref.listen<AuthState>(authControllerProvider, (_, state) {
    ownerId = _ownerId(state);
  });
  ref.keepAlive();
  return ReportsRepositoryImpl(
    dio,
    cache: ref.watch(reportCacheStoreProvider),
    currentOwnerId: () => ownerId,
  );
}

String? _ownerId(AuthState state) =>
    state is AuthSuccess ? state.user?.id : null;

final reportCacheStoreProvider = Provider<ReportCacheStore>((ref) {
  return ReportCacheStore(ref.watch(secureStorageProvider));
});

// ==================== USE CASES ====================

@riverpod
GetReportsUseCase getReportsUseCase(Ref ref) {
  return GetReportsUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
GetMyReportsUseCase getMyReportsUseCase(Ref ref) {
  return GetMyReportsUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
GetReportUseCase getReportUseCase(Ref ref) {
  return GetReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
CreateReportUseCase createReportUseCase(Ref ref) {
  return CreateReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
UpdateReportUseCase updateReportUseCase(Ref ref) {
  return UpdateReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
DeleteReportUseCase deleteReportUseCase(Ref ref) {
  return DeleteReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
GetReportStatsUseCase getReportStatsUseCase(Ref ref) {
  return GetReportStatsUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
VerifyReportUseCase verifyReportUseCase(Ref ref) {
  return VerifyReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

@riverpod
CitizenCloseReportUseCase citizenCloseReportUseCase(Ref ref) {
  return CitizenCloseReportUseCase(
    repository: ref.watch(reportsRepositoryDomainProvider),
  );
}

final reportCreateOutboxProvider = Provider<ReportCreateOutbox>((ref) {
  final createReport = ref.watch(createReportUseCaseProvider);
  final drafts = ref.watch(reportDraftStoreProvider);
  final session = ref.watch(authSessionRepositoryProvider);

  Future<bool> isCurrentOwner(String ownerId) async {
    final auth = ref.read(authControllerProvider);
    return auth is AuthSuccess &&
        auth.user?.id == ownerId &&
        auth.user?.isActive == true &&
        auth.user?.requiresPasswordChange != true;
  }

  final outbox = ReportCreateOutbox(
    store: ref.watch(reportCreateOutboxStoreProvider),
    drafts: drafts,
    isCurrentOwner: isCurrentOwner,
    hasValidSession: (ownerId) async =>
        await isCurrentOwner(ownerId) && await session.isAuthenticated,
    canReachBackend: () =>
        ref.read(isOnlineProvider) &&
        ref.read(backendReachabilityProvider) !=
            BackendReachability.unreachable,
    submit:
        ({required payload, required idempotencyKey, required cancelToken}) =>
            createReport(
              category: _snapshotString(payload, 'category'),
              incidentType: _snapshotString(payload, 'incidentType'),
              title: _snapshotString(payload, 'title'),
              description: _snapshotString(payload, 'description') ?? '',
              incidentDatetime: _snapshotString(payload, 'incidentDatetime'),
              isHappeningNow: _snapshotBool(payload, 'isHappeningNow'),
              zone: _snapshotString(payload, 'zone'),
              streetLandmark: _snapshotString(payload, 'streetLandmark'),
              municipalityId:
                  _snapshotString(payload, 'municipalityId') ?? 'urdaneta',
              barangayId: _snapshotString(payload, 'barangayId'),
              cityMunicipality: _snapshotString(payload, 'cityMunicipality'),
              province: _snapshotString(payload, 'province'),
              latitude: _snapshotString(payload, 'latitude'),
              longitude: _snapshotString(payload, 'longitude'),
              locationAccuracy:
                  _snapshotString(payload, 'locationAccuracy') ?? 'approximate',
              location: _snapshotString(payload, 'location'),
              barangay: _snapshotString(payload, 'barangay'),
              declarationConfirmed: _snapshotBool(
                payload,
                'declarationConfirmed',
              ),
              dataProcessingConsent: _snapshotBool(
                payload,
                'dataProcessingConsent',
              ),
              isQuickReport: _snapshotBool(payload, 'isQuickReport'),
              isEmergency: _snapshotBool(payload, 'isEmergency'),
              idempotencyKey: idempotencyKey,
              cancelToken: cancelToken,
            ),
    handoffAttachments: (item) async {
      if (!await isCurrentOwner(item.ownerId) ||
          !await session.isAuthenticated ||
          item.serverReportId == null) {
        return false;
      }
      final files = <File>[];
      for (final path in item.attachmentRefs) {
        final file = await resolveEvidenceDraftReference(
          path,
          allowMissing: true,
        );
        if (file == null) return false;
        files.add(file);
      }
      if (files.isEmpty) return true;
      final queue = await ref.read(evidenceUploadQueueProvider.future);
      final intents = await queue.enqueue(
        userId: item.ownerId,
        reportId: item.serverReportId!,
        files: files,
      );
      if (intents.length != files.length) return false;
      for (var index = 0; index < intents.length; index++) {
        final intent = intents[index];
        if (intent.ownerUserId != item.ownerId ||
            intent.reportId != item.serverReportId ||
            File(intent.localFilePath).absolute.path !=
                files[index].absolute.path ||
            intent.state == EvidenceUploadState.missingLocalFile) {
          return false;
        }
      }
      if (!await isCurrentOwner(item.ownerId) ||
          !await session.isAuthenticated) {
        return false;
      }
      unawaited(queue.resume(item.ownerId));
      return true;
    },
    onChanged: (ownerId) =>
        ref.invalidate(reportCreateOutboxItemsProvider(ownerId)),
  );
  ref.onDispose(outbox.dispose);
  return outbox;
});

String? _snapshotString(Map<String, Object?> payload, String key) =>
    payload[key] is String ? payload[key] as String : null;

bool _snapshotBool(Map<String, Object?> payload, String key) =>
    payload[key] == true;

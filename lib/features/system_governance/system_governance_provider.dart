import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/network/dio_provider.dart';
import 'system_governance_models.dart';

class SystemGovernanceRepository {
  SystemGovernanceRepository(this._dio);
  final Dio _dio;

  Future<SystemGovernanceState> status() async {
    final response = await _dio.get('/system/status/');
    return SystemGovernanceState.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<PublishedTerms> currentTerms() async {
    final response = await _dio.get('/legal/terms/current/');
    return PublishedTerms.fromJson(
      Map<String, dynamic>.from(response.data as Map),
    );
  }

  Future<void> accept(PublishedTerms terms, String language) async {
    await _dio.post(
      '/legal/terms/accept/',
      data: {
        'version_id': terms.versionId,
        'checksum': terms.checksum,
        'language': language == 'fil' ? 'fil' : 'en',
      },
    );
  }
}

final systemGovernanceRepositoryProvider = Provider<SystemGovernanceRepository>(
  (ref) {
    return SystemGovernanceRepository(ref.watch(dioProvider));
  },
);

final publishedTermsProvider = FutureProvider<PublishedTerms>((ref) {
  return ref.watch(systemGovernanceRepositoryProvider).currentTerms();
});

final systemGovernanceProvider =
    AsyncNotifierProvider<SystemGovernanceController, SystemGovernanceState>(
      SystemGovernanceController.new,
    );

class SystemGovernanceController extends AsyncNotifier<SystemGovernanceState> {
  int _revision = 0;

  @override
  Future<SystemGovernanceState> build() {
    return ref.watch(systemGovernanceRepositoryProvider).status();
  }

  Future<void> refresh() async {
    final revision = ++_revision;
    final updated = await AsyncValue.guard(
      () => ref.read(systemGovernanceRepositoryProvider).status(),
    );
    if (ref.mounted && revision == _revision) state = updated;
  }

  void noteRestriction(String code) {
    _revision++;
    final previous = state.asData?.value;
    if ((code == 'maintenance_read_only' &&
            previous?.maintenanceEnabled == true) ||
        (code == 'terms_acceptance_required' &&
            previous?.termsAcceptanceRequired == true)) {
      return;
    }
    state = AsyncData(
      SystemGovernanceState(
        maintenanceEnabled:
            code == 'maintenance_read_only' ||
            previous?.maintenanceEnabled == true,
        maintenanceMessage: previous?.maintenanceMessage ?? '',
        termsAcceptanceRequired:
            code == 'terms_acceptance_required' ||
            previous?.termsAcceptanceRequired == true,
        latestTermsVersion: previous?.latestTermsVersion,
        acceptedTermsVersion: previous?.acceptedTermsVersion,
      ),
    );
  }
}

bool permitsReportSnapshot(
  AsyncValue<SystemGovernanceState> state,
  Map<String, Object?> payload,
) =>
    payload['isEmergency'] == true ||
    state.asData?.value.permitsMutation(isEmergency: false) == true;

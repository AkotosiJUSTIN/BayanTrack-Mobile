import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../data/auth_models.dart';
import '../data/auth_repository.dart';
import '../../reports/data/reports_repository.dart';

part 'profile_controller.g.dart';

@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<UserProfile> build() async {
    final repository = ref.read(authRepositoryProvider);
    return repository.getProfile();
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final repository = ref.read(authRepositoryProvider);
      return repository.updateProfile(request);
    });
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final repository = ref.read(authRepositoryProvider);
    await repository.changePassword(request);
  }

  Future<void> reload() async {
    state = const AsyncValue.loading();
    ref.invalidateSelf();
  }
}

@riverpod
class ProfileStatsController extends _$ProfileStatsController {
  @override
  Future<Map<String, int>> build() async {
    final reportsRepo = ref.read(reportsRepositoryProvider);
    // Fetch up to 100 recent reports for stats approximation
    final response = await reportsRepo.getMyReports(pageSize: 100);
    final reports = response.results;

    return {
      'total': response.count,
      'resolved': reports
          .where((r) => r.status == 'resolved')
          .length,
      'pending': reports.where((r) => r.status == 'submitted').length,
    };
  }
}

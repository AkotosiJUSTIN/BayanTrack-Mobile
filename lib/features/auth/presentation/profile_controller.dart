import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth_di.dart';
import '../data/auth_models.dart';
import '../../reports/data/reports_repository.dart';

part 'profile_controller.g.dart';

/// ProfileController - manages user profile state.
///
/// Uses domain AuthRepository internally but exposes UserProfile DTO
/// for backward compatibility with screens.
@riverpod
class ProfileController extends _$ProfileController {
  @override
  Future<UserProfile> build() async {
    final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
    final result = await getCurrentUser();

    return result.when(
      success: (user) => UserProfile(
        id: user.id,
        email: user.email,
        firstName: user.firstName,
        lastName: user.lastName,
        role: user.role.toApiString(),
        isActive: true,
      ),
      failure: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final authRepository = ref.read(authRepositoryProvider);
      final result = await authRepository.updateProfile(
        firstName: request.firstName,
        lastName: request.lastName,
      );

      return result.when(
        success: (user) => UserProfile(
          id: user.id,
          email: user.email,
          firstName: user.firstName,
          lastName: user.lastName,
          role: user.role.toApiString(),
          isActive: true,
        ),
        failure: (failure) => throw Exception(failure.message),
      );
    });
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final authRepository = ref.read(authRepositoryProvider);
    final result = await authRepository.changePassword(
      currentPassword: request.currentPassword,
      newPassword: request.newPassword,
      newPasswordConfirm: request.newPasswordConfirm,
    );

    result.when(
      success: (_) {},
      failure: (failure) => throw Exception(failure.message),
    );
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
      'resolved': reports.where((r) => r.status == 'resolved').length,
      'pending': reports.where((r) => r.status == 'submitted').length,
    };
  }
}

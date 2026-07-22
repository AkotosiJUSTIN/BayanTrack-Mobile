import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../auth_di.dart';
import '../data/auth_models.dart';
import '../domain/entities/user.dart';
import '../../reports/reports_di.dart';

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
      success: _profileFromUser,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    state = const AsyncLoading<UserProfile>().copyWithPrevious(state);
    final result = await ref.read(authRepositoryProvider).updateProfile(
      firstName: request.firstName,
      lastName: request.lastName,
      phone: request.phone,
      expectedRevision: request.expectedRevision,
    );
    result.when(
      success: (user) => state = AsyncData(_profileFromUser(user)),
      failure: (failure) {
        final error = Exception(failure.message);
        state = AsyncError(error, StackTrace.current);
        throw error;
      },
    );
  }

  Future<void> uploadAvatar(
    File imageFile, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final result = await ref
        .read(authRepositoryProvider)
        .uploadAvatar(imageFile, onSendProgress: onSendProgress);
    result.when(
      success: (user) => state = AsyncData(_profileFromUser(user)),
      failure: (failure) {
        final error = Exception(failure.message);
        throw error;
      },
    );
  }

  Future<void> removeAvatar() async {
    final result = await ref.read(authRepositoryProvider).removeAvatar();
    result.when(
      success: (user) => state = AsyncData(_profileFromUser(user)),
      failure: (failure) {
        final error = Exception(failure.message);
        throw error;
      },
    );
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

  UserProfile _profileFromUser(User user) => UserProfile(
    id: user.id,
    email: user.email,
    firstName: user.firstName,
    lastName: user.lastName,
    phone: user.phone,
    avatarUrl: user.avatarUrl,
    avatarRevision: user.avatarRevision,
    avatarStorageStatus: user.avatarStorageStatus,
    profileRevision: user.profileRevision,
    role: user.role.toApiString(),
    isActive: user.isActive,
    createdAt: user.createdAt?.toIso8601String(),
    updatedAt: user.updatedAt?.toIso8601String(),
  );
}

@riverpod
class ProfileStatsController extends _$ProfileStatsController {
  @override
  Future<Map<String, int>> build() async {
    final getStats = ref.read(getReportStatsUseCaseProvider);
    final result = await getStats();

    return result.when(
      success: (stats) => {
        'total': stats.total,
        'resolved': stats.resolved,
        'pending': stats.submitted,
      },
      failure: (failure) => throw Exception(failure.message),
    );
  }
}

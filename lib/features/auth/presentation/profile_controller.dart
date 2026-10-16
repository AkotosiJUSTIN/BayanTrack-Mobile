import 'dart:async';
import '../../../core/providers/session_content_cache.dart';
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
  int _revision = 0;
  @override
  Future<UserProfile> build() async {
    _revision++;
    final cache = ref.watch(sessionContentCacheProvider);
    final cached = cache.read<UserProfile>('profile:me');
    if (cached != null) {
      Future.microtask(reload);
      return cached;
    }
    final profile = await _fetch();
    cache.write('profile:me', profile);
    return profile;
  }

  Future<UserProfile> _fetch() async {
    final getCurrentUser = ref.read(getCurrentUserUseCaseProvider);
    final result = await getCurrentUser();

    return result.when(
      success: _profileFromUser,
      failure: (failure) => throw Exception(failure.message),
    );
  }

  Future<void> updateProfile(ProfileUpdateRequest request) async {
    final revision = ++_revision;
    final cache = ref.read(sessionContentCacheProvider);
    final previous = state;
    final result = await ref
        .read(profileMutationUseCaseProvider)
        .updateProfile(
          firstName: request.firstName,
          lastName: request.lastName,
          phone: request.phone,
          expectedRevision: request.expectedRevision,
        );
    if (!ref.mounted || cache.isClosed || revision != _revision) return;
    result.when(
      success: (user) {
        final profile = _profileFromUser(user);
        cache.write('profile:me', profile);
        state = AsyncData(profile);
      },
      failure: (failure) {
        final error = Exception(failure.message);
        state = previous;
        throw error;
      },
    );
  }

  Future<void> uploadAvatar(
    File imageFile, {
    void Function(int sent, int total)? onSendProgress,
  }) async {
    final revision = ++_revision;
    final cache = ref.read(sessionContentCacheProvider);
    final result = await ref
        .read(profileMutationUseCaseProvider)
        .uploadAvatar(imageFile, onSendProgress: onSendProgress);
    if (!ref.mounted || cache.isClosed || revision != _revision) return;
    result.when(
      success: (user) {
        final profile = _profileFromUser(user);
        cache.write('profile:me', profile);
        state = AsyncData(profile);
      },
      failure: (failure) {
        final error = Exception(failure.message);
        throw error;
      },
    );
  }

  Future<void> removeAvatar() async {
    final revision = ++_revision;
    final cache = ref.read(sessionContentCacheProvider);
    final result = await ref
        .read(profileMutationUseCaseProvider)
        .removeAvatar();
    if (!ref.mounted || cache.isClosed || revision != _revision) return;
    result.when(
      success: (user) {
        final profile = _profileFromUser(user);
        cache.write('profile:me', profile);
        state = AsyncData(profile);
      },
      failure: (failure) {
        final error = Exception(failure.message);
        throw error;
      },
    );
  }

  Future<void> changePassword(ChangePasswordRequest request) async {
    final profileMutation = ref.read(profileMutationUseCaseProvider);
    final result = await profileMutation.changePassword(
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
    final revision = ++_revision;
    final cache = ref.read(sessionContentCacheProvider);
    final freshness = ref.read(contentFreshnessProvider.notifier);
    freshness.set('profile:me', ContentFreshness.refreshing);
    try {
      final profile = await _fetch();
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      cache.write('profile:me', profile);
      freshness.set('profile:me', ContentFreshness.current);
      state = AsyncData(profile);
    } catch (error, stack) {
      if (!ref.mounted || cache.isClosed || revision != _revision) return;
      freshness.set('profile:me', ContentFreshness.stale);
      if (!state.hasValue) state = AsyncError<UserProfile>(error, stack);
    }
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
    passwordChangedAt: user.passwordChangedAt?.toIso8601String(),
    passwordExpiresAt: user.passwordExpiresAt?.toIso8601String(),
    passwordDaysRemaining: user.passwordDaysRemaining,
    passwordWarningLevel: user.passwordWarningLevel,
    passwordExpired: user.passwordExpired,
    passwordChangeRequired: user.passwordChangeRequired,
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

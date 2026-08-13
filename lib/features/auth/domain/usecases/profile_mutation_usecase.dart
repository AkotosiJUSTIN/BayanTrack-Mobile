import 'dart:io';

import '../../../../core/domain/result.dart';
import '../auth_repository.dart';
import '../entities/user.dart';

/// Owns authenticated profile mutations exposed to the profile controller.
class ProfileMutationUseCase {
  const ProfileMutationUseCase({required AuthRepository repository})
    : _repository = repository;

  final AuthRepository _repository;

  Future<Result<User>> updateProfile({
    String? firstName,
    String? lastName,
    String? phone,
    int? expectedRevision,
  }) {
    return _repository.updateProfile(
      firstName: firstName,
      lastName: lastName,
      phone: phone,
      expectedRevision: expectedRevision,
    );
  }

  Future<Result<User>> uploadAvatar(
    File imageFile, {
    void Function(int sent, int total)? onSendProgress,
  }) {
    return _repository.uploadAvatar(imageFile, onSendProgress: onSendProgress);
  }

  Future<Result<User>> removeAvatar() => _repository.removeAvatar();

  Future<Result<void>> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirm,
  }) {
    return _repository.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
      newPasswordConfirm: newPasswordConfirm,
    );
  }
}

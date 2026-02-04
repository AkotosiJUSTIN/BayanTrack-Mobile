import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'data/notifications_repository.dart' as legacy;
import 'data/notifications_repository_impl.dart';
import 'domain/notifications_repository.dart';
import 'domain/usecases/get_notifications_usecase.dart';
import 'domain/usecases/get_preferences_usecase.dart';
import 'domain/usecases/mark_all_read_usecase.dart';
import 'domain/usecases/mark_as_read_usecase.dart';
import 'domain/usecases/update_preferences_usecase.dart';

/// Provides the [NotificationsRepository] implementation.
final notificationsDomainRepositoryProvider = Provider<NotificationsRepository>(
  (ref) {
    final legacyRepo = ref.watch(legacy.notificationsRepositoryProvider);
    return NotificationsRepositoryImpl(legacyRepo);
  },
);

/// Provides the [GetNotificationsUseCase].
final getNotificationsUseCaseProvider = Provider<GetNotificationsUseCase>((
  ref,
) {
  final repo = ref.watch(notificationsDomainRepositoryProvider);
  return GetNotificationsUseCase(repository: repo);
});

/// Provides the [MarkAsReadUseCase].
final markAsReadUseCaseProvider = Provider<MarkAsReadUseCase>((ref) {
  final repo = ref.watch(notificationsDomainRepositoryProvider);
  return MarkAsReadUseCase(repository: repo);
});

/// Provides the [MarkAllReadUseCase].
final markAllReadUseCaseProvider = Provider<MarkAllReadUseCase>((ref) {
  final repo = ref.watch(notificationsDomainRepositoryProvider);
  return MarkAllReadUseCase(repository: repo);
});

/// Provides the [GetPreferencesUseCase].
final getPreferencesUseCaseProvider = Provider<GetPreferencesUseCase>((ref) {
  final repo = ref.watch(notificationsDomainRepositoryProvider);
  return GetPreferencesUseCase(repository: repo);
});

/// Provides the [UpdatePreferencesUseCase].
final updatePreferencesUseCaseProvider = Provider<UpdatePreferencesUseCase>((
  ref,
) {
  final repo = ref.watch(notificationsDomainRepositoryProvider);
  return UpdatePreferencesUseCase(repository: repo);
});

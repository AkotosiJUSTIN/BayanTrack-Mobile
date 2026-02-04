// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// ProfileController - manages user profile state.
///
/// Uses domain AuthRepository internally but exposes UserProfile DTO
/// for backward compatibility with screens.

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

/// ProfileController - manages user profile state.
///
/// Uses domain AuthRepository internally but exposes UserProfile DTO
/// for backward compatibility with screens.
final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, UserProfile> {
  /// ProfileController - manages user profile state.
  ///
  /// Uses domain AuthRepository internally but exposes UserProfile DTO
  /// for backward compatibility with screens.
  ProfileControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileControllerHash();

  @$internal
  @override
  ProfileController create() => ProfileController();
}

String _$profileControllerHash() => r'6ddae5aaf93c4d706c89dbf80f07ec47114d385f';

/// ProfileController - manages user profile state.
///
/// Uses domain AuthRepository internally but exposes UserProfile DTO
/// for backward compatibility with screens.

abstract class _$ProfileController extends $AsyncNotifier<UserProfile> {
  FutureOr<UserProfile> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<UserProfile>, UserProfile>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<UserProfile>, UserProfile>,
              AsyncValue<UserProfile>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(ProfileStatsController)
final profileStatsControllerProvider = ProfileStatsControllerProvider._();

final class ProfileStatsControllerProvider
    extends $AsyncNotifierProvider<ProfileStatsController, Map<String, int>> {
  ProfileStatsControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'profileStatsControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$profileStatsControllerHash();

  @$internal
  @override
  ProfileStatsController create() => ProfileStatsController();
}

String _$profileStatsControllerHash() =>
    r'2449b6c701c549922e642dcf86cc505206e2098f';

abstract class _$ProfileStatsController
    extends $AsyncNotifier<Map<String, int>> {
  FutureOr<Map<String, int>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<Map<String, int>>, Map<String, int>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Map<String, int>>, Map<String, int>>,
              AsyncValue<Map<String, int>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

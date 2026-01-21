// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'profile_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(ProfileController)
final profileControllerProvider = ProfileControllerProvider._();

final class ProfileControllerProvider
    extends $AsyncNotifierProvider<ProfileController, UserProfile> {
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

String _$profileControllerHash() => r'7ae403a5ed3001a9e0f694f436dc54cbf6fe761b';

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
    r'23352aa9ffa210b79b69510c0a870b30af7a884a';

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barangays_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provider that fetches and caches the list of barangays from the API.
/// Used by the new report screen for the location dropdown.

@ProviderFor(Barangays)
final barangaysProvider = BarangaysProvider._();

/// Provider that fetches and caches the list of barangays from the API.
/// Used by the new report screen for the location dropdown.
final class BarangaysProvider
    extends $AsyncNotifierProvider<Barangays, List<BarangayModel>> {
  /// Provider that fetches and caches the list of barangays from the API.
  /// Used by the new report screen for the location dropdown.
  BarangaysProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'barangaysProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$barangaysHash();

  @$internal
  @override
  Barangays create() => Barangays();
}

String _$barangaysHash() => r'be0ed567092c9216bffd5f149b4d5cf9a7c87704';

/// Provider that fetches and caches the list of barangays from the API.
/// Used by the new report screen for the location dropdown.

abstract class _$Barangays extends $AsyncNotifier<List<BarangayModel>> {
  FutureOr<List<BarangayModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<List<BarangayModel>>, List<BarangayModel>>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<List<BarangayModel>>, List<BarangayModel>>,
              AsyncValue<List<BarangayModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'barangays_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(Municipalities)
final municipalitiesProvider = MunicipalitiesProvider._();

final class MunicipalitiesProvider
    extends $AsyncNotifierProvider<Municipalities, List<MunicipalityModel>> {
  MunicipalitiesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'municipalitiesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$municipalitiesHash();

  @$internal
  @override
  Municipalities create() => Municipalities();
}

String _$municipalitiesHash() => r'2282a8b3c0e83bc24cec11ffe3bf2ea5e3b88f2c';

abstract class _$Municipalities
    extends $AsyncNotifier<List<MunicipalityModel>> {
  FutureOr<List<MunicipalityModel>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref
            as $Ref<
              AsyncValue<List<MunicipalityModel>>,
              List<MunicipalityModel>
            >;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<
                AsyncValue<List<MunicipalityModel>>,
                List<MunicipalityModel>
              >,
              AsyncValue<List<MunicipalityModel>>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(MunicipalityBarangays)
final municipalityBarangaysProvider = MunicipalityBarangaysFamily._();

final class MunicipalityBarangaysProvider
    extends $AsyncNotifierProvider<MunicipalityBarangays, List<BarangayModel>> {
  MunicipalityBarangaysProvider._({
    required MunicipalityBarangaysFamily super.from,
    required String super.argument,
  }) : super(
         retry: null,
         name: r'municipalityBarangaysProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$municipalityBarangaysHash();

  @override
  String toString() {
    return r'municipalityBarangaysProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  MunicipalityBarangays create() => MunicipalityBarangays();

  @override
  bool operator ==(Object other) {
    return other is MunicipalityBarangaysProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$municipalityBarangaysHash() =>
    r'e178d1a9c493a4bf573d9ff67baae46e6390568b';

final class MunicipalityBarangaysFamily extends $Family
    with
        $ClassFamilyOverride<
          MunicipalityBarangays,
          AsyncValue<List<BarangayModel>>,
          List<BarangayModel>,
          FutureOr<List<BarangayModel>>,
          String
        > {
  MunicipalityBarangaysFamily._()
    : super(
        retry: null,
        name: r'municipalityBarangaysProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  MunicipalityBarangaysProvider call(String municipalityId) =>
      MunicipalityBarangaysProvider._(argument: municipalityId, from: this);

  @override
  String toString() => r'municipalityBarangaysProvider';
}

abstract class _$MunicipalityBarangays
    extends $AsyncNotifier<List<BarangayModel>> {
  late final _$args = ref.$arg as String;
  String get municipalityId => _$args;

  FutureOr<List<BarangayModel>> build(String municipalityId);
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
    element.handleCreate(ref, () => build(_$args));
  }
}

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

String _$barangaysHash() => r'b83e7748bf8789ac5f883c5b6d49d76619aec42c';

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

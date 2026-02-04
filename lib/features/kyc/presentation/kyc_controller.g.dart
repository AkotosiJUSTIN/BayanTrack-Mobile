// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning

@ProviderFor(KycStatusController)
final kycStatusControllerProvider = KycStatusControllerProvider._();

final class KycStatusControllerProvider
    extends $AsyncNotifierProvider<KycStatusController, KycStatusEntity?> {
  KycStatusControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycStatusControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycStatusControllerHash();

  @$internal
  @override
  KycStatusController create() => KycStatusController();
}

String _$kycStatusControllerHash() =>
    r'686d1d47d0482df33033f01a81f2cf56c85b4ed8';

abstract class _$KycStatusController extends $AsyncNotifier<KycStatusEntity?> {
  FutureOr<KycStatusEntity?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<KycStatusEntity?>, KycStatusEntity?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KycStatusEntity?>, KycStatusEntity?>,
              AsyncValue<KycStatusEntity?>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

@ProviderFor(idTypes)
final idTypesProvider = IdTypesProvider._();

final class IdTypesProvider
    extends
        $FunctionalProvider<
          AsyncValue<List<String>>,
          List<String>,
          FutureOr<List<String>>
        >
    with $FutureModifier<List<String>>, $FutureProvider<List<String>> {
  IdTypesProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'idTypesProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$idTypesHash();

  @$internal
  @override
  $FutureProviderElement<List<String>> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<List<String>> create(Ref ref) {
    return idTypes(ref);
  }
}

String _$idTypesHash() => r'78a8f594f78c31b70b55009cb2910e009dc462d5';

@ProviderFor(kycFormOptions)
final kycFormOptionsProvider = KycFormOptionsProvider._();

final class KycFormOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<domain.KycFormOptions>,
          domain.KycFormOptions,
          FutureOr<domain.KycFormOptions>
        >
    with
        $FutureModifier<domain.KycFormOptions>,
        $FutureProvider<domain.KycFormOptions> {
  KycFormOptionsProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycFormOptionsProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycFormOptionsHash();

  @$internal
  @override
  $FutureProviderElement<domain.KycFormOptions> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<domain.KycFormOptions> create(Ref ref) {
    return kycFormOptions(ref);
  }
}

String _$kycFormOptionsHash() => r'b54f7a4340b9654a5cf507a717482ad8d1142abc';

@ProviderFor(KycFormController)
final kycFormControllerProvider = KycFormControllerProvider._();

final class KycFormControllerProvider
    extends $NotifierProvider<KycFormController, KycFormState> {
  KycFormControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'kycFormControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$kycFormControllerHash();

  @$internal
  @override
  KycFormController create() => KycFormController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(KycFormState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<KycFormState>(value),
    );
  }
}

String _$kycFormControllerHash() => r'719e20d557816712217144404e1bc333ce64649b';

abstract class _$KycFormController extends $Notifier<KycFormState> {
  KycFormState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<KycFormState, KycFormState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<KycFormState, KycFormState>,
              KycFormState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

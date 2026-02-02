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
    extends $AsyncNotifierProvider<KycStatusController, KycStatusResponse?> {
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
    r'412e0f05051e9b964549b82397436e5ef1256189';

abstract class _$KycStatusController
    extends $AsyncNotifier<KycStatusResponse?> {
  FutureOr<KycStatusResponse?> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<KycStatusResponse?>, KycStatusResponse?>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<KycStatusResponse?>, KycStatusResponse?>,
              AsyncValue<KycStatusResponse?>,
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

String _$idTypesHash() => r'9b82ebf3ff18c13668ffd3938edb584806ce6365';

@ProviderFor(kycFormOptions)
final kycFormOptionsProvider = KycFormOptionsProvider._();

final class KycFormOptionsProvider
    extends
        $FunctionalProvider<
          AsyncValue<KycFormOptionsResponse>,
          KycFormOptionsResponse,
          FutureOr<KycFormOptionsResponse>
        >
    with
        $FutureModifier<KycFormOptionsResponse>,
        $FutureProvider<KycFormOptionsResponse> {
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
  $FutureProviderElement<KycFormOptionsResponse> $createElement(
    $ProviderPointer pointer,
  ) => $FutureProviderElement(pointer);

  @override
  FutureOr<KycFormOptionsResponse> create(Ref ref) {
    return kycFormOptions(ref);
  }
}

String _$kycFormOptionsHash() => r'5e8668ddff56470cacca4677d38d1c28fb53f2e7';

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

String _$kycFormControllerHash() => r'bc3f057d4cd63f00f66155a16a22d2b1688a8027';

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

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'dio_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Creates a raw Dio instance without auth interceptor.
/// Used for token refresh to avoid circular dependency.

@ProviderFor(dioRaw)
final dioRawProvider = DioRawProvider._();

/// Creates a raw Dio instance without auth interceptor.
/// Used for token refresh to avoid circular dependency.

final class DioRawProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Creates a raw Dio instance without auth interceptor.
  /// Used for token refresh to avoid circular dependency.
  DioRawProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioRawProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioRawHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dioRaw(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioRawHash() => r'3f0b687081b7fcff3d56389b7fb43c315b0de8bb';

/// Main Dio instance with auth interceptor for authenticated requests.

@ProviderFor(dio)
final dioProvider = DioProvider._();

/// Main Dio instance with auth interceptor for authenticated requests.

final class DioProvider extends $FunctionalProvider<Dio, Dio, Dio>
    with $Provider<Dio> {
  /// Main Dio instance with auth interceptor for authenticated requests.
  DioProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'dioProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$dioHash();

  @$internal
  @override
  $ProviderElement<Dio> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  Dio create(Ref ref) {
    return dio(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(Dio value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<Dio>(value),
    );
  }
}

String _$dioHash() => r'b8579917280acc74bf94cc9bb063b639a496502f';

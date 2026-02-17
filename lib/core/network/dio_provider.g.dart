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

String _$dioRawHash() => r'1fa421e6d0c9eda9d84f8fc6c72a6e0a3af44c17';

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

String _$dioHash() => r'c3698c4b9f166c3bde8dc27df8a998c77af8b824';

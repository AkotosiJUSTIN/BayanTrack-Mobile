// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AuthController - ViewModel for authentication flows.
///
/// Uses Clean Architecture use cases for all operations.
/// Does NOT directly access repositories or storage.

@ProviderFor(AuthController)
final authControllerProvider = AuthControllerProvider._();

/// AuthController - ViewModel for authentication flows.
///
/// Uses Clean Architecture use cases for all operations.
/// Does NOT directly access repositories or storage.
final class AuthControllerProvider
    extends $NotifierProvider<AuthController, AuthState> {
  /// AuthController - ViewModel for authentication flows.
  ///
  /// Uses Clean Architecture use cases for all operations.
  /// Does NOT directly access repositories or storage.
  AuthControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'authControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$authControllerHash();

  @$internal
  @override
  AuthController create() => AuthController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AuthState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<AuthState>(value),
    );
  }
}

String _$authControllerHash() => r'e008fe0ef5d0017720ef1eb2cb500d7ba8e84813';

/// AuthController - ViewModel for authentication flows.
///
/// Uses Clean Architecture use cases for all operations.
/// Does NOT directly access repositories or storage.

abstract class _$AuthController extends $Notifier<AuthState> {
  AuthState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AuthState, AuthState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AuthState, AuthState>,
              AuthState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

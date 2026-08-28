// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_di.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Provides the [ReportsRepository] implementation.
///
/// Returns [ReportsRepositoryImpl] which uses Dio and ErrorMapper
/// for proper Result<T> error handling.

@ProviderFor(reportsRepositoryDomain)
final reportsRepositoryDomainProvider = ReportsRepositoryDomainProvider._();

/// Provides the [ReportsRepository] implementation.
///
/// Returns [ReportsRepositoryImpl] which uses Dio and ErrorMapper
/// for proper Result<T> error handling.

final class ReportsRepositoryDomainProvider
    extends
        $FunctionalProvider<
          ReportsRepository,
          ReportsRepository,
          ReportsRepository
        >
    with $Provider<ReportsRepository> {
  /// Provides the [ReportsRepository] implementation.
  ///
  /// Returns [ReportsRepositoryImpl] which uses Dio and ErrorMapper
  /// for proper Result<T> error handling.
  ReportsRepositoryDomainProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'reportsRepositoryDomainProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$reportsRepositoryDomainHash();

  @$internal
  @override
  $ProviderElement<ReportsRepository> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  ReportsRepository create(Ref ref) {
    return reportsRepositoryDomain(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(ReportsRepository value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<ReportsRepository>(value),
    );
  }
}

String _$reportsRepositoryDomainHash() =>
    r'9372046eebd000c3e7ac2ab038710d0c98c67979';

@ProviderFor(getReportsUseCase)
final getReportsUseCaseProvider = GetReportsUseCaseProvider._();

final class GetReportsUseCaseProvider
    extends
        $FunctionalProvider<
          GetReportsUseCase,
          GetReportsUseCase,
          GetReportsUseCase
        >
    with $Provider<GetReportsUseCase> {
  GetReportsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReportsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReportsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReportsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetReportsUseCase create(Ref ref) {
    return getReportsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReportsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReportsUseCase>(value),
    );
  }
}

String _$getReportsUseCaseHash() => r'06d20df9c1f2c1706797d56e137aa4abe1c2d378';

@ProviderFor(getMyReportsUseCase)
final getMyReportsUseCaseProvider = GetMyReportsUseCaseProvider._();

final class GetMyReportsUseCaseProvider
    extends
        $FunctionalProvider<
          GetMyReportsUseCase,
          GetMyReportsUseCase,
          GetMyReportsUseCase
        >
    with $Provider<GetMyReportsUseCase> {
  GetMyReportsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getMyReportsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getMyReportsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetMyReportsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetMyReportsUseCase create(Ref ref) {
    return getMyReportsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetMyReportsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetMyReportsUseCase>(value),
    );
  }
}

String _$getMyReportsUseCaseHash() =>
    r'c55a673fdae0a5a7c5bceabce5e2f48f614246b8';

@ProviderFor(getReportUseCase)
final getReportUseCaseProvider = GetReportUseCaseProvider._();

final class GetReportUseCaseProvider
    extends
        $FunctionalProvider<
          GetReportUseCase,
          GetReportUseCase,
          GetReportUseCase
        >
    with $Provider<GetReportUseCase> {
  GetReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReportUseCase> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  GetReportUseCase create(Ref ref) {
    return getReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReportUseCase>(value),
    );
  }
}

String _$getReportUseCaseHash() => r'8d37ae92a89a27a9d1ccf456230a7f50c78419ab';

@ProviderFor(createReportUseCase)
final createReportUseCaseProvider = CreateReportUseCaseProvider._();

final class CreateReportUseCaseProvider
    extends
        $FunctionalProvider<
          CreateReportUseCase,
          CreateReportUseCase,
          CreateReportUseCase
        >
    with $Provider<CreateReportUseCase> {
  CreateReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'createReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$createReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<CreateReportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CreateReportUseCase create(Ref ref) {
    return createReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CreateReportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CreateReportUseCase>(value),
    );
  }
}

String _$createReportUseCaseHash() =>
    r'f1db02add8fde53004d43a1d48764843f7080907';

@ProviderFor(updateReportUseCase)
final updateReportUseCaseProvider = UpdateReportUseCaseProvider._();

final class UpdateReportUseCaseProvider
    extends
        $FunctionalProvider<
          UpdateReportUseCase,
          UpdateReportUseCase,
          UpdateReportUseCase
        >
    with $Provider<UpdateReportUseCase> {
  UpdateReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'updateReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$updateReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<UpdateReportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  UpdateReportUseCase create(Ref ref) {
    return updateReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(UpdateReportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<UpdateReportUseCase>(value),
    );
  }
}

String _$updateReportUseCaseHash() =>
    r'8c5945aa520367d43d8fbab494b46381b8376d28';

@ProviderFor(deleteReportUseCase)
final deleteReportUseCaseProvider = DeleteReportUseCaseProvider._();

final class DeleteReportUseCaseProvider
    extends
        $FunctionalProvider<
          DeleteReportUseCase,
          DeleteReportUseCase,
          DeleteReportUseCase
        >
    with $Provider<DeleteReportUseCase> {
  DeleteReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'deleteReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$deleteReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<DeleteReportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  DeleteReportUseCase create(Ref ref) {
    return deleteReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(DeleteReportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<DeleteReportUseCase>(value),
    );
  }
}

String _$deleteReportUseCaseHash() =>
    r'683f06d8c37e5118fc3da9aa172c3fbeb43056b6';

@ProviderFor(getReportStatsUseCase)
final getReportStatsUseCaseProvider = GetReportStatsUseCaseProvider._();

final class GetReportStatsUseCaseProvider
    extends
        $FunctionalProvider<
          GetReportStatsUseCase,
          GetReportStatsUseCase,
          GetReportStatsUseCase
        >
    with $Provider<GetReportStatsUseCase> {
  GetReportStatsUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'getReportStatsUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$getReportStatsUseCaseHash();

  @$internal
  @override
  $ProviderElement<GetReportStatsUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  GetReportStatsUseCase create(Ref ref) {
    return getReportStatsUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(GetReportStatsUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<GetReportStatsUseCase>(value),
    );
  }
}

String _$getReportStatsUseCaseHash() =>
    r'b996e7ff989c2822ded2bc1dd5b3422746331ec3';

@ProviderFor(verifyReportUseCase)
final verifyReportUseCaseProvider = VerifyReportUseCaseProvider._();

final class VerifyReportUseCaseProvider
    extends
        $FunctionalProvider<
          VerifyReportUseCase,
          VerifyReportUseCase,
          VerifyReportUseCase
        >
    with $Provider<VerifyReportUseCase> {
  VerifyReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'verifyReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$verifyReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<VerifyReportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  VerifyReportUseCase create(Ref ref) {
    return verifyReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(VerifyReportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<VerifyReportUseCase>(value),
    );
  }
}

String _$verifyReportUseCaseHash() =>
    r'cea77473a7640e05dc9bff9c193310a0c5c75cd4';

@ProviderFor(citizenCloseReportUseCase)
final citizenCloseReportUseCaseProvider = CitizenCloseReportUseCaseProvider._();

final class CitizenCloseReportUseCaseProvider
    extends
        $FunctionalProvider<
          CitizenCloseReportUseCase,
          CitizenCloseReportUseCase,
          CitizenCloseReportUseCase
        >
    with $Provider<CitizenCloseReportUseCase> {
  CitizenCloseReportUseCaseProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'citizenCloseReportUseCaseProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$citizenCloseReportUseCaseHash();

  @$internal
  @override
  $ProviderElement<CitizenCloseReportUseCase> $createElement(
    $ProviderPointer pointer,
  ) => $ProviderElement(pointer);

  @override
  CitizenCloseReportUseCase create(Ref ref) {
    return citizenCloseReportUseCase(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(CitizenCloseReportUseCase value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<CitizenCloseReportUseCase>(value),
    );
  }
}

String _$citizenCloseReportUseCaseHash() =>
    r'49a2a937a7d36df46fad6c963622b6e70a2cb7a5';

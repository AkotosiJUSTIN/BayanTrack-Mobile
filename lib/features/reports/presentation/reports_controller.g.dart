// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// A simple counter-based refresh trigger for [MyReportsScreen].
///
/// Call [MyReportsRefreshNotifier.increment] after a successful report
/// submission to signal [MyReportsScreen] to reload its local list without
/// requiring a manual pull-to-refresh.

@ProviderFor(MyReportsRefreshNotifier)
final myReportsRefreshProvider = MyReportsRefreshNotifierProvider._();

/// A simple counter-based refresh trigger for [MyReportsScreen].
///
/// Call [MyReportsRefreshNotifier.increment] after a successful report
/// submission to signal [MyReportsScreen] to reload its local list without
/// requiring a manual pull-to-refresh.
final class MyReportsRefreshNotifierProvider
    extends $NotifierProvider<MyReportsRefreshNotifier, int> {
  /// A simple counter-based refresh trigger for [MyReportsScreen].
  ///
  /// Call [MyReportsRefreshNotifier.increment] after a successful report
  /// submission to signal [MyReportsScreen] to reload its local list without
  /// requiring a manual pull-to-refresh.
  MyReportsRefreshNotifierProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'myReportsRefreshProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$myReportsRefreshNotifierHash();

  @$internal
  @override
  MyReportsRefreshNotifier create() => MyReportsRefreshNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(int value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<int>(value),
    );
  }
}

String _$myReportsRefreshNotifierHash() =>
    r'e41a8ca4a4a1553ab8124b0975ae4bf12c399c10';

/// A simple counter-based refresh trigger for [MyReportsScreen].
///
/// Call [MyReportsRefreshNotifier.increment] after a successful report
/// submission to signal [MyReportsScreen] to reload its local list without
/// requiring a manual pull-to-refresh.

abstract class _$MyReportsRefreshNotifier extends $Notifier<int> {
  int build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<int, int>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<int, int>,
              int,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

/// Controller for fetching reports from backend.
///
/// Uses [GetReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.

@ProviderFor(ReportsController)
final reportsControllerProvider = ReportsControllerFamily._();

/// Controller for fetching reports from backend.
///
/// Uses [GetReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.
final class ReportsControllerProvider
    extends $AsyncNotifierProvider<ReportsController, PaginatedReports> {
  /// Controller for fetching reports from backend.
  ///
  /// Uses [GetReportsUseCase] for proper clean architecture layering.
  /// Returns domain [PaginatedReports] entity.
  ReportsControllerProvider._({
    required ReportsControllerFamily super.from,
    required ({int page, String? status}) super.argument,
  }) : super(
         retry: null,
         name: r'reportsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportsControllerHash();

  @override
  String toString() {
    return r'reportsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  ReportsController create() => ReportsController();

  @override
  bool operator ==(Object other) {
    return other is ReportsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportsControllerHash() => r'798c9e4658a8942e09228fb72665b09d0d0f338d';

/// Controller for fetching reports from backend.
///
/// Uses [GetReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.

final class ReportsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ReportsController,
          AsyncValue<PaginatedReports>,
          PaginatedReports,
          FutureOr<PaginatedReports>,
          ({int page, String? status})
        > {
  ReportsControllerFamily._()
    : super(
        retry: null,
        name: r'reportsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for fetching reports from backend.
  ///
  /// Uses [GetReportsUseCase] for proper clean architecture layering.
  /// Returns domain [PaginatedReports] entity.

  ReportsControllerProvider call({int page = 1, String? status}) =>
      ReportsControllerProvider._(
        argument: (page: page, status: status),
        from: this,
      );

  @override
  String toString() => r'reportsControllerProvider';
}

/// Controller for fetching reports from backend.
///
/// Uses [GetReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.

abstract class _$ReportsController extends $AsyncNotifier<PaginatedReports> {
  late final _$args = ref.$arg as ({int page, String? status});
  int get page => _$args.page;
  String? get status => _$args.status;

  FutureOr<PaginatedReports> build({int page = 1, String? status});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PaginatedReports>, PaginatedReports>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaginatedReports>, PaginatedReports>,
              AsyncValue<PaginatedReports>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(page: _$args.page, status: _$args.status),
    );
  }
}

/// Controller for fetching user's own reports.
///
/// Uses [GetMyReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.

@ProviderFor(MyReportsController)
final myReportsControllerProvider = MyReportsControllerFamily._();

/// Controller for fetching user's own reports.
///
/// Uses [GetMyReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.
final class MyReportsControllerProvider
    extends $AsyncNotifierProvider<MyReportsController, PaginatedReports> {
  /// Controller for fetching user's own reports.
  ///
  /// Uses [GetMyReportsUseCase] for proper clean architecture layering.
  /// Returns domain [PaginatedReports] entity.
  MyReportsControllerProvider._({
    required MyReportsControllerFamily super.from,
    required ({int page, String? status}) super.argument,
  }) : super(
         retry: null,
         name: r'myReportsControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$myReportsControllerHash();

  @override
  String toString() {
    return r'myReportsControllerProvider'
        ''
        '$argument';
  }

  @$internal
  @override
  MyReportsController create() => MyReportsController();

  @override
  bool operator ==(Object other) {
    return other is MyReportsControllerProvider && other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$myReportsControllerHash() =>
    r'2caf6cd63418e56af4e114052d688283e05e260c';

/// Controller for fetching user's own reports.
///
/// Uses [GetMyReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.

final class MyReportsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MyReportsController,
          AsyncValue<PaginatedReports>,
          PaginatedReports,
          FutureOr<PaginatedReports>,
          ({int page, String? status})
        > {
  MyReportsControllerFamily._()
    : super(
        retry: null,
        name: r'myReportsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for fetching user's own reports.
  ///
  /// Uses [GetMyReportsUseCase] for proper clean architecture layering.
  /// Returns domain [PaginatedReports] entity.

  MyReportsControllerProvider call({int page = 1, String? status}) =>
      MyReportsControllerProvider._(
        argument: (page: page, status: status),
        from: this,
      );

  @override
  String toString() => r'myReportsControllerProvider';
}

/// Controller for fetching user's own reports.
///
/// Uses [GetMyReportsUseCase] for proper clean architecture layering.
/// Returns domain [PaginatedReports] entity.

abstract class _$MyReportsController extends $AsyncNotifier<PaginatedReports> {
  late final _$args = ref.$arg as ({int page, String? status});
  int get page => _$args.page;
  String? get status => _$args.status;

  FutureOr<PaginatedReports> build({int page = 1, String? status});
  @$mustCallSuper
  @override
  void runBuild() {
    final ref =
        this.ref as $Ref<AsyncValue<PaginatedReports>, PaginatedReports>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<PaginatedReports>, PaginatedReports>,
              AsyncValue<PaginatedReports>,
              Object?,
              Object?
            >;
    element.handleCreate(
      ref,
      () => build(page: _$args.page, status: _$args.status),
    );
  }
}

// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'reports_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for fetching reports from backend

@ProviderFor(ReportsController)
final reportsControllerProvider = ReportsControllerFamily._();

/// Controller for fetching reports from backend
final class ReportsControllerProvider
    extends $AsyncNotifierProvider<ReportsController, PaginatedReports> {
  /// Controller for fetching reports from backend
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

String _$reportsControllerHash() => r'112d736c2ef8c2a02a13c6b54bade93a4f105335';

/// Controller for fetching reports from backend

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

  /// Controller for fetching reports from backend

  ReportsControllerProvider call({int page = 1, String? status}) =>
      ReportsControllerProvider._(
        argument: (page: page, status: status),
        from: this,
      );

  @override
  String toString() => r'reportsControllerProvider';
}

/// Controller for fetching reports from backend

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

/// Controller for fetching user's own reports

@ProviderFor(MyReportsController)
final myReportsControllerProvider = MyReportsControllerFamily._();

/// Controller for fetching user's own reports
final class MyReportsControllerProvider
    extends $AsyncNotifierProvider<MyReportsController, PaginatedReports> {
  /// Controller for fetching user's own reports
  MyReportsControllerProvider._({
    required MyReportsControllerFamily super.from,
    required int super.argument,
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
        '($argument)';
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
    r'603082ffaed5160e85dc1bad8f88b97c4db3092a';

/// Controller for fetching user's own reports

final class MyReportsControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          MyReportsController,
          AsyncValue<PaginatedReports>,
          PaginatedReports,
          FutureOr<PaginatedReports>,
          int
        > {
  MyReportsControllerFamily._()
    : super(
        retry: null,
        name: r'myReportsControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for fetching user's own reports

  MyReportsControllerProvider call({int page = 1}) =>
      MyReportsControllerProvider._(argument: page, from: this);

  @override
  String toString() => r'myReportsControllerProvider';
}

/// Controller for fetching user's own reports

abstract class _$MyReportsController extends $AsyncNotifier<PaginatedReports> {
  late final _$args = ref.$arg as int;
  int get page => _$args;

  FutureOr<PaginatedReports> build({int page = 1});
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
    element.handleCreate(ref, () => build(page: _$args));
  }
}

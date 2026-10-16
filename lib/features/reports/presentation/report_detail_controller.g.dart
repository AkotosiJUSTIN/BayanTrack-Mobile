// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'report_detail_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for fetching a single report by ID.
///
/// Uses [GetReportUseCase] for proper clean architecture layering.
/// Returns domain [Report] entity.

@ProviderFor(ReportDetailController)
final reportDetailControllerProvider = ReportDetailControllerFamily._();

/// Controller for fetching a single report by ID.
///
/// Uses [GetReportUseCase] for proper clean architecture layering.
/// Returns domain [Report] entity.
final class ReportDetailControllerProvider
    extends $AsyncNotifierProvider<ReportDetailController, Report> {
  /// Controller for fetching a single report by ID.
  ///
  /// Uses [GetReportUseCase] for proper clean architecture layering.
  /// Returns domain [Report] entity.
  ReportDetailControllerProvider._({
    required ReportDetailControllerFamily super.from,
    required String super.argument,
  }) : super(
         retry: _noDetailRetry,
         name: r'reportDetailControllerProvider',
         isAutoDispose: true,
         dependencies: null,
         $allTransitiveDependencies: null,
       );

  @override
  String debugGetCreateSourceHash() => _$reportDetailControllerHash();

  @override
  String toString() {
    return r'reportDetailControllerProvider'
        ''
        '($argument)';
  }

  @$internal
  @override
  ReportDetailController create() => ReportDetailController();

  @override
  bool operator ==(Object other) {
    return other is ReportDetailControllerProvider &&
        other.argument == argument;
  }

  @override
  int get hashCode {
    return argument.hashCode;
  }
}

String _$reportDetailControllerHash() =>
    r'b6548d4d124da5c4098b92020ae8eaa89d5de84f';

/// Controller for fetching a single report by ID.
///
/// Uses [GetReportUseCase] for proper clean architecture layering.
/// Returns domain [Report] entity.

final class ReportDetailControllerFamily extends $Family
    with
        $ClassFamilyOverride<
          ReportDetailController,
          AsyncValue<Report>,
          Report,
          FutureOr<Report>,
          String
        > {
  ReportDetailControllerFamily._()
    : super(
        retry: _noDetailRetry,
        name: r'reportDetailControllerProvider',
        dependencies: null,
        $allTransitiveDependencies: null,
        isAutoDispose: true,
      );

  /// Controller for fetching a single report by ID.
  ///
  /// Uses [GetReportUseCase] for proper clean architecture layering.
  /// Returns domain [Report] entity.

  ReportDetailControllerProvider call(String reportId) =>
      ReportDetailControllerProvider._(argument: reportId, from: this);

  @override
  String toString() => r'reportDetailControllerProvider';
}

/// Controller for fetching a single report by ID.
///
/// Uses [GetReportUseCase] for proper clean architecture layering.
/// Returns domain [Report] entity.

abstract class _$ReportDetailController extends $AsyncNotifier<Report> {
  late final _$args = ref.$arg as String;
  String get reportId => _$args;

  FutureOr<Report> build(String reportId);
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<Report>, Report>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<AsyncValue<Report>, Report>,
              AsyncValue<Report>,
              Object?,
              Object?
            >;
    element.handleCreate(ref, () => build(_$args));
  }
}

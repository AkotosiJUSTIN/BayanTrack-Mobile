// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'new_report_controller.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Controller for managing new report flow state

@ProviderFor(NewReportController)
final newReportControllerProvider = NewReportControllerProvider._();

/// Controller for managing new report flow state
final class NewReportControllerProvider
    extends $NotifierProvider<NewReportController, NewReportState> {
  /// Controller for managing new report flow state
  NewReportControllerProvider._()
    : super(
        from: null,
        argument: null,
        retry: null,
        name: r'newReportControllerProvider',
        isAutoDispose: true,
        dependencies: null,
        $allTransitiveDependencies: null,
      );

  @override
  String debugGetCreateSourceHash() => _$newReportControllerHash();

  @$internal
  @override
  NewReportController create() => NewReportController();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(NewReportState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<NewReportState>(value),
    );
  }
}

String _$newReportControllerHash() =>
    r'bb4593514748046f6c519fba90862a8ed84e066c';

/// Controller for managing new report flow state

abstract class _$NewReportController extends $Notifier<NewReportState> {
  NewReportState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<NewReportState, NewReportState>;
    final element =
        ref.element
            as $ClassProviderElement<
              AnyNotifier<NewReportState, NewReportState>,
              NewReportState,
              Object?,
              Object?
            >;
    element.handleCreate(ref, build);
  }
}

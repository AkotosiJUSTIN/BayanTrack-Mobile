import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_report_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/report_detail_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

void main() {
  test('403 detail failure does not auto-retry provider', () async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getReport('report-1'),
    ).thenAnswer((_) async => const Err<Report>(AuthFailure('Access denied')));
    final container = ProviderContainer(
      overrides: [
        getReportUseCaseProvider.overrideWithValue(
          GetReportUseCase(repository: repository),
        ),
      ],
    );
    addTearDown(container.dispose);

    await expectLater(
      container.read(reportDetailControllerProvider('report-1').future),
      throwsA(isA<Exception>()),
    );
    await Future<void>.delayed(const Duration(seconds: 2));

    verify(() => repository.getReport('report-1')).called(1);
  });
}

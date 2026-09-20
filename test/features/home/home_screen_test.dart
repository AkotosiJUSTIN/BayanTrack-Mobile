import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/home/presentation/home_screen.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/paginated_reports.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

Widget _app(_ReportsRepositoryMock repository) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      getReportsUseCaseProvider.overrideWithValue(
        GetReportsUseCase(repository: repository),
      ),
      userPermissionsProvider.overrideWithValue(UserPermissions(null)),
    ],
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: const HomeScreen(),
    ),
  );
}

void _stubReports(
  _ReportsRepositoryMock repository,
  Future<Result<PaginatedReports>> Function() load,
) {
  when(
    () => repository.getReports(
      page: 1,
      pageSize: 20,
      status: null,
      zone: null,
      category: null,
      sortBy: 'date',
    ),
  ).thenAnswer((_) => load());
}

void main() {
  testWidgets('Home initializes public reports provider on first build', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      return const Success(PaginatedReports(results: [], total: 0));
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();

    expect(calls, 1);
  });

  testWidgets('Home retry emits a fresh public reports request after failure', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    var calls = 0;
    _stubReports(repository, () async {
      calls++;
      if (calls == 1) return const Err(NetworkFailure('offline'));
      return const Success(PaginatedReports(results: [], total: 0));
    });

    await tester.pumpWidget(_app(repository));
    await tester.pumpAndSettle();
    expect(find.text('Retry'), findsWidgets);

    await tester.tap(find.widgetWithText(FilledButton, 'Retry'));
    await tester.pumpAndSettle();

    expect(calls, 2);
  });
}

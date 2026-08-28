import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/home/presentation/home_screen.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/paginated_notifications.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_controller.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/paginated_reports.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/my_reports_screen.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

Widget _app({required Widget home, required List<Override> overrides}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    ),
  );
}

void main() {
  testWidgets('Home exposes accessible view controls and retry on failure', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getReports(
        page: 1,
        pageSize: 20,
        status: null,
        zone: null,
        category: null,
        sortBy: 'date',
      ),
    ).thenAnswer(
      (_) async => const Err<PaginatedReports>(ServerFailure('Unavailable')),
    );

    await tester.pumpWidget(
      _app(
        home: const HomeScreen(),
        overrides: [
          getReportsUseCaseProvider.overrideWithValue(
            GetReportsUseCase(repository: repository),
          ),
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byType(SegmentedButton<bool>), findsOneWidget);
    expect(find.text('Map'), findsOneWidget);
    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('My Reports keeps status context and retry on failure', (
    tester,
  ) async {
    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer(
      (_) async => const Err<PaginatedReports>(ServerFailure('Unavailable')),
    );

    await tester.pumpWidget(
      _app(
        home: const MyReportsScreen(),
        overrides: [
          getMyReportsUseCaseProvider.overrideWithValue(
            GetMyReportsUseCase(repository: repository),
          ),
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Status'), findsOneWidget);
    expect(find.text('Retry'), findsOneWidget);
  });

  testWidgets('Notifications keeps unread actions and readable message rows', (
    tester,
  ) async {
    const notification = NotificationEntity(
      id: 'notification-1',
      title: 'Report update',
      message: 'Your report is now under review.',
      type: NotificationType.statusChange,
    );

    await tester.pumpWidget(
      _app(
        home: const NotificationsScreen(),
        overrides: [
          notificationsControllerProvider.overrideWithBuild(
            (_, _) async => const PaginatedNotifications(
              results: [notification],
              unreadCount: 1,
            ),
          ),
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Mark all read'), findsOneWidget);
    expect(find.text('Report update'), findsOneWidget);
    expect(find.text('Your report is now under review.'), findsOneWidget);
  });
}

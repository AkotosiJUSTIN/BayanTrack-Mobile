import 'dart:async';

import 'package:bayantrack_mobile/core/domain/failures.dart';
import 'package:bayantrack_mobile/core/domain/result.dart';
import 'package:bayantrack_mobile/core/providers/backend_reachability_provider.dart';
import 'package:bayantrack_mobile/core/theme/app_colors.dart';
import 'package:bayantrack_mobile/features/auth/data/user_permissions.dart';
import 'package:bayantrack_mobile/features/home/presentation/home_screen.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/notification_type.dart';
import 'package:bayantrack_mobile/features/notifications/domain/entities/paginated_notifications.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_controller.dart';
import 'package:bayantrack_mobile/features/notifications/presentation/notifications_screen.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/paginated_reports.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report.dart';
import 'package:bayantrack_mobile/features/reports/domain/entities/report_enums.dart';
import 'package:bayantrack_mobile/features/reports/domain/reports_repository.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_my_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/domain/usecases/get_reports_usecase.dart';
import 'package:bayantrack_mobile/features/reports/presentation/my_reports_screen.dart';
import 'package:bayantrack_mobile/features/reports/presentation/reports_controller.dart';
import 'package:bayantrack_mobile/features/reports/reports_di.dart';
import 'package:bayantrack_mobile/l10n/app_localizations.dart';
import 'package:bayantrack_mobile/core/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart' show Override;

class _ReportsRepositoryMock extends Mock implements ReportsRepository {}

class _TestReachability extends BackendReachabilityNotifier {
  @override
  BackendReachability build() => BackendReachability.reachable;
}

class _FailingNotificationsController extends NotificationsController {
  @override
  Future<PaginatedNotifications> build() async {
    throw Exception('private backend details');
  }
}

Widget _app({
  required Widget home,
  required List<Override> overrides,
  ThemeData? theme,
  Locale? locale,
}) {
  return ProviderScope(
    retry: (_, _) => null,
    overrides: [
      ...overrides,
      backendReachabilityProvider.overrideWith(_TestReachability.new),
    ],
    child: MaterialApp(
      theme: theme,
      locale: locale,
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
    expect(find.text('Filter by status'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip('Try again'),
      ),
      findsNothing,
    );
    expect(find.byType(RefreshIndicator), findsOneWidget);
  });

  testWidgets('Home search keeps focus when keyboard changes header layout', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
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
      (_) async => Success(
        PaginatedReports(
          results: const [Report(id: 'home-1', description: 'Test report')],
          total: 1,
        ),
      ),
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

    expect(
      tester
          .widget<Scaffold>(find.byType(Scaffold).first)
          .resizeToAvoidBottomInset,
      isFalse,
    );

    final search = find.byType(TextField).first;
    await tester.tap(search);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.hasFocus, isTrue);

    tester.view.viewInsets = const FakeViewPadding(bottom: 220);
    await tester.pump();
    expect(tester.binding.focusManager.primaryFocus?.hasFocus, isTrue);

    await tester.enterText(search, 'street');
    expect(tester.widget<TextField>(search).controller?.text, 'street');
  });

  testWidgets('Home stays usable on compact and large-text phones', (
    tester,
  ) async {
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    tester.view.devicePixelRatio = 3;

    final repository = _ReportsRepositoryMock();
    when(
      () => repository.getReports(
        page: any(named: 'page'),
        pageSize: any(named: 'pageSize'),
        status: any(named: 'status'),
        zone: any(named: 'zone'),
        category: any(named: 'category'),
        sortBy: any(named: 'sortBy'),
      ),
    ).thenAnswer(
      (_) async => const Err<PaginatedReports>(ServerFailure('Unavailable')),
    );

    for (final size in [const Size(320, 568), const Size(412, 915)]) {
      tester.view.physicalSize = size * 3;
      await tester.pumpWidget(
        _app(
          home: Builder(
            builder: (context) => MediaQuery(
              data: MediaQuery.of(
                context,
              ).copyWith(textScaler: TextScaler.linear(1.3)),
              child: const HomeScreen(),
            ),
          ),
          overrides: [
            getReportsUseCaseProvider.overrideWithValue(
              GetReportsUseCase(repository: repository),
            ),
            userPermissionsProvider.overrideWithValue(UserPermissions(null)),
          ],
        ),
      );
      await tester.pumpAndSettle();
      expect(tester.takeException(), isNull);
    }
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

    expect(find.text('Filter by status'), findsOneWidget);
    expect(find.text('Try again'), findsOneWidget);
    expect(find.byKey(const Key('home-verification-toggle')), findsOneWidget);
    expect(
      find.descendant(
        of: find.byType(AppBar),
        matching: find.byTooltip('Try again'),
      ),
      findsNothing,
    );
    expect(find.byType(RefreshIndicator), findsOneWidget);
    expect(find.text('User Verification'), findsNothing);
    await tester.tap(find.byKey(const Key('home-verification-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('User Verification'), findsOneWidget);
  });

  testWidgets('My Reports highlights reports awaiting citizen confirmation', (
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
      (_) async => Success<PaginatedReports>(
        PaginatedReports(
          results: [
            Report(
              id: 'report-1',
              description: 'Resolved streetlight issue',
              status: ReportStatus.resolved,
              createdAt: DateTime(2026, 8, 29),
            ),
          ],
          total: 1,
        ),
      ),
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

    expect(find.text('1 awaiting your confirmation'), findsOneWidget);
    expect(find.text('Awaiting your confirmation'), findsOneWidget);
  });

  testWidgets('My Reports ignores stale refresh responses', (tester) async {
    final repository = _ReportsRepositoryMock();
    final firstResponse = Completer<Result<PaginatedReports>>();
    final secondResponse = Completer<Result<PaginatedReports>>();
    var calls = 0;

    when(
      () => repository.getMyReports(
        page: 1,
        pageSize: 20,
        status: null,
        sortBy: 'date',
      ),
    ).thenAnswer((_) {
      calls++;
      return calls == 1 ? firstResponse.future : secondResponse.future;
    });

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
    await tester.pump();
    expect(calls, 1);

    final container = ProviderScope.containerOf(
      tester.element(find.byType(MyReportsScreen)),
    );
    container.read(myReportsRefreshProvider.notifier).increment();
    await tester.pump();
    expect(calls, 2);

    const report = Report(id: 'report-1', description: 'Repeated report');
    firstResponse.complete(
      const Success(PaginatedReports(results: [report], total: 1)),
    );
    await tester.pump();
    expect(find.text('Repeated report'), findsNothing);

    secondResponse.complete(
      const Success(PaginatedReports(results: [report], total: 1)),
    );
    await tester.pumpAndSettle();

    expect(find.text('Repeated report'), findsOneWidget);
    expect(tester.takeException(), isNull);
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
    expect(find.byKey(const Key('home-verification-toggle')), findsOneWidget);
    expect(find.text('User Verification'), findsNothing);
    await tester.tap(find.byKey(const Key('home-verification-toggle')));
    await tester.pumpAndSettle();
    expect(find.text('User Verification'), findsOneWidget);
  });

  testWidgets(
    'Notifications use a light blue unread surface without changing dark mode',
    (tester) async {
      Future<void> pumpNotification(ThemeData theme, bool isRead) async {
        await tester.pumpWidget(const SizedBox.shrink());
        await tester.pumpWidget(
          _app(
            home: const NotificationsScreen(),
            theme: theme,
            overrides: [
              notificationsControllerProvider.overrideWithBuild(
                (_, _) async => PaginatedNotifications(
                  results: [
                    NotificationEntity(
                      id: 'notification-1',
                      title: 'Report update',
                      message: 'Your report is now under review.',
                      type: NotificationType.statusChange,
                      isRead: isRead,
                    ),
                  ],
                  unreadCount: isRead ? 0 : 1,
                ),
              ),
              userPermissionsProvider.overrideWithValue(UserPermissions(null)),
            ],
          ),
        );
        await tester.pumpAndSettle();
      }

      Material notificationMaterial() => tester.widget<Material>(
        find
            .ancestor(
              of: find.text('Report update'),
              matching: find.byType(Material),
            )
            .first,
      );

      await pumpNotification(AppTheme.light, false);
      final lightUnread = notificationMaterial();
      expect(lightUnread.color, AppColors.citizenLightUnreadNotification);
      final lightShape = lightUnread.shape! as RoundedRectangleBorder;
      expect(lightShape.borderRadius, BorderRadius.circular(16));
      expect(lightShape.side.style, BorderStyle.none);

      await pumpNotification(AppTheme.light, true);
      expect(notificationMaterial().color, AppTheme.light.colorScheme.surface);
      expect(notificationMaterial().color, isNot(lightUnread.color));

      await pumpNotification(AppTheme.dark, false);
      expect(
        notificationMaterial().color,
        Color.alphaBlend(
          AppTheme.dark.colorScheme.primary.withValues(alpha: 0.07),
          AppTheme.dark.colorScheme.surface,
        ),
      );
    },
  );

  testWidgets('Notifications hides raw failures behind localized retry copy', (
    tester,
  ) async {
    await tester.pumpWidget(
      _app(
        home: const NotificationsScreen(),
        overrides: [
          notificationsControllerProvider.overrideWith(
            _FailingNotificationsController.new,
          ),
          userPermissionsProvider.overrideWithValue(UserPermissions(null)),
        ],
      ),
    );
    await tester.pumpAndSettle();

    expect(
      find.text(
        'We’re having trouble loading notifications. Please check your internet connection and try again.',
      ),
      findsOneWidget,
    );
    expect(find.text('private backend details'), findsNothing);
  });

  testWidgets('Notifications stays readable on a narrow Filipino dark screen', (
    tester,
  ) async {
    addTearDown(tester.view.reset);
    tester.view.physicalSize = const Size(960, 1600);
    tester.view.devicePixelRatio = 3;

    const notification = NotificationEntity(
      id: 'notification-1',
      title: 'Pagbabago ng ulat',
      message: 'Sinusuri na ang iyong ulat.',
      type: NotificationType.statusChange,
    );
    await tester.pumpWidget(
      _app(
        home: const NotificationsScreen(),
        theme: AppTheme.dark,
        locale: const Locale('fil'),
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

    expect(find.text('Hindi pa nababasa'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}

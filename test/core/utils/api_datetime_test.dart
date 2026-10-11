import 'package:flutter_test/flutter_test.dart';
import 'package:bayantrack_mobile/core/utils/api_datetime.dart';
import 'package:bayantrack_mobile/features/notifications/data/notification_models.dart'
    as notifications;
import 'package:bayantrack_mobile/features/notifications/data/mappers/notification_mapper.dart';
import 'package:bayantrack_mobile/features/reports/data/report_models.dart'
    as reports;
import 'package:bayantrack_mobile/features/reports/data/mappers/report_mapper.dart';

void main() {
  test(
    'legacy naive timestamp, Z, and explicit offset identify the same instant',
    () {
      final expected = DateTime.utc(2026, 10, 11, 4, 18, 30, 123, 456);
      for (final value in [
        '2026-10-11T04:18:30.123456',
        '2026-10-11T04:18:30.123456Z',
        '2026-10-11T12:18:30.123456+08:00',
        '2026-10-10T23:18:30.123456-05:00',
      ]) {
        expect(parseApiDateTime(value)!.toUtc(), expected, reason: value);
        expect(parseApiDateTime(value)!.isUtc, isFalse);
      }
      expect(parseApiDateTime(null), isNull);
      expect(parseApiDateTime('invalid'), isNull);
    },
  );

  test('report and notification mappers share UTC interpretation', () {
    const timestamp = '2026-10-11T04:18:30';
    final report = ReportMapper.fromDto(
      reports.Report.fromJson({
        'id': 'r1',
        'created_at': timestamp,
        'submitted_at': timestamp,
      }),
    );
    final notification = NotificationMapper.toNotificationEntity(
      notifications.AppNotification.fromJson({
        'id': 'n1',
        'title': 'Anchored',
        'message': 'Synthetic notification',
        'type': 'system',
        'created_at': timestamp,
      }),
    );
    final expected = DateTime.utc(2026, 10, 11, 4, 18, 30);
    expect(report.createdAt!.toUtc(), expected);
    expect(report.submittedAt!.toUtc(), expected);
    expect(notification.createdAt!.toUtc(), expected);
  });
}

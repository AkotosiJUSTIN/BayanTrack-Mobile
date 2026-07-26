import 'package:bayantrack_mobile/core/realtime/realtime_contract.dart';
import 'package:flutter_test/flutter_test.dart';

Map<String, dynamic> event(String name, {String eventId = 'event-1'}) => {
  'version': 1,
  'event_id': eventId,
  'name': name,
  'entity': {'kind': 'report', 'id': 'RPT-1'},
  'occurred_at': '2026-07-16T00:00:00Z',
  'correlation_id': 'request-1',
};

void main() {
  test('parses the compact versioned contract', () {
    final parsed = RealtimeEvent.tryParse(event('report.status_changed'));
    expect(parsed?.entityId, 'RPT-1');
    expect(parsed?.correlationId, 'request-1');
    expect(
      RealtimeEvent.tryParse({...event('queue.changed'), 'version': 2}),
      isNull,
    );
  });

  test('accepts only compact profile and avatar revision metadata', () {
    final parsed = RealtimeEvent.tryParse({
      ...event('user_directory.changed'),
      'entity': {'kind': 'user', 'id': 'USR-1'},
      'revisions': {'profile': 7, 'avatar': 3},
    });

    expect(parsed?.profileRevision, 7);
    expect(parsed?.avatarRevision, 3);
    expect(
      RealtimeEvent.tryParse({
        ...event('user_directory.changed', eventId: 'event-private'),
        'entity': {'kind': 'user', 'id': 'USR-1'},
        'phone': '+639123456789',
      }),
      isNull,
    );
    expect(
      RealtimeEvent.tryParse({
        ...event('user_directory.changed', eventId: 'event-cid'),
        'entity': {'kind': 'user', 'id': 'USR-1', 'cid': 'private-cid'},
      }),
      isNull,
    );
    expect(
      RealtimeEvent.tryParse({
        ...event('user_directory.changed', eventId: 'event-provider'),
        'entity': {'kind': 'user', 'id': 'USR-1'},
        'revisions': {'profile': 7, 'gateway': 'provider.example'},
      }),
      isNull,
    );
    expect(
      RealtimeEvent.tryParse({
        ...event('user_directory.changed', eventId: 'event-partial-revisions'),
        'entity': {'kind': 'user', 'id': 'USR-1'},
        'revisions': {'profile': 7},
      }),
      isNull,
    );
    expect(
      RealtimeEvent.tryParse({
        ...event('report.status_changed', eventId: 'event-report-revision'),
        'revisions': {'profile': 7},
      }),
      isNull,
    );
  });

  test('deduplicates repeated events across reconnect delivery', () {
    final router = RealtimeEventRouter();
    expect(router.consume(event('queue.changed')), isNotNull);
    expect(router.consume(event('queue.changed')), isNull);
    expect(
      router.consume(event('queue.changed', eventId: 'event-2')),
      isNotNull,
    );
  });

  test('routes invalidations to existing REST-backed caches', () {
    expect(
      invalidationTargets(RealtimeEvent.tryParse(event('queue.changed'))!),
      {RealtimeTarget.reports},
    );
    expect(
      invalidationTargets(
        RealtimeEvent.tryParse(event('notification.created'))!,
      ),
      {RealtimeTarget.notifications},
    );
    expect(
      invalidationTargets(RealtimeEvent.tryParse(event('integrity.changed'))!),
      {RealtimeTarget.reports, RealtimeTarget.integrity},
    );
    expect(
      invalidationTargets(
        RealtimeEvent.tryParse(event('user_directory.changed'))!,
      ),
      {RealtimeTarget.profile},
    );
  });

  test('uses one fresh socket and bounded reconnect attempts', () {
    final options = buildSocketOptions('access-token');
    expect(options['autoConnect'], isFalse);
    expect(options['forceNew'], isTrue);
    expect(options['multiplex'], isFalse);
    expect(options['reconnectionAttempts'], 8);
    expect(options['transports'], ['websocket']);
  });
}

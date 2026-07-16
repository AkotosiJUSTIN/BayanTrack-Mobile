const realtimeEventNames = <String>{
  'report.created',
  'queue.changed',
  'report.status_changed',
  'report.assignment_changed',
  'duplicate_suggestion.created',
  'duplicate_suggestion.reviewed',
  'linked_case.changed',
  'incident_group.changed',
  'notification.created',
  'integrity.changed',
};

enum RealtimeTarget { reports, notifications, integrity }

class RealtimeEvent {
  const RealtimeEvent({
    required this.version,
    required this.eventId,
    required this.name,
    required this.entityKind,
    required this.entityId,
    required this.occurredAt,
    required this.correlationId,
  });

  final int version;
  final String eventId;
  final String name;
  final String entityKind;
  final String entityId;
  final String occurredAt;
  final String correlationId;

  static RealtimeEvent? tryParse(dynamic raw) {
    if (raw is! Map) return null;
    try {
      final payload = Map<String, dynamic>.from(raw);
      final rawEntity = payload['entity'];
      if (rawEntity is! Map) return null;
      final entity = Map<String, dynamic>.from(rawEntity);
      final name = payload['name'];
      if (payload['version'] != 1 ||
          name is! String ||
          !realtimeEventNames.contains(name) ||
          payload['event_id'] is! String ||
          entity['kind'] is! String ||
          entity['id'] is! String ||
          payload['occurred_at'] is! String ||
          payload['correlation_id'] is! String) {
        return null;
      }
      return RealtimeEvent(
        version: 1,
        eventId: payload['event_id'] as String,
        name: name,
        entityKind: entity['kind'] as String,
        entityId: entity['id'] as String,
        occurredAt: payload['occurred_at'] as String,
        correlationId: payload['correlation_id'] as String,
      );
    } on Object {
      return null;
    }
  }
}

class SeenEventIds {
  SeenEventIds({this.limit = 256});

  final int limit;
  final Set<String> _ids = {};

  bool add(String eventId) {
    if (!_ids.add(eventId)) return false;
    if (_ids.length > limit) _ids.remove(_ids.first);
    return true;
  }
}

class RealtimeEventRouter {
  RealtimeEventRouter({SeenEventIds? seen}) : _seen = seen ?? SeenEventIds();

  final SeenEventIds _seen;

  RealtimeEvent? consume(dynamic raw) {
    final event = RealtimeEvent.tryParse(raw);
    return event != null && _seen.add(event.eventId) ? event : null;
  }
}

Set<RealtimeTarget> invalidationTargets(RealtimeEvent event) => {
  if (event.name != 'notification.created') RealtimeTarget.reports,
  if (event.name == 'notification.created') RealtimeTarget.notifications,
  if (event.name == 'integrity.changed') RealtimeTarget.integrity,
};

Map<String, dynamic> buildSocketOptions(String token) => {
  'transports': ['websocket'],
  'autoConnect': false,
  'forceNew': true,
  'multiplex': false,
  'reconnection': true,
  'reconnectionAttempts': 8,
  'reconnectionDelay': 1000,
  'reconnectionDelayMax': 10000,
  'timeout': 10000,
  'auth': {'token': token},
};

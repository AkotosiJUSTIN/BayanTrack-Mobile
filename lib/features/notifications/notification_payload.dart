import 'dart:convert';

String encodeNotificationPayload(Map<String, dynamic> data) => jsonEncode({
  for (final key in ['type', 'report_id', 'terms_version_id', 'event_id'])
    if (data[key] != null) key: data[key].toString(),
});

Map<String, dynamic> decodeNotificationPayload(String? payload) {
  if (payload == null || payload.trim().isEmpty) return {};
  if (!payload.trimLeft().startsWith('{')) {
    // Older local notifications stored only the report ID.
    return {'report_id': payload};
  }
  try {
    final decoded = jsonDecode(payload);
    return decoded is Map<String, dynamic> ? decoded : {};
  } on FormatException {
    return {};
  }
}

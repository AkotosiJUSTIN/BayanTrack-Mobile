import 'package:socket_io_client/socket_io_client.dart' as io;

import 'realtime_contract.dart';

class RealtimeService {
  final RealtimeEventRouter _router = RealtimeEventRouter();
  io.Socket? _socket;

  void connect({
    required String serverUrl,
    required String token,
    required void Function(RealtimeEvent event) onEvent,
  }) {
    _disconnectSocket();
    final socket = io.io(serverUrl, buildSocketOptions(token));
    _socket = socket;
    for (final eventName in realtimeEventNames) {
      socket.on(eventName, (raw) {
        final event = _router.consume(raw);
        if (event != null) onEvent(event);
      });
    }
    socket.connect();
  }

  void _disconnectSocket() {
    final socket = _socket;
    if (socket == null) return;
    for (final eventName in realtimeEventNames) {
      socket.off(eventName);
    }
    socket.disconnect();
    socket.dispose();
    _socket = null;
  }

  void dispose() => _disconnectSocket();
}

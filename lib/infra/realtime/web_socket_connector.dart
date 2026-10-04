import 'package:web_socket/web_socket.dart';
import 'idempotent_web_socket.dart';
import 'web_socket_connector_web.dart'
    if (dart.library.io) 'web_socket_connector_io.dart'
    as platform;

Future<WebSocket> connectRealtimeWebSocket(
  Uri uri, {
  Iterable<String>? protocols,
  Map<String, String>? headers,
}) async => IdempotentWebSocket(
  await platform.connect(uri, protocols: protocols, headers: headers),
);

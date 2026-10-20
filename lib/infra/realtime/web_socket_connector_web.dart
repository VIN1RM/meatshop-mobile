import 'package:web_socket/web_socket.dart';

Future<WebSocket> connect(
  Uri uri, {
  Iterable<String>? protocols,
  Map<String, String>? headers,
}) => WebSocket.connect(uri, protocols: protocols);

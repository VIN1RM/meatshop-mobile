import 'dart:io' as io;
import 'package:web_socket/io_web_socket.dart';
import 'package:web_socket/web_socket.dart';

Future<WebSocket> connect(
  Uri uri, {
  Iterable<String>? protocols,
  Map<String, String>? headers,
}) async => IOWebSocket.fromWebSocket(
  await io.WebSocket.connect(
    uri.toString(),
    protocols: protocols,
    headers: headers,
  ),
);

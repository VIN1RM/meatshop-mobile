import 'dart:typed_data';
import 'package:web_socket/web_socket.dart';

/// Socket.IO may close a transport after the peer has already closed it.
/// Preserve all other failures; only an already-closed connection is harmless.
final class IdempotentWebSocket implements WebSocket {
  IdempotentWebSocket(this._socket);
  final WebSocket _socket;
  Future<void>? _closing;

  @override
  Future<void> close([int? code, String? reason]) =>
      _closing ??= _close(code, reason);

  Future<void> _close(int? code, String? reason) async {
    try {
      await _socket.close(code, reason);
    } on WebSocketConnectionClosed {
      // The desired closed state has already been reached.
    }
  }

  @override
  Stream<WebSocketEvent> get events => _socket.events;
  @override
  String get protocol => _socket.protocol;
  @override
  void sendText(String text) => _socket.sendText(text);
  @override
  void sendBytes(Uint8List bytes) => _socket.sendBytes(bytes);
}

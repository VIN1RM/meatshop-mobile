import 'dart:async';
import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:web_socket/web_socket.dart';
import 'package:meatshop_mobile/infra/realtime/idempotent_web_socket.dart';

void main() {
  test('closing after remote closure is harmless', () async {
    final raw = _Socket()..error = WebSocketConnectionClosed();
    final socket = IdempotentWebSocket(raw);
    await socket.close();
    await socket.close();
    expect(raw.closeCalls, 1);
  });
  test('simultaneous closes share one operation', () async {
    final raw = _Socket()..pending = Completer<void>();
    final socket = IdempotentWebSocket(raw);
    final first = socket.close(1000, 'done');
    final second = socket.close();
    expect(identical(first, second), isTrue);
    expect(raw.closeCalls, 1);
    raw.pending!.complete();
    await Future.wait([first, second]);
    expect(raw.closeCode, 1000);
  });
  test('unrelated connection errors remain visible', () async {
    final raw = _Socket()..error = StateError('unexpected failure');
    await expectLater(IdempotentWebSocket(raw).close(), throwsStateError);
  });
  test('messages and events are preserved', () {
    final raw = _Socket();
    final socket = IdempotentWebSocket(raw);
    socket.sendText('ping');
    final bytes = Uint8List.fromList([1, 2]);
    socket.sendBytes(bytes);
    expect(raw.text, 'ping');
    expect(raw.bytes, bytes);
    expect(socket.events, raw.events);
    expect(socket.protocol, 'test');
  });
}

class _Socket implements WebSocket {
  int closeCalls = 0;
  int? closeCode;
  Object? error;
  Completer<void>? pending;
  String? text;
  Uint8List? bytes;
  @override
  Future<void> close([int? code, String? reason]) async {
    closeCalls++;
    closeCode = code;
    if (error != null) throw error!;
    if (pending != null) await pending!.future;
  }

  @override
  Stream<WebSocketEvent> get events => const Stream.empty();
  @override
  String get protocol => 'test';
  @override
  void sendText(String value) => text = value;
  @override
  void sendBytes(Uint8List value) => bytes = value;
}

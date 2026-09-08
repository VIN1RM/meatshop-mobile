import 'dart:async';

import 'package:socket_io_client/socket_io_client.dart' as io;

import '../../core/auth/session_coordinator.dart';
import '../../core/config/api_config.dart';
import '../../core/enums/chat_enums.dart';
import '../../data/repositories/realtime_repository.dart';

final class BackendRealtimeClient implements RealtimeRepository {
  BackendRealtimeClient({
    required ApiConfig config,
    required SessionCoordinator session,
  }) : _origin = config.baseUrl.origin,
       _session = session;

  final String _origin;
  final SessionCoordinator _session;
  io.Socket? _chatSocket;
  io.Socket? _deliverySocket;
  bool _refreshing = false;
  int? _chatOrderId;
  ChatChannel? _chatChannel;
  final Set<int> _deliveryOrderIds = {};

  final _chatMessages = StreamController<Map<String, Object?>>.broadcast();
  final _chatReads = StreamController<Map<String, Object?>>.broadcast();
  final _chatTyping = StreamController<Map<String, Object?>>.broadcast();
  final _deliveryLocations = StreamController<Map<String, Object?>>.broadcast();
  final _deliveryStatuses = StreamController<Map<String, Object?>>.broadcast();
  final _connection = StreamController<RealtimeConnectionState>.broadcast();

  @override
  Stream<Map<String, Object?>> get chatMessages => _chatMessages.stream;
  @override
  Stream<Map<String, Object?>> get chatReads => _chatReads.stream;
  @override
  Stream<Map<String, Object?>> get chatTyping => _chatTyping.stream;
  @override
  Stream<Map<String, Object?>> get deliveryLocations =>
      _deliveryLocations.stream;
  Stream<Map<String, Object?>> get deliveryStatuses => _deliveryStatuses.stream;
  @override
  Stream<Map<String, Object?>> get statuses => deliveryStatuses;
  @override
  Stream<RealtimeConnectionState> get connection => _connection.stream;

  @override
  Future<void> connect() async {
    await _session.initialize();
    if (_session.current == null) return;
    _connection.add(RealtimeConnectionState.connecting);
    _chatSocket ??= _build('/chat', _configureChat);
    _deliverySocket ??= _build('/delivery', _configureDelivery);
    if (!_chatSocket!.connected) _chatSocket!.connect();
    if (!_deliverySocket!.connected) _deliverySocket!.connect();
  }

  io.Socket _build(String namespace, void Function(io.Socket) configure) {
    final socket = io.io(
      '$_origin$namespace',
      io.OptionBuilder()
          .setTransports(['websocket'])
          .disableAutoConnect()
          .enableReconnection()
          .setReconnectionAttempts(20)
          .setReconnectionDelay(1000)
          .setTimeout(10000)
          .setAuth({'token': _session.current!.accessToken})
          .build(),
    );
    configure(socket);
    socket.onConnect((_) {
      _connection.add(RealtimeConnectionState.connected);
      _restoreSubscriptions(socket);
    });
    socket.onDisconnect((reason) {
      _connection.add(RealtimeConnectionState.disconnected);
      if (reason == 'io server disconnect') {
        _recoverSession(socket, 'unauthorized server disconnect');
      }
    });
    socket.onConnectError((error) => _recoverSession(socket, error));
    return socket;
  }

  void _configureChat(io.Socket socket) {
    socket.on('chat:error', (error) {
      if (isRealtimeAuthenticationFailure(error)) {
        _recoverSession(socket, error);
      }
    });
    socket.on('chat:message', (data) => _addMap(_chatMessages, data));
    socket.on('chat:read', (data) => _addMap(_chatReads, data));
    socket.on('chat:typing', (data) => _addMap(_chatTyping, data));
  }

  void _configureDelivery(io.Socket socket) {
    socket.on(
      'delivery:location.updated',
      (data) => _addMap(_deliveryLocations, data),
    );
    socket.on(
      'delivery:status.updated',
      (data) => _addMap(_deliveryStatuses, data),
    );
  }

  Future<void> _recoverSession(io.Socket socket, Object? error) async {
    final authenticationFailure = isRealtimeAuthenticationFailure(error);
    if (!authenticationFailure || _refreshing || _session.current == null) {
      return;
    }
    _refreshing = true;
    try {
      final tokens = await _session.refresh();
      _chatSocket?.auth = {'token': tokens.accessToken};
      _deliverySocket?.auth = {'token': tokens.accessToken};
      if (!(_chatSocket?.connected ?? false)) _chatSocket?.connect();
      if (!(_deliverySocket?.connected ?? false)) _deliverySocket?.connect();
    } catch (_) {
      // SessionCoordinator classifies and clears only definitive auth failures.
    } finally {
      _refreshing = false;
    }
  }

  void _restoreSubscriptions(io.Socket socket) {
    if (identical(socket, _chatSocket) &&
        _chatOrderId != null &&
        _chatChannel != null) {
      socket.emit('chat:join', {
        'order_id': _chatOrderId,
        'participant_type': _chatChannel!.apiValue,
      });
    }
    if (identical(socket, _deliverySocket)) {
      for (final orderId in _deliveryOrderIds) {
        socket.emit('delivery:subscribe-order', {'orderId': orderId});
      }
    }
  }

  @override
  Future<void> joinChat(int orderId, ChatChannel channel) async {
    _chatOrderId = orderId;
    _chatChannel = channel;
    await connect();
    _chatSocket?.emit('chat:join', {
      'order_id': orderId,
      'participant_type': channel.apiValue,
    });
  }

  @override
  void leaveChat(int orderId, ChatChannel channel) {
    _chatSocket?.emit('chat:leave', {
      'order_id': orderId,
      'participant_type': channel.apiValue,
    });
    if (_chatOrderId == orderId && _chatChannel == channel) {
      _chatOrderId = null;
      _chatChannel = null;
    }
  }

  @override
  void sendTyping(int orderId, ChatChannel channel, bool typing) {
    _chatSocket?.emit('chat:typing', {
      'order_id': orderId,
      'participant_type': channel.apiValue,
      'typing': typing,
    });
  }

  @override
  Future<void> subscribeDelivery(int orderId) async {
    _deliveryOrderIds.add(orderId);
    await connect();
    _deliverySocket?.emit('delivery:subscribe-order', {'orderId': orderId});
  }

  @override
  void unsubscribeDelivery(int orderId) {
    _deliveryOrderIds.remove(orderId);
    _deliverySocket?.emit('delivery:unsubscribe-order', {'orderId': orderId});
  }

  void _addMap(
    StreamController<Map<String, Object?>> controller,
    Object? value,
  ) {
    if (value is Map<Object?, Object?>) {
      controller.add(value.map((key, item) => MapEntry(key.toString(), item)));
    }
  }

  void dispose() {
    _chatSocket?.dispose();
    _deliverySocket?.dispose();
    _chatMessages.close();
    _chatReads.close();
    _chatTyping.close();
    _deliveryLocations.close();
    _deliveryStatuses.close();
    _connection.close();
  }
}

bool isRealtimeAuthenticationFailure(Object? error) {
  final message = error.toString().toLowerCase();
  return message.contains('unauthorized') ||
      message.contains('jwt') ||
      message.contains('token') ||
      message.contains('authentication');
}

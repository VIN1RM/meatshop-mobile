import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/enums/chat_enums.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/realtime_repository.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatListProvider extends ChangeNotifier {
  ChatListProvider({
    ChatService? service,
    ChatRepository? repository,
    RealtimeRepository? realtime,
    required this.currentUserId,
    required this.activeType,
    this.backendUserId,
  }) : _service = service,
       _repository = repository,
       _realtime = realtime {
    _init();
  }

  final ChatService? _service;
  final ChatRepository? _repository;
  final RealtimeRepository? _realtime;
  final String currentUserId;
  final int? backendUserId;
  final ChatParticipantType activeType;
  List<ChatConversation> _conversations = [];
  bool _loading = true;
  String? _error;
  StreamSubscription<List<ChatConversation>>? _legacySubscription;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  List<ChatConversation> get conversations => _conversations;
  bool get loading => _loading;
  String? get error => _error;

  void _init() {
    if (_repository != null && _realtime != null && backendUserId != null) {
      _loadBackend();
      _realtime.connect();
      _subscriptions.add(
        _realtime.chatMessages.listen((_) => _loadBackend(silent: true)),
      );
      _subscriptions.add(
        _realtime.connection.listen((state) {
          if (state == RealtimeConnectionState.connected) {
            _loadBackend(silent: true);
          }
        }),
      );
      return;
    }
    final service = _service;
    if (service == null) {
      _loading = false;
      _error = 'Chat indisponível.';
      notifyListeners();
      return;
    }
    _legacySubscription = service
        .conversationsStream(currentUserId, activeType)
        .listen(
          (list) {
            _conversations = list;
            _loading = false;
            notifyListeners();
          },
          onError: (_) {
            _error = 'Não foi possível carregar as conversas.';
            _loading = false;
            notifyListeners();
          },
        );
  }

  Future<void> _loadBackend({bool silent = false}) async {
    if (!silent) {
      _loading = true;
      notifyListeners();
    }
    try {
      _conversations = await _repository!.conversations(
        currentUserId: backendUserId!,
        currentUserType: activeType,
      );
      _error = null;
    } catch (_) {
      _error = 'Não foi possível carregar as conversas.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _legacySubscription?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    ChatService? service,
    ChatRepository? repository,
    RealtimeRepository? realtime,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverType,
    this.backendUserId,
    this.orderId,
    this.channel,
    this.closed = false,
    this.currentUserPhoto,
    this.receiverPhoto,
  }) : _service = service,
       _repository = repository,
       _realtime = realtime {
    _init();
  }

  final ChatService? _service;
  final ChatRepository? _repository;
  final RealtimeRepository? _realtime;
  final String currentUserId;
  final int? backendUserId;
  final String currentUserName;
  final ChatParticipantType currentUserType;
  final String conversationId;
  final int? orderId;
  final ChatChannel? channel;
  final bool closed;
  final String receiverId;
  final String receiverName;
  final ChatParticipantType receiverType;
  final String? currentUserPhoto;
  final String? receiverPhoto;

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  bool _otherTyping = false;
  String? _error;
  Timer? _typingTimer;
  bool _typingSent = false;
  StreamSubscription<List<ChatMessage>>? _legacySubscription;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;
  bool get sending => _sending;
  bool get otherTyping => _otherTyping;
  String? get error => _error;
  bool get backendEnabled =>
      _repository != null &&
      _realtime != null &&
      backendUserId != null &&
      orderId != null &&
      channel != null;

  Future<void> _init() async {
    if (backendEnabled) {
      final realtime = _realtime!;
      _subscriptions.add(realtime.chatMessages.listen(_onRealtimeMessage));
      _subscriptions.add(realtime.chatReads.listen(_onRead));
      _subscriptions.add(realtime.chatTyping.listen(_onTyping));
      _subscriptions.add(
        realtime.connection.listen((state) {
          if (state == RealtimeConnectionState.connected) _reconcile();
        }),
      );
      await realtime.joinChat(orderId!, channel!);
      await _reconcile();
      return;
    }

    final service = _service;
    if (service == null) {
      _loading = false;
      _error = 'Chat indisponível.';
      notifyListeners();
      return;
    }
    await service.getOrCreateConversation(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      currentUserType: currentUserType,
      otherUserId: receiverId,
      otherUserName: receiverName,
      otherUserType: receiverType,
      currentUserPhoto: currentUserPhoto,
      otherUserPhoto: receiverPhoto,
    );
    service.markConversationAsRead(
      conversationId: conversationId,
      userId: currentUserId,
    );
    _legacySubscription = service.messagesStream(conversationId).listen((
      messages,
    ) {
      _messages = messages;
      _loading = false;
      notifyListeners();
      service.markConversationAsRead(
        conversationId: conversationId,
        userId: currentUserId,
      );
    });
  }

  Future<void> _reconcile() async {
    try {
      final values = await _repository!.history(
        orderId!,
        channel!,
        currentUserId: backendUserId!,
      );
      _merge(values);
      await _repository.markRead(orderId!, channel!);
      _error = null;
    } catch (_) {
      _error = 'Não foi possível sincronizar esta conversa.';
    } finally {
      _loading = false;
      notifyListeners();
    }
  }

  void _onRealtimeMessage(Map<String, Object?> data) {
    if (!_sameConversation(data)) return;
    final message = ChatMessage.fromApi(data, currentUserId: backendUserId);
    _merge([message]);
    if (!message.mine) _repository!.markRead(orderId!, channel!);
    notifyListeners();
  }

  void _onRead(Map<String, Object?> data) {
    if (!_sameConversation(data)) return;
    _messages = _messages
        .map(
          (message) => message.mine
              ? ChatMessage(
                  id: message.id,
                  senderId: message.senderId,
                  text: message.text,
                  sentAt: message.sentAt,
                  read: true,
                  mine: true,
                  orderId: message.orderId,
                  channel: message.channel,
                )
              : message,
        )
        .toList(growable: false);
    notifyListeners();
  }

  void _onTyping(Map<String, Object?> data) {
    if (!_sameConversation(data)) return;
    final userId = (data['user_id'] as num?)?.toInt();
    if (userId == backendUserId) return;
    _otherTyping = data['typing'] == true;
    notifyListeners();
  }

  bool _sameConversation(Map<String, Object?> data) =>
      (data['order_id'] as num?)?.toInt() == orderId &&
      data['participant_type'] == channel?.apiValue;

  void _merge(Iterable<ChatMessage> incoming) {
    final byId = {for (final message in _messages) message.id: message};
    for (final message in incoming) {
      byId[message.id] = message;
    }
    _messages = byId.values.toList()
      ..sort((left, right) => left.sentAt.compareTo(right.sentAt));
  }

  Future<void> sendMessage(String text) async {
    final normalized = text.trim();
    if (normalized.isEmpty || _sending || closed) return;
    _sending = true;
    _error = null;
    notifyListeners();
    try {
      if (backendEnabled) {
        final message = await _repository!.send(orderId!, channel!, normalized);
        _merge([message]);
      } else {
        await _service!.sendMessage(
          conversationId: conversationId,
          senderId: currentUserId,
          receiverId: receiverId,
          text: normalized,
        );
      }
    } catch (_) {
      _error = 'Não foi possível enviar a mensagem.';
      rethrow;
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  void setTyping(bool typing) {
    if (!backendEnabled || closed) return;
    _typingTimer?.cancel();
    if (!typing) {
      if (_typingSent) {
        _typingSent = false;
        _realtime!.sendTyping(orderId!, channel!, false);
      }
      return;
    }
    if (typing && !_typingSent) {
      _typingSent = true;
      _realtime!.sendTyping(orderId!, channel!, true);
    }
    _typingTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_typingSent) return;
      _typingSent = false;
      _realtime!.sendTyping(orderId!, channel!, false);
    });
  }

  bool isMyMessage(ChatMessage message) =>
      message.mine || message.senderId == currentUserId;

  @override
  void dispose() {
    _legacySubscription?.cancel();
    _typingTimer?.cancel();
    if (backendEnabled && _typingSent) {
      _realtime!.sendTyping(orderId!, channel!, false);
    }
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    if (backendEnabled) _realtime!.leaveChat(orderId!, channel!);
    super.dispose();
  }
}

class ChatUnreadProvider extends ChangeNotifier {
  ChatUnreadProvider({
    ChatService? service,
    ChatRepository? repository,
    RealtimeRepository? realtime,
    required this.currentUserId,
  }) : _service = service,
       _repository = repository,
       _realtime = realtime {
    _init();
  }

  final ChatService? _service;
  final ChatRepository? _repository;
  final RealtimeRepository? _realtime;
  final String currentUserId;
  int _total = 0;
  StreamSubscription<int>? _legacySubscription;
  StreamSubscription<Map<String, Object?>>? _messageSubscription;

  int get total => _total;
  bool get hasUnread => _total > 0;

  void _init() {
    if (_repository != null && _realtime != null) {
      _refresh();
      _realtime.connect();
      _messageSubscription = _realtime.chatMessages.listen((_) => _refresh());
      return;
    }
    _legacySubscription = _service?.totalUnreadStream(currentUserId).listen((
      count,
    ) {
      _total = count;
      notifyListeners();
    });
  }

  Future<void> _refresh() async {
    _total = await _repository!.unreadCount();
    notifyListeners();
  }

  @override
  void dispose() {
    _legacySubscription?.cancel();
    _messageSubscription?.cancel();
    super.dispose();
  }
}

import 'dart:async';

import 'package:flutter/foundation.dart';

import '../core/enums/chat_enums.dart';
import '../data/repositories/chat_repository.dart';
import '../data/repositories/realtime_repository.dart';
import '../models/chat_model.dart';

class ChatListProvider extends ChangeNotifier {
  ChatListProvider({
    required ChatRepository repository,
    required RealtimeRepository realtime,
    required this.currentUserId,
    required this.activeType,
    this.backendUserId,
  }) : _repository = repository,
       _realtime = realtime {
    _init();
  }

  static const pageSize = 50;
  final ChatRepository _repository;
  final RealtimeRepository _realtime;
  final String currentUserId;
  final int? backendUserId;
  final ChatParticipantType activeType;
  List<ChatConversation> _conversations = [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _fetching = false;
  bool _hasMore = false;
  bool _moreFailed = false;
  int _pages = 1;
  String? _error;
  final List<StreamSubscription<Object?>> _subscriptions = [];
  Timer? _inboxTimer;
  bool _inboxDisposed = false;

  List<ChatConversation> get conversations => List.unmodifiable(_conversations);
  bool get loading => _loading;
  bool get loadingMore => _loadingMore;
  bool get hasMore => _hasMore;
  String? get error => _error;

  void _init() {
    if (backendUserId == null) {
      _loading = false;
      _error = 'Sessão backend indisponível.';
      return;
    }
    _inboxTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => _loadBackend(silent: true),
    );
    _loadBackend();
    _connect();
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
  }

  Future<void> _connect() async {
    try {
      await _realtime.connect();
    } catch (_) {}
  }

  Future<void> refresh() => _loadBackend();
  Future<void> retry() => _moreFailed ? loadMore() : refresh();
  Future<void> loadMore() => _loadBackend(more: true, silent: true);

  Future<void> _loadBackend({bool silent = false, bool more = false}) async {
    if (_inboxDisposed ||
        _fetching ||
        backendUserId == null ||
        (more && !_hasMore)) {
      return;
    }
    _fetching = true;
    _loadingMore = more;
    if (!silent) _loading = _conversations.isEmpty;
    _error = null;
    notifyListeners();
    try {
      final values = <ChatConversation>[];
      var lastPage = more ? _pages + 1 : 1;
      var hasMore = false;
      for (
        var page = more ? _pages + 1 : 1;
        page <= (more ? _pages + 1 : _pages);
        page++
      ) {
        final rows = await _repository.conversations(
          currentUserId: backendUserId!,
          currentUserType: activeType,
          page: page,
          limit: pageSize,
        );
        if (_inboxDisposed) return;
        values.addAll(rows);
        lastPage = page;
        hasMore = rows.length == pageSize;
        if (!hasMore) break;
      }
      final byId = {
        if (more)
          for (final item in _conversations) item.id: item,
        for (final item in values) item.id: item,
      };
      _conversations = byId.values.toList()
        ..sort(
          (a, b) => (b.lastMessageAt ?? b.createdAt).compareTo(
            a.lastMessageAt ?? a.createdAt,
          ),
        );
      _pages = lastPage;
      _hasMore = hasMore;
      _moreFailed = false;
      _error = null;
    } catch (_) {
      if (!_inboxDisposed) {
        _moreFailed = more;
        _error = 'Não foi possível carregar as conversas.';
      }
    } finally {
      _fetching = false;
      if (!_inboxDisposed) {
        _loading = false;
        _loadingMore = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _inboxDisposed = true;
    _inboxTimer?.cancel();
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }
}

class ChatProvider extends ChangeNotifier {
  ChatProvider({
    required ChatRepository repository,
    required RealtimeRepository realtime,
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
  }) : _repository = repository,
       _realtime = realtime {
    _init();
  }

  final ChatRepository _repository;
  final RealtimeRepository _realtime;
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
  bool _disposed = false;
  bool _refreshing = false;
  bool _loadingOlder = false;
  bool _hasOlder = false;
  bool _olderFailed = false;
  bool get olderFailed => _olderFailed;
  int _historyPages = 1;
  static const historyPageSize = 100;

  bool get loadingOlder => _loadingOlder;
  bool get hasOlder => _hasOlder;
  final List<StreamSubscription<Object?>> _subscriptions = [];

  List<ChatMessage> get messages => List.unmodifiable(_messages);
  bool get loading => _loading;
  bool get sending => _sending;
  bool get otherTyping => _otherTyping;
  String? get error => _error;
  bool get backendEnabled =>
      backendUserId != null && orderId != null && channel != null;

  Future<void> _init() async {
    if (backendEnabled) {
      final realtime = _realtime;
      _subscriptions.add(realtime.chatMessages.listen(_onRealtimeMessage));
      _subscriptions.add(realtime.chatReads.listen(_onRead));
      _subscriptions.add(realtime.chatTyping.listen(_onTyping));
      _subscriptions.add(
        realtime.connection.listen((state) {
          if (state == RealtimeConnectionState.connected) _reconcile();
        }),
      );
      try {
        await realtime.joinChat(orderId!, channel!);
        if (_disposed) return;
      } catch (_) {
        if (_disposed) return;
      }
      await _reconcile();
      return;
    }

    _loading = false;
    _error = 'Sessão backend indisponível.';
    notifyListeners();
  }

  Future<void> retry() => _reconcile();

  Future<void> _markRead() async {
    if (_disposed || closed) return;
    try {
      await _repository.markRead(orderId!, channel!);
    } catch (_) {}
  }

  Future<void> _reconcile() async {
    if (_disposed || _refreshing || _loadingOlder || !backendEnabled) return;
    _refreshing = true;
    try {
      for (var page = 1; page <= _historyPages; page++) {
        final values = await _repository.history(
          orderId!,
          channel!,
          currentUserId: backendUserId!,
          page: page,
          limit: historyPageSize,
        );
        if (_disposed) return;
        _merge(values);
        _hasOlder = values.length == historyPageSize;
        if (!_hasOlder) {
          _historyPages = page;
          break;
        }
      }
      await _markRead();
      if (!_disposed) {
        _error = null;
        _olderFailed = false;
      }
    } catch (_) {
      if (!_disposed) {
        _olderFailed = false;
        _error = 'Não foi possível sincronizar esta conversa.';
      }
    } finally {
      _refreshing = false;
      if (!_disposed) {
        _loading = false;
        notifyListeners();
      }
    }
  }

  Future<void> loadOlder() async {
    if (_disposed || _refreshing || _loadingOlder || !_hasOlder) return;
    _loadingOlder = true;
    _error = null;
    notifyListeners();
    try {
      final values = await _repository.history(
        orderId!,
        channel!,
        currentUserId: backendUserId!,
        page: _historyPages + 1,
        limit: historyPageSize,
      );
      if (_disposed) return;
      _merge(values);
      ++_historyPages;
      _hasOlder = values.length == historyPageSize;
      _olderFailed = false;
    } catch (_) {
      if (!_disposed) {
        _olderFailed = true;
        _error = 'Não foi possível carregar mensagens anteriores.';
      }
    } finally {
      if (!_disposed) {
        _loadingOlder = false;
        notifyListeners();
      }
    }
  }

  void _onRealtimeMessage(Map<String, Object?> data) {
    if (_disposed || !_sameConversation(data)) return;
    final message = ChatMessage.fromApi(data, currentUserId: backendUserId);
    _merge([message]);
    if (!message.mine) unawaited(_markRead());
    notifyListeners();
  }

  void _onRead(Map<String, Object?> data) {
    if (_disposed || !_sameConversation(data)) return;
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
    if (_disposed || !_sameConversation(data)) return;
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
    if (_disposed || normalized.isEmpty || _sending || closed) return;
    _sending = true;
    _error = null;
    notifyListeners();
    try {
      if (backendEnabled) {
        final message = await _repository.send(orderId!, channel!, normalized);
        if (_disposed) return;
        _merge([message]);
      } else {
        throw StateError('Sessão backend indisponível.');
      }
    } catch (_) {
      if (!_disposed) _error = 'Não foi possível enviar a mensagem.';
      rethrow;
    } finally {
      if (!_disposed) {
        _sending = false;
        notifyListeners();
      }
    }
  }

  void setTyping(bool typing) {
    if (_disposed || !backendEnabled || closed) return;
    _typingTimer?.cancel();
    if (!typing) {
      if (_typingSent) {
        _typingSent = false;
        _realtime.sendTyping(orderId!, channel!, false);
      }
      return;
    }
    if (typing && !_typingSent) {
      _typingSent = true;
      _realtime.sendTyping(orderId!, channel!, true);
    }
    _typingTimer = Timer(const Duration(milliseconds: 800), () {
      if (!_typingSent) return;
      _typingSent = false;
      _realtime.sendTyping(orderId!, channel!, false);
    });
  }

  bool isMyMessage(ChatMessage message) =>
      message.mine || message.senderId == currentUserId;

  @override
  void dispose() {
    _disposed = true;
    _typingTimer?.cancel();
    if (backendEnabled && _typingSent) {
      _realtime.sendTyping(orderId!, channel!, false);
    }
    for (final subscription in _subscriptions) {
      subscription.cancel();
    }
    if (backendEnabled) _realtime.leaveChat(orderId!, channel!);
    super.dispose();
  }
}

class ChatUnreadProvider extends ChangeNotifier {
  ChatUnreadProvider({
    required ChatRepository repository,
    required RealtimeRepository realtime,
    required this.currentUserId,
  }) : _repository = repository,
       _realtime = realtime {
    _init();
  }

  final ChatRepository _repository;
  final RealtimeRepository _realtime;
  final String currentUserId;
  int _total = 0;
  bool _disposed = false;
  bool _refreshing = false;
  StreamSubscription<Map<String, Object?>>? _messageSubscription;

  int get total => _total;
  bool get hasUnread => _total > 0;

  void _init() {
    _refresh();
    _connect();
    _messageSubscription = _realtime.chatMessages.listen((_) => _refresh());
  }

  Future<void> _connect() async {
    try {
      await _realtime.connect();
    } catch (_) {}
  }

  Future<void> _refresh() async {
    if (_disposed || _refreshing) return;
    _refreshing = true;
    try {
      final total = await _repository.unreadCount();
      if (_disposed) return;
      _total = total;
      notifyListeners();
    } catch (_) {
    } finally {
      _refreshing = false;
    }
  }

  @override
  void dispose() {
    _disposed = true;
    _messageSubscription?.cancel();
    super.dispose();
  }
}

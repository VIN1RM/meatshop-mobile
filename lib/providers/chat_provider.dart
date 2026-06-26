import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/services/chat_service.dart';

class ChatListProvider extends ChangeNotifier {
  final ChatService _service;
  final String currentUserId;
  final ChatParticipantType activeType;

  ChatListProvider({
    required ChatService service,
    required this.currentUserId,
    required this.activeType,
  }) : _service = service {
    _init();
  }
  List<ChatConversation> _conversations = [];
  bool _loading = true;
  StreamSubscription<List<ChatConversation>>? _sub;

  List<ChatConversation> get conversations => _conversations;
  bool get loading => _loading;

  void _init() {
    _sub = _service
        .conversationsStream(currentUserId, activeType)
        .listen(
          (list) {
            print('[ChatList] recebeu ${list.length} conversas');
            _conversations = list;
            _loading = false;
            notifyListeners();
          },
          onError: (e) {
            print('[ChatList] ERRO: $e');
            _loading = false;
            notifyListeners();
          },
        );
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class ChatProvider extends ChangeNotifier {
  final ChatService _service;
  final String currentUserId;
  final String currentUserName;
  final ChatParticipantType currentUserType;
  final String conversationId;
  final String receiverId;
  final String receiverName;
  final ChatParticipantType receiverType;
  final String? currentUserPhoto;
  final String? receiverPhoto;

  ChatProvider({
    required ChatService service,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
    required this.conversationId,
    required this.receiverId,
    required this.receiverName,
    required this.receiverType,
    this.currentUserPhoto,
    this.receiverPhoto,
  }) : _service = service {
    _init();
  }

  List<ChatMessage> _messages = [];
  bool _loading = true;
  bool _sending = false;
  StreamSubscription<List<ChatMessage>>? _sub;

  List<ChatMessage> get messages => _messages;
  bool get loading => _loading;
  bool get sending => _sending;

  void _init() async {
    await _service.getOrCreateConversation(
      currentUserId: currentUserId,
      currentUserName: currentUserName,
      currentUserType: currentUserType,
      otherUserId: receiverId,
      otherUserName: receiverName,
      otherUserType: receiverType,
      currentUserPhoto: currentUserPhoto,
      otherUserPhoto: receiverPhoto,
    );

    _service.markConversationAsRead(
      conversationId: conversationId,
      userId: currentUserId,
    );

    _sub = _service.messagesStream(conversationId).listen((msgs) {
      _messages = msgs;
      _loading = false;
      notifyListeners();

      _service.markConversationAsRead(
        conversationId: conversationId,
        userId: currentUserId,
      );
    });
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty || _sending) return;
    _sending = true;
    notifyListeners();

    try {
      await _service.sendMessage(
        conversationId: conversationId,
        senderId: currentUserId,
        receiverId: receiverId,
        text: text,
      );
    } finally {
      _sending = false;
      notifyListeners();
    }
  }

  bool isMyMessage(ChatMessage msg) => msg.senderId == currentUserId;

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

class ChatUnreadProvider extends ChangeNotifier {
  final ChatService _service;
  final String currentUserId;

  ChatUnreadProvider({
    required ChatService service,
    required this.currentUserId,
  }) : _service = service {
    _init();
  }

  int _total = 0;
  StreamSubscription<int>? _sub;

  int get total => _total;
  bool get hasUnread => _total > 0;

  void _init() {
    _sub = _service.totalUnreadStream(currentUserId).listen((count) {
      _total = count;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';

class ChatParticipant {
  final String userId;
  final String name;
  final String? photoUrl;
  final ChatParticipantType type;

  const ChatParticipant({
    required this.userId,
    required this.name,
    this.photoUrl,
    required this.type,
  });

  factory ChatParticipant.fromMap(String userId, Map<String, dynamic> map) {
    return ChatParticipant(
      userId: userId,
      name: map['name'] as String? ?? '',
      photoUrl: map['photo_url'] as String?,
      type: ChatParticipantType.values.firstWhere(
        (e) => e.name.toUpperCase() == (map['type'] as String? ?? 'CLIENT'),
        orElse: () => ChatParticipantType.client,
      ),
    );
  }

  Map<String, dynamic> toMap() => {
    'name': name,
    'photo_url': photoUrl,
    'type': type.name.toUpperCase(),
  };
}

class ChatConversation {
  final String id;
  final int? orderId;
  final ChatChannel? channel;
  final bool closed;

  final List<String> participantIds;
  final Map<String, ChatParticipant> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;

  final DateTime createdAt;

  const ChatConversation({
    required this.id,
    this.orderId,
    this.channel,
    this.closed = false,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.createdAt,
  });

  factory ChatConversation.fromApi(
    Map<String, Object?> data, {
    required int currentUserId,
    required ChatParticipantType currentUserType,
  }) {
    final participant = data['participant'];
    if (participant is! Map<String, Object?>) {
      throw const FormatException('Participante do chat inválido');
    }
    final participantId = (participant['id'] as num).toInt();
    final channel = ChatChannel.fromApi(data['participant_type'] as String);
    final participantType = switch (channel) {
      ChatChannel.unit =>
        currentUserType == ChatParticipantType.client
            ? ChatParticipantType.unit
            : ChatParticipantType.client,
      ChatChannel.deliveryPerson =>
        currentUserType == ChatParticipantType.client
            ? ChatParticipantType.delivery
            : ChatParticipantType.client,
      ChatChannel.unitDeliveryPerson =>
        currentUserType == ChatParticipantType.delivery
            ? ChatParticipantType.unit
            : ChatParticipantType.delivery,
    };
    final other = ChatParticipant(
      userId: '$participantId',
      name: participant['name'] as String? ?? '',
      photoUrl: participant['avatar_url'] as String?,
      type: participantType,
    );
    final lastMessageAt = DateTime.parse(data['last_message_at'] as String);
    return ChatConversation(
      id: data['id'] as String,
      orderId: (data['order_id'] as num).toInt(),
      channel: channel,
      closed: data['closed'] as bool? ?? false,
      participantIds: ['$currentUserId', '$participantId'],
      participants: {'$participantId': other},
      lastMessage: data['last_message'] as String?,
      lastMessageAt: lastMessageAt,
      unreadCount: {
        '$currentUserId': (data['unread_count'] as num?)?.toInt() ?? 0,
      },
      createdAt: lastMessageAt,
    );
  }

  factory ChatConversation.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    final rawParticipants =
        (data['participants'] as Map<String, dynamic>?) ?? {};
    final participants = rawParticipants.map(
      (userId, pMap) => MapEntry(
        userId,
        ChatParticipant.fromMap(userId, pMap as Map<String, dynamic>),
      ),
    );

    final rawUnread = (data['unread_count'] as Map<String, dynamic>?) ?? {};
    final unreadCount = rawUnread.map(
      (k, v) => MapEntry(k, (v as num).toInt()),
    );

    return ChatConversation(
      id: doc.id,
      participantIds: List<String>.from(data['participant_ids'] ?? []),
      participants: participants,
      lastMessage: data['last_message'] as String?,
      lastMessageAt: (data['last_message_at'] as Timestamp?)?.toDate(),
      lastMessageSenderId: data['last_message_sender_id'] as String?,
      unreadCount: unreadCount,
      createdAt: (data['created_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  ChatParticipant? otherParticipant(String currentUserId) {
    String otherId = participantIds.firstWhere(
      (id) => id != currentUserId,
      orElse: () => '',
    );

    if (otherId.isEmpty) {
      final parts = id.split('_');
      otherId = parts.firstWhere((p) => p != currentUserId, orElse: () => '');
    }

    return participants[otherId] ??
        (otherId.isNotEmpty
            ? ChatParticipant(
                userId: otherId,
                name: _inferName(otherId),
                type: _inferType(otherId),
              )
            : null);
  }

  int unreadFor(String userId) => unreadCount[userId] ?? 0;

  static String buildId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }

  String _inferName(String otherId) {
    final p = participants[otherId];
    if (p != null && p.name.isNotEmpty) return p.name;
    final type = _inferType(otherId);
    switch (type) {
      case ChatParticipantType.delivery:
        return 'Entregador';
      case ChatParticipantType.unit:
        return 'Açougue';
      default:
        return 'Cliente';
    }
  }

  ChatParticipantType _inferType(String otherId) {
    return ChatParticipantType.client;
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool read;
  final bool mine;
  final int? orderId;
  final ChatChannel? channel;

  final String? attachmentUrl;
  final String? attachmentType;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.read,
    this.mine = false,
    this.orderId,
    this.channel,
    this.attachmentUrl,
    this.attachmentType,
  });

  factory ChatMessage.fromApi(
    Map<String, Object?> data, {
    int? currentUserId,
    bool? isMine,
  }) {
    final senderId = (data['sender_id'] as num).toInt();
    final participantType = data['participant_type'] as String;
    return ChatMessage(
      id: '${data['id']}',
      senderId: '$senderId',
      text: data['message'] as String,
      sentAt: DateTime.parse(data['sent_at'] as String),
      read: data['read_at'] != null,
      mine: isMine ?? senderId == currentUserId,
      orderId: (data['order_id'] as num).toInt(),
      channel: ChatChannel.fromApi(participantType),
    );
  }

  factory ChatMessage.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ChatMessage(
      id: doc.id,
      senderId: data['sender_id'] as String? ?? '',
      text: data['text'] as String? ?? '',
      sentAt: (data['sent_at'] as Timestamp?)?.toDate() ?? DateTime.now(),
      read: data['read'] as bool? ?? false,
      attachmentUrl: data['attachment_url'] as String?,
      attachmentType: data['attachment_type'] as String?,
    );
  }

  bool get isMe => false;
}

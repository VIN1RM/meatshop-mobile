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

  final List<String> participantIds;
  final Map<String, ChatParticipant> participants;
  final String? lastMessage;
  final DateTime? lastMessageAt;
  final String? lastMessageSenderId;
  final Map<String, int> unreadCount;

  final DateTime createdAt;

  const ChatConversation({
    required this.id,
    required this.participantIds,
    required this.participants,
    this.lastMessage,
    this.lastMessageAt,
    this.lastMessageSenderId,
    required this.unreadCount,
    required this.createdAt,
  });

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
                name: 'Usuário',
                type: ChatParticipantType.client,
              )
            : null);
  }

  int unreadFor(String userId) => unreadCount[userId] ?? 0;

  static String buildId(String userId1, String userId2) {
    final sorted = [userId1, userId2]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}

class ChatMessage {
  final String id;
  final String senderId;
  final String text;
  final DateTime sentAt;
  final bool read;

  final String? attachmentUrl;
  final String? attachmentType;

  const ChatMessage({
    required this.id,
    required this.senderId,
    required this.text,
    required this.sentAt,
    required this.read,
    this.attachmentUrl,
    this.attachmentType,
  });

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

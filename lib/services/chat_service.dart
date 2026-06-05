import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/models/chat_model.dart';

const _kConversations = 'chat_conversations';
const _kMessages = 'messages';

class ChatService {
  final FirebaseFirestore _db;

  ChatService({FirebaseFirestore? db}) : _db = db ?? FirebaseFirestore.instance;

  Future<String> getOrCreateConversation({
    required String currentUserId,
    required String currentUserName,
    required ChatParticipantType currentUserType,
    required String otherUserId,
    required String otherUserName,
    required ChatParticipantType otherUserType,
    String? currentUserPhoto,
    String? otherUserPhoto,
  }) async {
    final conversationId = ChatConversation.buildId(currentUserId, otherUserId);
    final ref = _db.collection(_kConversations).doc(conversationId);

    final snapshot = await ref.get();
    if (!snapshot.exists) {
      await ref.set({
        'participant_ids': [currentUserId, otherUserId],
        'participants': {
          currentUserId: {
            'name': currentUserName,
            'photo_url': currentUserPhoto,
            'type': currentUserType.name.toUpperCase(),
          },
          otherUserId: {
            'name': otherUserName,
            'photo_url': otherUserPhoto,
            'type': otherUserType.name.toUpperCase(),
          },
        },
        'last_message': null,
        'last_message_at': null,
        'last_message_sender_id': null,
        'unread_count': {currentUserId: 0, otherUserId: 0},
        'created_at': FieldValue.serverTimestamp(),
        'participant_types': {
          currentUserId: currentUserType.name.toUpperCase(),
          otherUserId: otherUserType.name.toUpperCase(),
        },
      });
    }

    return conversationId;
  }

  Stream<List<ChatConversation>> conversationsStream(
    String userId,
    ChatParticipantType activeType,
  ) {
    final cutoff = Timestamp.fromDate(
      DateTime.now().subtract(const Duration(days: 30)),
    );

    return _db
        .collection(_kConversations)
        .where('participant_ids', arrayContains: userId)
        .where(
          'participant_types.$userId',
          isEqualTo: activeType.name.toUpperCase(),
        )
        .where('last_message_at', isGreaterThan: cutoff)
        .orderBy('last_message_at', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map(ChatConversation.fromDoc).toList());
  }

  Stream<List<ChatMessage>> messagesStream(String conversationId) {
    return _db
        .collection(_kConversations)
        .doc(conversationId)
        .collection(_kMessages)
        .orderBy('sent_at', descending: false)
        .snapshots()
        .map((snap) => snap.docs.map(ChatMessage.fromDoc).toList());
  }

  Future<void> sendMessage({
    required String conversationId,
    required String senderId,
    required String receiverId,
    required String text,
  }) async {
    if (text.trim().isEmpty) return;

    final convRef = _db.collection(_kConversations).doc(conversationId);
    final msgRef = convRef.collection(_kMessages).doc();

    final batch = _db.batch();

    batch.set(msgRef, {
      'sender_id': senderId,
      'text': text.trim(),
      'sent_at': FieldValue.serverTimestamp(),
      'read': false,
      'attachment_url': null,
      'attachment_type': null,
    });

    batch.set(convRef, {
      'last_message': text.trim(),
      'last_message_at': FieldValue.serverTimestamp(),
      'last_message_sender_id': senderId,
      'unread_count.$receiverId': FieldValue.increment(1),
    }, SetOptions(merge: true));

    await batch.commit();
  }

  Future<void> markConversationAsRead({
    required String conversationId,
    required String userId,
  }) async {
    final convRef = _db.collection(_kConversations).doc(conversationId);

    final unreadSnap = await convRef
        .collection(_kMessages)
        .where('read', isEqualTo: false)
        .where('sender_id', isNotEqualTo: userId)
        .get();

    if (unreadSnap.docs.isEmpty) return;

    final batch = _db.batch();

    for (final doc in unreadSnap.docs) {
      batch.update(doc.reference, {'read': true});
    }

    batch.update(convRef, {'unread_count.$userId': 0});

    await batch.commit();
  }

  Stream<int> totalUnreadStream(String userId) {
    return _db
        .collection(_kConversations)
        .where('participant_ids', arrayContains: userId)
        .snapshots()
        .map((snap) {
          int total = 0;
          for (final doc in snap.docs) {
            final data = doc.data();
            final unread =
                (data['unread_count'] as Map<String, dynamic>?)?[userId];
            total += (unread as num?)?.toInt() ?? 0;
          }
          return total;
        });
  }
}

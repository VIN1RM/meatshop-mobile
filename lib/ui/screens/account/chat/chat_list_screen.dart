import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/chat_args.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/providers/chat_provider.dart';
import 'package:meatshop_mobile/services/chat_service.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

/// Exemplo de como obter o usuário logado — adapte ao seu AuthProvider.
// ignore: non_constant_identifier_names
// final _auth = FirebaseAuth.instance;

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  // TODO: substituir pelo currentUserId real do AuthProvider
  static const String _mockCurrentUserId = 'current_user_id';
  static const String _mockCurrentUserName = 'Você';
  static const ChatParticipantType _mockCurrentUserType =
      ChatParticipantType.client;

  static const Color _red = Color(0xFFC0392B);
  static const Color _pageBg = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => ChatListProvider(
        service: ChatService(),
        currentUserId: _mockCurrentUserId,
      ),
      child: Scaffold(
        backgroundColor: _pageBg,
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: SizedBox(
                height: 130,
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) =>
                      Container(color: const Color(0xFF1A1A1A)),
                ),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const AppHeader(showBack: true),
                  Expanded(
                    child: Consumer<ChatListProvider>(
                      builder: (context, provider, _) {
                        if (provider.loading) {
                          return const Center(
                            child: CircularProgressIndicator(color: _red),
                          );
                        }

                        if (provider.conversations.isEmpty) {
                          return _buildEmpty();
                        }

                        return ListView(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 10,
                          ),
                          children: [
                            const Text(
                              'CHATS',
                              style: TextStyle(
                                color: Color(0xFFF5F5F5),
                                fontSize: 28,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 1.2,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Suas conversas',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 16),
                            ...provider.conversations.map(
                              (conv) => _ConversationTile(
                                conversation: conv,
                                currentUserId: _mockCurrentUserId,
                                currentUserName: _mockCurrentUserName,
                                currentUserType: _mockCurrentUserType,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Icon(Icons.chat_bubble_outline, color: Colors.white12, size: 52),
          SizedBox(height: 12),
          Text(
            'Nenhuma conversa ainda',
            style: TextStyle(color: Colors.white38, fontSize: 15),
          ),
          SizedBox(height: 4),
          Text(
            'Inicie um chat pelo pedido ou pelo açougue',
            style: TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }
}

class _ConversationTile extends StatelessWidget {
  final ChatConversation conversation;
  final String currentUserId;
  final String currentUserName;
  final ChatParticipantType currentUserType;

  const _ConversationTile({
    required this.conversation,
    required this.currentUserId,
    required this.currentUserName,
    required this.currentUserType,
  });

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final other = conversation.otherParticipant(currentUserId);
    if (other == null) return const SizedBox.shrink();

    final unread = conversation.unreadFor(currentUserId);
    final hasUnread = unread > 0;

    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: ChatArgs(
          currentUserId: currentUserId,
          currentUserName: currentUserName,
          currentUserType: currentUserType,
          otherUserId: other.userId,
          otherUserName: other.name,
          otherUserType: other.type,
          otherUserPhoto: other.photoUrl,
        ),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFFF5F5F5),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            _Avatar(participant: other, unread: unread),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          other.name,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: hasUnread
                                ? FontWeight.w700
                                : FontWeight.w600,
                            color: const Color(0xFF1A1A1A),
                          ),
                        ),
                      ),
                      if (conversation.lastMessageAt != null)
                        Text(
                          _formatTime(conversation.lastMessageAt!),
                          style: TextStyle(
                            fontSize: 11,
                            color: hasUnread ? _red : const Color(0xFF888888),
                            fontWeight: hasUnread
                                ? FontWeight.w600
                                : FontWeight.normal,
                          ),
                        ),
                    ],
                  ),
                  if (conversation.lastMessage != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      conversation.lastMessage!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 13,
                        color: hasUnread
                            ? const Color(0xFF444444)
                            : const Color(0xFF888888),
                        fontWeight: hasUnread
                            ? FontWeight.w500
                            : FontWeight.normal,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Agora';
    if (diff.inMinutes < 60) return '${diff.inMinutes}min';
    if (diff.inHours < 24 && now.day == dt.day) {
      return '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
    }
    if (diff.inDays == 1) return 'Ontem';
    return '${dt.day.toString().padLeft(2, '0')}/${dt.month.toString().padLeft(2, '0')}/${dt.year}';
  }
}

class _Avatar extends StatelessWidget {
  final ChatParticipant participant;
  final int unread;

  const _Avatar({required this.participant, required this.unread});

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: const Color(0xFFE0E0E0), width: 1.5),
          ),
          child: ClipOval(
            child: participant.photoUrl != null
                ? Image.network(
                    participant.photoUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => _fallback(),
                  )
                : _fallback(),
          ),
        ),
        if (unread > 0)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              width: 20,
              height: 20,
              decoration: const BoxDecoration(
                color: _red,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  unread > 9 ? '9+' : '$unread',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _fallback() {
    final isUnit = participant.type == ChatParticipantType.unit;
    return Container(
      color: const Color(0xFFE0E0E0),
      child: Icon(
        isUnit ? Icons.storefront_outlined : Icons.person_outline,
        color: const Color(0xFFBDBDBD),
        size: 24,
      ),
    );
  }
}

import '../../../widgets/chat_participant_avatar.dart';
import 'package:meatshop_mobile/ui/widgets/app_empty_state.dart';
import '../../../widgets/chat_load_error.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/chat_args.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/providers/chat_provider.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/data/repositories/realtime_repository.dart';

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const Color _red = Color(0xFFC0392B);
  static const Color _pageBg = Color(0xFF3A3A3A);

  @override
  Widget build(BuildContext context) {
    final auth = context.read<AuthProvider>();
    final currentUserId = auth.backendUserId?.toString() ?? '';
    final currentUserName = auth.currentUser?.displayName ?? 'Você';
    final activeType = auth.isDelivery
        ? ChatParticipantType.delivery
        : ChatParticipantType.client;
    final backend = context.read<BackendRealtimeAccess>();

    return ChangeNotifierProvider(
      create: (_) => ChatListProvider(
        repository: backend.chat!,
        realtime: backend.realtime!,
        backendUserId: auth.backendUserId,
        currentUserId: currentUserId,
        activeType: activeType,
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
                  errorBuilder: (_, _, _) =>
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

                        if (provider.conversations.isEmpty &&
                            provider.error != null) {
                          return Center(
                            child: ChatLoadError(
                              message: provider.error!,
                              onRetry: provider.retry,
                            ),
                          );
                        }
                        if (provider.conversations.isEmpty) {
                          return _buildEmpty();
                        }

                        return RefreshIndicator(
                          onRefresh: provider.refresh,
                          child: ListView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 10,
                            ),
                            children: [
                              if (provider.error != null)
                                ChatLoadError(
                                  message: provider.error!,
                                  onRetry: provider.retry,
                                ),
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
                                'Todas as suas conversas',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 16),
                              ...provider.conversations.map(
                                (conv) => _ConversationTile(
                                  conversation: conv,
                                  currentUserId: currentUserId,
                                  currentUserName: currentUserName,
                                  currentUserType: activeType,
                                ),
                              ),
                              if (provider.hasMore)
                                TextButton(
                                  onPressed: provider.loadingMore
                                      ? null
                                      : provider.loadMore,
                                  child: Text(
                                    provider.loadingMore
                                        ? 'Carregando conversas…'
                                        : 'Carregar mais conversas',
                                    style: const TextStyle(color: Colors.white),
                                  ),
                                ),
                            ],
                          ),
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
    return const AppEmptyState(
      title: 'Nenhuma conversa ainda',
      icon: Icons.chat_bubble_outline,
      description:
          'Abra uma conversa pelo pedido ou pelo açougue para falar com a equipe.',
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
      onTap: () async {
        await Navigator.pushNamed(
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
            orderId: conversation.orderId,
            channel: conversation.channel,
            closed: conversation.closed,
          ),
        );
        if (context.mounted) await context.read<ChatListProvider>().refresh();
      },
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
                  const SizedBox(height: 4),
                  Text(
                    '${other.type.label}${conversation.orderId == null ? '' : ' • Pedido #${conversation.orderId}'}',
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (hasUnread)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        '$unread ${unread == 1 ? 'mensagem não lida' : 'mensagens não lidas'}',
                        style: const TextStyle(
                          color: _red,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
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
          child: ChatParticipantAvatar(
            photoUrl: participant.photoUrl,
            type: participant.type,
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
}

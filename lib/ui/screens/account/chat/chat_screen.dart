import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meatshop_mobile/core/utils/chat_args.dart';
import 'package:meatshop_mobile/models/chat_model.dart';
import 'package:meatshop_mobile/providers/chat_provider.dart';
import 'package:meatshop_mobile/services/chat_service.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _pageBg = Color(0xFF2E2E2E);
  static const Color _surface = Color(0xFF424242);

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  ChatArgs? _args;
  ChatProvider? _chatProvider;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_args != null) return; // já inicializado

    final args = ModalRoute.of(context)?.settings.arguments;
    if (args is! ChatArgs) return;

    _args = args;
    _chatProvider = ChatProvider(
      service: ChatService(),
      currentUserId: args.currentUserId,
      conversationId: args.conversationId,
      receiverId: args.otherUserId,
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _chatProvider?.dispose();
    super.dispose();
  }

  void _send() {
    final text = _messageController.text;
    _messageController.clear();
    _chatProvider?.sendMessage(text).then((_) => _scrollToBottom());
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_chatProvider == null) {
      return const Scaffold(
        body: Center(child: Text('Erro ao carregar conversa')),
      );
    }

    return ChangeNotifierProvider.value(
      value: _chatProvider!,
      child: Scaffold(
        backgroundColor: _pageBg,
        resizeToAvoidBottomInset: false,
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
              bottom: false,
              child: Column(
                children: [
                  const AppHeader(showBack: true),
                  _buildParticipantHeader(),
                  Expanded(child: _buildMessageList()),
                  _buildInputBar(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Header com info do outro participante ───
  Widget _buildParticipantHeader() {
    final other = _args!;
    final isUnit = other.otherUserType == ChatParticipantType.unit;
    final accentColor = isUnit ? _red : const Color(0xFF27AE60);

    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: accentColor, width: 2),
            ),
            child: ClipOval(child: _buildAvatar(other, accentColor)),
          ),
          const SizedBox(height: 8),
          Text(
            other.otherUserName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              other.otherUserType.label,
              style: TextStyle(
                fontSize: 11,
                color: accentColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatArgs args, Color accent) {
    if (args.logoAsset != null) {
      return Image.asset(
        args.logoAsset!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _fallbackAvatar(args.otherUserType, accent),
      );
    }
    if (args.otherUserPhoto != null) {
      return Image.network(
        args.otherUserPhoto!,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) =>
            _fallbackAvatar(args.otherUserType, accent),
      );
    }
    return _fallbackAvatar(args.otherUserType, accent);
  }

  Widget _fallbackAvatar(ChatParticipantType type, Color accent) {
    return Container(
      color: _surface,
      child: Icon(
        type == ChatParticipantType.unit
            ? Icons.storefront_outlined
            : Icons.person_outline,
        color: Colors.white,
        size: 30,
      ),
    );
  }

  // ─── Lista de mensagens ───
  Widget _buildMessageList() {
    return Consumer<ChatProvider>(
      builder: (context, provider, _) {
        if (provider.loading) {
          return const Center(child: CircularProgressIndicator(color: _red));
        }

        if (provider.messages.isEmpty) {
          return _buildEmptyState();
        }

        // Scroll automático quando chegam novas mensagens
        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: provider.messages.length,
          itemBuilder: (context, i) {
            final msg = provider.messages[i];
            final isMe = provider.isMyMessage(msg);
            final showDate =
                i == 0 ||
                !_isSameDay(provider.messages[i - 1].sentAt, msg.sentAt);

            return Column(
              children: [
                if (showDate) _DateDivider(date: msg.sentAt),
                _MessageBubble(
                  message: msg,
                  isMe: isMe,
                  showTail:
                      i == provider.messages.length - 1 ||
                      provider
                              .messages[i + 1 < provider.messages.length
                                  ? i + 1
                                  : i]
                              .senderId !=
                          msg.senderId,
                ),
              ],
            );
          },
        );
      },
    );
  }

  bool _isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            color: Colors.white12,
            size: 48,
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma mensagem ainda',
            style: TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Inicie a conversa com ${_args?.otherUserName ?? ''}',
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ─── Barra de input ───
  Widget _buildInputBar() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Consumer<ChatProvider>(
      builder: (context, provider, _) => AnimatedPadding(
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOut,
        padding: EdgeInsets.only(bottom: bottomInset),
        child: Container(
          color: const Color(0xFFF5F5F5),
          padding: EdgeInsets.only(
            left: 12,
            right: 12,
            top: 10,
            bottom: 10 + bottomPadding,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: _showAttachmentOptions,
                child: const Padding(
                  padding: EdgeInsets.only(right: 8),
                  child: Icon(Icons.attach_file_rounded, color: _red, size: 26),
                ),
              ),
              Expanded(
                child: Container(
                  height: 44,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22),
                    border: Border.all(color: const Color(0xFFDDDDDD)),
                  ),
                  child: TextField(
                    controller: _messageController,
                    style: const TextStyle(fontSize: 14, color: Colors.black87),
                    decoration: const InputDecoration(
                      hintText: 'Mensagem...',
                      hintStyle: TextStyle(
                        color: Color(0xFFAAAAAA),
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                    onSubmitted: (_) => _send(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              GestureDetector(
                onTap: provider.sending ? null : _send,
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: provider.sending ? const Color(0xFFAAAAAA) : _red,
                    shape: BoxShape.circle,
                  ),
                  child: provider.sending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 20,
                        ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => _AttachmentSheet(),
    );
  }
}

// ─────────────────────────────────────────────
// Widgets auxiliares
// ─────────────────────────────────────────────

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showTail;

  const _MessageBubble({
    required this.message,
    required this.isMe,
    this.showTail = true,
  });

  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF424242);

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Column(
        crossAxisAlignment: isMe
            ? CrossAxisAlignment.end
            : CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(
              top: 2,
              bottom: showTail ? 6 : 2,
              left: isMe ? 48 : 0,
              right: isMe ? 0 : 48,
            ),
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.72,
              minHeight: 40,
              minWidth: 60,
            ),
            decoration: BoxDecoration(
              color: isMe ? _red : _surface,
              borderRadius: BorderRadius.only(
                topLeft: const Radius.circular(18),
                topRight: const Radius.circular(18),
                bottomLeft: Radius.circular(isMe ? 18 : (showTail ? 4 : 18)),
                bottomRight: Radius.circular(isMe ? (showTail ? 4 : 18) : 18),
              ),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  message.text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _formatTime(message.sentAt),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.6),
                    fontSize: 10,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime dt) =>
      '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
}

class _DateDivider extends StatelessWidget {
  final DateTime date;
  const _DateDivider({required this.date});

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    String label;
    if (now.day == date.day &&
        now.month == date.month &&
        now.year == date.year) {
      label = 'Hoje';
    } else if (now.subtract(const Duration(days: 1)).day == date.day) {
      label = 'Ontem';
    } else {
      label =
          '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        children: [
          const Expanded(child: Divider(color: Colors.white12, thickness: 1)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Text(
              label,
              style: const TextStyle(
                color: Colors.white38,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider(color: Colors.white12, thickness: 1)),
        ],
      ),
    );
  }
}

class _AttachmentSheet extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 32),
      decoration: BoxDecoration(
        color: const Color(0xFF525252),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: const Color(0xFF777777),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Anexar arquivo',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha como deseja enviar',
            style: TextStyle(fontSize: 13, color: Colors.white54),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _AttachOption(
                icon: Icons.camera_alt_outlined,
                label: 'Câmera',
                onTap: () async {
                  Navigator.pop(context);
                  await ImagePicker().pickImage(source: ImageSource.camera);
                },
              ),
              _AttachOption(
                icon: Icons.photo_library_outlined,
                label: 'Galeria',
                onTap: () async {
                  Navigator.pop(context);
                  await ImagePicker().pickImage(source: ImageSource.gallery);
                },
              ),
              _AttachOption(
                icon: Icons.insert_drive_file_outlined,
                label: 'Arquivo',
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 20),
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(
                color: Color(0xFFC0392B),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _AttachOption extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _AttachOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: const Color(0xFF424242),
              shape: BoxShape.circle,
              border: Border.all(color: const Color(0xFF666666)),
            ),
            child: Icon(icon, color: const Color(0xFFC0392B), size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }
}

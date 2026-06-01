import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

class ChatMessage {
  final String text;
  final bool isMe;

  const ChatMessage({required this.text, required this.isMe});
}

class ChatArgs {
  final String participantName;
  final ChatParticipantType participantType;
  final String? logoAsset;

  const ChatArgs({
    required this.participantName,
    required this.participantType,
    this.logoAsset,
  });
}

class _AttachOption extends StatelessWidget {
  const _AttachOption({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final VoidCallback onTap;

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

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _pageBg = Color(0xFF2E2E2E);
  static const Color _surface = Color.fromARGB(255, 66, 66, 66);
  static const Color _white = Colors.white;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [];

  ChatArgs? _args;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _args = ModalRoute.of(context)?.settings.arguments as ChatArgs?;
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty) return;

    setState(() {
      _messages.add(ChatMessage(text: text, isMe: true));
      _messageController.clear();
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  String get _participantName => _args?.participantName ?? 'MeatShop';

  String get _participantLabel =>
      _args?.participantType.label ?? 'Estabelecimento';

  Color get _accentColor => _args?.participantType == ChatParticipantType.client
      ? const Color(0xFF27AE60)
      : _red;

  IconData get _participantIcon =>
      _args?.participantType == ChatParticipantType.client
      ? Icons.person_outline
      : Icons.storefront_outlined;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
                _buildParticipantInfo(),
                Expanded(
                  child: _messages.isEmpty
                      ? _buildEmptyState()
                      : ListView.builder(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          itemCount: _messages.length,
                          itemBuilder: (context, index) =>
                              _buildMessageBubble(_messages[index]),
                        ),
                ),
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildParticipantInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 20, bottom: 8),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: _accentColor, width: 2),
            ),
            child: ClipOval(
              child: _args?.logoAsset != null
                  ? Image.asset(
                      _args!.logoAsset!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => _defaultAvatar(),
                    )
                  : _defaultAvatar(),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _participantName,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: _white,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 2),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
            decoration: BoxDecoration(
              color: _accentColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              _participantLabel,
              style: TextStyle(
                fontSize: 11,
                color: _accentColor,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }

  Widget _defaultAvatar() {
    return Container(
      color: _surface,
      child: Icon(_participantIcon, color: _white, size: 30),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline, color: Colors.white12, size: 48),
          const SizedBox(height: 12),
          Text(
            'Nenhuma mensagem ainda',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
          const SizedBox(height: 4),
          Text(
            'Inicie a conversa com $_participantName',
            style: const TextStyle(color: Colors.white24, fontSize: 12),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isMe = message.isMe;
    return Align(
      alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 6),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.72,
          minHeight: 44,
          minWidth: 80,
        ),
        decoration: BoxDecoration(
          color: isMe ? _accentColor : _surface,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Text(
          message.text,
          style: TextStyle(
            color: isMe ? _white : Colors.white70,
            fontSize: 14,
            height: 1.4,
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return AnimatedPadding(
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
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                  ],
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
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: _sendMessage,
              child: Container(
                width: 40,
                height: 40,
                decoration: const BoxDecoration(
                  color: _red,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.send_rounded,
                  color: Colors.white,
                  size: 20,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => Container(
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
                    final picker = ImagePicker();
                    await picker.pickImage(
                      source: ImageSource.camera,
                      imageQuality: 85,
                    );
                  },
                ),
                _AttachOption(
                  icon: Icons.photo_library_outlined,
                  label: 'Galeria',
                  onTap: () async {
                    Navigator.pop(context);
                    final picker = ImagePicker();
                    await picker.pickImage(
                      source: ImageSource.gallery,
                      imageQuality: 85,
                    );
                  },
                ),
                _AttachOption(
                  icon: Icons.insert_drive_file_outlined,
                  label: 'Arquivo',
                  onTap: () async {
                    Navigator.pop(context);
                  },
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
      ),
    );
  }
}

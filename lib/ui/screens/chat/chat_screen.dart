import 'package:flutter/material.dart';

class ChatMessage {
  final String text;
  final bool isMe;

  const ChatMessage({required this.text, required this.isMe});
}

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _headerBg = Color(0xFF3A3A3A);
  static const Color _pageBg = Color(0xFFEFEFEF);
  static const Color _white = Colors.white;

  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<ChatMessage> _messages = [
    const ChatMessage(text: '', isMe: true),
    const ChatMessage(text: '', isMe: false),
    const ChatMessage(text: '', isMe: true),
    const ChatMessage(text: '', isMe: false),
  ];

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: Stack(
              children: [
                Positioned.fill(
                  child: Opacity(
                    opacity: 0.08,
                    child: Image.asset(
                      'assets/images/background_pattern.png',
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                Column(
                  children: [
                    _buildStoreInfo(),
                    Expanded(
                      child: ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          return _buildMessageBubble(_messages[index]);
                        },
                      ),
                    ),
                    _buildFinalizeButton(),
                    _buildInputBar(),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _headerBg,
      child: SafeArea(
        bottom: false,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              GestureDetector(
                onTap: () => Navigator.pop(context),
                child: const Icon(Icons.arrow_back, color: _white, size: 24),
              ),
              const Spacer(),
              const Text(
                'MeatShop',
                style: TextStyle(
                  color: _white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              const Spacer(),

              SizedBox(
                width: 48,
                height: 40,
                child: Image.asset(
                  'assets/images/logo1.png',
                  fit: BoxFit.contain,
                  errorBuilder: (_, __, ___) => const Icon(
                    Icons.storefront_outlined,
                    color: _white,
                    size: 28,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStoreInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 8),
      child: Column(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo_master.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  color: const Color(0xFF1A1A1A),
                  child: const Icon(Icons.store, color: _white, size: 30),
                ),
              ),
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Master Carnes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 8),
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
          minHeight: 60,
          minWidth: 120,
        ),
        decoration: BoxDecoration(
          color: isMe ? _red : const Color(0xFFE0E0E0),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(18),
            topRight: const Radius.circular(18),
            bottomLeft: Radius.circular(isMe ? 18 : 4),
            bottomRight: Radius.circular(isMe ? 4 : 18),
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: message.text.isNotEmpty
            ? Text(
                message.text,
                style: TextStyle(
                  color: isMe ? _white : const Color(0xFF1A1A1A),
                  fontSize: 14,
                ),
              )
            : const SizedBox.shrink(),
      ),
    );
  }

  Widget _buildFinalizeButton() {
    return Padding(
      padding: const EdgeInsets.only(right: 16, bottom: 6),
      child: Align(
        alignment: Alignment.centerRight,
        child: GestureDetector(
          onTap: () {},
          child: const Text(
            'Finalizar atendimento',
            style: TextStyle(
              color: Color(0xFFBE2C1B),
              fontSize: 13,
              decoration: TextDecoration.underline,
              decorationColor: Color(0xFFBE2C1B),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return SafeArea(
      top: false,
      child: Container(
        color: _pageBg,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        child: Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.attach_file_rounded, color: _red, size: 26),
              ),
            ),

            Expanded(
              child: Container(
                height: 44,
                decoration: BoxDecoration(
                  color: _white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFDDDDDD)),
                ),
                child: TextField(
                  controller: _messageController,
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: '',
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
              child: const Icon(Icons.send_rounded, color: _red, size: 26),
            ),
          ],
        ),
      ),
    );
  }
}

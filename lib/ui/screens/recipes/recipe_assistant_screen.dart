import 'package:flutter/material.dart';
import 'package:meatshop_mobile/services/recipe_service.dart';

class RecipeScreen extends StatefulWidget {
  const RecipeScreen({super.key});

  @override
  State<RecipeScreen> createState() => _RecipeScreenState();
}

class _RecipeScreenState extends State<RecipeScreen> {
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _cardDark = Color(0xFF4A4A4A);

  final RecipeService _recipeService = RecipeService();
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_RecipeMsg> _messages = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _messages.add(
      _RecipeMsg(
        text:
            'Olá! 🥩 Bem-vindo ao assistente de receitas da MeatShop!\n\nPosso te ajudar com receitas, cortes, temperos e técnicas de preparo. Como posso te ajudar hoje?',
        isUser: false,
      ),
    );
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _isLoading) return;

    setState(() {
      _messages.add(_RecipeMsg(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await _recipeService.sendMessage(text);
      setState(() => _messages.add(_RecipeMsg(text: reply, isUser: false)));
    } catch (e, stackTrace) {
      debugPrint('❌ ERRO AO CHAMAR GEMINI: $e');
      debugPrint('📍 StackTrace: $stackTrace');
      setState(
        () => _messages.add(
          _RecipeMsg(text: 'Erro: $e', isUser: false, isError: true),
        ),
      );
    } finally {
      setState(() => _isLoading = false);
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
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
    // Sem Scaffold próprio — o AppShell já fornece
    return Scaffold(
      backgroundColor: const Color(0xFF2A2A2A),
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
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(),
                _buildSubtitle(),
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
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
          // Botão limpar conversa
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: _white, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              padding: EdgeInsets.zero,
              icon: const Icon(Icons.refresh_rounded, color: _white, size: 20),
              onPressed: () {
                setState(() {
                  _messages.clear();
                  _messages.add(
                    _RecipeMsg(
                      text: 'Conversa reiniciada! Como posso te ajudar? 🥩',
                      isUser: false,
                    ),
                  );
                  _recipeService.clearHistory();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Container(
      width: double.infinity,
      color: _surface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: const Row(
        children: [
          Icon(Icons.restaurant_menu_rounded, color: _red, size: 20),
          SizedBox(width: 8),
          Text(
            'ASSISTENTE DE RECEITAS',
            style: TextStyle(
              color: _white,
              fontSize: 13,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isLoading ? 1 : 0),
      itemBuilder: (context, index) {
        if (index == _messages.length) return const _TypingBubble();
        return _buildBubble(_messages[index]);
      },
    );
  }

  Widget _buildBubble(_RecipeMsg msg) {
    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        decoration: BoxDecoration(
          color: msg.isError
              ? Colors.red.shade900.withOpacity(0.6)
              : msg.isUser
              ? _red
              : _cardDark,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
        ),
        child: Text(
          msg.text,
          style: const TextStyle(color: _white, fontSize: 14, height: 1.4),
        ),
      ),
    );
  }

  Widget _buildInputBar() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 16),
      color: _surface,
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              style: const TextStyle(color: _white),
              onSubmitted: (_) => _send(),
              maxLines: null,
              decoration: InputDecoration(
                hintText: 'Pergunte sobre carnes e receitas...',
                hintStyle: const TextStyle(color: Colors.white38),
                filled: true,
                fillColor: const Color(0xFF2A2A2A),
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(24),
                  borderSide: BorderSide.none,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isLoading ? null : _send,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isLoading ? Colors.grey : _red,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: _white, size: 20),
            ),
          ),
        ],
      ),
    );
  }
}

// --- Modelos e widgets auxiliares ---

class _RecipeMsg {
  final String text;
  final bool isUser;
  final bool isError;
  _RecipeMsg({required this.text, required this.isUser, this.isError = false});
}

class _TypingBubble extends StatefulWidget {
  const _TypingBubble();

  @override
  State<_TypingBubble> createState() => _TypingBubbleState();
}

class _TypingBubbleState extends State<_TypingBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 5),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: const Color(0xFF4A4A4A),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(
            3,
            (i) => _Dot(controller: _controller, index: i),
          ),
        ),
      ),
    );
  }
}

class _Dot extends StatelessWidget {
  final AnimationController controller;
  final int index;

  const _Dot({required this.controller, required this.index});

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: controller,
      builder: (_, __) {
        final offset = (controller.value - index * 0.15).clamp(0.0, 1.0);
        final dy = -4.0 * (1 - (2 * offset - 1).abs().clamp(0.0, 1.0));
        return Transform.translate(
          offset: Offset(0, dy),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 3),
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFC0392B),
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }
}

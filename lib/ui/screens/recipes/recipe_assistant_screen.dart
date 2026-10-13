import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:meatshop_mobile/core/network/cancellation_token.dart';
import 'package:meatshop_mobile/data/repositories/ai_assistant_repository.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';

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

  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  final List<_RecipeMsg> _messages = [];
  bool _isLoading = false;
  bool _isRestoring = true;
  CancellationToken? _cancellationToken;
  String? _lastQuestion;

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
    WidgetsBinding.instance.addPostFrameCallback((_) => _restoreHistory());
  }

  Future<void> _restoreHistory() async {
    try {
      final history = await context.read<AiAssistantRepository>().loadHistory();
      if (!mounted || history.isEmpty) return;
      setState(() {
        _messages
          ..clear()
          ..addAll(
            history.map(
              (message) =>
                  _RecipeMsg(text: message.text, isUser: message.isUser),
            ),
          );
      });
      _scrollToBottom();
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(
        () => _messages.add(
          _RecipeMsg(text: failure.message, isUser: false, isError: true),
        ),
      );
    } finally {
      if (mounted) setState(() => _isRestoring = false);
    }
  }

  Future<void> _send([String? repeatedText]) async {
    final text = (repeatedText ?? _controller.text).trim();
    if (text.isEmpty || _isLoading || _isRestoring) return;

    final token = CancellationToken();
    _cancellationToken = token;
    _lastQuestion = text;

    setState(() {
      _messages.add(_RecipeMsg(text: text, isUser: true));
      _isLoading = true;
      _controller.clear();
    });
    _scrollToBottom();

    try {
      final reply = await context.read<AiAssistantRepository>().send(
        text,
        cancellationToken: token,
      );
      if (!mounted) return;
      setState(
        () => _messages.add(_RecipeMsg(text: reply.text, isUser: false)),
      );
    } on ApiFailure catch (failure) {
      if (!mounted || failure.kind == ApiFailureKind.cancelled) return;
      setState(
        () => _messages.add(
          _RecipeMsg(text: failure.message, isUser: false, isError: true),
        ),
      );
    } catch (error, stackTrace) {
      debugPrint('Erro ao chamar o assistente: $error');
      debugPrintStack(stackTrace: stackTrace);
      if (!mounted) return;
      setState(
        () => _messages.add(
          const _RecipeMsg(
            text: 'Não foi possível consultar o assistente. Tente novamente.',
            isUser: false,
            isError: true,
          ),
        ),
      );
    } finally {
      _cancellationToken = null;
      if (mounted) {
        setState(() => _isLoading = false);
        _scrollToBottom();
      }
    }
  }

  void _cancel() {
    _cancellationToken?.cancel();
    if (mounted) setState(() => _isLoading = false);
  }

  Future<void> _clearConversation() async {
    if (_isLoading) _cancel();
    setState(() => _isLoading = true);
    try {
      await context.read<AiAssistantRepository>().clearHistory();
      if (!mounted) return;
      setState(() {
        _messages
          ..clear()
          ..add(
            const _RecipeMsg(
              text: 'Conversa limpa. Como posso ajudar com carnes ou receitas?',
              isUser: false,
            ),
          );
        _lastQuestion = null;
      });
    } on ApiFailure catch (failure) {
      if (!mounted) return;
      setState(
        () => _messages.add(
          _RecipeMsg(text: failure.message, isUser: false, isError: true),
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
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
  void dispose() {
    _cancellationToken?.cancel();
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
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
                const AppHeader(),
                _buildSubtitle(),
                _buildAiNotice(),
                Expanded(child: _buildMessageList()),
                _buildInputBar(),
              ],
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
      child: Row(
        children: [
          const Icon(Icons.restaurant_menu_rounded, color: _red, size: 20),
          const SizedBox(width: 8),
          const Expanded(
            child: Text(
              'ASSISTENTE DE RECEITAS',
              style: TextStyle(
                color: _white,
                fontSize: 13,
                fontWeight: FontWeight.w900,
                letterSpacing: 1.2,
              ),
            ),
          ),
          IconButton(
            tooltip: 'Limpar conversa',
            onPressed: _isLoading || _isRestoring
                ? null
                : () => _clearConversation(),
            icon: const Icon(Icons.delete_outline, color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildAiNotice() => Container(
    width: double.infinity,
    color: const Color(0xFF252525),
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: const Text(
      'Respostas são geradas por IA e podem conter erros. O histórico fica no servidor por 7 dias. Não envie dados pessoais, de pedidos ou pagamento.',
      style: TextStyle(color: Colors.white60, fontSize: 11, height: 1.3),
    ),
  );

  Widget _buildMessageList() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      itemCount: _messages.length + (_isLoading || _isRestoring ? 1 : 0),
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
              ? Colors.red.shade900.withValues(alpha: 0.6)
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
              maxLength: 1000,
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
                counterText: '',
              ),
            ),
          ),
          const SizedBox(width: 10),
          GestureDetector(
            onTap: _isRestoring ? null : (_isLoading ? _cancel : _send),
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _isLoading || _isRestoring ? Colors.grey : _red,
                shape: BoxShape.circle,
              ),
              child: Icon(
                _isLoading
                    ? Icons.stop_rounded
                    : _isRestoring
                    ? Icons.hourglass_top_rounded
                    : Icons.send_rounded,
                color: _white,
                size: 20,
              ),
            ),
          ),
          if (!_isLoading &&
              _messages.lastOrNull?.isError == true &&
              _lastQuestion != null) ...[
            const SizedBox(width: 6),
            IconButton(
              tooltip: 'Tentar novamente',
              onPressed: () => _send(_lastQuestion),
              icon: const Icon(Icons.refresh, color: _white),
            ),
          ],
        ],
      ),
    );
  }
}

class _RecipeMsg {
  final String text;
  final bool isUser;
  final bool isError;
  const _RecipeMsg({
    required this.text,
    required this.isUser,
    this.isError = false,
  });
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
      builder: (_, _) {
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

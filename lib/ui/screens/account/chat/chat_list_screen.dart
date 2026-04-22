import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class ChatContact {
  final String nome;
  final String ultimaMensagem;
  final String horario;
  final String logoAsset;
  final int mensagensNaoLidas;

  const ChatContact({
    required this.nome,
    required this.ultimaMensagem,
    required this.horario,
    this.logoAsset = '',
    this.mensagensNaoLidas = 0,
  });
}

class ChatListScreen extends StatelessWidget {
  const ChatListScreen({super.key});

  static const Color _red = Color(0xFFC0392B);
  static const Color _pageBg = Color(0xFF1A1A1A);
  static const Color _cardBg = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  static final List<ChatContact> _chats = [
    const ChatContact(
      nome: 'Master Carnes',
      ultimaMensagem: '',
      horario: 'Há 1 minuto',
      logoAsset: 'assets/images/logo_master.png',
      mensagensNaoLidas: 0,
    ),
    const ChatContact(
      nome: 'Frigorífico Goiás',
      ultimaMensagem: '',
      horario: 'Hoje às 20:15',
      logoAsset: 'assets/images/logo_frigorifico.png',
      mensagensNaoLidas: 2,
    ),
    const ChatContact(
      nome: 'Mendes',
      ultimaMensagem: '',
      horario: '06/12/2023',
      logoAsset: 'assets/images/logo_mendes.png',
      mensagensNaoLidas: 0,
    ),
    const ChatContact(
      nome: 'Master Carnes',
      ultimaMensagem: '',
      horario: '22/11/2023',
      logoAsset: 'assets/images/logo_master.png',
      mensagensNaoLidas: 0,
    ),
    const ChatContact(
      nome: 'Master Carnes',
      ultimaMensagem: '',
      horario: '08/11/2023',
      logoAsset: 'assets/images/logo_master.png',
      mensagensNaoLidas: 0,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                const Text(
                  'CHATS',
                  style: TextStyle(
                    color: _red,
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Suas conversas com os estabelecimentos',
                  style: TextStyle(color: Color(0xFF9E9E9E), fontSize: 13),
                ),
                const SizedBox(height: 16),
                ..._chats.map((chat) => _buildChatItem(context, chat)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return SizedBox(
      height: 130,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            errorBuilder: (_, __, ___) =>
                Container(color: const Color(0xFF1A1A1A)),
          ),
          SafeArea(
            bottom: false,
            child: Padding(
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
                  Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      border: Border.all(color: _white, width: 1.5),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.help_outline,
                      color: _white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChatItem(BuildContext context, ChatContact chat) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.chat),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: _cardBg,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFF3A3A3A),
                      width: 1.5,
                    ),
                  ),
                  child: ClipOval(
                    child: Image.asset(
                      chat.logoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF3A3A3A),
                        child: const Icon(Icons.store, color: _white, size: 22),
                      ),
                    ),
                  ),
                ),
                if (chat.mensagensNaoLidas > 0)
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
                          '${chat.mensagensNaoLidas}',
                          style: const TextStyle(
                            color: _white,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chat.nome,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: _white,
                    ),
                  ),
                  if (chat.ultimaMensagem.isNotEmpty)
                    Text(
                      chat.ultimaMensagem,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF9E9E9E),
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Text(
              chat.horario,
              style: const TextStyle(fontSize: 11, color: Color(0xFF9E9E9E)),
            ),
          ],
        ),
      ),
    );
  }
}

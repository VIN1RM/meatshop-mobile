import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';
import 'package:meatshop_mobile/ui/screens/account/chat/chat_screen.dart';

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
          SizedBox(height: 90, child: Stack(fit: StackFit.expand)),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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

  Widget _buildChatItem(BuildContext context, ChatContact chat) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.chat,
        arguments: ChatArgs(
          participantName: chat.nome,
          participantType: ChatParticipantType.unit,
          logoAsset: chat.logoAsset.isNotEmpty ? chat.logoAsset : null,
        ),
      ),
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

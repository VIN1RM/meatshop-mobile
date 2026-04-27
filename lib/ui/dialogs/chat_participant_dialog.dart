import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/chat_enums.dart';

class ChatParticipantDialog {
  static Future<ChatParticipantType?> show({
    required BuildContext context,
    required String unitName,
    required String clientName,
  }) {
    return showModalBottomSheet<ChatParticipantType>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) =>
          _ChatParticipantSheet(unitName: unitName, clientName: clientName),
    );
  }
}

class _ChatParticipantSheet extends StatelessWidget {
  const _ChatParticipantSheet({
    required this.unitName,
    required this.clientName,
  });

  final String unitName;
  final String clientName;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Color(0xFF2C2C2C),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(24, 12, 24, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Com quem quer falar?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Escolha o destinatário da conversa',
            style: TextStyle(color: Colors.white38, fontSize: 13),
          ),
          const SizedBox(height: 20),
          _ParticipantTile(
            emoji: ChatParticipantType.unit.icon,
            label: ChatParticipantType.unit.label,
            name: unitName,
            accentColor: const Color(0xFFC0392B),
            onTap: () => Navigator.pop(context, ChatParticipantType.unit),
          ),
          const SizedBox(height: 12),
          _ParticipantTile(
            emoji: ChatParticipantType.client.icon,
            label: ChatParticipantType.client.label,
            name: clientName,
            accentColor: const Color(0xFF27AE60),
            onTap: () => Navigator.pop(context, ChatParticipantType.client),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
        ],
      ),
    );
  }
}

class _ParticipantTile extends StatelessWidget {
  const _ParticipantTile({
    required this.emoji,
    required this.label,
    required this.name,
    required this.accentColor,
    required this.onTap,
  });

  final String emoji;
  final String label;
  final String name;
  final Color accentColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: accentColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: accentColor.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: accentColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1,
                    ),
                  ),
                  Text(
                    name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: accentColor, size: 20),
          ],
        ),
      ),
    );
  }
}

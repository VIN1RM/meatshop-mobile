import 'package:flutter/material.dart';
import '../../../models/support_ticket_model.dart';
import '../../widgets/buttons_widget.dart';

class TicketSummaryCard extends StatelessWidget {
  const TicketSummaryCard({super.key, required this.ticket});
  final SupportTicketModel ticket;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF383838),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .05)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(
              Icons.support_agent_rounded,
              color: Color(0xFFE78176),
              size: 22,
            ),
            const SizedBox(width: 8),
            const Expanded(
              child: Text(
                'ATENDIMENTO',
                style: TextStyle(
                  color: Colors.white54,
                  fontSize: 10,
                  letterSpacing: 1.1,
                ),
              ),
            ),
            _TicketStatus(status: ticket.status),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          ticket.subject,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        if (ticket.contact?.trim().isNotEmpty == true) ...[
          const SizedBox(height: 14),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.contact_mail_outlined,
                color: Colors.white38,
                size: 17,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Contato informado',
                      style: TextStyle(color: Colors.white38, fontSize: 11),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      ticket.contact!,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.4,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ],
    ),
  );
}

class _TicketStatus extends StatelessWidget {
  const _TicketStatus({required this.status});
  final String status;
  String get label => switch (status) {
    'OPEN' => 'Aberto',
    'ANSWERED' => 'Respondido',
    'WAITING_SUPPORT' => 'Com a equipe',
    'WAITING_USER' => 'Sua resposta',
    'CLOSED' => 'Encerrado',
    _ => status,
  };
  Color get tone => switch (status) {
    'WAITING_USER' => const Color(0xFFE8BB73),
    'ANSWERED' => const Color(0xFF8BC3A4),
    'CLOSED' => Colors.white54,
    _ => const Color(0xFFE99C91),
  };
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    decoration: BoxDecoration(
      color: tone.withValues(alpha: .10),
      borderRadius: BorderRadius.circular(8),
    ),
    child: Text(
      label,
      style: TextStyle(color: tone, fontSize: 11, fontWeight: FontWeight.w600),
    ),
  );
}

class TicketMessageBubble extends StatelessWidget {
  const TicketMessageBubble({
    super.key,
    required this.message,
    required this.mine,
  });
  final SupportMessageModel message;
  final bool mine;
  @override
  Widget build(BuildContext context) {
    final local = message.createdAt.toLocal();
    final material = MaterialLocalizations.of(context);
    final timestamp =
        '${material.formatCompactDate(local)} • ${material.formatTimeOfDay(TimeOfDay.fromDateTime(local), alwaysUse24HourFormat: true)}';
    return Padding(
      padding: EdgeInsets.only(
        left: mine ? 20 : 0,
        right: mine ? 0 : 20,
        bottom: 14,
      ),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: mine ? const Color(0xFF423330) : const Color(0xFF383838),
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(mine ? 16 : 4),
            bottomRight: Radius.circular(mine ? 4 : 16),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  mine ? Icons.person_outline : Icons.support_agent,
                  color: const Color(0xFFE99C91),
                  size: 16,
                ),
                const SizedBox(width: 7),
                Expanded(
                  child: Text(
                    mine ? 'Você' : message.senderName ?? 'Mensagem',
                    style: const TextStyle(
                      color: Color(0xFFE8B4AC),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Text(
              message.text.isEmpty ? 'Anexo enviado' : message.text,
              style: const TextStyle(
                color: Colors.white,
                height: 1.6,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 10),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                timestamp,
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 11,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TicketReplyComposer extends StatelessWidget {
  const TicketReplyComposer({
    super.key,
    required this.controller,
    required this.busy,
    required this.onSend,
    this.error,
  });
  final TextEditingController controller;
  final bool busy;
  final VoidCallback onSend;
  final String? error;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: const Color(0xFF383838),
      borderRadius: BorderRadius.circular(18),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const Text(
          'Responder chamado',
          style: TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        const Text(
          'Acrescente informações para ajudar a equipe no atendimento.',
          style: TextStyle(color: Colors.white54, fontSize: 12, height: 1.5),
        ),
        const SizedBox(height: 14),
        TextField(
          controller: controller,
          enabled: !busy,
          maxLength: 2000,
          minLines: 3,
          maxLines: 6,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            height: 1.5,
          ),
          decoration: const InputDecoration(
            labelText: 'Sua resposta',
            hintText: 'Escreva sua mensagem…',
            alignLabelWithHint: true,
            fillColor: Color(0xFF303030),
          ),
        ),
        if (error != null) ...[
          const SizedBox(height: 8),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(
                Icons.info_outline,
                color: Color(0xFFFFA99F),
                size: 18,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  error!,
                  style: const TextStyle(
                    color: Color(0xFFFFC2BA),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ),
            ],
          ),
        ],
        const SizedBox(height: 8),
        ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, value, _) => PrimaryButton(
            label: 'Enviar resposta',
            icon: Icons.send_rounded,
            isLoading: busy,
            onPressed:
                !busy &&
                    value.text.trim().isNotEmpty &&
                    value.text.trim().length <= 2000
                ? onSend
                : null,
          ),
        ),
      ],
    ),
  );
}

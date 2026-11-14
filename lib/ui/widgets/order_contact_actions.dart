import 'chat_participant_avatar.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../core/enums/chat_enums.dart';
import '../../core/network/api_failure.dart';
import '../../core/utils/chat_args.dart';
import '../../data/repositories/realtime_repository.dart';
import '../../models/order_model.dart';
import '../../providers/auth/auth_provider.dart';
import '../../routes/app_routes.dart';

/// Customer entry points use the existing authorized order chat channels.
class OrderContactActions extends StatefulWidget {
  const OrderContactActions({
    super.key,
    required this.order,
    this.dark = true,
    this.compact = false,
  });
  final OrderModel order;
  final bool dark;
  final bool compact;
  @override
  State<OrderContactActions> createState() => _OrderContactActionsState();
}

class _OrderContactActionsState extends State<OrderContactActions> {
  ChatParticipantType? _opening;
  String? _error;
  bool get _hasCourier =>
      !widget.order.isPickup &&
      (widget.order.deliveryPersonId?.isNotEmpty ?? false);

  @override
  void didUpdateWidget(covariant OrderContactActions oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.order.id != widget.order.id ||
        oldWidget.order.deliveryPersonId != widget.order.deliveryPersonId) {
      _error = null;
    }
  }

  Future<void> _open(ChatParticipantType type) async {
    if (_opening != null) return;
    final auth = context.read<AuthProvider>();
    final userId = auth.backendUserId;
    final orderId = int.tryParse(widget.order.id);
    final repository = context.read<BackendRealtimeAccess>().chat;
    if (userId == null || orderId == null || repository == null) {
      setState(
        () => _error =
            'Não foi possível abrir a conversa. Entre novamente e tente outra vez.',
      );
      return;
    }
    final courierId = widget.order.deliveryPersonId;
    final channel = ChatChannel.between(ChatParticipantType.client, type);
    setState(() {
      _opening = type;
      _error = null;
    });
    try {
      final recipient = await repository.participant(orderId, channel);
      if (!mounted ||
          auth.backendUserId != userId ||
          widget.order.id != orderId.toString()) {
        return;
      }
      if (type == ChatParticipantType.delivery &&
          widget.order.deliveryPersonId != courierId) {
        setState(
          () => _error =
              'O entregador mudou. Toque novamente para abrir a conversa atual.',
        );
        return;
      }
      if (recipient.userId.isEmpty || recipient.userId == '0') {
        throw StateError('Missing chat participant');
      }
      await Navigator.of(context).pushNamed(
        AppRoutes.chat,
        arguments: ChatArgs(
          currentUserId: userId.toString(),
          currentUserName: auth.currentUser?.displayName ?? 'Você',
          currentUserPhoto: auth.currentUser?.photoURL,
          currentUserType: ChatParticipantType.client,
          otherUserId: recipient.userId,
          otherUserName: recipient.name,
          otherUserPhoto: recipient.photoUrl,
          otherUserType: type,
          orderId: orderId,
          channel: channel,
          closed: widget.order.isFinished,
        ),
      );
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiFailure
              ? error.message
              : 'Não foi possível abrir a conversa. Toque no contato para tentar novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _opening = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final foreground = widget.dark ? Colors.white : const Color(0xFF262626);
    final muted = widget.dark ? Colors.white70 : const Color(0xFF666666);
    return Container(
      width: double.infinity,
      padding: widget.compact ? EdgeInsets.zero : const EdgeInsets.all(16),
      decoration: widget.compact
          ? null
          : BoxDecoration(
              color: widget.dark
                  ? const Color(0xFF383838)
                  : const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(18),
            ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Conversas do pedido',
            style: TextStyle(
              color: foreground,
              fontWeight: FontWeight.w700,
              fontSize: widget.compact ? 13 : 16,
            ),
          ),
          const SizedBox(height: 10),
          Material(
            color: widget.dark ? const Color(0xFF383838) : Colors.white,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
              side: BorderSide(
                color: widget.dark ? Colors.white12 : const Color(0xFFE6E3E2),
              ),
            ),
            clipBehavior: Clip.antiAlias,
            child: Column(
              children: [
                _contact(
                  ChatParticipantType.unit,
                  widget.order.isFinished
                      ? 'Ver conversa com açougue'
                      : 'Falar com açougue',
                  Icons.storefront_outlined,
                ),
                if (_hasCourier)
                  const Divider(height: 1, indent: 16, endIndent: 16),
                if (_hasCourier)
                  _contact(
                    ChatParticipantType.delivery,
                    widget.order.isFinished
                        ? 'Ver conversa com entregador'
                        : 'Falar com entregador',
                    Icons.delivery_dining,
                  ),
              ],
            ),
          ),
          if (!_hasCourier &&
              !widget.order.isPickup &&
              !widget.order.isFinished) ...[
            const SizedBox(height: 8),
            Text(
              'O contato com o entregador aparece quando ele aceitar a entrega.',
              style: TextStyle(color: muted, fontSize: 12, height: 1.4),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: 8),
            Text(
              _error!,
              style: TextStyle(
                color: widget.dark
                    ? const Color(0xFFFFA99F)
                    : const Color(0xFFB3261E),
                fontSize: 12,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _contact(ChatParticipantType type, String label, IconData icon) {
    final isUnit = type == ChatParticipantType.unit;
    final accent = widget.dark
        ? const Color(0xFFFFA99F)
        : const Color(0xFFC0392B);
    final name = isUnit
        ? widget.order.unitName
        : widget.order.deliveryPersonName;
    return InkWell(
      onTap: _opening == null ? () => _open(type) : null,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          children: [
            ChatParticipantAvatar(
              type: type,
              photoUrl: isUnit ? widget.order.unitLogoUrl : null,
              size: 36,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: widget.dark
                          ? Colors.white
                          : const Color(0xFF292929),
                      fontWeight: FontWeight.w600,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    name?.trim().isNotEmpty == true
                        ? name!
                        : (isUnit
                              ? 'Equipe do açougue'
                              : 'Responsável pela sua entrega'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      color: widget.dark
                          ? Colors.white60
                          : const Color(0xFF777777),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            if (_opening == type)
              SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2, color: accent),
              )
            else
              Icon(
                widget.order.isFinished
                    ? Icons.history_rounded
                    : Icons.chat_bubble_outline_rounded,
                color: accent,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}

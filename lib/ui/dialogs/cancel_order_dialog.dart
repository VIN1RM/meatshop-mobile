import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/order_cancellation_model.dart';

class CancelOrderDialog extends StatefulWidget {
  final VoidCallback? onCancel;
  final void Function(CancellationReason reason)? onConfirm;

  const CancelOrderDialog({super.key, this.onCancel, this.onConfirm});

  @override
  State<CancelOrderDialog> createState() => _CancelOrderDialogState();
}

class _CancelOrderDialogState extends State<CancelOrderDialog> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _surface = Color(0xFF3A3A3A);
  static const Color _bg = Color(0xFF2E2E2E);

  CancellationReason? _selectedReason;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: _bg,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.cancel_outlined, color: _red, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Cancelar pedido',
                      style: TextStyle(
                        color: _white,
                        fontSize: 17,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Selecione o motivo do cancelamento',
                      style: TextStyle(color: Colors.white54, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF3A3020),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: const Color(0xFF7A6030).withValues(alpha: 0.5),
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Icon(Icons.info_outline, color: Color(0xFFFFB800), size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'O cancelamento só é permitido enquanto o pedido ainda não entrou em preparo.',
                    style: TextStyle(
                      color: Color(0xFFDDA060),
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          ...CancellationReason.values.map((reason) {
            final selected = _selectedReason == reason;
            return GestureDetector(
              onTap: () => setState(() => _selectedReason = reason),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 14,
                ),
                decoration: BoxDecoration(
                  color: selected ? _red.withValues(alpha: 0.12) : _surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: selected ? _red : const Color(0xFF555555),
                    width: 1.5,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      reason.icon,
                      color: selected ? _red : Colors.white38,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        reason.label,
                        style: TextStyle(
                          color: selected ? _white : Colors.white70,
                          fontSize: 14,
                          fontWeight: selected
                              ? FontWeight.w700
                              : FontWeight.w400,
                        ),
                      ),
                    ),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selected ? _red : Colors.transparent,
                        border: Border.all(
                          color: selected ? _red : Colors.white38,
                          width: 2,
                        ),
                      ),
                      child: selected
                          ? const Icon(Icons.check, color: _white, size: 12)
                          : null,
                    ),
                  ],
                ),
              ),
            );
          }),

          const SizedBox(height: 8),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white70,
                    side: const BorderSide(color: Color(0xFF555555)),
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Voltar',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: _selectedReason == null
                      ? null
                      : () {
                          Navigator.pop(context);
                          widget.onConfirm?.call(_selectedReason!);
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _red,
                    disabledBackgroundColor: _red.withValues(alpha: 0.3),
                    foregroundColor: _white,
                    minimumSize: const Size(double.infinity, 48),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 0,
                  ),
                  child: Text(
                    _selectedReason == null
                        ? 'Confirmar'
                        : 'Confirmar cancelamento',
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/delivery_enums.dart';

class RejectOrderDialog extends StatefulWidget {
  const RejectOrderDialog({super.key});

  static Future<List<OrderRejectionReason>?> show(BuildContext context) {
    return showDialog<List<OrderRejectionReason>>(
      context: context,
      builder: (_) => const RejectOrderDialog(),
    );
  }

  @override
  State<RejectOrderDialog> createState() => _RejectOrderDialogState();
}

class _RejectOrderDialogState extends State<RejectOrderDialog> {
  final Set<OrderRejectionReason> _selected = {};

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF2C2C2C),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Por que está recusando?',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      ),
      content: SizedBox(
        width: double.maxFinite,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Selecione um ou mais motivos. Isso nos ajuda a melhorar.',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
            const SizedBox(height: 16),
            ...OrderRejectionReason.values.map(
              (reason) => _ReasonTile(
                reason: reason,
                isSelected: _selected.contains(reason),
                onTap: () => setState(() {
                  if (_selected.contains(reason)) {
                    _selected.remove(reason);
                  } else {
                    _selected.add(reason);
                  }
                }),
              ),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white38),
          ),
        ),
        ElevatedButton(
          onPressed: _selected.isEmpty
              ? null
              : () => Navigator.pop(context, _selected.toList()),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFC0392B),
            foregroundColor: Colors.white,
            disabledBackgroundColor: const Color(
              0xFFC0392B,
            ).withValues(alpha: 0.4),
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          child: Text(
            _selected.isEmpty
                ? 'Confirmar recusa'
                : 'Confirmar (${_selected.length})',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }
}

class _ReasonTile extends StatelessWidget {
  const _ReasonTile({
    required this.reason,
    required this.isSelected,
    required this.onTap,
  });

  final OrderRejectionReason reason;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected
              ? const Color(0xFFC0392B).withValues(alpha: 0.15)
              : Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: isSelected
                ? const Color(0xFFC0392B).withValues(alpha: 0.6)
                : Colors.white.withValues(alpha: 0.08),
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(reason.icon, style: const TextStyle(fontSize: 18)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                reason.label,
                style: TextStyle(
                  color: isSelected ? Colors.white : Colors.white70,
                  fontSize: 14,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 180),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: isSelected
                    ? const Color(0xFFC0392B)
                    : Colors.transparent,
                border: Border.all(
                  color: isSelected ? const Color(0xFFC0392B) : Colors.white24,
                  width: 1.5,
                ),
                borderRadius: BorderRadius.circular(4),
              ),
              child: isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';

class DeliveryAvailabilityControl extends StatefulWidget {
  const DeliveryAvailabilityControl({super.key});

  @override
  State<DeliveryAvailabilityControl> createState() =>
      _DeliveryAvailabilityControlState();
}

class _DeliveryAvailabilityControlState
    extends State<DeliveryAvailabilityControl> {
  bool _working = false;

  Future<void> _toggle() async {
    if (_working) return;
    final provider = context.read<DeliveryProvider>();
    setState(() => _working = true);
    try {
      await provider.toggleAvailability();
    } catch (_) {
      if (mounted) {
        CustomSnackBar.error(
          provider.lastError ?? 'Não foi possível alterar sua disponibilidade.',
          context: context,
        );
      }
    } finally {
      if (mounted) setState(() => _working = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();
    final online = provider.isAvailable;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 8, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Icon(
            Icons.circle,
            size: 10,
            color: online ? const Color(0xFF66BB6A) : Colors.white38,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              online ? 'Você está online' : 'Você está offline',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 12),
          FilledButton(
            onPressed: _working ? null : _toggle,
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
            ),
            child: _working
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                : Text(online ? 'Ficar offline' : 'Ficar online'),
          ),
        ],
      ),
    );
  }
}

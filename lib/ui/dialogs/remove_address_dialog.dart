import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/address_model.dart';

class RemoveAddressDialog extends StatelessWidget {
  const RemoveAddressDialog({
    super.key,
    required this.address,
    required this.onConfirm,
  });

  final AddressModel address;
  final VoidCallback onConfirm;

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _background = Color(0xFF2E2E2E);

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: _background,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text(
        'Remover endereço',
        style: TextStyle(
          color: _white,
          fontWeight: FontWeight.bold,
        ),
      ),
      content: Text(
        'Deseja remover "${address.label}"?',
        style: const TextStyle(color: Colors.white70),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancelar',
            style: TextStyle(color: Colors.white54),
          ),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            onConfirm();
          },
          child: const Text(
            'Remover',
            style: TextStyle(color: _red),
          ),
        ),
      ],
    );
  }
}
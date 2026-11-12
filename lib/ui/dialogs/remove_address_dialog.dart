import 'package:meatshop_mobile/core/network/api_failure.dart';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/address_model.dart';

class RemoveAddressDialog extends StatefulWidget {
  const RemoveAddressDialog({
    super.key,
    required this.address,
    required this.onConfirm,
  });

  final AddressModel address;
  final Future<void> Function() onConfirm;

  @override
  State<RemoveAddressDialog> createState() => _RemoveAddressDialogState();
}

class _RemoveAddressDialogState extends State<RemoveAddressDialog> {
  bool _removing = false;
  String? _error;

  Future<void> _confirm() async {
    if (_removing) return;
    setState(() {
      _removing = true;
      _error = null;
    });
    try {
      await widget.onConfirm();
      if (mounted) Navigator.of(context).pop(true);
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiFailure
              ? error.message
              : 'Não foi possível remover o endereço. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _removing = false);
    }
  }

  static const Color _red = Color(0xFFC0392B);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF555555);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_removing,
      child: Dialog(
        backgroundColor: const Color(0xFFF5F5F5),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: _red.withValues(alpha: 0.10),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: _red,
                  size: 28,
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Remover endereço?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w700,
                  color: _dark,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                '"${widget.address.label}" será removido permanentemente da sua lista de endereços.',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  color: _grey,
                  height: 1.5,
                ),
              ),
              if (_error != null) ...[
                const SizedBox(height: 16),
                Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: _red,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: _removing
                          ? null
                          : () => Navigator.of(context).pop(),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: _dark,
                        side: const BorderSide(color: Color(0xFFDDDDDD)),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text(
                        'Cancelar',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _removing ? null : _confirm,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _red,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: _removing
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              'Remover',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

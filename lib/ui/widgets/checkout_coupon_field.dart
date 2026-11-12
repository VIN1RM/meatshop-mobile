import 'package:flutter/material.dart';
import 'buttons_widget.dart';

class CheckoutCouponField extends StatefulWidget {
  const CheckoutCouponField({
    super.key,
    required this.code,
    required this.busy,
    required this.discount,
    required this.onApply,
    required this.onDraftChanged,
    this.error,
  });
  final String? code;
  final String? error;
  final bool busy;
  final double discount;
  final ValueChanged<String> onApply;
  final ValueChanged<bool> onDraftChanged;
  @override
  State<CheckoutCouponField> createState() => _CheckoutCouponFieldState();
}

class _CheckoutCouponFieldState extends State<CheckoutCouponField> {
  late final TextEditingController _controller = TextEditingController(
    text: widget.code,
  );
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _apply() {
    widget.onDraftChanged(false);
    widget.onApply(_controller.text.trim());
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      const SizedBox(height: 16),
      TextField(
        controller: _controller,
        enabled: !widget.busy,
        textCapitalization: TextCapitalization.characters,
        textInputAction: TextInputAction.done,
        onSubmitted: (_) => _apply(),
        onChanged: (value) {
          widget.onDraftChanged(value.trim() != (widget.code ?? ''));
          setState(() {});
        },
        decoration: InputDecoration(
          labelText: 'Cupom de desconto',
          hintText: 'Ex.: BEMVINDO10',
          prefixIcon: const Icon(Icons.local_offer_outlined),
          errorText: widget.error,
          errorMaxLines: 3,
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  tooltip: 'Remover cupom',
                  onPressed: widget.busy
                      ? null
                      : () {
                          _controller.clear();
                          _apply();
                          setState(() {});
                        },
                  icon: const Icon(Icons.close_rounded, size: 18),
                )
              : null,
          helperText: 'O desconto será confirmado antes de finalizar.',
          helperMaxLines: 2,
        ),
      ),
      const SizedBox(height: 10),
      SizedBox(
        width: double.infinity,
        child: OutlinedButton.icon(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.redPrimary,
            side: const BorderSide(color: AppColors.redPrimary),
            minimumSize: const Size(0, 44),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          onPressed: widget.busy ? null : _apply,
          icon: const Icon(Icons.check_circle_outline, size: 18),
          label: Text(
            widget.busy
                ? 'Validando cotação…'
                : _controller.text.trim().isEmpty && widget.code != null
                ? 'Remover cupom'
                : 'Aplicar cupom',
          ),
        ),
      ),
      if (widget.error == null &&
          widget.discount > 0 &&
          _controller.text.trim() == widget.code) ...[
        const SizedBox(height: 10),
        Row(
          children: [
            const Icon(Icons.check_circle, color: Color(0xFF237A45), size: 18),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Cupom aplicado! Desconto de R\$ ${widget.discount.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  color: Color(0xFF237A45),
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ],
      const SizedBox(height: 16),
    ],
  );
}

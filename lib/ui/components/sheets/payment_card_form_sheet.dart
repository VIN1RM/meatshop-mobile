import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PaymentCardData {
  final String holderName;
  final String cardNumber;
  final String expirationMonth;
  final String expirationYear;
  final String cvv;
  final bool isDefault;

  const PaymentCardData({
    required this.holderName,
    required this.cardNumber,
    required this.expirationMonth,
    required this.expirationYear,
    required this.cvv,
    this.isDefault = false,
  });
}

class PaymentCardFormSheet extends StatefulWidget {
  const PaymentCardFormSheet({super.key, required this.onSave});

  final void Function(PaymentCardData) onSave;

  @override
  State<PaymentCardFormSheet> createState() => _PaymentCardFormSheetState();
}

class _PaymentCardFormSheetState extends State<PaymentCardFormSheet> {
  static const Color _white = Colors.white;

  final _formKey = GlobalKey<FormState>();
  final _holderCtrl = TextEditingController();
  final _numberCtrl = TextEditingController();
  final _monthCtrl = TextEditingController();
  final _yearCtrl = TextEditingController();
  final _cvvCtrl = TextEditingController();

  bool _isDefault = false;
  bool _isSaving = false;
  bool _obscureCvv = true;

  @override
  void dispose() {
    _holderCtrl.dispose();
    _numberCtrl.dispose();
    _monthCtrl.dispose();
    _yearCtrl.dispose();
    _cvvCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    if (!mounted) return;

    widget.onSave(
      PaymentCardData(
        holderName: _holderCtrl.text.trim().toUpperCase(),
        cardNumber: _numberCtrl.text.replaceAll(' ', ''),
        expirationMonth: _monthCtrl.text.trim(),
        expirationYear: _yearCtrl.text.trim(),
        cvv: _cvvCtrl.text.trim(),
        isDefault: _isDefault,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return Container(
      constraints: BoxConstraints(
        minHeight: screenH * 0.80,
        maxHeight: screenH * 0.92,
      ),

      decoration: const BoxDecoration(
        color: Color(0xFF232323),
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
      child: Form(
        key: _formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            Flexible(
              child: SingleChildScrollView(
                physics: const ClampingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTitle(),
                    const SizedBox(height: 4),
                    const Text(
                      'Os dados são tokenizados com segurança pelo Mercado Pago.',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 11,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 20),

                    _CardFormField(
                      controller: _holderCtrl,
                      label: 'Nome impresso no cartão',
                      icon: Icons.person_outline,
                      textCapitalization: TextCapitalization.characters,
                      validator: (v) => (v == null || v.trim().isEmpty)
                          ? 'Informe o nome'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    _CardFormField(
                      controller: _numberCtrl,
                      label: 'Número do cartão',
                      icon: Icons.credit_card_outlined,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(16),
                        _CardNumberFormatter(),
                      ],
                      validator: (v) {
                        final digits = v?.replaceAll(' ', '') ?? '';
                        if (digits.length < 13) return 'Número inválido';
                        return null;
                      },
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _CardFormField(
                            controller: _monthCtrl,
                            label: 'Mês (MM)',
                            icon: Icons.calendar_today_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              if (n == null || n < 1 || n > 12) {
                                return 'Mês inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _CardFormField(
                            controller: _yearCtrl,
                            label: 'Ano (AAAA)',
                            icon: Icons.event_outlined,
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            validator: (v) {
                              final n = int.tryParse(v ?? '');
                              final now = DateTime.now().year;
                              if (n == null || n < now || n > now + 20) {
                                return 'Ano inválido';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _CardFormField(
                            controller: _cvvCtrl,
                            label: 'CVV',
                            icon: Icons.lock_outline,
                            keyboardType: TextInputType.number,
                            obscureText: _obscureCvv,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(4),
                            ],
                            suffixIcon: GestureDetector(
                              onTap: () =>
                                  setState(() => _obscureCvv = !_obscureCvv),
                              child: Icon(
                                _obscureCvv
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.white38,
                                size: 18,
                              ),
                            ),
                            validator: (v) => (v == null || v.length < 3)
                                ? 'CVV inválido'
                                : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    _DefaultToggle(
                      value: _isDefault,
                      onToggle: () => setState(() => _isDefault = !_isDefault),
                    ),
                    const SizedBox(height: 24),

                    _SaveCardButton(isSaving: _isSaving, onPressed: _save),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 20),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Colors.white24,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildTitle() {
    return const Text(
      'Adicionar cartão',
      style: TextStyle(
        color: _white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(' ', '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length; i++) {
      if (i > 0 && i % 4 == 0) buffer.write(' ');
      buffer.write(digits[i]);
    }
    final formatted = buffer.toString();
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

class _CardFormField extends StatelessWidget {
  const _CardFormField({
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
    this.inputFormatters,
    this.validator,
    this.obscureText = false,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final bool obscureText;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      inputFormatters: inputFormatters,
      validator: validator,
      obscureText: obscureText,
      textCapitalization: textCapitalization,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: const Color(0xFF3A3A3A),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Color(0xFFC0392B), width: 1.5),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
        ),
        errorStyle: const TextStyle(fontSize: 11),
      ),
    );
  }
}

class _DefaultToggle extends StatelessWidget {
  const _DefaultToggle({required this.value, required this.onToggle});

  final bool value;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFC0392B);
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? red : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: value ? red : Colors.white38, width: 2),
            ),
            child: value
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Definir como cartão padrão',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveCardButton extends StatelessWidget {
  const _SaveCardButton({required this.isSaving, required this.onPressed});

  final bool isSaving;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    const red = Color(0xFFC0392B);
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: red,
          disabledBackgroundColor: red.withValues(alpha: 0.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        child: isSaving
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: Colors.white,
                ),
              )
            : const Text(
                'Adicionar cartão',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

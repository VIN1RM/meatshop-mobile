import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/core/utils/field_validations.dart';
import 'app_dialog.dart';
import '../widgets/buttons_widget.dart';

class DeliveryCodeDialog extends StatefulWidget {
  const DeliveryCodeDialog({super.key});
  static Future<String?> show(BuildContext context) => showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (_) => const DeliveryCodeDialog(),
  );
  @override
  State<DeliveryCodeDialog> createState() => _DeliveryCodeDialogState();
}

class _DeliveryCodeDialogState extends State<DeliveryCodeDialog> {
  final _form = GlobalKey<FormState>();
  final _code = TextEditingController();
  @override
  void dispose() {
    _code.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_form.currentState!.validate()) Navigator.pop(context, _code.text);
  }

  @override
  Widget build(BuildContext context) => AppDialog(
    title: 'Código do cliente',
    icon: Icons.verified_user_outlined,
    description:
        'Após entregar o pedido, peça ao cliente o código de seis dígitos exibido no aplicativo.',
    content: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextFormField(
            controller: _code,
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.done,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            maxLength: 6,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              letterSpacing: 4,
            ),
            decoration: const InputDecoration(
              labelText: 'Código de seis dígitos',
              hintText: '000000',
            ),
            validator: FieldValidations.verificationCode,
            onFieldSubmitted: (_) => _confirm(),
          ),
          const SizedBox(height: 16),
          PrimaryButton(label: 'Confirmar entrega', onPressed: _confirm),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
        ],
      ),
    ),
  );
}

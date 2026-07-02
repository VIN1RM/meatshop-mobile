import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class UserExistsDialog extends StatelessWidget {
  const UserExistsDialog({super.key, required this.field, this.email});

  final String field;
  final String? email;

  static const Color _red = Color(0xFFC0392B);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _grey = Color(0xFF555555);

  bool get _isEmailDuplicate => field == 'email';

  String get _fieldLabel => switch (field) {
    'cpf' => 'CPF',
    'email' => 'e-mail',
    'phone' => 'celular',
    _ => 'dado',
  };
  @override
  Widget build(BuildContext context) {
    return Dialog(
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
                Icons.person_off_outlined,
                color: _red,
                size: 28,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Conta já existe',
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
              'Já existe uma conta cadastrada com esse $_fieldLabel. '
              'Faça login para continuar.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w400,
                color: _grey,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  if (_isEmailDuplicate) {
                    Navigator.of(context).pop();
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      AppRoutes.login,
                      (route) => false,
                      arguments: email,
                    );
                  } else {
                    Navigator.of(context).pop();
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: _red,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  _isEmailDuplicate ? 'Ir para login' : 'OK',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

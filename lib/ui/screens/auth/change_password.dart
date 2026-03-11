import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

class ChangePasswordPage extends StatefulWidget {
  const ChangePasswordPage({super.key});

  @override
  State<ChangePasswordPage> createState() => _ChangePasswordPageState();
}

class _ChangePasswordPageState extends State<ChangePasswordPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _emailController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  bool _obscureNew = true;
  bool _obscureConfirm = true;

  bool _hasMinLength = false;
  bool _hasUpperCase = false;
  bool _hasLowerCase = false;
  bool _hasNumber = false;
  bool _hasSpecialChar = false;

  @override
  void dispose() {
    _emailController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _checkPassword(String value) {
    setState(() {
      _hasMinLength = value.length >= 6;
      _hasUpperCase = RegExp(r'[A-Z]').hasMatch(value);
      _hasLowerCase = RegExp(r'[a-z]').hasMatch(value);
      _hasNumber = RegExp(r'[0-9]').hasMatch(value);
      _hasSpecialChar = RegExp(r'[!@#\$%^&*(),.?":{}|<>]').hasMatch(value);
    });
  }

  String? _validateNewPassword(String? v) {
    if (v == null || v.isEmpty) return 'Informe a nova senha';
    if (!_hasMinLength) return 'Mínimo 6 caracteres';
    if (!_hasUpperCase) return 'Adicione uma letra maiúscula';
    if (!_hasLowerCase) return 'Adicione uma letra minúscula';
    if (!_hasNumber) return 'Adicione um número';
    if (!_hasSpecialChar) return 'Adicione um caractere especial';
    return null;
  }

  void _onChangePassword() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);

    Navigator.of(context).pushReplacementNamed(AppRoutes.login);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;
    final double fontScale = (sw / 390).clamp(0.80, 1.20);

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.04,
                vertical: sh * 0.01,
              ),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(
                      Icons.arrow_back_ios_new,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Alterar Senha',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Crie uma nova senha segura',
                        style: TextStyle(color: Colors.white54, fontSize: 12),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            Container(height: 1, color: Colors.white12),

            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.symmetric(
                  horizontal: sw * 0.06,
                  vertical: sh * 0.03,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Identificação'),
                      SizedBox(height: sh * 0.015),

                      _buildTextField(
                        controller: _emailController,
                        label: 'E-mail cadastrado',
                        hint: 'seu@email.com',
                        icon: Icons.email_outlined,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Informe o e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),

                      SizedBox(height: sh * 0.03),

                      _sectionTitle('Informe a Nova Senha'),
                      SizedBox(height: sh * 0.015),

                      _buildTextField(
                        controller: _newPasswordController,
                        label: 'Nova senha',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscureText: _obscureNew,
                        onChanged: _checkPassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureNew
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black45,
                            size: 20,
                          ),
                          onPressed: () =>
                              setState(() => _obscureNew = !_obscureNew),
                        ),
                        validator: _validateNewPassword,
                      ),

                      SizedBox(height: sh * 0.010),

                      _passwordRequirements(),

                      SizedBox(height: sh * 0.018),

                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar nova senha',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscureText: _obscureConfirm,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscureConfirm
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black45,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscureConfirm = !_obscureConfirm,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) {
                            return 'Confirme a nova senha';
                          }
                          if (v != _newPasswordController.text) {
                            return 'As senhas não coincidem';
                          }
                          return null;
                        },
                      ),

                      SizedBox(height: sh * 0.04),

                      PrimaryButton(
                        label: 'SALVAR NOVA SENHA',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _onChangePassword,
                      ),

                      SizedBox(height: sh * 0.03),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _passwordRequirements() {
    Widget req(String label, bool valid) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 4),
        child: Row(
          children: [
            Icon(
              valid ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 14,
              color: valid ? const Color(0xFF22C55E) : Colors.white38,
            ),
            const SizedBox(width: 6),
            Expanded(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: 12,
                  color: valid ? const Color(0xFF22C55E) : Colors.white54,
                  fontWeight: valid ? FontWeight.w600 : FontWeight.normal,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF525252),
        borderRadius: BorderRadius.circular(10),
        border: const Border(
          left: BorderSide(color: Color(0xFFC0392B), width: 3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'A senha deve conter:',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          req('No mínimo 6 caracteres', _hasMinLength),
          req('Pelo menos uma letra maiúscula (A-Z)', _hasUpperCase),
          req('Pelo menos uma letra minúscula (a-z)', _hasLowerCase),
          req('Pelo menos um número (0-9)', _hasNumber),
          req('Pelo menos um caractere especial (!@#\$%...)', _hasSpecialChar),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Row(
      children: [
        Container(
          width: 3,
          height: 16,
          decoration: BoxDecoration(
            color: const Color(0xFFC0392B),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
      ],
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    IconData? icon,
    bool obscureText = false,
    Widget? suffixIcon,
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          validator: validator,
          onChanged: onChanged,
          style: const TextStyle(color: Colors.black, fontSize: 15),
          cursorColor: const Color(0xFF424242),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.black38, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: const Color(0xFFFFFFFF),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFDDDDDD), width: 1),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 12),
          ),
        ),
      ],
    );
  }
}

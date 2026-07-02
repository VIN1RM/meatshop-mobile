import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/app_version_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/services.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscurePassword = true;
  bool _isLoading = false;

  bool _isGoogleLoading = false;
  bool _isAppleLoading = false;

  bool _emailPrefilled = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_emailPrefilled) {
      final prefilledEmail =
          ModalRoute.of(context)?.settings.arguments as String?;
      if (prefilledEmail != null && prefilledEmail.isNotEmpty) {
        _emailController.text = prefilledEmail;
      }
      _emailPrefilled = true;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    final authProvider = context.read<AuthProvider>();
    await authProvider.login(
      context: context,
      email: _emailController.text,
      password: _passwordController.text,
    );

    if (mounted) setState(() => _isLoading = false);
  }

  void _onGoogleLogin() async {
    setState(() => _isGoogleLoading = true);
    await context.read<AuthProvider>().loginWithGoogle(context);
    if (mounted) setState(() => _isGoogleLoading = false);
  }

  void _onAppleLogin() async {
    setState(() => _isAppleLoading = true);
    await context.read<AuthProvider>().loginWithApple(context);
    if (mounted) setState(() => _isAppleLoading = false);
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
        child: Stack(
          children: [
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Opacity(
                opacity: 0.8,
                child: Image.asset(
                  'assets/images/background.png',
                  fit: BoxFit.fitWidth,
                ),
              ),
            ),

            Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(horizontal: sw * 0.08),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          SizedBox(height: sh * 0.02),

                          Image.asset(
                            'assets/images/logo.png',
                            width: 190,
                            height: 190,
                            fit: BoxFit.contain,
                            errorBuilder: (_, __, ___) => const Icon(
                              Icons.storefront_outlined,
                              color: Color(0xFFC0392B),
                              size: 48,
                            ),
                          ),

                          SizedBox(height: sh * 0.035),

                          _buildTextField(
                            controller: _emailController,
                            label: 'Usuário',
                            hint: 'seu@email.com',
                            keyboardType: TextInputType.emailAddress,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Informe o usuário';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: sh * 0.022),

                          _buildTextField(
                            controller: _passwordController,
                            label: 'Senha',
                            hint: '••••••••',
                            obscureText: _obscurePassword,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                color: Colors.black45,
                                size: 20,
                              ),
                              onPressed: () {
                                setState(
                                  () => _obscurePassword = !_obscurePassword,
                                );
                              },
                            ),
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Informe a senha';
                              }
                              if (v.length < 6) {
                                return 'Mínimo 6 caracteres';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: sh * 0.020),

                          Align(
                            alignment: Alignment.centerLeft,
                            child: GestureDetector(
                              onTap: () => Navigator.of(
                                context,
                              ).pushNamed(AppRoutes.forgotPassword),
                              child: Text(
                                'Esqueceu sua senha?',
                                style: TextStyle(
                                  color: const Color(0xFFFFFFFF),
                                  fontSize: 13 * fontScale,
                                  fontWeight: FontWeight.bold,
                                  decoration: TextDecoration.underline,
                                  decorationColor: const Color(0xFFFFFFFF),
                                ),
                              ),
                            ),
                          ),

                          SizedBox(height: sh * 0.02),

                          PrimaryButton(
                            label: 'ENTRAR',
                            isLoading: _isLoading,
                            onPressed: _isLoading ? null : _onLogin,
                          ),

                          SizedBox(height: sh * 0.03),

                          Row(
                            children: const [
                              Expanded(child: Divider(color: Colors.white24)),
                              Padding(
                                padding: EdgeInsets.symmetric(horizontal: 12),
                                child: Text(
                                  'ou',
                                  style: TextStyle(color: Colors.white54),
                                ),
                              ),
                              Expanded(child: Divider(color: Colors.white24)),
                            ],
                          ),

                          SizedBox(height: sh * 0.025),

                          _SocialButton(
                            label: 'Continuar com Google',
                            icon: Icons.g_mobiledata,
                            isLoading: _isGoogleLoading,
                            onPressed: _isGoogleLoading ? null : _onGoogleLogin,
                          ),

                          SizedBox(height: sh * 0.015),

                          _SocialButton(
                            label: 'Continuar com Apple',
                            icon: Icons.apple,
                            isLoading: _isAppleLoading,
                            onPressed: _isAppleLoading ? null : _onAppleLogin,
                          ),

                          SizedBox(height: sh * 0.02),

                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Não tem uma conta? ',
                                style: TextStyle(
                                  color: const Color.fromARGB(
                                    167,
                                    255,
                                    255,
                                    255,
                                  ),
                                  fontSize: 13 * fontScale,
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.of(
                                  context,
                                ).pushNamed(AppRoutes.selectRegister),
                                child: Text(
                                  'Cadastre-se',
                                  style: TextStyle(
                                    color: const Color(0xFFFFFFFF),
                                    fontSize: 13 * fontScale,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: const Color(0xFFFFFFFF),
                                  ),
                                ),
                              ),
                            ],
                          ),

                          SizedBox(height: sh * 0.02),

                          const Center(child: AppVersionText()),

                          SizedBox(height: sh * 0.02),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    String? hint,
    bool obscureText = false,
    TextInputType? keyboardType,
    Widget? suffixIcon,
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
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(color: Colors.black, fontSize: 15),
          cursorColor: const Color(0xFF424242),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
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

class _SocialButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isLoading;
  final VoidCallback? onPressed;

  const _SocialButton({
    required this.label,
    required this.icon,
    required this.isLoading,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFDDDDDD)),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: isLoading
            ? const SizedBox(
                width: 16,
                height: 16,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Icon(icon, color: Colors.black87),
        label: Text(
          label,
          style: const TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}

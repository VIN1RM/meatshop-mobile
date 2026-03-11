import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/screens/auth/select_register_screen.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  final _zipController = TextEditingController();
  final _streetController = TextEditingController();
  final _numberController = TextEditingController();
  final _neighborhoodController = TextEditingController();
  final _cityController = TextEditingController();
  final _stateController = TextEditingController();

  String? _selectedVehicle;
  final List<String> _vehicles = ['MOTORCYCLE', 'BIKE', 'CAR', 'ON_FOOT'];
  final Map<String, String> _vehicleLabels = {
    'MOTORCYCLE': 'Moto',
    'BIKE': 'Bicicleta',
    'CAR': 'Carro',
    'ON_FOOT': 'A pé',
  };
  final Map<String, IconData> _vehicleIcons = {
    'MOTORCYCLE': Icons.two_wheeler,
    'BIKE': Icons.directions_bike,
    'CAR': Icons.directions_car,
    'ON_FOOT': Icons.directions_walk,
  };

  bool _obscurePassword = true;
  bool _obscureConfirm = true;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _zipController.dispose();
    _streetController.dispose();
    _numberController.dispose();
    _neighborhoodController.dispose();
    _cityController.dispose();
    _stateController.dispose();
    super.dispose();
  }

  void _onRegister() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    if (!mounted) return;
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final type =
        ModalRoute.of(context)?.settings.arguments as RegisterType? ??
        RegisterType.client;

    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;
    final double fontScale = (sw / 390).clamp(0.80, 1.20);

    final isClient = type == RegisterType.client;

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: sw * 0.06,
                vertical: sh * 0.02,
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isClient
                          ? const Color(0xFFC0392B).withOpacity(0.15)
                          : const Color(0xFFC0392B).withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFC0392B).withOpacity(0.4),
                      ),
                    ),
                    child: Icon(
                      isClient
                          ? Icons.shopping_bag_outlined
                          : Icons.delivery_dining_outlined,
                      color: const Color(0xFFC0392B),
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        isClient
                            ? 'Cadastro de Cliente'
                            : 'Cadastro de Entregador',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 17 * fontScale,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        isClient
                            ? 'Preencha seus dados para começar'
                            : 'Preencha seus dados para entregar',
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 12,
                        ),
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
                  vertical: sh * 0.025,
                ),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _sectionTitle('Dados Pessoais'),
                      SizedBox(height: sh * 0.015),

                      _buildTextField(
                        controller: _nameController,
                        label: 'Nome completo',
                        hint: 'João da Silva',
                        icon: Icons.person_outline,
                        validator: (v) => v == null || v.trim().isEmpty
                            ? 'Informe o nome'
                            : null,
                      ),

                      SizedBox(height: sh * 0.018),

                      _buildTextField(
                        controller: _emailController,
                        label: 'E-mail',
                        hint: 'seu@email.com',
                        icon: Icons.email_outlined,
                        keyboardType: TextInputType.emailAddress,
                        validator: (v) {
                          if (v == null || v.trim().isEmpty)
                            return 'Informe o e-mail';
                          if (!v.contains('@')) return 'E-mail inválido';
                          return null;
                        },
                      ),

                      SizedBox(height: sh * 0.018),

                      _buildTextField(
                        controller: _cpfController,
                        label: 'CPF',
                        hint: '000.000.000-00',
                        icon: Icons.badge_outlined,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(11),
                        ],
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe o CPF';
                          if (v.length < 11) return 'CPF inválido';
                          return null;
                        },
                      ),

                      SizedBox(height: sh * 0.018),

                      _buildTextField(
                        controller: _passwordController,
                        label: 'Senha',
                        hint: '••••••••',
                        icon: Icons.lock_outline,
                        obscureText: _obscurePassword,
                        suffixIcon: IconButton(
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_off_outlined
                                : Icons.visibility_outlined,
                            color: Colors.black45,
                            size: 20,
                          ),
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                        ),
                        validator: (v) {
                          if (v == null || v.isEmpty) return 'Informe a senha';
                          if (v.length < 6) return 'Mínimo 6 caracteres';
                          return null;
                        },
                      ),

                      SizedBox(height: sh * 0.018),

                      _buildTextField(
                        controller: _confirmPasswordController,
                        label: 'Confirmar senha',
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
                          if (v == null || v.isEmpty) return 'Confirme a senha';
                          if (v != _passwordController.text)
                            return 'As senhas não coincidem';
                          return null;
                        },
                      ),

                      SizedBox(height: sh * 0.03),

                      if (isClient) ...[
                        _sectionTitle('Endereço'),
                        SizedBox(height: sh * 0.015),

                        _buildTextField(
                          controller: _zipController,
                          label: 'CEP',
                          hint: '00000-000',
                          icon: Icons.location_on_outlined,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                            LengthLimitingTextInputFormatter(8),
                          ],
                          validator: (v) {
                            if (v == null || v.isEmpty) return 'Informe o CEP';
                            if (v.length < 8) return 'CEP inválido';
                            return null;
                          },
                        ),

                        SizedBox(height: sh * 0.018),

                        _buildTextField(
                          controller: _streetController,
                          label: 'Rua',
                          hint: 'Rua das Flores',
                          icon: Icons.signpost_outlined,
                          validator: (v) =>
                              v == null || v.isEmpty ? 'Informe a rua' : null,
                        ),

                        SizedBox(height: sh * 0.018),

                        Row(
                          children: [
                            SizedBox(
                              width: sw * 0.25,
                              child: _buildTextField(
                                controller: _numberController,
                                label: 'Número',
                                hint: '123',
                                icon: Icons.tag,
                                keyboardType: TextInputType.number,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Obrigatório'
                                    : null,
                              ),
                            ),
                            SizedBox(width: sw * 0.04),
                            Expanded(
                              child: _buildTextField(
                                controller: _neighborhoodController,
                                label: 'Bairro',
                                hint: 'Centro',
                                icon: Icons.map_outlined,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Informe o bairro'
                                    : null,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: sh * 0.018),

                        Row(
                          children: [
                            Expanded(
                              child: _buildTextField(
                                controller: _cityController,
                                label: 'Cidade',
                                hint: 'São Paulo',
                                icon: Icons.location_city_outlined,
                                validator: (v) => v == null || v.isEmpty
                                    ? 'Informe a cidade'
                                    : null,
                              ),
                            ),
                            SizedBox(width: sw * 0.04),
                            SizedBox(
                              width: sw * 0.22,
                              child: _buildTextField(
                                controller: _stateController,
                                label: 'UF',
                                hint: 'SP',
                                icon: Icons.flag_outlined,
                                inputFormatters: [
                                  LengthLimitingTextInputFormatter(2),
                                  UpperCaseTextFormatter(),
                                ],
                                validator: (v) =>
                                    v == null || v.isEmpty ? 'UF' : null,
                              ),
                            ),
                          ],
                        ),

                        SizedBox(height: sh * 0.03),
                      ],

                      if (!isClient) ...[
                        _sectionTitle('Tipo de Veículo'),
                        SizedBox(height: sh * 0.015),

                        GridView.count(
                          crossAxisCount: 2,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          crossAxisSpacing: 12,
                          mainAxisSpacing: 12,
                          childAspectRatio: 2.2,
                          children: _vehicles.map((v) {
                            final selected = _selectedVehicle == v;
                            return GestureDetector(
                              onTap: () => setState(() => _selectedVehicle = v),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 200),
                                decoration: BoxDecoration(
                                  color: selected
                                      ? const Color(
                                          0xFFC0392B,
                                        ).withOpacity(0.15)
                                      : const Color(0xFF525252),
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(
                                    color: selected
                                        ? const Color(0xFFC0392B)
                                        : Colors.transparent,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      _vehicleIcons[v],
                                      color: selected
                                          ? const Color(0xFFC0392B)
                                          : Colors.white60,
                                      size: 22,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      _vehicleLabels[v]!,
                                      style: TextStyle(
                                        color: selected
                                            ? const Color(0xFFC0392B)
                                            : Colors.white60,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 14,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }).toList(),
                        ),

                        if (_selectedVehicle == null && _isLoading)
                          const Padding(
                            padding: EdgeInsets.only(top: 6),
                            child: Text(
                              'Selecione um veículo',
                              style: TextStyle(
                                color: Colors.redAccent,
                                fontSize: 12,
                              ),
                            ),
                          ),

                        SizedBox(height: sh * 0.03),
                      ],

                      PrimaryButton(
                        label: 'CADASTRAR',
                        isLoading: _isLoading,
                        onPressed: _isLoading ? null : _onRegister,
                      ),

                      SizedBox(height: sh * 0.025),

                      Center(
                        child: GestureDetector(
                          onTap: () => Navigator.of(
                            context,
                          ).pushReplacementNamed(AppRoutes.login),
                          child: RichText(
                            text: TextSpan(
                              style: TextStyle(fontSize: 13 * fontScale),
                              children: const [
                                TextSpan(
                                  text: 'Já tem uma conta? ',
                                  style: TextStyle(color: Colors.white54),
                                ),
                                TextSpan(
                                  text: 'Entrar',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    decoration: TextDecoration.underline,
                                    decorationColor: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
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
    TextInputType? keyboardType,
    Widget? suffixIcon,
    List<TextInputFormatter>? inputFormatters,
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
          inputFormatters: inputFormatters,
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

class UpperCaseTextFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    return newValue.copyWith(text: newValue.text.toUpperCase());
  }
}

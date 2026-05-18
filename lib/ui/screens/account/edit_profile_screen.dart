import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/ui/components/sheets/avatar_picker_sheet.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/providers/user_provider.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  static const Color _red = Color(0xFFC0392B);

  final _formKey = GlobalKey<FormState>();
  bool _isSaving = false;
  File? _avatarFile;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final user = context.read<UserProvider>().user;
      if (user != null) {
        _nameController.text = user.name;
        _emailController.text = user.email;
        _cpfController.text = _maskCpf(user.cpf);
        _phoneController.text = user.phone;
      }
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  String _maskCpf(String cpf) {
    final digits = cpf.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 11) return cpf;
    return '${digits.substring(0, 3)}.${digits.substring(3, 6)}.${digits.substring(6, 9)}-${digits.substring(9)}';
  }

  Future<void> _pickAvatar() async {
    final file = await AvatarPickerSheet.show(
      context,
      hasPhoto:
          _avatarFile != null ||
          (context.read<UserProvider>().user?.photoUrl.isNotEmpty ?? false),
      onRemove: () => setState(() => _avatarFile = null),
    );
    if (file != null) setState(() => _avatarFile = file);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);

    try {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid == null) return;

      await context.read<UserProvider>().updateUser(
        uid: uid,
        name: _nameController.text,
        email: _emailController.text,
        phone: _phoneController.text,
      );
      if (_avatarFile != null) {
        await context.read<UserProvider>().updateAvatar(uid, _avatarFile!);
      }
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Dados atualizados com sucesso!'),
          backgroundColor: Color(0xFF22C55E),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Erro ao salvar. Tente novamente.'),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sw = size.width;
    final sh = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      appBar: null,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 130,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: sw * 0.06,
                      vertical: sh * 0.025,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _AvatarSection(
                            avatarFile: _avatarFile,
                            currentPhotoUrl: context
                                .watch<UserProvider>()
                                .user
                                ?.photoUrl,
                            onTap: _pickAvatar,
                          ),
                          SizedBox(height: sh * 0.035),

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
                            controller: _phoneController,
                            label: 'Celular',
                            hint: '(00) 0 0000-0000',
                            icon: Icons.phone_outlined,
                            keyboardType: TextInputType.phone,
                            inputFormatters: [_PhoneFormatter()],
                            validator: (v) {
                              if (v == null || v.isEmpty)
                                return 'Informe o celular';
                              if (v.replaceAll(RegExp(r'\D'), '').length < 11) {
                                return 'Celular inválido';
                              }
                              return null;
                            },
                          ),

                          SizedBox(height: sh * 0.018),

                          _buildTextField(
                            controller: _cpfController,
                            label: 'CPF',
                            hint: '',
                            icon: Icons.badge_outlined,
                            enabled: false,
                          ),

                          SizedBox(height: sh * 0.10),

                          SizedBox(
                            width: double.infinity,
                            height: 54,
                            child: ElevatedButton(
                              onPressed: _isSaving ? null : _save,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _red,
                                foregroundColor: Colors.white,
                                disabledBackgroundColor: _red.withOpacity(0.4),
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: _isSaving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        color: Colors.white,
                                      ),
                                    )
                                  : const Text(
                                      'SALVAR ALTERAÇÕES',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing: 1.5,
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
            color: _red,
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
    ValueChanged<String>? onChanged,
    String? Function(String?)? validator,
    bool enabled = true,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            color: enabled ? Colors.white : Colors.white38,
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
          onChanged: onChanged,
          enabled: enabled,
          style: TextStyle(
            color: enabled ? Colors.black : Colors.black45,
            fontSize: 15,
          ),
          cursorColor: const Color(0xFF424242),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.black38, fontSize: 14),
            prefixIcon: icon != null
                ? Icon(icon, color: Colors.black38, size: 20)
                : null,
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: enabled
                ? const Color(0xFFFFFFFF)
                : const Color(0xFFDDDDDD),
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
            disabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFCCCCCC), width: 1),
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

class _AvatarSection extends StatelessWidget {
  const _AvatarSection({
    required this.avatarFile,
    required this.onTap,
    this.currentPhotoUrl,
  });

  final File? avatarFile;
  final String? currentPhotoUrl;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final hasNetworkPhoto =
        currentPhotoUrl != null && currentPhotoUrl!.isNotEmpty;

    return Center(
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          children: [
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF525252),
                border: Border.all(color: const Color(0xFF666666), width: 2),
                image: avatarFile != null
                    ? DecorationImage(
                        image: FileImage(avatarFile!),
                        fit: BoxFit.cover,
                      )
                    : hasNetworkPhoto
                    ? DecorationImage(
                        image: NetworkImage(currentPhotoUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              child: (avatarFile == null && !hasNetworkPhoto)
                  ? const Icon(Icons.person, color: Colors.white38, size: 52)
                  : null,
            ),
            Positioned(
              bottom: 0,
              right: 0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFC0392B),
                  shape: BoxShape.circle,
                  border: Border.all(color: const Color(0xFF424242), width: 2),
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 15,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PhoneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final buffer = StringBuffer();
    for (int i = 0; i < digits.length && i < 11; i++) {
      if (i == 0) buffer.write('(');
      if (i == 2) buffer.write(') ');
      if (i == 7) buffer.write('-');
      buffer.write(digits[i]);
    }
    final text = buffer.toString();
    return newValue.copyWith(
      text: text,
      selection: TextSelection.collapsed(offset: text.length),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/input_masks.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/ui/components/sheets/vehicle_edit_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/ui/components/sheets/address_form_sheet.dart';
import 'package:meatshop_mobile/services/auth_service.dart';

class CompleteProfileScreen extends StatefulWidget {
  const CompleteProfileScreen({super.key});

  @override
  State<CompleteProfileScreen> createState() => _CompleteProfileScreenState();
}

class _CompleteProfileScreenState extends State<CompleteProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _cpfController = TextEditingController();
  final _phoneController = TextEditingController();

  AppProfile? _selectedProfile;
  Map<String, dynamic>? _vehicleData;
  String? _selectedVehicle;
  AddressModel? _addressData;

  bool _isLoading = false;

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

  @override
  void dispose() {
    _nameController.dispose();
    _cpfController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _onSubmit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_selectedProfile == null) {
      CustomSnackBar.warning(
        'Selecione um tipo de perfil para continuar.',
        context: context,
      );
      return;
    }

    if (_selectedProfile != AppProfile.client && _vehicleData == null) {
      CustomSnackBar.warning(
        'Preencha os dados do veículo para continuar.',
        context: context,
      );
      return;
    }

    if (_selectedProfile == AppProfile.client && _addressData == null) {
      CustomSnackBar.warning(
        'Preencha seu endereço para continuar.',
        context: context,
      );
      return;
    }
    setState(() => _isLoading = true);

    final cpfOk = await AuthService.instance.isCpfAvailable(
      _cpfController.text,
    );
    if (!cpfOk) {
      setState(() => _isLoading = false);
      CustomSnackBar.warning(
        'Este CPF já está sendo utilizado por outra conta.',
        context: context,
      );
      return;
    }

    final phoneOk = await AuthService.instance.isPhoneAvailable(
      _phoneController.text,
    );
    if (!phoneOk) {
      setState(() => _isLoading = false);
      CustomSnackBar.warning(
        'Este celular já está sendo utilizado por outra conta.',
        context: context,
      );
      return;
    }

    try {
      await context.read<AuthProvider>().completeProfileWithType(
        context: context,
        name: _nameController.text.trim(),
        cpf: _cpfController.text,
        phone: _phoneController.text,
        profile: _selectedProfile!,
        vehicleType: _selectedVehicle,
        vehicleData: _vehicleData,
        addressData: _addressData,
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final sh = size.height;

    return Scaffold(
      backgroundColor: const Color(0xFF424242),
      body: SafeArea(
        child: Column(
          children: [
            _buildTopBar(),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHero(),
                      SizedBox(height: sh * 0.03),
                      _buildCard(),
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

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.arrow_back_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
          const SizedBox(width: 12),
          const Text(
            'Complete seu perfil',
            style: TextStyle(
              color: Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHero() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(4, 24, 4, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFC0392B).withOpacity(0.15),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: const Color(0xFFC0392B).withOpacity(0.3),
              ),
            ),
            child: const Icon(
              Icons.verified_user_outlined,
              color: Color(0xFFC0392B),
              size: 22,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Falta pouco!',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Precisamos de mais alguns dados para continuar',
            style: TextStyle(color: Colors.white, fontSize: 12, height: 1.5),
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoBanner(),
          const SizedBox(height: 20),

          _buildSectionTitle('Tipo de Perfil'),
          const SizedBox(height: 14),
          _buildProfileSelection(),

          if (_selectedProfile != null) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Dados Pessoais'),
            const SizedBox(height: 14),
            _buildField(
              label: 'Nome completo',
              controller: _nameController,
              hint: 'Seu nome',
              icon: Icons.person_outline,
              validator: (v) {
                if (v == null || v.trim().isEmpty) return 'Informe o nome';
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildField(
              label: 'CPF',
              controller: _cpfController,
              hint: '000.000.000-00',
              icon: Icons.badge_outlined,
              keyboardType: TextInputType.number,
              formatters: [CpfInputFormatter()],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o CPF';
                if (v.replaceAll(RegExp(r'\D'), '').length < 11) {
                  return 'CPF inválido';
                }
                return null;
              },
            ),
            const SizedBox(height: 12),
            _buildField(
              label: 'Celular',
              controller: _phoneController,
              hint: '(00) 0 0000-0000',
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
              formatters: [PhoneInputFormatter()],
              validator: (v) {
                if (v == null || v.isEmpty) return 'Informe o celular';
                if (v.replaceAll(RegExp(r'\D'), '').length < 11) {
                  return 'Celular inválido';
                }
                return null;
              },
            ),
          ],

          if (_selectedProfile == AppProfile.client) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Endereço'),
            const SizedBox(height: 14),
            _buildAddressCard(),
          ],

          if (_selectedProfile == AppProfile.delivery ||
              _selectedProfile == AppProfile.both) ...[
            const SizedBox(height: 20),
            _buildSectionTitle('Tipo de Veículo'),
            const SizedBox(height: 14),
            _buildVehicleSelection(),
          ],

          const SizedBox(height: 24),
          const Divider(color: Colors.white10, height: 1),
          const SizedBox(height: 20),
          PrimaryButton(
            label: 'CONTINUAR',
            isLoading: _isLoading,
            onPressed: _isLoading ? null : _onSubmit,
          ),
        ],
      ),
    );
  }

  Widget _buildInfoBanner() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: const Color(0xFFC0392B).withOpacity(0.08),
        borderRadius: BorderRadius.circular(8),
        border: const Border(
          left: BorderSide(color: Color(0xFFC0392B), width: 2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: const [
          Icon(Icons.info_outline_rounded, color: Color(0xFFC0392B), size: 14),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'Seus dados são usados apenas para identificação e nunca compartilhados.',
              style: TextStyle(
                color: Color.fromARGB(255, 255, 255, 255),
                fontSize: 11,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
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

  Widget _buildProfileSelection() {
    return Column(
      children: [
        _buildProfileCard(
          AppProfile.client,
          'Cliente',
          'Compre cortes frescos dos melhores açougues.',
          Icons.shopping_bag_outlined,
        ),
        const SizedBox(height: 10),
        _buildProfileCard(
          AppProfile.delivery,
          'Entregador',
          'Faça entregas e ganhe dinheiro no seu horário.',
          Icons.delivery_dining_outlined,
        ),
        const SizedBox(height: 10),
        _buildProfileCard(
          AppProfile.both,
          'Cliente & Entregador',
          'Peça e entregue com o mesmo perfil.',
          Icons.people_outline,
        ),
      ],
    );
  }

  Widget _buildProfileCard(
    AppProfile profile,
    String title,
    String desc,
    IconData icon,
  ) {
    final selected = _selectedProfile == profile;
    return GestureDetector(
      onTap: () => setState(() {
        _selectedProfile = profile;
        if (profile == AppProfile.client) {
          _selectedVehicle = null;
          _vehicleData = null;
        }
      }),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFC0392B).withOpacity(0.15)
              : const Color(0xFF525252),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: selected ? const Color(0xFFC0392B) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFC0392B).withOpacity(0.2)
                    : const Color(0xFF3A3A3A),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: selected ? const Color(0xFFC0392B) : Colors.white38,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: selected ? const Color(0xFFC0392B) : Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    desc,
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? const Color(0xFFC0392B) : Colors.transparent,
                border: Border.all(
                  color: selected ? const Color(0xFFC0392B) : Colors.white30,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check, color: Colors.white, size: 12)
                  : null,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVehicleSelection() {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 2,
      children: _vehicles.map((v) {
        final selected = _selectedVehicle == v;
        return GestureDetector(
          onTap: () async {
            final result = await showModalBottomSheet<Map<String, dynamic>>(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => VehicleEditModal(vehicleType: v),
            );
            if (result != null) {
              setState(() {
                _selectedVehicle = v;
                _vehicleData = result;
              });
            }
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              color: selected
                  ? const Color(0xFFC0392B).withOpacity(0.15)
                  : const Color(0xFF525252),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: selected ? const Color(0xFFC0392B) : Colors.transparent,
                width: 1.5,
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  _vehicleIcons[v],
                  color: selected ? const Color(0xFFC0392B) : Colors.white60,
                  size: 20,
                ),
                const SizedBox(width: 6),
                Text(
                  _vehicleLabels[v]!,
                  style: TextStyle(
                    color: selected ? const Color(0xFFC0392B) : Colors.white60,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildAddressCard() {
    final hasAddress = _addressData != null;
    return GestureDetector(
      onTap: () async {
        await showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          backgroundColor: Colors.transparent,
          builder: (_) => AddressFormSheet(
            address: _addressData,
            onSave: (address) async {
              setState(() => _addressData = address);
            },
          ),
        );
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: hasAddress
              ? const Color(0xFFC0392B).withValues(alpha: 0.15)
              : const Color(0xFF525252),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: hasAddress ? const Color(0xFFC0392B) : Colors.transparent,
            width: 1.5,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.location_on_outlined,
              color: hasAddress ? const Color(0xFFC0392B) : Colors.white38,
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                hasAddress
                    ? _addressData!.fullAddress
                    : 'Toque para adicionar seu endereço',
                style: TextStyle(
                  color: hasAddress ? Colors.white : Colors.white54,
                  fontSize: 13,
                ),
              ),
            ),
            Icon(
              hasAddress ? Icons.edit_outlined : Icons.add,
              color: Colors.white38,
              size: 18,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField({
    required String label,
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    List<dynamic>? formatters,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: Colors.white54,
            fontSize: 11,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.5,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          inputFormatters: formatters?.cast(),
          validator: validator,
          style: const TextStyle(color: Colors.white, fontSize: 14),
          cursorColor: const Color(0xFFC0392B),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Colors.white24, fontSize: 13),
            prefixIcon: Icon(icon, color: Colors.white30, size: 18),
            filled: true,
            fillColor: Colors.white.withOpacity(0.07),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.white12),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(
                color: Color(0xFFC0392B),
                width: 1.2,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
            ),
            errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 11),
          ),
        ),
      ],
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/models/address_model.dart';
import 'package:meatshop_mobile/ui/components/sheets/address_form_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

class SavedAddressesScreen extends StatefulWidget {
  const SavedAddressesScreen({super.key});

  @override
  State<SavedAddressesScreen> createState() => _SavedAddressesScreenState();
}

class _SavedAddressesScreenState extends State<SavedAddressesScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _surface = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  List<AddressModel> _addresses = [
    const AddressModel(
      id: 1,
      label: 'Casa',
      street: 'Avenida Rodovanio Rodovalho',
      number: '17',
      complement: 'Casa cinza',
      neighborhood: 'Bairro Eldorado',
      city: 'Anápolis',
      state: 'GO',
      zipCode: '75113-460',
      isDefault: true,
    ),
    const AddressModel(
      id: 2,
      label: 'Trabalho',
      street: 'Rua Ângelo Teles',
      number: 'SN',
      complement: '',
      neighborhood: 'Centro',
      city: 'Anápolis',
      state: 'GO',
      zipCode: '75113-300',
      isDefault: false,
    ),
  ];

  void _setDefault(int id) {
    setState(() {
      _addresses = _addresses
          .map(
            (a) => AddressModel(
              id: a.id,
              label: a.label,
              street: a.street,
              number: a.number,
              complement: a.complement,
              neighborhood: a.neighborhood,
              city: a.city,
              state: a.state,
              zipCode: a.zipCode,
              isDefault: a.id == id,
            ),
          )
          .toList();
    });
  }

  void _deleteAddress(int id) {
    setState(() {
      _addresses.removeWhere((a) => a.id == id);
    });
  }

  void _openAddressSheet({AddressModel? address}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      useRootNavigator: true,
      builder: (_) => AddressFormSheet(
        address: address,
        onSave: (newAddress) {
          setState(() {
            if (newAddress.isDefault) {
              _addresses = _addresses
                  .map((a) => a.copyWith(isDefault: false))
                  .toList();
            }
            if (address != null) {
              final idx = _addresses.indexWhere((a) => a.id == address.id);
              if (idx != -1) _addresses[idx] = newAddress;
            } else {
              _addresses.add(
                newAddress.copyWith(id: DateTime.now().millisecondsSinceEpoch),
              );
            }
          });
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _dark,
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
                _Header(onBack: () => Navigator.pop(context)),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        const _SectionTitle('ENDEREÇOS SALVOS'),
                        const SizedBox(height: 6),
                        const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 16),
                          child: Text(
                            'Gerencie os seus endereços de entrega.',
                            style: TextStyle(
                              color: Colors.white54,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),
                        if (_addresses.isEmpty)
                          const _EmptyState()
                        else
                          ..._addresses.map(
                            (a) => _AddressCard(
                              address: a,
                              onSetDefault: () => _setDefault(a.id),
                              onEdit: () => _openAddressSheet(address: a),
                              onDelete: () => _confirmDelete(a),
                            ),
                          ),
                        const SizedBox(height: 24),
                        _AddNewButton(onTap: () => _openAddressSheet()),
                        const SizedBox(height: 32),
                      ],
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

  void _confirmDelete(AddressModel address) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: _surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Remover endereço',
          style: TextStyle(color: _white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'Deseja remover "${address.label}"?',
          style: const TextStyle(color: Colors.white70),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white54),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteAddress(address.id);
            },
            child: const Text('Remover', style: TextStyle(color: _red)),
          ),
        ],
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onBack});

  final VoidCallback onBack;

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                border: Border.all(color: _white, width: 1.5),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.arrow_back, color: _white, size: 20),
            ),
          ),
          const SizedBox(width: 10),
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MeatShop',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Color(0xFFC0392B),
          fontSize: 20,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _AddressCard extends StatelessWidget {
  const _AddressCard({
    required this.address,
    required this.onSetDefault,
    required this.onEdit,
    required this.onDelete,
  });

  final AddressModel address;
  final VoidCallback onSetDefault;
  final VoidCallback onEdit;
  final VoidCallback onDelete;

  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFF2E2E2E);
  static const Color _white = Colors.white;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(14),
        border: address.isDefault ? Border.all(color: _red, width: 1.5) : null,
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                GestureDetector(
                  onTap: onSetDefault,
                  child: Container(
                    width: 22,
                    height: 22,
                    margin: const EdgeInsets.only(top: 2, right: 12),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: address.isDefault ? _red : Colors.white38,
                        width: 2,
                      ),
                    ),
                    child: address.isDefault
                        ? Center(
                            child: Container(
                              width: 10,
                              height: 10,
                              decoration: const BoxDecoration(
                                shape: BoxShape.circle,
                                color: _red,
                              ),
                            ),
                          )
                        : null,
                  ),
                ),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text(
                            address.label,
                            style: const TextStyle(
                              color: _white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          if (address.isDefault) ...[
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: _red.withValues(alpha: 0.15),

                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                'Padrão',
                                style: TextStyle(
                                  color: _red,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        address.fullAddress,
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 13,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        address.formattedZip,
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFF3A3A3A)),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                if (!address.isDefault) ...[
                  _ActionButton(
                    label: 'Definir como padrão',
                    icon: Icons.check_circle_outline,
                    color: Colors.white54,
                    onTap: onSetDefault,
                  ),
                  const Spacer(),
                ] else
                  const Spacer(),
                _ActionButton(
                  label: 'Editar',
                  icon: Icons.edit_outlined,
                  color: Colors.white54,
                  onTap: onEdit,
                ),
                const SizedBox(width: 16),
                _ActionButton(
                  label: 'Remover',
                  icon: Icons.delete_outline,
                  color: _red,
                  onTap: onDelete,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  const _ActionButton({
    required this.label,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 15),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _AddNewButton extends StatelessWidget {
  const _AddNewButton({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: PrimaryButton(
        label: 'Adicionar novo endereço',
        icon: Icons.add_location_alt_outlined,
        onPressed: onTap,
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Center(
        child: Column(
          children: [
            Icon(Icons.location_off_outlined, color: Colors.white24, size: 56),
            SizedBox(height: 12),
            Text(
              'Nenhum endereço salvo ainda.',
              style: TextStyle(color: Colors.white38, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}

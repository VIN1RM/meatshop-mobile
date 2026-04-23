import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:meatshop_mobile/ui/dialogs/image_source_dialog.dart';

class VehicleEditModal extends StatefulWidget {
  const VehicleEditModal({super.key});

  @override
  State<VehicleEditModal> createState() => _VehicleEditModalState();
}

class _VehicleEditModalState extends State<VehicleEditModal> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  final _formKey = GlobalKey<FormState>();

  late TextEditingController _plateController;
  late TextEditingController _modelController;
  late TextEditingController _colorController;
  late TextEditingController _yearController;

  _VehicleOption? _selectedVehicleType;
  bool _isSaving = false;
  final List<String> _vehicleImages = [];

  final List<_VehicleOption> _vehicleTypes = const [
    _VehicleOption(
      label: 'Carro',
      icon: Icons.directions_car_outlined,
      description: 'Permitido na plataforma para volumes maiores.',
      fields: ['Modelo', 'Placa', 'Cor', 'Ano'],
    ),
    _VehicleOption(
      label: 'Moto',
      icon: Icons.two_wheeler_outlined,
      description: 'Mais ágil, ideal para longas distâncias.',
      fields: ['Modelo', 'Placa', 'Cor', 'Ano'],
    ),
    _VehicleOption(
      label: 'Bicicleta',
      icon: Icons.pedal_bike_outlined,
      description: 'Convencional ou elétrica, ideal para centros urbanos.',
      fields: ['Modelo', 'Cor'],
    ),
    _VehicleOption(
      label: 'Patinete',
      icon: Icons.electric_scooter_outlined,
      description: 'Ideal para regiões planas e áreas centrais.',
      fields: ['Modelo', 'Cor'],
    ),
  ];

  @override
  void initState() {
    super.initState();
    _selectedVehicleType = null;
    _plateController = TextEditingController();
    _modelController = TextEditingController();
    _colorController = TextEditingController();
    _yearController = TextEditingController();
  }

  @override
  void dispose() {
    _plateController.dispose();
    _modelController.dispose();
    _colorController.dispose();
    _yearController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    if (_vehicleImages.length >= 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de 3 fotos permitidas.'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    // Abre o dialog de seleção
    final source = await showDialog<ImageSource>(
      context: context,
      builder: (ctx) => const ImageSourceDialog(),
    );

    if (source == null || !mounted) return;

    final picker = ImagePicker();
    final XFile? picked = await picker.pickImage(
      source: source,
      imageQuality: 80,
      maxWidth: 1080,
    );

    if (picked != null && mounted) {
      setState(() => _vehicleImages.add(picked.path));
    }
  }

  void _removeImage(int index) {
    setState(() => _vehicleImages.removeAt(index));
  }

  Future<void> _save() async {
    if (_selectedVehicleType == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecione o tipo de veículo.'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    if (_selectedVehicleType!.fields.isNotEmpty) {
      if (!_formKey.currentState!.validate()) return;
    }

    if (_vehicleImages.length < 3) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Adicione ao menos 3 fotos do veículo.'),
          backgroundColor: _red,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    await Future.delayed(const Duration(milliseconds: 800));
    if (!mounted) return;
    setState(() => _isSaving = false);

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Veículo atualizado com sucesso!'),
        backgroundColor: _red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _hintForField(String field) {
    if (_selectedVehicleType == null) return '';
    switch (_selectedVehicleType!.label) {
      case 'Moto':
        return 'Ex: Honda CG 160';
      case 'Bicicleta':
        return 'Ex: Caloi Elite';
      case 'Carro':
        return 'Ex: Fiat Uno';
      case 'Patinete':
        return 'Ex: Xiaomi Pro 2';
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;
    final screenH = MediaQuery.of(context).size.height;

    return ConstrainedBox(
      constraints: BoxConstraints(
        minHeight: screenH * 0.80,
        maxHeight: screenH * 0.92,
      ),
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 12, 20, 20 + bottom),
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    margin: const EdgeInsets.only(bottom: 20),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE0E0E0),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const Text(
                  'EDITAR VEÍCULO',
                  style: TextStyle(
                    color: _red,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 1.1,
                  ),
                ),
                const SizedBox(height: 20),

                const Text(
                  'Tipo de veículo',
                  style: TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 10),

                GridView.count(
                  crossAxisCount: 2,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisSpacing: 8,
                  mainAxisSpacing: 8,
                  childAspectRatio: 2.8,
                  children: _vehicleTypes.map((option) {
                    final isSelected =
                        _selectedVehicleType?.label == option.label;
                    return GestureDetector(
                      onTap: () =>
                          setState(() => _selectedVehicleType = option),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 180),
                        decoration: BoxDecoration(
                          color: isSelected ? _red : const Color(0xFFF5F5F5),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isSelected ? _red : const Color(0xFFE0E0E0),
                            width: 1.5,
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              option.icon,
                              size: 16,
                              color: isSelected
                                  ? _white
                                  : const Color(0xFF555555),
                            ),
                            const SizedBox(width: 6),
                            Text(
                              option.label,
                              style: TextStyle(
                                color: isSelected
                                    ? _white
                                    : const Color(0xFF1A1A1A),
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),

                const SizedBox(height: 20),
                const Divider(height: 1, color: Color(0xFFE0E0E0)),
                const SizedBox(height: 20),

                if (_selectedVehicleType != null) ...[
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: const Color(0xFFC0392B).withValues(alpha: 0.06),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: const Color(0xFFC0392B).withValues(alpha: 0.15),
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(_selectedVehicleType!.icon, color: _red, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _selectedVehicleType!.description,
                            style: const TextStyle(
                              color: Color(0xFF555555),
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  if (_selectedVehicleType!.fields.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    const Text(
                      'Dados do veículo',
                      style: TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 14),
                    if (_selectedVehicleType!.fields.contains('Modelo')) ...[
                      _buildField(
                        controller: _modelController,
                        label: 'Modelo',
                        hint: _hintForField('Modelo'),
                        icon: Icons.directions_car_outlined,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_selectedVehicleType!.fields.contains('Placa')) ...[
                      _buildField(
                        controller: _plateController,
                        label: 'Placa',
                        hint: 'Ex: ABC-1234',
                        icon: Icons.pin_outlined,
                        textCapitalization: TextCapitalization.characters,
                      ),
                      const SizedBox(height: 12),
                    ],
                    if (_selectedVehicleType!.fields.contains('Cor') ||
                        _selectedVehicleType!.fields.contains('Ano'))
                      Row(
                        children: [
                          if (_selectedVehicleType!.fields.contains('Cor'))
                            Expanded(
                              child: _buildField(
                                controller: _colorController,
                                label: 'Cor',
                                hint: 'Ex: Preto',
                                icon: Icons.color_lens_outlined,
                              ),
                            ),
                          if (_selectedVehicleType!.fields.contains('Cor') &&
                              _selectedVehicleType!.fields.contains('Ano'))
                            const SizedBox(width: 12),
                          if (_selectedVehicleType!.fields.contains('Ano'))
                            Expanded(
                              child: _buildField(
                                controller: _yearController,
                                label: 'Ano',
                                hint: 'Ex: 2022',
                                icon: Icons.calendar_today_outlined,
                                keyboardType: TextInputType.number,
                              ),
                            ),
                        ],
                      ),

                    _buildPhotoSection(),
                  ],
                ],

                const SizedBox(height: 28),

                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _save,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _red,
                      disabledBackgroundColor: const Color(
                        0xFFC0392B,
                      ).withValues(alpha: 0.6),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 0,
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: _white,
                            ),
                          )
                        : const Text(
                            'Salvar alterações',
                            style: TextStyle(
                              color: _white,
                              fontSize: 15,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                  ),
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        const Text(
          'Fotos do veículo',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 13,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        const Text(
          'Adicione ao menos 3 fotos do seu veículo.',
          style: TextStyle(color: Color(0xFF888888), fontSize: 11),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            ...List.generate(_vehicleImages.length, (i) {
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFE0E0E0)),
                      ),
                      child: const Icon(
                        Icons.image_outlined,
                        color: Color(0xFFBDBDBD),
                        size: 32,
                      ),
                    ),
                    Positioned(
                      top: -6,
                      right: -6,
                      child: GestureDetector(
                        onTap: () => _removeImage(i),
                        child: Container(
                          width: 20,
                          height: 20,
                          decoration: const BoxDecoration(
                            color: _red,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: Colors.white,
                            size: 12,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            }),

            if (_vehicleImages.length < 3)
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Icon(Icons.add_a_photo_outlined, color: _red, size: 22),
                      SizedBox(height: 4),
                      Text(
                        'Adicionar',
                        style: TextStyle(
                          color: _red,
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            ...List.generate(
              _vehicleImages.isEmpty
                  ? 2
                  : (2 - _vehicleImages.length).clamp(0, 2),
              (_) => Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: const Color(0xFFE0E0E0)),
                  ),
                  child: const Icon(
                    Icons.image_outlined,
                    color: Color(0xFFE0E0E0),
                    size: 32,
                  ),
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 10),
        Row(
          children: List.generate(3, (i) {
            final filled = i < _vehicleImages.length;
            return Container(
              margin: const EdgeInsets.only(right: 4),
              width: 24,
              height: 4,
              decoration: BoxDecoration(
                color: filled ? _red : const Color(0xFFE0E0E0),
                borderRadius: BorderRadius.circular(2),
              ),
            );
          }),
        ),
      ],
    );
  }

  Widget _buildField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    TextCapitalization textCapitalization = TextCapitalization.words,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          keyboardType: keyboardType,
          textCapitalization: textCapitalization,
          style: const TextStyle(color: Color(0xFF1A1A1A), fontSize: 14),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFFBDBDBD), fontSize: 13),
            prefixIcon: Icon(icon, color: const Color(0xFF888888), size: 18),
            filled: true,
            fillColor: const Color(0xFFF5F5F5),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: Color(0xFFE0E0E0)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(10),
              borderSide: const BorderSide(color: _red, width: 1.5),
            ),
          ),
          validator: (v) =>
              (v == null || v.trim().isEmpty) ? 'Campo obrigatório' : null,
        ),
      ],
    );
  }
}

class _VehicleOption {
  final String label;
  final IconData icon;
  final String description;
  final List<String> fields;
  const _VehicleOption({
    required this.label,
    required this.icon,
    required this.description,
    required this.fields,
  });
}

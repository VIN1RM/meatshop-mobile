import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/services/cep_service.dart';
import 'package:meatshop_mobile/models/address_model.dart';

class AddressFormSheet extends StatefulWidget {
  const AddressFormSheet({super.key, this.address, required this.onSave});

  final AddressModel? address;
  final void Function(AddressModel) onSave;

  @override
  State<AddressFormSheet> createState() => _AddressFormSheetState();
}

class _AddressFormSheetState extends State<AddressFormSheet> {
  static const Color _white = Colors.white;

  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _labelCtrl;
  late final TextEditingController _zipCtrl;
  late final TextEditingController _streetCtrl;
  late final TextEditingController _numberCtrl;
  late final TextEditingController _complementCtrl;
  late final TextEditingController _neighborhoodCtrl;
  late final TextEditingController _cityCtrl;
  late final TextEditingController _stateCtrl;

  bool _isDefault = false;
  bool _isSaving = false;
  bool _isLoadingCep = false;
  String? _cepError;

  @override
  void initState() {
    super.initState();
    final a = widget.address;
    _labelCtrl = TextEditingController(text: a?.label ?? '');
    _zipCtrl = TextEditingController(text: a?.zipCode ?? '');
    _streetCtrl = TextEditingController(text: a?.street ?? '');
    _numberCtrl = TextEditingController(text: a?.number ?? '');
    _complementCtrl = TextEditingController(text: a?.complement ?? '');
    _neighborhoodCtrl = TextEditingController(text: a?.neighborhood ?? '');
    _cityCtrl = TextEditingController(text: a?.city ?? '');
    _stateCtrl = TextEditingController(text: a?.state ?? '');
    _isDefault = a?.isDefault ?? false;
  }

  @override
  void dispose() {
    _labelCtrl.dispose();
    _zipCtrl.dispose();
    _streetCtrl.dispose();
    _numberCtrl.dispose();
    _complementCtrl.dispose();
    _neighborhoodCtrl.dispose();
    _cityCtrl.dispose();
    _stateCtrl.dispose();
    super.dispose();
  }

  Future<void> _fetchCep(String raw) async {
    final digits = raw.replaceAll(RegExp(r'\D'), '');
    if (digits.length != 8) return;

    setState(() {
      _isLoadingCep = true;
      _cepError = null;
    });

    final result = await CepService.fetch(digits);

    if (!mounted) return;

    result.fold(
      onSuccess: (data) {
        _streetCtrl.text = data.street;
        _neighborhoodCtrl.text = data.neighborhood;
        _cityCtrl.text = data.city;
        _stateCtrl.text = data.state;

        FocusScope.of(context).nextFocus();
      },
      onFailure: (message) => setState(() => _cepError = message),
    );

    setState(() => _isLoadingCep = false);
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isSaving = true);
    if (!mounted) return;

    widget.onSave(
      AddressModel(
        id: widget.address?.id ?? 0,
        label: _labelCtrl.text.trim(),
        street: _streetCtrl.text.trim(),
        number: _numberCtrl.text.trim(),
        complement: _complementCtrl.text.trim(),
        neighborhood: _neighborhoodCtrl.text.trim(),
        city: _cityCtrl.text.trim(),
        state: _stateCtrl.text.trim().toUpperCase(),
        zipCode: _zipCtrl.text.trim(),
        isDefault: _isDefault,
      ),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.address != null;
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
                    _buildTitle(isEditing),
                    const SizedBox(height: 16),

                    _AddressFormField(
                      controller: _labelCtrl,
                      label: 'Apelido (ex: Casa, Trabalho)',
                      icon: Icons.label_outline,
                      validator: (v) => (v == null || v.isEmpty)
                          ? 'Informe um apelido'
                          : null,
                    ),
                    const SizedBox(height: 12),

                    _CepField(
                      controller: _zipCtrl,
                      isLoading: _isLoadingCep,
                      externalError: _cepError,
                      onCompleted: _fetchCep,
                    ),
                    const SizedBox(height: 12),

                    _AddressFormField(
                      controller: _streetCtrl,
                      label: 'Rua / Avenida',
                      icon: Icons.signpost_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe a rua' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 2,
                          child: _AddressFormField(
                            controller: _numberCtrl,
                            label: 'Número',
                            icon: Icons.tag,
                            validator: (v) =>
                                (v == null || v.isEmpty) ? 'Obrigatório' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 3,
                          child: _AddressFormField(
                            controller: _complementCtrl,
                            label: 'Complemento',
                            icon: Icons.home_outlined,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),

                    _AddressFormField(
                      controller: _neighborhoodCtrl,
                      label: 'Bairro',
                      icon: Icons.map_outlined,
                      validator: (v) =>
                          (v == null || v.isEmpty) ? 'Informe o bairro' : null,
                    ),
                    const SizedBox(height: 12),

                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _AddressFormField(
                            controller: _cityCtrl,
                            label: 'Cidade',
                            icon: Icons.location_city_outlined,
                            validator: (v) => (v == null || v.isEmpty)
                                ? 'Informe a cidade'
                                : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _AddressFormField(
                            controller: _stateCtrl,
                            label: 'UF',
                            icon: Icons.flag_outlined,
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(
                                RegExp(r'[a-zA-Z]'),
                              ),
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (v) => (v == null || v.length < 2)
                                ? 'UF inválida'
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

                    _SaveButton(
                      isEditing: isEditing,
                      isSaving: _isSaving,
                      onPressed: _save,
                    ),
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

  Widget _buildTitle(bool isEditing) {
    return Text(
      isEditing ? 'Editar endereço' : 'Novo endereço',
      style: const TextStyle(
        color: _white,
        fontSize: 18,
        fontWeight: FontWeight.w800,
      ),
    );
  }
}

class _CepField extends StatelessWidget {
  const _CepField({
    required this.controller,
    required this.isLoading,
    required this.onCompleted,
    this.externalError,
  });

  final TextEditingController controller;
  final bool isLoading;
  final String? externalError;
  final void Function(String) onCompleted;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: TextInputType.number,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly,
        LengthLimitingTextInputFormatter(8),
      ],
      style: const TextStyle(color: Colors.white, fontSize: 14),
      onChanged: (v) {
        if (v.length == 8) onCompleted(v);
      },
      validator: (v) {
        if (v == null || v.length < 8) return 'CEP inválido';
        if (externalError != null) return externalError;
        return null;
      },
      decoration: InputDecoration(
        labelText: 'CEP',
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: const Icon(
          Icons.pin_drop_outlined,
          color: Colors.white38,
          size: 18,
        ),
        suffixIcon: isLoading
            ? const Padding(
                padding: EdgeInsets.all(12),
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Color(0xFFC0392B),
                  ),
                ),
              )
            : null,
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

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Row(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 120),
            width: 22,
            height: 22,
            decoration: BoxDecoration(
              color: value ? _red : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(
                color: value ? _red : Colors.white38,
                width: 2,
              ),
            ),
            child: value
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : null,
          ),
          const SizedBox(width: 10),
          const Expanded(
            child: Text(
              'Definir como endereço padrão',
              style: TextStyle(color: Colors.white70, fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }
}

class _SaveButton extends StatelessWidget {
  const _SaveButton({
    required this.isEditing,
    required this.isSaving,
    required this.onPressed,
  });

  final bool isEditing;
  final bool isSaving;
  final VoidCallback onPressed;

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton(
        onPressed: isSaving ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          disabledBackgroundColor: _red.withValues(alpha: 0.5),
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
            : Text(
                isEditing ? 'Salvar alterações' : 'Adicionar endereço',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
      ),
    );
  }
}

class _AddressFormField extends StatelessWidget {
  const _AddressFormField({
    required this.controller,
    required this.label,
    required this.icon,

    this.inputFormatters,
    this.validator,
  });

  final TextEditingController controller;
  final String label;
  final IconData icon;

  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,

      inputFormatters: inputFormatters,
      validator: validator,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: Colors.white54, fontSize: 13),
        prefixIcon: Icon(icon, color: Colors.white38, size: 18),
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

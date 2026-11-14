import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../../core/utils/business_clock.dart';
import '../../../../core/utils/field_validations.dart';
import '../../../../data/repositories/delivery_expense_repository.dart';
import '../../../../models/delivery_expense_model.dart';
import '../../../widgets/account_page.dart';
import '../../../widgets/app_surface.dart';
import '../../../widgets/buttons_widget.dart';
import 'expense_widgets.dart';

class ExpenseFormScreen extends StatefulWidget {
  const ExpenseFormScreen({super.key, this.expense});
  final DeliveryExpenseModel? expense;
  @override
  State<ExpenseFormScreen> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<ExpenseFormScreen> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _description;
  late final TextEditingController _amount;
  late DateTime _date;
  late String _category;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    _description = TextEditingController(text: widget.expense?.description);
    _amount = TextEditingController(
      text: widget.expense?.amount.toStringAsFixed(2).replaceAll('.', ','),
    );
    _date = widget.expense?.date ?? BusinessClock.now();
    _category = widget.expense?.category ?? 'FUEL';
  }

  @override
  void dispose() {
    _description.dispose();
    _amount.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<DeliveryExpenseRepository>().save(
        id: widget.expense?.id,
        category: _category,
        description: _description.text,
        amount: FieldValidations.parseMoney(_amount.text)!,
        date: DateFormat('yyyy-MM-dd').format(_date),
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () =>
              _error = 'Não foi possível salvar. Seus dados foram preservados.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => AccountPage(
    dark: true,
    surfaceColor: const Color(0xFF2E2E2E),
    title: widget.expense == null ? 'Nova despesa' : 'Editar despesa',
    description:
        'Preencha os dados do gasto para manter seu controle atualizado.',
    action: PrimaryButton(
      label: 'Salvar despesa',
      icon: Icons.check,
      onPressed: _save,
      isLoading: _saving,
    ),
    body: _fields(),
  );

  Widget _fields() => Theme(
    data: appDarkSurfaceTheme(context),
    child: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF333333),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white10),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Row(
                  children: [
                    Icon(
                      Icons.receipt_long_outlined,
                      color: Color(0xFFE78176),
                      size: 22,
                    ),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Dados da despesa',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                _label('Categoria'),
                _categoryField(),
                const SizedBox(height: 20),
                _label('Descrição'),
                _descriptionField(),
                const SizedBox(height: 16),
                _label('Valor da despesa'),
                _amountField(),
                const SizedBox(height: 20),
                _label('Data da despesa'),
                _dateField(),
              ],
            ),
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: Color(0xFFFFA99F), height: 1.4),
              ),
            ),
          const SizedBox(height: 16),
        ],
      ),
    ),
  );

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(
      text,
      style: const TextStyle(
        color: Colors.white70,
        fontSize: 13,
        fontWeight: FontWeight.w600,
      ),
    ),
  );

  Widget _categoryField() => DropdownButtonFormField<String>(
    isExpanded: true,
    initialValue: _category,
    dropdownColor: const Color(0xFF383838),
    style: const TextStyle(color: Colors.white, fontSize: 15),
    icon: const Icon(Icons.expand_more, color: Colors.white70),
    decoration: const InputDecoration(
      prefixIcon: Icon(Icons.category_outlined),
    ),
    items: expenseCategories.entries
        .map(
          (entry) =>
              DropdownMenuItem(value: entry.key, child: Text(entry.value)),
        )
        .toList(),
    onChanged: _saving ? null : (value) => setState(() => _category = value!),
  );

  Widget _descriptionField() => TextFormField(
    controller: _description,
    enabled: !_saving,
    maxLength: 300,
    minLines: 2,
    maxLines: 3,
    style: const TextStyle(color: Colors.white, fontSize: 15),
    textCapitalization: TextCapitalization.sentences,
    decoration: const InputDecoration(
      hintText: 'Ex.: abastecimento da moto',
      hintMaxLines: 2,
      alignLabelWithHint: true,
    ),
    validator: (value) => FieldValidations.text(
      value,
      requiredMessage: 'Informe a descrição',
      maximumLength: 300,
    ),
  );

  Widget _amountField() => TextFormField(
    controller: _amount,
    enabled: !_saving,
    style: const TextStyle(
      color: Colors.white,
      fontSize: 22,
      fontWeight: FontWeight.w700,
    ),
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: const InputDecoration(
      hintText: '0,00',
      prefixIcon: Padding(
        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 18),
        child: Text(
          r'R$',
          style: TextStyle(
            color: Colors.white70,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    ),
    validator: FieldValidations.money,
  );

  Widget _dateField() => Builder(
    builder: (fieldContext) => Semantics(
      button: true,
      label: 'Data da despesa',
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: _saving ? null : _pickDate,
        child: InputDecorator(
          decoration: InputDecoration(
            enabled: !_saving,
            prefixIcon: const Icon(Icons.calendar_month_outlined),
            suffixIcon: const Icon(Icons.expand_more, color: Colors.white70),
          ),
          child: Text(
            DateFormat('dd/MM/yyyy').format(_date),
            style: const TextStyle(color: Colors.white, fontSize: 15),
          ),
        ),
      ),
    ),
  );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: BusinessClock.now(),
      builder: (context, child) =>
          Theme(data: appDarkSurfaceTheme(context), child: child!),
    );
    if (date != null && mounted) setState(() => _date = date);
  }
}

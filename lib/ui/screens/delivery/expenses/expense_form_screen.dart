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
        padding: const EdgeInsets.all(20),
        children: [
          _categoryField(),
          const SizedBox(height: 20),
          _descriptionField(),
          const SizedBox(height: 12),
          _amountField(),
          const SizedBox(height: 20),
          _dateField(),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text(
                _error!,
                style: const TextStyle(color: AppColors.redPrimary),
              ),
            ),
        ],
      ),
    ),
  );

  Widget _categoryField() => DropdownButtonFormField<String>(
    isExpanded: true,
    initialValue: _category,
    decoration: const InputDecoration(
      labelText: 'Categoria',
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
    textCapitalization: TextCapitalization.sentences,
    decoration: const InputDecoration(
      labelText: 'Descrição',
      hintText: 'Ex.: abastecimento da moto',
      prefixIcon: Icon(Icons.notes),
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
    keyboardType: const TextInputType.numberWithOptions(decimal: true),
    decoration: const InputDecoration(
      labelText: r'Valor (R$)',
      hintText: '0,00',
      prefixIcon: Icon(Icons.payments_outlined),
    ),
    validator: FieldValidations.money,
  );

  Widget _dateField() => OutlinedButton.icon(
    style: OutlinedButton.styleFrom(
      padding: const EdgeInsets.all(16),
      alignment: Alignment.centerLeft,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),
    onPressed: _saving ? null : _pickDate,
    icon: const Icon(Icons.calendar_month_outlined),
    label: Text('Data da despesa: ${DateFormat('dd/MM/yyyy').format(_date)}'),
  );

  Future<void> _pickDate() async {
    final date = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: BusinessClock.now(),
    );
    if (date != null && mounted) setState(() => _date = date);
  }
}

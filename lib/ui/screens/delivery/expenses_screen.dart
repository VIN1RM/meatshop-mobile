import 'package:meatshop_mobile/core/utils/field_validations.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/business_clock.dart';
import '../../../data/repositories/delivery_expense_repository.dart';
import '../../../models/delivery_expense_model.dart';
import '../../widgets/buttons_widget.dart';

const _categories = {
  'FUEL': 'Combustível',
  'MAINTENANCE': 'Manutenção',
  'PARKING': 'Estacionamento',
  'TOLL': 'Pedágio',
  'INSURANCE': 'Seguro',
  'OTHER': 'Outros',
};

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});
  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  DeliveryExpensePage? _result;
  bool _loading = true;
  String? _error;
  int _page = 1;
  DateTime _month = DateTime(
    BusinessClock.now().year,
    BusinessClock.now().month,
  );
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final end = DateTime(_month.year, _month.month + 1, 0);
      final result = await context.read<DeliveryExpenseRepository>().list(
        from: DateFormat('yyyy-MM-dd').format(_month),
        to: DateFormat('yyyy-MM-dd').format(end),
        page: _page,
      );
      if (mounted) setState(() => _result = result);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível carregar as despesas.');
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _edit([DeliveryExpenseModel? expense]) async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(builder: (_) => _ExpenseForm(expense: expense)),
    );
    if (saved == true && mounted) await _load();
  }

  Future<void> _remove(DeliveryExpenseModel expense) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        title: const Text('Excluir despesa?'),
        content: Text(expense.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Excluir'),
          ),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;
    setState(() => _loading = true);
    try {
      await context.read<DeliveryExpenseRepository>().remove(expense.id);
      if (mounted) await _load();
    } catch (_) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = 'Não foi possível excluir a despesa.';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Minhas despesas')),
    floatingActionButton: FloatingActionButton(
      onPressed: _loading ? null : () => _edit(),
      tooltip: 'Nova despesa',
      child: const Icon(Icons.add),
    ),
    body: Column(
      children: [
        Wrap(
          alignment: WrapAlignment.center,
          children: [
            IconButton(
              tooltip: 'Mês anterior',
              onPressed: _loading
                  ? null
                  : () {
                      _month = DateTime(_month.year, _month.month - 1);
                      _page = 1;
                      _load();
                    },
              icon: const Icon(Icons.chevron_left),
            ),
            Text(DateFormat('MM/yyyy').format(_month)),
            IconButton(
              tooltip: 'Próximo mês',
              onPressed: _loading
                  ? null
                  : () {
                      _month = DateTime(_month.year, _month.month + 1);
                      _page = 1;
                      _load();
                    },
              icon: const Icon(Icons.chevron_right),
            ),
          ],
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
              ? Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(_error!),
                      TextButton(
                        onPressed: _load,
                        child: const Text('Tentar novamente'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _load,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 96),
                    children: [
                      Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Text(
                            'Despesas no mês: ${NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(_result?.totalAmount ?? 0)}',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                        ),
                      ),
                      if (_result?.items.isEmpty ?? true)
                        const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text('Nenhuma despesa neste mês.'),
                        ),
                      for (final expense
                          in _result?.items ?? <DeliveryExpenseModel>[])
                        Card(
                          child: ListTile(
                            onTap: () => _edit(expense),
                            title: Text(expense.description),
                            subtitle: Text(
                              '${_categories[expense.category] ?? expense.category} - ${DateFormat('dd/MM/yyyy').format(expense.date)}\n${NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(expense.amount)}',
                            ),
                            trailing: IconButton(
                              tooltip: 'Excluir',
                              onPressed: () => _remove(expense),
                              icon: const Icon(Icons.delete_outline),
                            ),
                          ),
                        ),
                      Wrap(
                        alignment: WrapAlignment.center,
                        children: [
                          TextButton(
                            onPressed: _page > 1
                                ? () {
                                    _page--;
                                    _load();
                                  }
                                : null,
                            child: const Text('Anterior'),
                          ),
                          Text('$_page'),
                          TextButton(
                            onPressed: _page * 30 < (_result?.total ?? 0)
                                ? () {
                                    _page++;
                                    _load();
                                  }
                                : null,
                            child: const Text('Próxima'),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
        ),
      ],
    ),
  );
}

class _ExpenseForm extends StatefulWidget {
  const _ExpenseForm({this.expense});
  final DeliveryExpenseModel? expense;
  @override
  State<_ExpenseForm> createState() => _ExpenseFormState();
}

class _ExpenseFormState extends State<_ExpenseForm> {
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
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.expense == null ? 'Nova despesa' : 'Editar despesa'),
    ),
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: _categories.entries
                .map(
                  (entry) => DropdownMenuItem(
                    value: entry.key,
                    child: Text(entry.value),
                  ),
                )
                .toList(),
            onChanged: _saving ? null : (v) => setState(() => _category = v!),
          ),
          TextFormField(
            controller: _description,
            enabled: !_saving,
            maxLength: 300,
            decoration: const InputDecoration(labelText: 'Descrição'),
            validator: (v) => FieldValidations.text(
              v,
              requiredMessage: 'Informe a descrição',
              maximumLength: 300,
            ),
          ),
          TextFormField(
            controller: _amount,
            enabled: !_saving,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: r'Valor (R$)'),
            validator: FieldValidations.money,
          ),
          ListTile(
            title: const Text('Data da despesa'),
            subtitle: Text(DateFormat('dd/MM/yyyy').format(_date)),
            trailing: const Icon(Icons.calendar_month),
            onTap: _saving
                ? null
                : () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: _date,
                      firstDate: DateTime(2000),
                      lastDate: BusinessClock.now(),
                    );
                    if (date != null && mounted) setState(() => _date = date);
                  },
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          PrimaryButton(
            label: 'Salvar despesa',
            onPressed: _save,
            isLoading: _saving,
          ),
        ],
      ),
    ),
  );
}

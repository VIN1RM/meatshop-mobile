import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/business_clock.dart';
import '../../../data/repositories/delivery_expense_repository.dart';
import '../../../models/delivery_expense_model.dart';
import '../../../models/delivery_export_model.dart';
import '../../dialogs/app_dialog.dart';
import '../../widgets/account_page.dart';
import '../../widgets/buttons_widget.dart';
import '../../widgets/delivery_export_button.dart';
import 'expenses/expense_form_screen.dart';
import 'expenses/expense_widgets.dart';

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
      MaterialPageRoute(builder: (_) => ExpenseFormScreen(expense: expense)),
    );
    if (saved == true && mounted) await _load();
  }

  Future<void> _remove(DeliveryExpenseModel expense) async {
    final confirmed = await _confirmRemove(expense);
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

  Future<bool?> _confirmRemove(DeliveryExpenseModel expense) =>
      showDialog<bool>(
        context: context,
        builder: (dialog) => AppDialog(
          title: 'Excluir despesa?',
          icon: Icons.delete_outline,
          description: 'Esta despesa será removida do seu controle pessoal.',
          content: Text(expense.description),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialog, false),
              child: const Text('Cancelar'),
            ),
            PrimaryButton(
              label: 'Excluir despesa',
              width: 180,
              onPressed: () => Navigator.pop(dialog, true),
            ),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) => AccountPage(
    dark: true,
    surfaceColor: const Color(0xFF2E2E2E),
    title: 'Minhas despesas',
    description: 'Organize seus gastos e acompanhe o total de cada mês.',
    action: Tooltip(
      message: 'Nova despesa',
      child: PrimaryButton(
        label: 'Nova despesa',
        icon: Icons.add,
        onPressed: _loading ? null : () => _edit(),
      ),
    ),
    body: _body(),
  );

  Widget _body() {
    if (_loading) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.redPrimary),
      );
    }
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(_error!, textAlign: TextAlign.center),
              TextButton(
                onPressed: _load,
                child: const Text('Tentar novamente'),
              ),
            ],
          ),
        ),
      );
    }
    return _list();
  }

  Widget _list() => RefreshIndicator(
    onRefresh: _load,
    child: ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        ..._overview(),
        const Text(
          'Lançamentos',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w700,
            letterSpacing: .2,
          ),
        ),
        const SizedBox(height: 12),
        if (_result?.items.isEmpty ?? true) const ExpenseEmptyState(),
        for (final expense in _result?.items ?? <DeliveryExpenseModel>[])
          ExpenseTile(
            expense: expense,
            onEdit: () => _edit(expense),
            onRemove: () => _remove(expense),
          ),
        if ((_result?.total ?? 0) > 30) _pagination(),
      ],
    ),
  );

  List<Widget> _overview() => [
    ExpenseMonthSelector(month: _month, busy: _loading, onChange: _changeMonth),
    const SizedBox(height: 16),
    ExpenseSummary(total: _result?.totalAmount ?? 0),
    const SizedBox(height: 16),
    DeliveryExportButton(
      report: DeliveryReportType.expenses,
      from: _month,
      to: DateTime(_month.year, _month.month + 1, 0),
      label: 'Exportar despesas',
    ),
    const SizedBox(height: 20),
  ];

  void _changeMonth(int offset) {
    _month = DateTime(_month.year, _month.month + offset);
    _page = 1;
    _load();
  }

  Widget _pagination() => Wrap(
    alignment: WrapAlignment.center,
    crossAxisAlignment: WrapCrossAlignment.center,
    spacing: 8,
    children: [
      TextButton(
        onPressed: _page > 1 ? () => _changePage(-1) : null,
        child: const Text('Anterior'),
      ),
      Text('Página $_page'),
      TextButton(
        onPressed: _page * 30 < (_result?.total ?? 0)
            ? () => _changePage(1)
            : null,
        child: const Text('Próxima'),
      ),
    ],
  );

  void _changePage(int offset) {
    _page += offset;
    _load();
  }
}

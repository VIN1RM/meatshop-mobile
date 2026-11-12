import 'package:meatshop_mobile/ui/widgets/app_empty_state.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../models/delivery_expense_model.dart';
import '../../../widgets/buttons_widget.dart';

const expenseCategories = {
  'FUEL': 'Combustível',
  'MAINTENANCE': 'Manutenção',
  'PARKING': 'Estacionamento',
  'TOLL': 'Pedágio',
  'INSURANCE': 'Seguro',
  'OTHER': 'Outros',
};

String expenseMoney(double value) =>
    NumberFormat.currency(locale: 'pt_BR', symbol: r'R$').format(value);

class ExpenseMonthSelector extends StatelessWidget {
  const ExpenseMonthSelector({
    super.key,
    required this.month,
    required this.busy,
    required this.onChange,
  });
  final DateTime month;
  final bool busy;
  final ValueChanged<int> onChange;

  @override
  Widget build(BuildContext context) => Row(
    children: [
      IconButton(
        tooltip: 'Mês anterior',
        onPressed: busy ? null : () => onChange(-1),
        icon: const Icon(Icons.chevron_left),
      ),
      Expanded(
        child: Column(
          children: [
            const Text(
              'Período',
              style: TextStyle(color: Color(0xFF555555), fontSize: 12),
            ),
            Text(
              DateFormat('MMMM / yyyy', 'pt_BR').format(month),
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ],
        ),
      ),
      IconButton(
        tooltip: 'Próximo mês',
        onPressed: busy ? null : () => onChange(1),
        icon: const Icon(Icons.chevron_right),
      ),
    ],
  );
}

class ExpenseSummary extends StatelessWidget {
  const ExpenseSummary({super.key, required this.total});
  final double total;
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: const Color(0xFFE4E4E4)),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(Icons.receipt_long_outlined, color: AppColors.redPrimary),
        const SizedBox(height: 12),
        const Text(
          'Despesas no mês',
          style: TextStyle(color: Color(0xFF555555)),
        ),
        const SizedBox(height: 6),
        Text(
          expenseMoney(total),
          style: const TextStyle(
            color: AppColors.dark,
            fontWeight: FontWeight.w900,
            fontSize: 28,
          ),
        ),
      ],
    ),
  );
}

class ExpenseTile extends StatelessWidget {
  const ExpenseTile({
    super.key,
    required this.expense,
    required this.onEdit,
    required this.onRemove,
  });
  final DeliveryExpenseModel expense;
  final VoidCallback onEdit;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) => Card(
    color: Colors.white,
    elevation: 0,
    margin: const EdgeInsets.only(bottom: 12),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(14),
      side: const BorderSide(color: Color(0xFFE4E4E4)),
    ),
    child: Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ..._description(),
          const SizedBox(height: 12),
          Text(
            expenseMoney(expense.amount),
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.redPrimary,
            ),
          ),
          _actions(),
        ],
      ),
    ),
  );

  List<Widget> _description() => [
    Text(
      expense.description,
      style: const TextStyle(
        fontSize: 16,
        color: AppColors.dark,
        fontWeight: FontWeight.w700,
      ),
    ),
    const SizedBox(height: 6),
    Text(
      '${expenseCategories[expense.category] ?? expense.category} • ${DateFormat('dd/MM/yyyy').format(expense.date)}',
      style: const TextStyle(color: Color(0xFF555555)),
    ),
  ];

  Widget _actions() => Wrap(
    alignment: WrapAlignment.end,
    spacing: 8,
    children: [
      TextButton.icon(
        onPressed: onEdit,
        icon: const Icon(Icons.edit_outlined),
        label: const Text('Editar'),
      ),
      IconButton(
        tooltip: 'Excluir despesa',
        onPressed: onRemove,
        icon: const Icon(Icons.delete_outline, color: AppColors.redPrimary),
      ),
    ],
  );
}

class ExpenseEmptyState extends StatelessWidget {
  const ExpenseEmptyState({super.key});
  @override
  Widget build(BuildContext context) => const AppEmptyState(
    title: 'Nenhuma despesa neste mês',
    icon: Icons.receipt_long_outlined,
    description: 'Adicione uma despesa para acompanhar seus gastos.',
  );
}

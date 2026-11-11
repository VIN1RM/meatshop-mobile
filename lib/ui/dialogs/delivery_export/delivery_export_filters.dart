import 'package:flutter/material.dart';
import '../../../models/delivery_export_model.dart';

class DeliveryExportFilters extends StatelessWidget {
  const DeliveryExportFilters({
    super.key,
    required this.report,
    required this.busy,
    required this.value,
    required this.onChanged,
  });
  final DeliveryReportType report;
  final bool busy;
  final String value;
  final ValueChanged<String> onChanged;

  @override
  Widget build(BuildContext context) {
    final (label, options) = _options();
    if (options.isEmpty) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: DropdownButtonFormField<String>(
        key: ValueKey('filter-${report.name}'),
        initialValue: value,
        isExpanded: true,
        decoration: InputDecoration(labelText: label),
        items: options.entries
            .map(
              (entry) => DropdownMenuItem(
                value: entry.key,
                child: Text(
                  entry.value,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            )
            .toList(),
        onChanged: busy
            ? null
            : (value) {
                if (value != null) onChanged(value);
              },
      ),
    );
  }

  (String, Map<String, String>) _options() => switch (report) {
    DeliveryReportType.earnings => (
      'Recebimentos',
      {
        'all': 'Todos',
        'received': 'Com recebimento',
        'pending': 'Com saldo a receber',
      },
    ),
    DeliveryReportType.expenses => (
      'Categoria',
      {
        'all': 'Todas',
        'FUEL': 'Combustível',
        'MAINTENANCE': 'Manutenção',
        'PARKING': 'Estacionamento',
        'TOLL': 'Pedágio',
        'INSURANCE': 'Seguro',
        'OTHER': 'Outras',
      },
    ),
    DeliveryReportType.support => (
      'Situação do chamado',
      {
        'all': 'Todas',
        'OPEN': 'Aberto',
        'ANSWERED': 'Respondido',
        'WAITING_SUPPORT': 'Aguardando suporte',
        'WAITING_USER': 'Aguardando você',
        'CLOSED': 'Fechado',
      },
    ),
    _ => ('', {}),
  };
}

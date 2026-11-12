import 'package:flutter/material.dart';
import '../../../models/delivery_export_model.dart';

class DeliveryExportFields extends StatelessWidget {
  const DeliveryExportFields({
    super.key,
    required this.report,
    required this.format,
    required this.busy,
    required this.onReport,
    required this.onFormat,
  });
  final DeliveryReportType report;
  final DeliveryExportFormat format;
  final bool busy;
  final ValueChanged<DeliveryReportType> onReport;
  final ValueChanged<DeliveryExportFormat> onFormat;

  @override
  Widget build(BuildContext context) => Column(
    children: [_reportField(), const SizedBox(height: 16), _formatField()],
  );

  Widget _reportField() => DropdownButtonFormField<DeliveryReportType>(
    key: ValueKey('report-${report.name}'),
    initialValue: report,
    isExpanded: true,
    decoration: const InputDecoration(labelText: 'Relatório'),
    items: DeliveryReportType.values
        .map(
          (value) => DropdownMenuItem(
            value: value,
            child: Text(
              value.label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        )
        .toList(),
    onChanged: busy
        ? null
        : (value) {
            if (value != null) onReport(value);
          },
  );

  Widget _formatField() => DropdownButtonFormField<DeliveryExportFormat>(
    initialValue: format,
    isExpanded: true,
    decoration: const InputDecoration(labelText: 'Formato'),
    items: const [
      DropdownMenuItem(
        value: DeliveryExportFormat.xlsx,
        child: Text('Excel (.xlsx)'),
      ),
      DropdownMenuItem(
        value: DeliveryExportFormat.pdf,
        child: Text('PDF (.pdf)'),
      ),
    ],
    onChanged: busy
        ? null
        : (value) {
            if (value != null) onFormat(value);
          },
  );
}

class DeliveryExportDates extends StatelessWidget {
  const DeliveryExportDates({
    super.key,
    required this.from,
    required this.to,
    required this.busy,
    required this.onPick,
  });
  final DateTime from;
  final DateTime to;
  final bool busy;
  final ValueChanged<bool> onPick;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 16),
    child: Wrap(
      spacing: 12,
      runSpacing: 8,
      children: [
        OutlinedButton.icon(
          onPressed: busy ? null : () => onPick(true),
          icon: const Icon(Icons.calendar_today),
          label: Text('De: ${_date(from)}'),
        ),
        OutlinedButton.icon(
          onPressed: busy ? null : () => onPick(false),
          icon: const Icon(Icons.event),
          label: Text('Até: ${_date(to)}'),
        ),
      ],
    ),
  );

  String _date(DateTime date) =>
      '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
}

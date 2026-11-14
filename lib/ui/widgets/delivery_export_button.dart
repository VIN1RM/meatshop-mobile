import 'package:flutter/material.dart';
import '../../models/delivery_export_model.dart';
import '../dialogs/delivery_export/delivery_export_dialog.dart';
import 'buttons_widget.dart';

class DeliveryExportButton extends StatelessWidget {
  const DeliveryExportButton({
    super.key,
    this.report = DeliveryReportType.earnings,
    this.from,
    this.to,
    this.label = 'Exportar relatório',
  });
  final DeliveryReportType report;
  final DateTime? from;
  final DateTime? to;
  final String label;

  @override
  Widget build(BuildContext context) => FilledButton.icon(
    style: FilledButton.styleFrom(
      backgroundColor: AppColors.redPrimary,
      foregroundColor: Colors.white,
      minimumSize: const Size(0, 48),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    onPressed: () =>
        DeliveryExportDialog.show(context, report: report, from: from, to: to),
    icon: const Icon(Icons.download_outlined),
    label: Text(label, style: const TextStyle(fontWeight: FontWeight.w700)),
  );
}

import 'package:flutter/material.dart';
import 'app_dialog.dart';
import '../widgets/buttons_widget.dart';

class PersonalDataExportDialog extends StatelessWidget {
  const PersonalDataExportDialog({super.key});
  static Future<void> show(BuildContext context) => showDialog<void>(
    context: context,
    builder: (_) => const PersonalDataExportDialog(),
  );
  @override
  Widget build(BuildContext context) => AppDialog(
    title: 'Exportar meus dados',
    icon: Icons.download_outlined,
    description:
        'Em breve você poderá baixar uma cópia dos seus dados. Os formatos abaixo ainda não estão disponíveis.',
    content: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        for (final option in [
          (Icons.data_object, 'JSON', 'Dados estruturados'),
          (Icons.table_chart_outlined, 'Excel', 'Planilha para consulta'),
          (Icons.picture_as_pdf_outlined, 'PDF', 'Documento para leitura'),
        ])
          Container(
            margin: const EdgeInsets.only(bottom: 10),
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFE0E0E0)),
              borderRadius: BorderRadius.circular(12),
            ),
            child: ListTile(
              leading: Icon(option.$1, color: AppColors.redPrimary),
              title: Text(
                option.$2,
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              subtitle: Text('${option.$3} · Em breve'),
            ),
          ),
        PrimaryButton(
          label: 'Entendi',
          onPressed: () => Navigator.pop(context),
        ),
      ],
    ),
  );
}

import 'package:flutter/material.dart';
import '../../models/legal_document.dart';
import '../dialogs/legal_document_dialog.dart';
import 'buttons_widget.dart';

class LegalDocumentList extends StatelessWidget {
  const LegalDocumentList({super.key, required this.documents});
  final List<LegalDocument> documents;

  static Future<void> open(BuildContext context, LegalDocument document) =>
      showDialog<void>(
        context: context,
        builder: (_) => LegalDocumentDialog(document: document),
      );

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: documents
        .map((document) => _DocumentTile(document: document))
        .toList(),
  );
}

class _DocumentTile extends StatelessWidget {
  const _DocumentTile({required this.document});
  final LegalDocument document;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Material(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => LegalDocumentList.open(context, document),
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Row(
            children: [
              _leading(),
              const SizedBox(width: 12),
              Expanded(child: _details()),
              const SizedBox(width: 8),
              const Icon(
                Icons.chevron_right,
                color: AppColors.redPrimary,
                size: 22,
              ),
            ],
          ),
        ),
      ),
    ),
  );

  Widget _leading() => Container(
    padding: const EdgeInsets.all(10),
    decoration: BoxDecoration(
      color: AppColors.redPrimary.withValues(alpha: 0.08),
      borderRadius: BorderRadius.circular(10),
    ),
    child: const Icon(
      Icons.description_outlined,
      color: AppColors.redPrimary,
      size: 22,
    ),
  );

  Widget _details() => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text(
        '${document.title} · ${document.version}',
        style: const TextStyle(
          color: AppColors.dark,
          fontSize: 14,
          height: 1.4,
          fontWeight: FontWeight.w600,
        ),
      ),
      const SizedBox(height: 4),
      const Text(
        'Toque para ler o documento',
        style: TextStyle(color: Colors.black54, fontSize: 12),
      ),
    ],
  );
}

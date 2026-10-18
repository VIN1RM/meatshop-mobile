import 'package:flutter/material.dart';
import '../../models/legal_document.dart';
import '../widgets/buttons_widget.dart';

class LegalDocumentDialog extends StatelessWidget {
  const LegalDocumentDialog({super.key, required this.document});
  final LegalDocument document;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: AppColors.white,
    surfaceTintColor: Colors.transparent,
    insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    clipBehavior: Clip.antiAlias,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 640),
      child: SizedBox(
        height: MediaQuery.sizeOf(context).height * 0.82,
        child: Column(
          children: [
            _header(context),
            Expanded(child: _body()),
            _footer(context),
          ],
        ),
      ),
    ),
  );

  Widget _header(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
    color: AppColors.background,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _headerActions(context),
        Text(
          document.title,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 17,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          'Versão ${document.version}',
          style: const TextStyle(color: Colors.black54, fontSize: 12),
        ),
      ],
    ),
  );

  Widget _headerActions(BuildContext context) => Row(
    children: [
      const Icon(
        Icons.description_outlined,
        color: AppColors.redPrimary,
        size: 20,
      ),
      const SizedBox(width: 8),
      const Expanded(
        child: Text(
          'DOCUMENTO LEGAL',
          style: TextStyle(
            color: AppColors.redPrimary,
            fontSize: 10,
            fontWeight: FontWeight.w800,
            letterSpacing: 1,
          ),
        ),
      ),
      IconButton(
        tooltip: 'Fechar documento',
        onPressed: () => Navigator.of(context).pop(),
        icon: const Icon(Icons.close, color: AppColors.grey),
      ),
    ],
  );

  Widget _body() => Scrollbar(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: SelectionArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: document.content
              .split(RegExp(r'\n\n+'))
              .map((block) => _DocumentParagraph(block: block))
              .toList(),
        ),
      ),
    ),
  );

  Widget _footer(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: const BoxDecoration(
      color: AppColors.background,
      border: Border(top: BorderSide(color: Colors.black12)),
    ),
    child: PrimaryButton(
      label: 'Fechar',
      onPressed: () => Navigator.of(context).pop(),
    ),
  );
}

class _DocumentParagraph extends StatelessWidget {
  const _DocumentParagraph({required this.block});
  final String block;
  static const _bodyStyle = TextStyle(
    color: AppColors.dark,
    fontSize: 14,
    height: 1.7,
  );

  @override
  Widget build(BuildContext context) {
    final lines = block.split('\n');
    final heading = RegExp(r'^\d{1,2}[.)]?\s+\S').hasMatch(lines.first);
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: heading
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _heading(lines.first),
                if (lines.length > 1) ...[
                  const SizedBox(height: 8),
                  Text(lines.skip(1).join('\n'), style: _bodyStyle),
                ],
              ],
            )
          : Text(block, style: _bodyStyle),
    );
  }

  Widget _heading(String title) => Container(
    padding: const EdgeInsets.only(left: 10),
    decoration: const BoxDecoration(
      border: Border(left: BorderSide(color: AppColors.redPrimary, width: 2)),
    ),
    child: Text(
      title,
      style: const TextStyle(
        color: AppColors.dark,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

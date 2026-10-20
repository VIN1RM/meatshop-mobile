import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/repositories/legal_repository.dart';
import '../../models/legal_document.dart';
import 'legal_document_list.dart';
import 'legal_section.dart';
import 'buttons_widget.dart';

class LegalRegistration extends StatefulWidget {
  const LegalRegistration({super.key, required this.onChanged});
  final ValueChanged<List<int>?> onChanged;

  @override
  State<LegalRegistration> createState() => _LegalRegistrationState();
}

class _LegalRegistrationState extends State<LegalRegistration> {
  late Future<LegalCatalog> _catalog;
  bool _accepted = false;

  @override
  void initState() {
    super.initState();
    _catalog = context.read<LegalRepository>().catalog();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<LegalCatalog>(
    future: _catalog,
    builder: (context, snapshot) {
      if (snapshot.hasError) return _buildError();
      if (!snapshot.hasData) {
        return const Padding(
          padding: EdgeInsets.all(16),
          child: Center(
            child: CircularProgressIndicator(color: AppColors.redPrimary),
          ),
        );
      }
      return _buildConsent(snapshot.data!.documents);
    },
  );

  Widget _buildError() => Column(
    children: [
      const Text(
        'Não foi possível carregar os documentos.',
        style: TextStyle(color: Colors.white),
      ),
      TextButton(
        onPressed: () => setState(() {
          _catalog = context.read<LegalRepository>().catalog();
        }),
        child: const Text('Tentar novamente'),
      ),
    ],
  );

  Widget _buildConsent(List<LegalDocument> documents) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      const Padding(
        padding: EdgeInsets.symmetric(vertical: 12),
        child: Text(
          'TERMOS E PRIVACIDADE',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 12,
            fontWeight: FontWeight.w700,
            letterSpacing: 1,
          ),
        ),
      ),
      LegalDocumentList(documents: documents),
      LegalConsentTile(
        value: _accepted,
        dark: true,
        onChanged: (value) {
          setState(() => _accepted = value);
          widget.onChanged(
            value ? documents.map((document) => document.id).toList() : null,
          );
        },
      ),
      const SizedBox(height: 16),
    ],
  );
}

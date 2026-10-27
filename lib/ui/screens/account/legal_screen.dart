import 'package:intl/intl.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons_widget.dart';
import '../../widgets/legal_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'support_screen.dart';
import '../../../data/repositories/legal_repository.dart';
import '../../../models/legal_document.dart';
import '../../widgets/legal_document_list.dart';

class LegalScreen extends StatefulWidget {
  const LegalScreen({
    super.key,
    this.requiredAcceptance = false,
    this.onDeleteAccount,
  });
  final bool requiredAcceptance;
  final Future<void> Function()? onDeleteAccount;

  @override
  State<LegalScreen> createState() => _LegalScreenState();
}

class _LegalScreenState extends State<LegalScreen> {
  List<LegalDocument>? _documents;
  List<LegalAcceptanceRecord> _history = [];
  String? _error;
  bool _accepted = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() {
      _documents = null;
      _error = null;
      _accepted = false;
    });
    try {
      final repository = context.read<LegalRepository>();
      final catalog = await repository.catalog();
      final history = widget.requiredAcceptance
          ? <LegalAcceptanceRecord>[]
          : await repository.history();
      if (mounted) {
        setState(() {
          _documents = catalog.documents;
          _history = history;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível carregar os documentos.');
      }
    }
  }

  Future<void> _submit() async {
    setState(() => _busy = true);
    try {
      await context.read<LegalRepository>().accept(
        _documents!.map((document) => document.id).toList(),
      );
      if (mounted) Navigator.of(context).pop(true);
    } catch (_) {
      if (mounted) {
        await _load();
        if (mounted) {
          setState(
            () => _error =
                'Não foi possível registrar. Confira os documentos e tente novamente.',
          );
        }
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _openRecord(LegalAcceptanceRecord record) async {
    try {
      final document = await context.read<LegalRepository>().document(
        record.documentId,
      );
      if (mounted) await LegalDocumentList.open(context, document);
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível abrir a versão solicitada.');
      }
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: Scaffold(
      backgroundColor: AppColors.darkSurface,
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const AppHeader(showBack: true),
                Expanded(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
                    children: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  List<Widget> _buildContent() => [
    ..._introduction(),
    if (_error != null) ...[_buildError(), const SizedBox(height: 16)],
    if (_documents == null && _error == null)
      const Padding(
        padding: EdgeInsets.all(24),
        child: Center(
          child: CircularProgressIndicator(color: AppColors.redPrimary),
        ),
      ),
    if (_documents != null)
      LegalSection(
        title: 'Documentos vigentes',
        icon: Icons.description_outlined,
        description:
            'Leia as condições de uso e saiba como seus dados são tratados.',
        child: LegalDocumentList(documents: _documents!),
      ),
    if (_documents != null && widget.requiredAcceptance) ...[
      const SizedBox(height: 16),
      _buildAcceptance(),
    ],
    if (_documents != null && !widget.requiredAcceptance) ...[
      const SizedBox(height: 16),
      _buildHistory(),
    ],
    const SizedBox(height: 16),
    _buildSupport(),
  ];

  List<Widget> _introduction() => [
    const Text(
      'TERMOS E PRIVACIDADE',
      style: TextStyle(
        color: AppColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w900,
        letterSpacing: 0.6,
      ),
    ),
    const SizedBox(height: 8),
    Text(
      widget.requiredAcceptance
          ? 'Confira os documentos para continuar com sua conta.'
          : 'Consulte os documentos e suas confirmações.',
      style: const TextStyle(color: Colors.white70, fontSize: 14, height: 1.5),
    ),
    const SizedBox(height: 24),
  ];

  Widget _buildError() => LegalSection(
    title: 'Não foi possível concluir',
    icon: Icons.error_outline,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          _error!,
          style: const TextStyle(
            color: AppColors.dark,
            fontSize: 13,
            height: 1.5,
          ),
        ),
        TextButton(
          onPressed: _busy ? null : _load,
          child: const Text(
            'Tentar novamente',
            style: TextStyle(color: AppColors.redPrimary),
          ),
        ),
      ],
    ),
  );

  Widget _buildAcceptance() => LegalSection(
    title: 'Sua confirmação',
    icon: Icons.verified_user_outlined,
    child: Column(
      children: [
        LegalConsentTile(
          value: _accepted,
          onChanged: _busy
              ? null
              : (value) => setState(() => _accepted = value),
        ),
        const SizedBox(height: 16),
        LegalActionButton(
          label: 'Aceitar e continuar',
          loading: _busy,
          onPressed: !_accepted || _documents == null ? null : _submit,
        ),
        TextButton(
          onPressed: _busy ? null : () => Navigator.of(context).pop(false),
          child: const Text(
            'Sair sem aceitar',
            style: TextStyle(color: Colors.black54),
          ),
        ),
      ],
    ),
  );

  Widget _buildHistory() => LegalSection(
    title: 'Meu histórico',
    icon: Icons.history,
    description: 'Versões confirmadas por você e datas dos registros.',
    child: _history.isEmpty
        ? const Padding(
            padding: EdgeInsets.symmetric(vertical: 12),
            child: Text(
              'Nenhuma confirmação registrada.',
              style: TextStyle(color: Colors.black54, fontSize: 13),
            ),
          )
        : Column(children: _history.map(_historyRecord).toList()),
  );

  Widget _historyRecord(LegalAcceptanceRecord record) => ListTile(
    contentPadding: EdgeInsets.zero,
    title: Text(
      record.title,
      style: const TextStyle(
        color: AppColors.dark,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    ),
    subtitle: Text(
      'Versão ${record.version}\n${DateFormat('dd/MM/yyyy · HH:mm').format(record.acceptedAt.toLocal())}',
      style: const TextStyle(color: Colors.black54, fontSize: 12, height: 1.5),
    ),
    trailing: const Icon(Icons.chevron_right, color: AppColors.redPrimary),
    onTap: () => _openRecord(record),
  );

  Widget _buildSupport() => LegalSection(
    title: 'Precisa de ajuda?',
    icon: Icons.support_agent,
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _contactButton(),
        if (widget.onDeleteAccount != null)
          TextButton(
            onPressed: _busy ? null : widget.onDeleteAccount,
            child: const Text(
              'Excluir minha conta',
              style: TextStyle(color: AppColors.redPrimary),
            ),
          ),
      ],
    ),
  );

  Widget _contactButton() => TextButton(
    onPressed: _contact,
    style: TextButton.styleFrom(foregroundColor: AppColors.redPrimary),
    child: const Row(
      children: [
        Icon(Icons.mail_outline),
        SizedBox(width: 10),
        Expanded(
          child: Text(
            'Suporte, pedidos e solicitações sobre dados pessoais',
            style: TextStyle(fontSize: 13, height: 1.5),
          ),
        ),
      ],
    ),
  );

  Future<void> _contact() async {
    await Navigator.of(
      context,
    ).push(MaterialPageRoute(builder: (_) => const SupportScreen()));
  }
}

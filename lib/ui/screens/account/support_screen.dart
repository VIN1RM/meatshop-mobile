import '../../widgets/app_header.dart';
import '../../widgets/app_surface.dart';
import 'package:meatshop_mobile/core/utils/field_validations.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/support_repository.dart';
import '../../../models/support_ticket_model.dart';
import '../../widgets/buttons_widget.dart';

class SupportScreen extends StatefulWidget {
  const SupportScreen({super.key});
  @override
  State<SupportScreen> createState() => _SupportScreenState();
}

class _SupportScreenState extends State<SupportScreen> {
  List<SupportTicketModel> _tickets = [];
  bool _loading = true;
  String? _error;
  int _page = 1;
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
      final rows = await context.read<SupportRepository>().list(page: _page);
      if (mounted) setState(() => _tickets = rows);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível carregar os chamados. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _create() async {
    final result = await Navigator.of(
      context,
    ).push<bool>(MaterialPageRoute(builder: (_) => const _NewTicketScreen()));
    if (result == true && mounted) {
      _page = 1;
      await _load();
    }
  }

  @override
  Widget build(BuildContext context) => _SupportPage(
    title: 'Meus chamados',
    description: 'Acompanhe suas solicitações e converse com nossa equipe.',
    action: Tooltip(
      message: 'Novo chamado',
      child: PrimaryButton(
        label: 'Novo chamado',
        icon: Icons.add,
        onPressed: _create,
      ),
    ),
    body: _loading
        ? const Center(child: CircularProgressIndicator())
        : _error != null
        ? Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(_error!),
                TextButton(
                  onPressed: _load,
                  child: const Text('Tentar novamente'),
                ),
              ],
            ),
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                if (_tickets.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(24),
                    child: Text('Nenhum chamado encontrado.'),
                  ),
                for (final ticket in _tickets)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFFE0E0E0)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFFF8E9E7),
                        child: Icon(
                          Icons.support_agent,
                          color: AppColors.redPrimary,
                        ),
                      ),
                      title: Text(ticket.subject),
                      subtitle: Text(
                        '#${ticket.id} - ${_status(ticket.status)}',
                      ),
                      trailing: const Icon(Icons.chevron_right),
                      onTap: () async {
                        await Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => _TicketScreen(id: ticket.id),
                          ),
                        );
                        if (mounted) await _load();
                      },
                    ),
                  ),
                Wrap(
                  alignment: WrapAlignment.center,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    TextButton(
                      onPressed: _page > 1
                          ? () {
                              _page--;
                              _load();
                            }
                          : null,
                      child: const Text('Anterior'),
                    ),
                    Text('$_page'),
                    TextButton(
                      onPressed: _tickets.length == 30
                          ? () {
                              _page++;
                              _load();
                            }
                          : null,
                      child: const Text('Próxima'),
                    ),
                  ],
                ),
              ],
            ),
          ),
  );
}

String _status(String status) => switch (status) {
  'OPEN' => 'Aberto',
  'WAITING_SUPPORT' => 'Aguardando equipe',
  'WAITING_USER' => 'Aguardando sua resposta',
  'CLOSED' => 'Encerrado',
  _ => status,
};

class _NewTicketScreen extends StatefulWidget {
  const _NewTicketScreen();
  @override
  State<_NewTicketScreen> createState() => _NewTicketScreenState();
}

class _NewTicketScreenState extends State<_NewTicketScreen> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _description = TextEditingController();
  final _contact = TextEditingController();
  bool _saving = false;
  String _category = 'TECHNICAL';
  String? _error;
  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
    _contact.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_form.currentState!.validate()) return;
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      await context.read<SupportRepository>().create(
        _subject.text,
        _description.text,
        _category,
        contact: _contact.text,
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível enviar. Seu texto foi preservado; tente novamente.',
        );
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(_error!), backgroundColor: AppColors.redDark),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => _SupportPage(
    title: 'Novo chamado',
    action: PrimaryButton(
      label: 'Enviar chamado',
      onPressed: _save,
      isLoading: _saving,
    ),
    description:
        'Conte o que aconteceu. Quanto mais detalhes, melhor poderemos ajudar.',
    body: Form(
      key: _form,
      child: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          DropdownButtonFormField<String>(
            isExpanded: true,
            initialValue: _category,
            decoration: const InputDecoration(labelText: 'Categoria'),
            items: const [
              DropdownMenuItem(
                value: 'TECHNICAL',
                child: Text('Problema técnico'),
              ),
              DropdownMenuItem(value: 'ACCOUNT', child: Text('Conta')),
              DropdownMenuItem(value: 'BILLING', child: Text('Pagamento')),
              DropdownMenuItem(value: 'ORDER', child: Text('Pedido')),
              DropdownMenuItem(value: 'OTHER', child: Text('Outro')),
            ],
            onChanged: _saving ? null : (v) => setState(() => _category = v!),
          ),
          const SizedBox(height: 20),
          TextFormField(
            controller: _subject,
            enabled: !_saving,
            maxLength: 150,
            decoration: const InputDecoration(labelText: 'Assunto'),
            validator: (v) => FieldValidations.text(
              v,
              requiredMessage: 'Informe o assunto',
              maximumLength: 150,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _contact,
            enabled: !_saving,
            maxLength: 150,
            decoration: const InputDecoration(labelText: 'Contato (opcional)'),
            validator: (value) => FieldValidations.text(
              value,
              maximumLength: 150,
              optional: true,
            ),
          ),
          const SizedBox(height: 12),
          TextFormField(
            controller: _description,
            enabled: !_saving,
            maxLength: 2000,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Descreva o problema'),
            validator: (v) => FieldValidations.text(
              v,
              requiredMessage: 'Descreva o problema',
              maximumLength: 2000,
            ),
          ),
        ],
      ),
    ),
  );
}

class _TicketScreen extends StatefulWidget {
  const _TicketScreen({required this.id});
  final int id;
  @override
  State<_TicketScreen> createState() => _TicketScreenState();
}

class _TicketScreenState extends State<_TicketScreen> {
  SupportTicketModel? _ticket;
  final _message = TextEditingController();
  String? _error;
  bool _busy = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    try {
      final value = await context.read<SupportRepository>().get(widget.id);
      if (mounted) {
        setState(() {
          _ticket = value;
          _error = null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível carregar a conversa.');
      }
    }
  }

  Future<void> _act(
    Future<void> Function() action, {
    bool clear = false,
  }) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      await action();
      if (mounted) {
        if (clear) _message.clear();
        await _load();
      }
    } catch (_) {
      if (mounted) {
        setState(() => _error = 'Não foi possível concluir. Tente novamente.');
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = context.read<SupportRepository>();
    final ticket = _ticket;
    return _SupportPage(
      title: 'Chamado #${widget.id}',
      description: 'Veja as mensagens e acompanhe a resposta da equipe.',
      body: ticket == null && _error == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                if (_error != null) ...[
                  Text(_error!, style: const TextStyle(color: Colors.red)),
                  TextButton(
                    onPressed: _busy ? null : _load,
                    child: const Text('Atualizar'),
                  ),
                ],
                if (ticket != null) ...[
                  Text(
                    ticket.subject,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  Text(_status(ticket.status)),
                  if (ticket.contact?.isNotEmpty == true)
                    Text('Contato: ${ticket.contact}'),
                  for (final message in ticket.messages)
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              message.text.isEmpty
                                  ? 'Anexo enviado'
                                  : message.text,
                            ),
                            Text(
                              MaterialLocalizations.of(
                                context,
                              ).formatCompactDate(message.createdAt.toLocal()),
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                          ],
                        ),
                      ),
                    ),
                  if (ticket.status != 'CLOSED') ...[
                    TextField(
                      controller: _message,
                      enabled: !_busy,
                      maxLength: 2000,
                      minLines: 2,
                      maxLines: 6,
                      decoration: const InputDecoration(
                        labelText: 'Sua resposta',
                      ),
                    ),
                    PrimaryButton(
                      label: 'Enviar resposta',
                      isLoading: _busy,
                      onPressed: () {
                        if (_message.text.trim().isNotEmpty) {
                          _act(
                            () => repo.send(widget.id, _message.text),
                            clear: true,
                          );
                        }
                      },
                    ),
                  ],
                  TextButton(
                    onPressed: _busy
                        ? null
                        : () => _act(
                            () => ticket.status == 'CLOSED'
                                ? repo.reopen(widget.id)
                                : repo.close(widget.id),
                          ),
                    child: Text(
                      ticket.status == 'CLOSED'
                          ? 'Reabrir chamado'
                          : 'Encerrar chamado',
                    ),
                  ),
                  TextButton(
                    onPressed: _busy ? null : _load,
                    child: const Text('Atualizar conversa'),
                  ),
                ],
              ],
            ),
    );
  }
}

class _SupportPage extends StatelessWidget {
  const _SupportPage({
    required this.title,
    required this.description,
    required this.body,
    this.action,
  });
  final String title;
  final String description;
  final Widget body;
  final Widget? action;
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2E2E2E),
    bottomNavigationBar: action == null
        ? null
        : SafeArea(
            top: false,
            child: Padding(
              padding: EdgeInsets.fromLTRB(
                16,
                12,
                16,
                16 + MediaQuery.viewInsetsOf(context).bottom,
              ),
              child: Center(
                heightFactor: 1,
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 688),
                  child: action!,
                ),
              ),
            ),
          ),
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
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(showBack: true),
              Expanded(
                child: LayoutBuilder(
                  builder: (context, constraints) => Align(
                    alignment: Alignment.topCenter,
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 720),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (constraints.maxHeight > 280)
                            Padding(
                              padding: const EdgeInsets.fromLTRB(
                                16,
                                12,
                                16,
                                16,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 22,
                                      fontWeight: FontWeight.w900,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    description,
                                    style: const TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                      height: 1.5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Theme(
                                  data: appSurfaceTheme(context),
                                  child: ColoredBox(
                                    color: const Color(0xFFF5F5F5),
                                    child: body,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

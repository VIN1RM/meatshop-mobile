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
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppColors.background,
    appBar: AppBar(title: const Text('Meus chamados')),
    floatingActionButton: FloatingActionButton(
      onPressed: _create,
      tooltip: 'Novo chamado',
      child: const Icon(Icons.add),
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
                    child: ListTile(
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
  bool _saving = false;
  String _category = 'TECHNICAL';
  String? _error;
  @override
  void dispose() {
    _subject.dispose();
    _description.dispose();
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
      );
      if (mounted) Navigator.pop(context, true);
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Não foi possível enviar. Seu texto foi preservado; tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Novo chamado')),
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
          TextFormField(
            controller: _subject,
            enabled: !_saving,
            maxLength: 150,
            decoration: const InputDecoration(labelText: 'Assunto'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Informe o assunto' : null,
          ),
          TextFormField(
            controller: _description,
            enabled: !_saving,
            maxLength: 2000,
            minLines: 4,
            maxLines: 10,
            decoration: const InputDecoration(labelText: 'Descreva o problema'),
            validator: (v) =>
                v == null || v.trim().isEmpty ? 'Descreva o problema' : null,
          ),
          if (_error != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12),
              child: Text(_error!, style: const TextStyle(color: Colors.red)),
            ),
          PrimaryButton(
            label: 'Enviar chamado',
            onPressed: _save,
            isLoading: _saving,
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
    return Scaffold(
      appBar: AppBar(title: Text('Chamado #${widget.id}')),
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

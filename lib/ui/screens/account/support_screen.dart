import 'support_ticket_screen.dart';
import 'package:meatshop_mobile/ui/widgets/app_empty_state.dart';
import '../../widgets/account_page.dart';
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
  Widget build(BuildContext context) => AccountPage(
    title: 'Meus chamados',
    surfaceColor: Colors.transparent,
    dark: true,
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
        ? AppEmptyState(
            title: 'Não foi possível carregar os chamados',
            description: _error,
            icon: Icons.wifi_off_outlined,
            actionLabel: 'Tentar novamente',
            onAction: _load,
          )
        : RefreshIndicator(
            onRefresh: _load,
            child: ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
              children: [
                if (_tickets.isEmpty)
                  AppEmptyState(
                    title: 'Você ainda não tem chamados',
                    description:
                        'Precisa de ajuda com um pedido ou com o aplicativo? Fale com nossa equipe.',
                    icon: Icons.support_agent,
                    actionLabel: 'Abrir um chamado',
                    onAction: _create,
                  ),
                for (final ticket in _tickets)
                  Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    color: const Color(0xFF383838),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                      side: const BorderSide(color: Color(0xFF484848)),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      leading: const CircleAvatar(
                        backgroundColor: Color(0xFF492F2C),
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
                            builder: (_) => SupportTicketScreen(id: ticket.id),
                          ),
                        );
                        if (mounted) await _load();
                      },
                    ),
                  ),
                if (_tickets.isNotEmpty || _page > 1)
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
  Widget build(BuildContext context) => AccountPage(
    title: 'Novo chamado',
    surfaceColor: Colors.transparent,
    dark: true,
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
            dropdownColor: const Color(0xFF383838),
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
            decoration: const InputDecoration(
              labelText: 'Assunto',
              hintText: 'Ex.: Preciso de ajuda com meu pedido',
              prefixIcon: Icon(Icons.subject_outlined),
            ),
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
            decoration: const InputDecoration(
              labelText: 'Contato (opcional)',
              hintText: 'Ex.: seu e-mail ou telefone',
              prefixIcon: Icon(Icons.contact_mail_outlined),
            ),
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
            decoration: const InputDecoration(
              labelText: 'Descreva o problema',
              hintText:
                  'Informe o pedido, o que aconteceu e como podemos ajudar.',
              alignLabelWithHint: true,
            ),
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

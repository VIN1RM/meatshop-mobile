import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/network/api_failure.dart';
import '../../../data/repositories/support_repository.dart';
import '../../../models/support_ticket_model.dart';
import '../../widgets/account_page.dart';
import '../../widgets/app_empty_state.dart';
import '../../widgets/buttons_widget.dart';
import 'support_ticket_widgets.dart';

class SupportTicketScreen extends StatefulWidget {
  const SupportTicketScreen({super.key, required this.id});
  final int id;
  @override
  State<SupportTicketScreen> createState() => _SupportTicketScreenState();
}

class _SupportTicketScreenState extends State<SupportTicketScreen> {
  SupportTicketModel? _ticket;
  final _message = TextEditingController();
  String? _error;
  bool _busy = false;
  bool _refreshing = false;
  Timer? _refreshTimer;
  bool _initialized = false;
  int? _cursor;
  bool _loadingHistory = false;
  String? _historyError;
  List<SupportMessageModel> _messages = [];
  List<SupportMessageModel> _merge(List<SupportMessageModel> incoming) {
    final merged = <String, SupportMessageModel>{};
    for (final item in [..._messages, ...incoming]) {
      merged[item.id?.toString() ??
              '${item.senderId}:${item.createdAt}:${item.text}'] =
          item;
    }
    return merged.values.toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  Future<void> _loadEarlier() async {
    final repo = context.read<SupportRepository>();
    final cursor = _cursor;
    if (repo is! PaginatedSupportRepository ||
        cursor == null ||
        _loadingHistory) {
      return;
    }
    setState(() {
      _loadingHistory = true;
      _historyError = null;
    });
    try {
      final page = await (repo as PaginatedSupportRepository).messages(
        widget.id,
        beforeId: cursor,
      );
      if (mounted) {
        setState(() {
          _messages = _merge(page.items);
          _cursor = page.hasMore ? page.nextBeforeId : null;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _historyError =
              'Não foi possível carregar as mensagens anteriores. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _loadingHistory = false);
    }
  }

  @override
  void initState() {
    super.initState();
    _load();
    _refreshTimer = Timer.periodic(const Duration(seconds: 10), (_) {
      if (!_busy) unawaited(_load());
    });
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    _message.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    if (_refreshing) return;
    _refreshing = true;
    try {
      final ticket = await context.read<SupportRepository>().get(widget.id);
      if (mounted) {
        setState(() {
          _ticket = ticket;
          _messages = _merge(ticket.messages);
          if (!_initialized) {
            _cursor = ticket.messagesHasMore
                ? ticket.messagesNextBeforeId
                : null;
            _initialized = true;
          }
          _error = null;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiFailure
              ? error.message
              : 'Não foi possível atualizar a conversa. Tente novamente.',
        );
      }
    } finally {
      _refreshing = false;
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
      if (!mounted) return;
      if (clear) _message.clear();
      await _load();
    } catch (error) {
      if (mounted) {
        setState(
          () => _error = error is ApiFailure
              ? error.message
              : 'Não foi possível concluir. Sua mensagem foi preservada; tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _send() {
    final text = _message.text.trim();
    if (text.isEmpty || text.length > 2000 || _busy) return;
    _act(
      () => context.read<SupportRepository>().send(widget.id, text),
      clear: true,
    );
  }

  @override
  Widget build(BuildContext context) {
    final ticket = _ticket;
    final repo = context.read<SupportRepository>();
    return AccountPage(
      title: 'Chamado #${widget.id}',
      description: 'Seu atendimento, organizado em uma conversa.',
      dark: true,
      surfaceColor: Colors.transparent,
      body: ticket == null
          ? _error == null
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppColors.redPrimary,
                    ),
                  )
                : AppEmptyState(
                    title: 'Não foi possível abrir o chamado',
                    description: _error,
                    icon: Icons.wifi_off_outlined,
                    actionLabel: 'Tentar novamente',
                    onAction: _load,
                  )
          : RefreshIndicator(
              color: AppColors.redPrimary,
              onRefresh: () async {
                if (!_busy) await _load();
              },
              child: ListView(
                padding: const EdgeInsets.fromLTRB(0, 4, 0, 24),
                physics: const AlwaysScrollableScrollPhysics(),
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                children: [
                  if (_cursor != null)
                    OutlinedButton(
                      onPressed: _loadingHistory ? null : _loadEarlier,
                      child: Text(
                        _loadingHistory
                            ? 'Carregando...'
                            : 'Carregar mensagens anteriores',
                      ),
                    ),
                  if (_historyError != null)
                    Padding(
                      padding: const EdgeInsets.all(12),
                      child: Text(
                        _historyError!,
                        style: const TextStyle(color: Color(0xFFFFA99F)),
                      ),
                    ),
                  TicketSummaryCard(ticket: ticket),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      const Icon(
                        Icons.forum_outlined,
                        size: 18,
                        color: Colors.white60,
                      ),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Conversa',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      IconButton.outlined(
                        tooltip: 'Atualizar conversa',
                        onPressed: _busy ? null : _load,
                        style: IconButton.styleFrom(
                          foregroundColor: Colors.white70,
                          side: const BorderSide(color: Colors.white12),
                        ),
                        icon: const Icon(Icons.refresh_rounded, size: 19),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (_error != null && ticket.status == 'CLOSED') ...[
                    Container(
                      padding: const EdgeInsets.all(14),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: const Color(0xFF442E2B),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Icon(
                            Icons.info_outline,
                            color: Color(0xFFFFA99F),
                            size: 18,
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _error!,
                              style: const TextStyle(
                                color: Color(0xFFFFC2BA),
                                height: 1.5,
                                fontSize: 13,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  if (_messages.isEmpty)
                    const AppEmptyState(
                      title: 'A conversa começa aqui',
                      icon: Icons.chat_bubble_outline,
                      description:
                          'As mensagens e as respostas da equipe aparecerão neste espaço.',
                    ),
                  for (final message in _messages)
                    TicketMessageBubble(
                      message: message,
                      mine:
                          ticket.userId != null &&
                          message.senderId == ticket.userId,
                    ),
                  const SizedBox(height: 12),
                  if (ticket.status != 'CLOSED')
                    TicketReplyComposer(
                      controller: _message,
                      error: _error,
                      busy: _busy,
                      onSend: _send,
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(18),
                      decoration: BoxDecoration(
                        color: const Color(0xFF383838),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: const Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(
                            Icons.check_circle_outline,
                            color: Colors.white54,
                            size: 22,
                          ),
                          SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Este chamado foi encerrado. Se ainda precisar de ajuda, você pode reabri-lo.',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 13,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _busy
                        ? null
                        : () => _act(
                            () => ticket.status == 'CLOSED'
                                ? repo.reopen(widget.id)
                                : repo.close(widget.id),
                          ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.white70,
                      side: const BorderSide(color: Colors.white12),
                      minimumSize: const Size(0, 48),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    icon: Icon(
                      ticket.status == 'CLOSED'
                          ? Icons.refresh_rounded
                          : Icons.check_circle_outline,
                      size: 18,
                    ),
                    label: Text(
                      ticket.status == 'CLOSED'
                          ? 'Reabrir chamado'
                          : 'Encerrar chamado',
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/utils/business_clock.dart';
import '../../../data/repositories/delivery_export_repository.dart';
import '../../../models/delivery_export_model.dart';
import '../../../providers/auth/auth_provider.dart';
import '../../../providers/delivery_export_controller.dart';
import '../../../services/report_export_service.dart';
import '../../widgets/buttons_widget.dart';
import '../app_dialog.dart';
import 'delivery_export_fields.dart';
import 'delivery_export_filters.dart';

class DeliveryExportDialog extends StatefulWidget {
  const DeliveryExportDialog({
    super.key,
    required this.repository,
    required this.isAllowed,
    this.report = DeliveryReportType.earnings,
    this.from,
    this.to,
    this.shareFile = ReportExportService.share,
    this.session,
  });
  final DeliveryExportRepository repository;
  final bool Function() isAllowed;
  final DeliveryReportType report;
  final DateTime? from;
  final DateTime? to;
  final DeliveryFileSharer shareFile;
  final Listenable? session;

  static Future<void> show(
    BuildContext context, {
    DeliveryReportType report = DeliveryReportType.earnings,
    DateTime? from,
    DateTime? to,
  }) {
    final auth = context.read<AuthProvider>();
    if (!auth.isDelivery) return Future.value();
    final user = auth.backendUserId;
    return showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (_) => DeliveryExportDialog(
        repository: context.read<DeliveryExportRepository>(),
        report: report,
        from: from,
        to: to,
        isAllowed: () => auth.isDelivery && auth.backendUserId == user,
        session: auth,
      ),
    );
  }

  @override
  State<DeliveryExportDialog> createState() => _DeliveryExportDialogState();
}

class _DeliveryExportDialogState extends State<DeliveryExportDialog> {
  late final DeliveryExportController _controller;
  late DeliveryReportType _report;
  DeliveryExportFormat _format = DeliveryExportFormat.xlsx;
  late DateTime _from;
  late DateTime _to;
  String _filter = 'all';

  @override
  void initState() {
    super.initState();
    final today = BusinessClock.now();
    _from = widget.from ?? DateTime(today.year, today.month, 1);
    _to = widget.to ?? DateTime(today.year, today.month, today.day);
    _report = widget.report;
    _controller = DeliveryExportController(
      repository: widget.repository,
      shareFile: widget.shareFile,
      isAllowed: widget.isAllowed,
    );
    widget.session?.addListener(_sessionChanged);
  }

  void _sessionChanged() {
    if (!widget.isAllowed()) _controller.cancel();
  }

  @override
  void dispose() {
    widget.session?.removeListener(_sessionChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => AnimatedBuilder(
    animation: _controller,
    builder: (context, _) => PopScope(
      canPop: !_controller.busy,
      child: AppDialog(
        title: 'Exportar relatório pessoal',
        icon: Icons.download_outlined,
        description: 'Exporte e compartilhe seus dados pessoais de entregador.',
        canClose: !_controller.busy,
        content: _content(),
      ),
    ),
  );

  Widget _content() => Column(
    mainAxisSize: MainAxisSize.min,
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      _fields(),
      if (_report != DeliveryReportType.personal)
        DeliveryExportDates(
          from: _from,
          to: _to,
          busy: _controller.busy,
          onPick: _pickDate,
        ),
      const SizedBox(height: 12),
      DeliveryExportFilters(
        report: _report,
        busy: _controller.busy,
        value: _filter,
        onChanged: (value) => setState(() => _filter = value),
      ),
      ..._help(),
      if (_controller.error != null) _message(_controller.error!, true),
      if (_controller.status != null) _message(_controller.status!, false),
      PrimaryButton(
        label: _controller.busy
            ? 'Preparando arquivo...'
            : 'Gerar e compartilhar',
        icon: Icons.ios_share,
        isLoading: _controller.busy,
        onPressed: _export,
      ),
    ],
  );

  Widget _fields() => DeliveryExportFields(
    report: _report,
    format: _format,
    busy: _controller.busy,
    onReport: (report) => setState(() {
      _report = report;
      _filter = 'all';
    }),
    onFormat: (format) => setState(() => _format = format),
  );

  List<Widget> _help() => [
    if (_report == DeliveryReportType.personal)
      _helpNotice(
        'Inclui os dados pessoais completos da sua conta. Não usa filtro de período.',
      ),
    if (_report == DeliveryReportType.financial)
      _helpNotice(
        'Ganhos usam a conclusão da entrega. Recebimentos usam a data do acerto. Resultado de caixa é o recebido menos as despesas do período.',
      ),
  ];

  Widget _helpNotice(String message) => Container(
    margin: const EdgeInsets.only(bottom: 16),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: const Color(0xFFF8E9E7),
      borderRadius: BorderRadius.circular(12),
    ),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.only(top: 1),
          child: Icon(
            Icons.info_outline,
            size: 18,
            color: AppColors.redPrimary,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            message,
            style: const TextStyle(color: AppColors.dark, height: 1.4),
          ),
        ),
      ],
    ),
  );

  Widget _message(String message, bool error) => Semantics(
    liveRegion: true,
    container: true,
    child: Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: error ? const Color(0xFFFFEBEE) : const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: error ? const Color(0xFFFFCDD2) : const Color(0xFFC8E6C9),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            error ? Icons.error_outline : Icons.check_circle_outline,
            size: 20,
            color: error ? AppColors.redPrimary : const Color(0xFF2E7D32),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: error
                    ? const Color(0xFFB71C1C)
                    : const Color(0xFF1B5E20),
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    ),
  );

  Future<void> _pickDate(bool start) async {
    final value = await showDatePicker(
      context: context,
      initialDate: start ? _from : _to,
      firstDate: DateTime(2000),
      lastDate: DateTime(2100, 12, 31),
    );
    if (!mounted || value == null) return;
    setState(() {
      if (start) {
        _from = value;
      } else {
        _to = value;
      }
    });
  }

  void _export() {
    final box = context.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;
    final request = DeliveryExportRequest(
      report: _report,
      format: _format,
      from: _from,
      to: _to,
      payment: _filter,
      category: _filter == 'all' ? null : _filter,
      status: _filter == 'all' ? null : _filter,
    );
    _controller.export(request, box.localToGlobal(Offset.zero) & box.size);
  }
}

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
    builder: (context, _) => AppDialog(
      title: 'Exportar relatório pessoal',
      icon: Icons.download_outlined,
      description: 'Exporte e compartilhe seus dados pessoais de entregador.',
      content: _content(),
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
      const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Inclui os dados pessoais completos da sua conta. Não usa filtro de período.',
        ),
      ),
    if (_report == DeliveryReportType.financial)
      const Padding(
        padding: EdgeInsets.only(bottom: 16),
        child: Text(
          'Ganhos usam a conclusão da entrega. Recebimentos usam a data do acerto. Resultado de caixa é o recebido menos as despesas do período.',
        ),
      ),
  ];

  Widget _message(String message, bool error) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: Text(
      message,
      style: TextStyle(color: error ? AppColors.redPrimary : Colors.black87),
      semanticsLabel: message,
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

import 'dart:typed_data';

enum DeliveryReportType {
  earnings,
  history,
  expenses,
  financial,
  settlements,
  personal,
  support,
}

enum DeliveryExportFormat { xlsx, pdf }

extension DeliveryReportLabels on DeliveryReportType {
  String get label => switch (this) {
    DeliveryReportType.earnings => 'Meus ganhos',
    DeliveryReportType.history => 'Histórico de entregas',
    DeliveryReportType.expenses => 'Minhas despesas',
    DeliveryReportType.financial => 'Demonstrativo financeiro',
    DeliveryReportType.settlements => 'Acertos recebidos',
    DeliveryReportType.personal => 'Meus dados pessoais',
    DeliveryReportType.support => 'Meus atendimentos',
  };
}

class DeliveryExportRequest {
  const DeliveryExportRequest({
    required this.report,
    required this.format,
    this.from,
    this.to,
    this.payment = 'all',
    this.category,
    this.status,
  });
  final DeliveryReportType report;
  final DeliveryExportFormat format;
  final DateTime? from;
  final DateTime? to;
  final String payment;
  final String? category;
  final String? status;

  Map<String, Object?> toQuery() => {
    'report': report.name,
    'format': format.name,
    if (report != DeliveryReportType.personal) ...{
      'from': exportDate(from!),
      'to': exportDate(to!),
    },
    if ([
      DeliveryReportType.earnings,
      DeliveryReportType.history,
    ].contains(report))
      'payment': payment,
    if (report == DeliveryReportType.expenses &&
        category != null &&
        category!.isNotEmpty)
      'category': category,
    if (report == DeliveryReportType.support &&
        status != null &&
        status!.isNotEmpty)
      'status': status,
  };
}

String exportDate(DateTime value) =>
    '${value.year.toString().padLeft(4, '0')}-${value.month.toString().padLeft(2, '0')}-${value.day.toString().padLeft(2, '0')}';

class DeliveryExportFile {
  const DeliveryExportFile({
    required this.bytes,
    required this.fileName,
    required this.mimeType,
  });
  final Uint8List bytes;
  final String fileName;
  final String mimeType;
}

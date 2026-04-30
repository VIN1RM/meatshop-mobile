import 'dart:io';
import 'package:csv/csv.dart';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:share_plus/share_plus.dart';

import 'package:meatshop_mobile/models/earning_entry.dart';

class ReportExportService {
  ReportExportService._();

  static Future<void> exportPdf({
    required String period,
    required List<EarningEntry> earnings,
    required Map<String, String> summary,
  }) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (ctx) => [
          pw.Row(
            mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
            children: [
              pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Text(
                    'MeatShop',
                    style: pw.TextStyle(
                      fontSize: 22,
                      fontWeight: pw.FontWeight.bold,
                      color: PdfColor.fromHex('#C0392B'),
                    ),
                  ),
                  pw.Text(
                    'Relatório de Ganhos — $period',
                    style: pw.TextStyle(
                      fontSize: 13,
                      color: PdfColor.fromHex('#888888'),
                    ),
                  ),
                ],
              ),
              pw.Text(
                _formattedDate(),
                style: pw.TextStyle(
                  fontSize: 11,
                  color: PdfColor.fromHex('#888888'),
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColor.fromHex('#EEEEEE')),
          pw.SizedBox(height: 16),
          pw.Text(
            'Resumo do Período',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1A1A1A'),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Row(
            children: [
              _summaryBox('Total ganho', summary['total'] ?? '—'),
              pw.SizedBox(width: 12),
              _summaryBox('Entregas', summary['entregas'] ?? '—'),
              pw.SizedBox(width: 12),
              _summaryBox('Ticket médio', summary['media'] ?? '—'),
              pw.SizedBox(width: 12),
              _summaryBox('Melhor período', summary['melhorDia'] ?? '—'),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Text(
            'Detalhamento de Entregas',
            style: pw.TextStyle(
              fontSize: 14,
              fontWeight: pw.FontWeight.bold,
              color: PdfColor.fromHex('#1A1A1A'),
            ),
          ),
          pw.SizedBox(height: 12),
          pw.Table(
            border: pw.TableBorder.all(
              color: PdfColor.fromHex('#EEEEEE'),
              width: 0.5,
            ),
            columnWidths: {
              0: const pw.FlexColumnWidth(2),
              1: const pw.FlexColumnWidth(1.5),
              2: const pw.FlexColumnWidth(1),
            },
            children: [
              pw.TableRow(
                decoration: pw.BoxDecoration(
                  color: PdfColor.fromHex('#C0392B'),
                ),
                children: [
                  _tableHeader('Pedido'),
                  _tableHeader('Valor'),
                  _tableHeader('Horário'),
                ],
              ),
              ...earnings.map(
                (e) => pw.TableRow(
                  children: [
                    _tableCell(e.label),
                    _tableCell(
                      'R\$ ${e.amount.toStringAsFixed(2).replaceAll('.', ',')}',
                    ),
                    _tableCell(e.time),
                  ],
                ),
              ),
            ],
          ),
          pw.SizedBox(height: 24),
          pw.Divider(color: PdfColor.fromHex('#EEEEEE')),
          pw.SizedBox(height: 8),
          pw.Text(
            'Documento gerado automaticamente pelo app MeatShop.',
            style: pw.TextStyle(
              fontSize: 9,
              color: PdfColor.fromHex('#AAAAAA'),
            ),
          ),
        ],
      ),
    );

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/relatorio_meatshop_$period.pdf');
    await file.writeAsBytes(await pdf.save());

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Relatório MeatShop — $period');
  }

  static Future<void> exportCsv({
    required String period,
    required List<EarningEntry> earnings,
    required Map<String, String> summary,
  }) async {
    final rows = <List<dynamic>>[
      ['RELATÓRIO MEATSHOP — $period'],
      ['Gerado em', _formattedDate()],
      [],
      ['RESUMO'],
      ['Total ganho', summary['total'] ?? '—'],
      ['Entregas', summary['entregas'] ?? '—'],
      ['Ticket médio', summary['media'] ?? '—'],
      ['Melhor período', summary['melhorDia'] ?? '—'],
      [],
      ['ENTREGAS'],
      ['Pedido', 'Valor (R\$)', 'Horário'],
      ...earnings.map(
        (e) => [
          e.label,
          e.amount.toStringAsFixed(2).replaceAll('.', ','),
          e.time,
        ],
      ),
    ];

    final csvString = const ListToCsvConverter().convert(rows);

    final dir = await getTemporaryDirectory();
    final file = File('${dir.path}/relatorio_meatshop_$period.csv');
    await file.writeAsString(csvString);

    await Share.shareXFiles([
      XFile(file.path),
    ], subject: 'Relatório MeatShop — $period');
  }

  static pw.Widget _summaryBox(String label, String value) {
    return pw.Expanded(
      child: pw.Container(
        padding: const pw.EdgeInsets.all(8),
        decoration: pw.BoxDecoration(
          color: PdfColor.fromHex('#F5F5F5'),
          borderRadius: const pw.BorderRadius.all(pw.Radius.circular(6)),
        ),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Text(
              value,
              style: pw.TextStyle(
                fontSize: 12,
                fontWeight: pw.FontWeight.bold,
                color: PdfColor.fromHex('#1A1A1A'),
              ),
            ),
            pw.SizedBox(height: 2),
            pw.Text(
              label,
              style: pw.TextStyle(
                fontSize: 9,
                color: PdfColor.fromHex('#888888'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static pw.Widget _tableHeader(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(
          fontSize: 10,
          fontWeight: pw.FontWeight.bold,
          color: PdfColors.white,
        ),
      ),
    );
  }

  static pw.Widget _tableCell(String text) {
    return pw.Padding(
      padding: const pw.EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      child: pw.Text(
        text,
        style: pw.TextStyle(fontSize: 10, color: PdfColor.fromHex('#333333')),
      ),
    );
  }

  static String _formattedDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/'
        '${now.month.toString().padLeft(2, '0')}/'
        '${now.year}';
  }
}

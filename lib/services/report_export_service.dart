import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import '../models/delivery_export_model.dart';

typedef DeliveryFileSharer =
    Future<bool> Function(DeliveryExportFile file, Rect origin);

class ReportExportService {
  ReportExportService._();

  static Future<bool> share(DeliveryExportFile file, Rect origin) async {
    final result = await Share.shareXFiles(
      [XFile.fromData(file.bytes, mimeType: file.mimeType)],
      fileNameOverrides: [file.fileName],
      subject: 'Relatório pessoal MeatShop',
      sharePositionOrigin: origin,
    );
    return result.status != ShareResultStatus.dismissed;
  }
}

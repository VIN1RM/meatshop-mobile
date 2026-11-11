import 'dart:ui';
import 'package:share_plus/share_plus.dart';
import '../models/delivery_export_model.dart';

enum DeliveryShareOutcome { success, dismissed, unavailable }

typedef DeliveryFileSharer =
    Future<DeliveryShareOutcome> Function(DeliveryExportFile file, Rect origin);

class ReportExportService {
  ReportExportService._();

  static Future<DeliveryShareOutcome> share(
    DeliveryExportFile file,
    Rect origin,
  ) async {
    final result = await Share.shareXFiles(
      [XFile.fromData(file.bytes, mimeType: file.mimeType)],
      fileNameOverrides: [file.fileName],
      subject: 'Relatório pessoal MeatShop',
      sharePositionOrigin: origin,
    );
    return switch (result.status) {
      ShareResultStatus.success => DeliveryShareOutcome.success,
      ShareResultStatus.dismissed => DeliveryShareOutcome.dismissed,
      ShareResultStatus.unavailable => DeliveryShareOutcome.unavailable,
    };
  }
}

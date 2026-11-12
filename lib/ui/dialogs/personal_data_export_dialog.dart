import 'package:flutter/material.dart';
import '../../models/delivery_export_model.dart';
import 'delivery_export/delivery_export_dialog.dart';

abstract final class PersonalDataExportDialog {
  static Future<void> show(BuildContext context) =>
      DeliveryExportDialog.show(context, report: DeliveryReportType.personal);
}

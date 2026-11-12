import '../../core/network/cancellation_token.dart';
import '../../models/delivery_export_model.dart';

abstract interface class DeliveryExportRepository {
  String? get accountId;
  Future<DeliveryExportFile> export(
    DeliveryExportRequest request, {
    CancellationToken? cancellationToken,
  });
}

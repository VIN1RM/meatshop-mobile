import 'dart:async';
import 'dart:typed_data';
import 'package:meatshop_mobile/core/network/cancellation_token.dart';
import 'package:meatshop_mobile/data/repositories/delivery_export_repository.dart';
import 'package:meatshop_mobile/models/delivery_export_model.dart';

class FakeDeliveryExportRepository implements DeliveryExportRepository {
  @override
  String? accountId = '7';
  int calls = 0;
  DeliveryExportRequest? lastRequest;
  CancellationToken? lastCancellation;
  Object? failure;
  Completer<DeliveryExportFile>? pending;
  final file = DeliveryExportFile(
    bytes: Uint8List.fromList([37, 80, 68, 70, 45]),
    fileName: 'ganhos.pdf',
    mimeType: 'application/pdf',
  );

  @override
  Future<DeliveryExportFile> export(
    DeliveryExportRequest request, {
    CancellationToken? cancellationToken,
  }) async {
    calls++;
    lastRequest = request;
    lastCancellation = cancellationToken;
    if (failure != null) throw failure!;
    return pending == null ? file : pending!.future;
  }
}

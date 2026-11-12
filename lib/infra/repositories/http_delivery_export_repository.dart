import '../../core/network/api_failure.dart';
import '../../core/network/cancellation_token.dart';
import '../../data/repositories/delivery_export_repository.dart';
import '../../models/delivery_export_model.dart';
import '../http/api_client.dart';

class HttpDeliveryExportRepository implements DeliveryExportRepository {
  HttpDeliveryExportRepository(this.client);
  final ApiClient client;
  @override
  String? get accountId => client.accountId;

  @override
  Future<DeliveryExportFile> export(
    DeliveryExportRequest request, {
    CancellationToken? cancellationToken,
  }) async {
    final bytes = await client.download(
      '/delivery/me/exports',
      query: request.toQuery(),
      cancellationToken: cancellationToken,
    );
    final pdf = request.format == DeliveryExportFormat.pdf;
    final valid = pdf
        ? bytes.length >= 5 && String.fromCharCodes(bytes.take(5)) == '%PDF-'
        : bytes.length >= 4 &&
              bytes[0] == 80 &&
              bytes[1] == 75 &&
              bytes[2] == 3 &&
              bytes[3] == 4;
    if (!valid) {
      throw const ApiFailure(
        kind: ApiFailureKind.malformedResponse,
        message: 'O arquivo recebido está inválido. Tente novamente.',
        code: 'MALFORMED_EXPORT',
      );
    }
    return DeliveryExportFile(
      bytes: bytes,
      fileName:
          'meatshop-entregador-${request.report.fileLabel}.${request.format.name}',
      mimeType: pdf
          ? 'application/pdf'
          : 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    );
  }
}

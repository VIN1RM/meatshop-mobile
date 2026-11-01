import 'dart:ui';
import 'package:flutter/foundation.dart';
import '../core/network/api_failure.dart';
import '../core/network/cancellation_token.dart';
import '../data/repositories/delivery_export_repository.dart';
import '../models/delivery_export_model.dart';
import '../services/report_export_service.dart';

class DeliveryExportController extends ChangeNotifier {
  DeliveryExportController({
    required this.repository,
    this.shareFile = ReportExportService.share,
    required this.isAllowed,
  });
  final DeliveryExportRepository repository;
  final DeliveryFileSharer shareFile;
  final bool Function() isAllowed;
  CancellationToken? _request;
  bool _disposed = false;
  bool busy = false;
  String? error;
  String? status;

  Future<void> export(DeliveryExportRequest request, Rect origin) async {
    if (busy || _disposed) return;
    error = null;
    status = null;
    if (!_validate(request)) {
      notifyListeners();
      return;
    }
    busy = true;
    final account = repository.accountId;
    final cancellation = _request = CancellationToken();
    notifyListeners();
    try {
      await _generateAndShare(request, origin, cancellation, account);
    } catch (failure) {
      if (_current(cancellation, account)) {
        error = failure is ApiFailure
            ? failure.message
            : 'Não foi possível preparar ou compartilhar o arquivo. Tente novamente.';
      }
    } finally {
      if (!_disposed) {
        busy = false;
        _request = null;
        notifyListeners();
      }
    }
  }

  Future<void> _generateAndShare(
    DeliveryExportRequest request,
    Rect origin,
    CancellationToken cancellation,
    String? account,
  ) async {
    final file = await repository.export(
      request,
      cancellationToken: cancellation,
    );
    if (!_current(cancellation, account)) return;
    final shared = await shareFile(file, origin);
    if (_current(cancellation, account)) {
      status = shared
          ? 'Arquivo preparado. Compartilhamento solicitado.'
          : 'Compartilhamento cancelado. Você pode tentar novamente.';
    }
  }

  bool _validate(DeliveryExportRequest request) {
    if (!isAllowed()) {
      error = 'Esta opção está disponível apenas no perfil de entregador.';
      return false;
    }
    if (request.report != DeliveryReportType.personal &&
        (request.from == null ||
            request.to == null ||
            request.from!.isAfter(request.to!))) {
      error = 'A data inicial deve ser anterior ou igual à data final.';
      return false;
    }
    return true;
  }

  bool _current(CancellationToken request, String? account) =>
      !_disposed &&
      !request.isCancelled &&
      repository.accountId == account &&
      isAllowed();
  void cancel() {
    _request?.cancel();
  }

  @override
  void dispose() {
    _disposed = true;
    cancel();
    super.dispose();
  }
}

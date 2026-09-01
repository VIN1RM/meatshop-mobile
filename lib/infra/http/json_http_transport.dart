import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../core/config/api_config.dart';
import '../../core/network/api_failure.dart';
import '../../core/network/cancellation_token.dart';

final class JsonHttpTransport {
  JsonHttpTransport({required ApiConfig config, http.Client? client})
    : _config = config,
      _client = client ?? http.Client();

  final ApiConfig _config;
  final http.Client _client;

  Future<Object?> send({
    required String method,
    required String path,
    Map<String, Object?> query = const {},
    Map<String, String> headers = const {},
    Object? body,
    CancellationToken? cancellationToken,
  }) async {
    if (cancellationToken?.isCancelled ?? false) {
      throw const ApiFailure(
        kind: ApiFailureKind.cancelled,
        message: 'A requisição foi cancelada.',
        code: 'REQUEST_CANCELLED',
      );
    }

    final uri = _config.resolve(path, query);
    var timedOut = false;
    final abort = Completer<void>();
    final timeout = Timer(_config.requestTimeout, () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    cancellationToken?.whenCancelled.then((_) {
      if (!abort.isCompleted) abort.complete();
    });

    final request =
        http.AbortableRequest(
            method.toUpperCase(),
            uri,
            abortTrigger: abort.future,
          )
          ..headers.addAll({
            'accept': 'application/json',
            if (body != null) 'content-type': 'application/json; charset=utf-8',
            ...headers,
          });
    if (body != null) request.body = jsonEncode(body);

    try {
      final streamedResponse = await _client.send(request);
      final response = await http.Response.fromStream(streamedResponse);
      final payload = _decodeBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _failureFromResponse(response, payload);
      }
      return payload;
    } on http.RequestAbortedException catch (_) {
      if (timedOut) {
        throw const ApiFailure(
          kind: ApiFailureKind.timeout,
          message: 'O servidor demorou para responder. Tente novamente.',
          code: 'REQUEST_TIMEOUT',
        );
      }
      throw const ApiFailure(
        kind: ApiFailureKind.cancelled,
        message: 'A requisição foi cancelada.',
        code: 'REQUEST_CANCELLED',
      );
    } on http.ClientException catch (_) {
      throw const ApiFailure(
        kind: ApiFailureKind.network,
        message: 'Não foi possível conectar ao servidor.',
        code: 'NETWORK_ERROR',
      );
    } on ApiFailure {
      rethrow;
    } catch (_) {
      throw const ApiFailure(
        kind: ApiFailureKind.unexpected,
        message: 'Não foi possível concluir a requisição.',
        code: 'UNEXPECTED_ERROR',
      );
    } finally {
      timeout.cancel();
    }
  }

  void close() => _client.close();

  Object? _decodeBody(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    try {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } on FormatException {
      if (response.statusCode >= 200 && response.statusCode < 300) {
        throw const ApiFailure(
          kind: ApiFailureKind.malformedResponse,
          message: 'O servidor retornou uma resposta inválida.',
          code: 'MALFORMED_RESPONSE',
        );
      }
      return null;
    }
  }

  ApiFailure _failureFromResponse(http.Response response, Object? payload) {
    final json = payload is Map<String, Object?>
        ? payload
        : const <String, Object?>{};
    final rawMessage = json['message'];
    final message = switch (rawMessage) {
      String value when value.isNotEmpty => value,
      List<Object?> values => values.whereType<String>().join('\n'),
      _ => 'O servidor não conseguiu concluir a operação.',
    };
    final rawDetails = json['details'];
    final retryAfterSeconds = int.tryParse(
      response.headers['retry-after'] ?? '',
    );
    final rawRequestId = json['request_id'] ?? response.headers['x-request-id'];
    return ApiFailure.forStatus(
      statusCode: response.statusCode,
      message: message.isEmpty
          ? 'O servidor não conseguiu concluir a operação.'
          : message,
      code: json['code'] is String ? json['code']! as String : null,
      details: rawDetails is List<Object?> ? rawDetails : const [],
      requestId: rawRequestId is String ? rawRequestId : null,
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds),
    );
  }
}

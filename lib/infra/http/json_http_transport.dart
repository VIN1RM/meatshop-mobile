import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../core/config/api_config.dart';
import '../../core/network/api_failure.dart';
import '../../core/network/cancellation_token.dart';

typedef RequestHeadersProvider = Future<Map<String, String>> Function();

final class JsonHttpTransport {
  JsonHttpTransport({
    required ApiConfig config,
    http.Client? client,
    RequestHeadersProvider? requestHeaders,
  }) : _config = config,
       _client = client ?? http.Client(),
       _requestHeaders = requestHeaders;

  final ApiConfig _config;
  final http.Client _client;
  final RequestHeadersProvider? _requestHeaders;

  Future<Object?> send({
    required String method,
    required String path,
    Map<String, Object?> query = const {},
    Map<String, String> headers = const {},
    Object? body,
    CancellationToken? cancellationToken,
  }) async {
    final dynamicHeaders = await _requestHeaders?.call() ?? const {};
    final uri = _config.resolve(path, query);
    final encodedBody = body == null ? null : utf8.encode(jsonEncode(body));
    return _execute(
      cancellationToken: cancellationToken,
      buildRequest: (abortTrigger) {
        final request =
            http.AbortableRequest(
                method.toUpperCase(),
                uri,
                abortTrigger: abortTrigger,
              )
              ..headers.addAll({
                'accept': 'application/json',
                if (body != null)
                  'content-type': 'application/json; charset=utf-8',
                ...dynamicHeaders,
                ...headers,
              });
        if (encodedBody != null) request.bodyBytes = encodedBody;
        return request;
      },
    );
  }

  Future<Object?> sendMultipart({
    required String path,
    required Uint8List bytes,
    required String fileName,
    required String contentType,
    Map<String, String> headers = const {},
    CancellationToken? cancellationToken,
  }) async {
    _throwIfCancelled(cancellationToken);
    final uri = _config.resolve(path);
    final dynamicHeaders = await _requestHeaders?.call() ?? const {};
    final multipart = http.MultipartRequest('POST', uri)
      ..headers.addAll({
        'accept': 'application/json',
        ...dynamicHeaders,
        ...headers,
      })
      ..files.add(
        http.MultipartFile.fromBytes(
          'file',
          bytes,
          filename: fileName,
          contentType: MediaType.parse(contentType),
        ),
      );
    final encodedBody = await multipart.finalize().toBytes();
    final multipartHeaders = Map<String, String>.from(multipart.headers);
    return _execute(
      cancellationToken: cancellationToken,
      buildRequest: (abortTrigger) =>
          http.AbortableRequest('POST', uri, abortTrigger: abortTrigger)
            ..headers.addAll(multipartHeaders)
            ..bodyBytes = encodedBody,
    );
  }

  Future<Object?> _execute({
    required http.AbortableRequest Function(Future<void>) buildRequest,
    CancellationToken? cancellationToken,
  }) async {
    _throwIfCancelled(cancellationToken);
    var timedOut = false;
    final abort = Completer<void>();
    final timeout = Timer(_config.requestTimeout, () {
      timedOut = true;
      if (!abort.isCompleted) abort.complete();
    });
    cancellationToken?.whenCancelled.then((_) {
      if (!abort.isCompleted) abort.complete();
    });

    try {
      final streamedResponse = await _client.send(buildRequest(abort.future));
      final response = await http.Response.fromStream(streamedResponse);
      final payload = _decodeBody(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        throw _failureFromResponse(response, payload);
      }
      return payload;
    } on http.RequestAbortedException catch (_) {
      throw _abortedFailure(timedOut);
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

  void _throwIfCancelled(CancellationToken? token) {
    if (!(token?.isCancelled ?? false)) return;
    throw const ApiFailure(
      kind: ApiFailureKind.cancelled,
      message: 'A requisição foi cancelada.',
      code: 'REQUEST_CANCELLED',
    );
  }

  ApiFailure _abortedFailure(bool timedOut) => ApiFailure(
    kind: timedOut ? ApiFailureKind.timeout : ApiFailureKind.cancelled,
    message: timedOut
        ? 'O servidor demorou para responder. Tente novamente.'
        : 'A requisição foi cancelada.',
    code: timedOut ? 'REQUEST_TIMEOUT' : 'REQUEST_CANCELLED',
  );

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
      details: json['details'] is List<Object?>
          ? json['details']! as List<Object?>
          : const [],
      requestId: rawRequestId is String ? rawRequestId : null,
      retryAfter: retryAfterSeconds == null
          ? null
          : Duration(seconds: retryAfterSeconds),
    );
  }
}

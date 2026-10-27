import 'dart:async';
import 'dart:convert';
import 'dart:typed_data';

import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';

import '../../core/config/api_config.dart';
import 'api_asset_resolver.dart';
import '../../core/network/api_error_localizer.dart';
import '../../core/network/api_failure.dart';
import '../../core/network/cancellation_token.dart';

typedef RequestHeadersProvider = Future<Map<String, String>> Function();

final class JsonHttpTransport {
  static const clientPlatformHeader = 'x-client-platform';
  static const clientPlatform = 'mobile';

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
    Duration? timeout,
  }) async {
    final dynamicHeaders = await _requestHeaders?.call() ?? const {};
    final uri = _config.resolve(path, query);
    final encodedBody = body == null ? null : utf8.encode(jsonEncode(body));
    return _execute(
      cancellationToken: cancellationToken,
      timeout: timeout,
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
                clientPlatformHeader: clientPlatform,
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
        clientPlatformHeader: clientPlatform,
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
    Duration? timeout,
  }) async {
    _throwIfCancelled(cancellationToken);
    var timedOut = false;
    final abort = Completer<void>();
    final timeoutTimer = Timer(timeout ?? _config.requestTimeout, () {
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
      return ApiAssetResolver(_config).resolve(payload);
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
      timeoutTimer.cancel();
    }
  }

  Stream<String> streamSse({
    required String path,
    required Object body,
    Map<String, String> headers = const {},
    CancellationToken? cancellationToken,
  }) async* {
    _throwIfCancelled(cancellationToken);
    final abort = Completer<void>();
    final timer = Timer(const Duration(seconds: 55), () {
      if (!abort.isCompleted) abort.complete();
    });
    cancellationToken?.whenCancelled.then((_) {
      if (!abort.isCompleted) abort.complete();
    });
    try {
      final dynamicHeaders =
          await _requestHeaders?.call() ?? const <String, String>{};
      final request =
          http.AbortableRequest(
              'POST',
              _config.resolve(path),
              abortTrigger: abort.future,
            )
            ..headers.addAll({
              ...dynamicHeaders,
              ...headers,
              'accept': 'text/event-stream',
              'content-type': 'application/json; charset=utf-8',
              clientPlatformHeader: clientPlatform,
            })
            ..bodyBytes = utf8.encode(jsonEncode(body));
      final response = await _client.send(request);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final value = await http.Response.fromStream(response);
        throw _failureFromResponse(value, _decodeBody(value));
      }
      var data = <String>[];
      await for (final line
          in response.stream
              .transform(utf8.decoder)
              .transform(const LineSplitter())) {
        _throwIfCancelled(cancellationToken);
        if (line.isEmpty) {
          if (data.isNotEmpty) {
            yield data.join('\n');
            data = [];
          }
        } else if (line.startsWith('data:')) {
          data.add(line.substring(5).trimLeft());
        }
      }
      if (data.isNotEmpty) yield data.join('\n');
    } on http.RequestAbortedException {
      throw _abortedFailure(!(cancellationToken?.isCancelled ?? false));
    } finally {
      timer.cancel();
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
    final code = json['code'] is String ? json['code']! as String : null;
    final message = ApiErrorLocalizer.translate(
      code: code,
      statusCode: response.statusCode,
    );
    final lockedUntil = DateTime.tryParse('${json['locked_until'] ?? ''}');
    final retryAfterSeconds = int.tryParse(
      response.headers['retry-after'] ??
          '${json['retry_after_seconds'] ?? lockedUntil?.difference(DateTime.now()).inSeconds ?? ''}',
    );
    final rawRequestId = json['request_id'] ?? response.headers['x-request-id'];
    return ApiFailure.forStatus(
      statusCode: response.statusCode,
      message: message,
      code: code,
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

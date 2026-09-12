import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:geolocator/geolocator.dart';
import '../../core/network/api_failure.dart';
import '../../data/repositories/delivery_repository.dart';
import '../../services/delivery_location_source.dart';

class LocationSharingController extends ChangeNotifier {
  LocationSharingController({
    required this.repository,
    DeliveryLocationSource? source,
  }) : source = source ?? GeolocatorDeliverySource();
  final DeliveryRepository repository;
  final DeliveryLocationSource source;
  StreamSubscription<Position>? _subscription;
  Timer? _heartbeat;
  Timer? _revocationRetry;
  final Set<int> _pendingRevocations = {};
  bool _revoking = false;
  int _generation = 0;
  int? _orderId;
  String? _session;
  bool _sending = false;
  bool _acquiring = false;
  bool _disposed = false;
  bool starting = false;
  bool sharing = false;
  String? message;
  DateTime? lastSent;
  DateTime? _lastAttempt;
  DateTime? _lastCapture;

  void _notify() {
    if (!_disposed) notifyListeners();
  }

  Future<bool> start(int orderId) async {
    if (starting) return false;
    starting = true;
    final stopping = stop();
    final generation = _generation;
    await stopping;
    if (generation != _generation || _disposed) {
      starting = false;
      _notify();
      return false;
    }
    starting = true;
    message = null;
    lastSent = null;
    _notify();
    try {
      await _flushRevocations();
      if (_pendingRevocations.contains(orderId)) {
        throw StateError(
          'Aguarde a conexão para confirmar a pausa anterior e retomar.',
        );
      }
      if (!await source.enabled()) {
        throw StateError('Ative o GPS nas configurações do aparelho.');
      }
      var permission = await source.permission();
      if (permission == LocationPermission.denied) {
        permission = await source.requestPermission();
      }
      if (permission != LocationPermission.always &&
          permission != LocationPermission.whileInUse) {
        throw StateError(
          'Permita a localização nas configurações para compartilhar a entrega.',
        );
      }
      if (generation != _generation || _disposed) return false;
      final session = await repository.setLocationSharing(orderId, true);
      if (generation != _generation || _disposed) {
        await repository.setLocationSharing(orderId, false);
        return false;
      }
      if (session == null || session.isEmpty) {
        throw StateError(
          'O servidor não confirmou o compartilhamento. Tente novamente.',
        );
      }
      _session = session;
      _orderId = orderId;
      sharing = true;
      _lastAttempt = null;
      _lastCapture = null;
      _subscription = source.positions().listen(
        (p) => unawaited(_send(p, generation)),
        onError: (Object error) {
          message =
              'O GPS parou de responder. Verifique a permissão e tente retomar.';
          unawaited(stop());
        },
      );
      _heartbeat = Timer.periodic(
        const Duration(seconds: 10),
        (_) => unawaited(_capture(generation)),
      );
      await _capture(generation);
      return sharing;
    } catch (error) {
      if (generation == _generation) {
        message = error is StateError
            ? error.message
            : 'Não foi possível iniciar o compartilhamento. Tente novamente.';
        await stop();
      }
      return false;
    } finally {
      starting = false;
      _notify();
    }
  }

  Future<void> _capture(int generation) async {
    if (_acquiring || !sharing || generation != _generation) return;
    _acquiring = true;
    try {
      if (!await source.enabled()) {
        message = 'GPS desligado. Ative-o e retome o compartilhamento.';
        await stop();
        return;
      }
      await _send(await source.current(), generation);
    } catch (_) {
      if (generation == _generation) {
        message = 'Aguardando uma posição atual do GPS.';
        _notify();
      }
    } finally {
      _acquiring = false;
    }
  }

  Future<void> _send(Position position, int generation) async {
    if (generation != _generation || !sharing || _sending || _session == null) {
      return;
    }
    final now = DateTime.now();
    if (_lastAttempt != null && now.difference(_lastAttempt!).inSeconds < 10) {
      return;
    }
    final age = now.difference(position.timestamp).inSeconds;
    if (position.isMocked ||
        !position.accuracy.isFinite ||
        position.accuracy > 150 ||
        position.accuracy < 0 ||
        age > 45 ||
        age < -10) {
      message =
          'Sinal impreciso. Ative a localização precisa e aguarde em uma área aberta.';
      _notify();
      return;
    }
    if (_lastCapture != null && !position.timestamp.isAfter(_lastCapture!)) {
      return;
    }
    _sending = true;
    _lastAttempt = now;
    try {
      await repository.sendLocation(
        _orderId!,
        position.latitude,
        position.longitude,
        accuracy: position.accuracy,
        capturedAt: position.timestamp,
        sessionId: _session!,
        sampleId: _uuid(),
        isMocked: position.isMocked,
      );
      if (generation == _generation) {
        lastSent = DateTime.now();
        _lastCapture = position.timestamp;
        message = null;
      }
    } on ApiFailure catch (error) {
      if (generation != _generation) return;
      if ([401, 403, 404].contains(error.statusCode) ||
          error.code == 'TRACKING_ENDED') {
        message =
            'Compartilhamento encerrado. Atualize a entrega para continuar.';
        await stop();
      } else {
        message = 'Aguardando conexão ou um novo sinal de GPS.';
      }
    } catch (_) {
      if (generation == _generation) {
        message = 'Sem conexão. O envio será retomado com uma posição atual.';
      }
    } finally {
      _sending = false;
      _notify();
    }
  }

  Future<void> stop() async {
    ++_generation;
    final orderId = _orderId;
    _orderId = null;
    _session = null;
    sharing = false;
    _heartbeat?.cancel();
    _heartbeat = null;
    await _subscription?.cancel();
    _subscription = null;
    _notify();
    if (orderId != null) {
      _pendingRevocations.add(orderId);
      await _flushRevocations();
    }
  }

  Future<void> _flushRevocations() async {
    if (_revoking) return;
    _revoking = true;
    try {
      for (final id in _pendingRevocations.toList()) {
        try {
          await repository.setLocationSharing(id, false);
          _pendingRevocations.remove(id);
        } on ApiFailure catch (error) {
          if ([401, 403, 404].contains(error.statusCode)) {
            _pendingRevocations.remove(id);
          }
        } catch (_) {}
      }
    } finally {
      _revoking = false;
      if (_pendingRevocations.isNotEmpty && !_disposed) {
        _revocationRetry ??= Timer.periodic(
          const Duration(seconds: 10),
          (_) => unawaited(_flushRevocations()),
        );
      } else {
        _revocationRetry?.cancel();
        _revocationRetry = null;
      }
    }
  }

  static String _uuid() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    bytes[6] = (bytes[6] & 15) | 64;
    bytes[8] = (bytes[8] & 63) | 128;
    final hex = bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
    return '${hex.substring(0, 8)}-${hex.substring(8, 12)}-${hex.substring(12, 16)}-${hex.substring(16, 20)}-${hex.substring(20)}';
  }

  @override
  void dispose() {
    _disposed = true;
    _revocationRetry?.cancel();
    unawaited(stop());
    super.dispose();
  }
}

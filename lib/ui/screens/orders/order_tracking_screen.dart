import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/realtime_repository.dart';
import '../../../models/order_model.dart';
import '../../../core/network/api_failure.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({super.key, required this.orderId});
  final int orderId;
  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  final _map = MapController();
  RealtimeRepository? _realtime;
  StreamSubscription<Map<String, Object?>>? _positions;
  StreamSubscription<Map<String, Object?>>? _statuses;
  StreamSubscription<RealtimeConnectionState>? _connection;
  Timer? _timer;
  DeliveryTrackingPoint? _point;
  DateTime? _pointReceivedAt;
  OrderModel? _order;
  String? _error;
  bool _busy = false;
  bool _follow = true;
  bool _started = false;
  bool get _ended =>
      _order != null &&
      const {'DELIVERED', 'CANCELLED'}.contains(_order!.status);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _realtime = context.read<BackendRealtimeAccess>().realtime;
    _positions = _realtime?.deliveryLocations.listen((event) {
      if (event['orderId'] != widget.orderId || _ended) return;
      final lat = event['latitude'], lng = event['longitude'];
      final captured = DateTime.tryParse(
        '${event['capturedAt'] ?? event['recordedAt']}',
      );
      if (lat is! num ||
          lng is! num ||
          captured == null ||
          !lat.isFinite ||
          !lng.isFinite ||
          lat.abs() > 90 ||
          lng.abs() > 180) {
        return;
      }
      _accept(
        DeliveryTrackingPoint(
          orderId: widget.orderId,
          latitude: lat.toDouble(),
          longitude: lng.toDouble(),
          recordedAt: captured,
          accuracy: (event['accuracy'] as num?)?.toDouble(),
        ),
      );
    });
    _statuses = _realtime?.statuses.listen((event) {
      if (event['orderId'] == widget.orderId) unawaited(_refresh());
    });
    _connection = _realtime?.connection.listen((_) => unawaited(_refresh()));
    unawaited(_realtime?.subscribeDelivery(widget.orderId));
    unawaited(_refresh());
    _timer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => unawaited(_refresh()),
    );
  }

  void _accept(DeliveryTrackingPoint point) {
    if (!mounted ||
        _ended ||
        (_point != null && !point.recordedAt.isAfter(_point!.recordedAt))) {
      return;
    }
    setState(() {
      _point = point;
      _pointReceivedAt = DateTime.now();
      _error = null;
    });
    if (_follow) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _map.move(LatLng(point.latitude, point.longitude), 16);
      });
    }
  }

  Future<void> _refresh() async {
    if (_busy || !mounted) return;
    _busy = true;
    final started = DateTime.now();
    final deliveries = context.read<DeliveryRepository>();
    final orders = context.read<OrderRepository>();
    try {
      final order = await orders.get('${widget.orderId}');
      if (!mounted) return;
      final firstLoad = _order == null;
      final courierChanged =
          _order != null && _order!.deliveryPersonId != order.deliveryPersonId;
      setState(() {
        _order = order;
        if (courierChanged) _point = null;
        _error = null;
      });
      if (firstLoad &&
          order.destination?.lat != null &&
          order.destination?.lng != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted && _point == null) {
            _map.move(
              LatLng(order.destination!.lat!, order.destination!.lng!),
              16,
            );
          }
        });
      }
      if (_ended) {
        setState(() => _point = null);
        _timer?.cancel();
        return;
      }
      final point = await deliveries.latestTracking(widget.orderId);
      if (!mounted) return;
      if (point != null) {
        _accept(point);
      } else if (_pointReceivedAt == null ||
          !_pointReceivedAt!.isAfter(started)) {
        setState(() => _point = null);
      }
    } on ApiFailure catch (error) {
      if (mounted) {
        setState(() {
          _error = error.message;
          if ([401, 403, 404].contains(error.statusCode)) {
            _point = null;
            _timer?.cancel();
          }
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _error =
              'Sem conexão. A última posição pode estar desatualizada.',
        );
      }
    } finally {
      _busy = false;
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _positions?.cancel();
    _statuses?.cancel();
    _connection?.cancel();
    _realtime?.unsubscribeDelivery(widget.orderId);
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final destination = _order?.destination;
    final dest = destination?.lat != null && destination?.lng != null
        ? LatLng(destination!.lat!, destination.lng!)
        : null;
    final point = _point == null
        ? null
        : LatLng(_point!.latitude, _point!.longitude);
    final age = _point == null
        ? null
        : DateTime.now().difference(_point!.recordedAt).inSeconds;
    final signal = _ended
        ? 'Entrega encerrada'
        : age == null
        ? 'Aguardando compartilhamento do entregador'
        : age <= 30
        ? 'Posição atualizada'
        : 'Última posição há $age segundos';
    return Scaffold(
      appBar: AppBar(
        title: Text('Entrega #${widget.orderId}'),
        actions: [
          IconButton(
            onPressed: _refresh,
            icon: const Icon(Icons.refresh),
            tooltip: 'Atualizar',
          ),
        ],
      ),
      body: Column(
        children: [
          ListTile(
            title: Text(signal),
            subtitle: Text(
              _error ?? (destination?.fullAddress ?? 'Carregando destino…'),
            ),
          ),
          if (_point?.accuracy != null)
            Text('Precisão estimada: ${_point!.accuracy!.round()} m'),
          Expanded(
            child: FlutterMap(
              mapController: _map,
              options: MapOptions(
                initialCenter: point ?? dest ?? const LatLng(-14.2, -51.9),
                initialZoom: point == null && dest == null ? 4 : 16,
                onPositionChanged: (_, gesture) {
                  if (gesture && _follow) setState(() => _follow = false);
                },
              ),
              children: [
                TileLayer(
                  urlTemplate: const String.fromEnvironment(
                    'MAP_TILE_URL',
                    defaultValue:
                        'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  ),
                  userAgentPackageName: 'com.meatshop.mobile',
                ),
                if (point != null && _point?.accuracy != null)
                  CircleLayer(
                    circles: [
                      CircleMarker(
                        point: point,
                        radius: _point!.accuracy!,
                        useRadiusInMeter: true,
                        color: Colors.blue.withValues(alpha: 0.12),
                      ),
                    ],
                  ),
                MarkerLayer(
                  markers: [
                    if (dest != null)
                      Marker(
                        point: dest,
                        width: 44,
                        height: 44,
                        child: const Tooltip(
                          message: 'Destino',
                          child: Icon(Icons.home, color: Colors.red, size: 36),
                        ),
                      ),
                    if (point != null)
                      Marker(
                        point: point,
                        width: 44,
                        height: 44,
                        child: const Tooltip(
                          message: 'Entregador',
                          child: Icon(
                            Icons.delivery_dining,
                            color: Colors.blue,
                            size: 36,
                          ),
                        ),
                      ),
                  ],
                ),
                const SimpleAttributionWidget(
                  source: Text('© OpenStreetMap contributors'),
                ),
              ],
            ),
          ),
          SafeArea(
            top: false,
            child: TextButton.icon(
              onPressed: point == null
                  ? null
                  : () {
                      setState(() => _follow = true);
                      _map.move(point, 16);
                    },
              icon: const Icon(Icons.my_location),
              label: const Text('Seguir entregador'),
            ),
          ),
        ],
      ),
    );
  }
}

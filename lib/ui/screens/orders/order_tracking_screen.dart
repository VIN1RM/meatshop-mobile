import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../data/repositories/delivery_repository.dart';
import '../../../data/repositories/order_repository.dart';
import '../../../data/repositories/realtime_repository.dart';
import '../../../models/order_model.dart';
import '../../../models/unit_model.dart';
import '../../../data/repositories/marketplace_context.dart';
import '../../../core/network/api_failure.dart';
import '../../widgets/app_header.dart';
import '../../widgets/buttons_widget.dart';

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
  UnitModel? _unit;
  bool _loadingUnit = false;
  String? _unitError;
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
      if (event['orderId'] != widget.orderId ||
          _ended ||
          _order == null ||
          '${event['deliveryPersonId']}' != _order!.deliveryPersonId) {
        return;
      }
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
      if (_unit?.id != order.unitId && !_loadingUnit) {
        unawaited(_loadUnit(order.unitId));
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

  Future<void> _loadUnit(String unitId) async {
    _loadingUnit = true;
    try {
      final unit = await context.read<MarketplaceContext>().repository.getUnit(
        unitId,
      );
      if (!mounted || _order?.unitId != unitId) return;
      final lat = unit.latitude;
      final lng = unit.longitude;
      final valid =
          lat != null &&
          lng != null &&
          lat.isFinite &&
          lng.isFinite &&
          lat.abs() <= 90 &&
          lng.abs() <= 180;
      setState(() {
        _unit = unit;
        _unitError = valid ? null : 'Localização da unidade indisponível.';
      });
      if (valid && _follow) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || !_follow) return;
          final destination = _order?.destination;
          final points = <LatLng>[
            LatLng(lat, lng),
            if (destination?.lat != null && destination?.lng != null)
              LatLng(destination!.lat!, destination.lng!),
            if (_point != null) LatLng(_point!.latitude, _point!.longitude),
          ];
          _map.fitCamera(
            CameraFit.bounds(
              bounds: LatLngBounds.fromPoints(points),
              padding: const EdgeInsets.all(48),
              maxZoom: 16,
            ),
          );
        });
      }
    } catch (_) {
      if (mounted) {
        setState(
          () => _unitError = 'Não foi possível carregar a unidade no mapa.',
        );
      }
    } finally {
      _loadingUnit = false;
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
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: const Color(0xFF2E2E2E),
        body: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Image.asset(
                'assets/images/background.png',
                height: 130,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) => const SizedBox(height: 130),
              ),
            ),
            SafeArea(
              child: Column(
                children: [
                  const AppHeader(showBack: true),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 12, 8),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            'ENTREGA #${widget.orderId}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                        IconButton(
                          onPressed: _refresh,
                          icon: const Icon(Icons.refresh_rounded),
                          color: Colors.white,
                          tooltip: 'Atualizar entrega',
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF5F5F5),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              _ended
                                  ? Icons.check_circle_outline
                                  : Icons.delivery_dining,
                              color: AppColors.redPrimary,
                              size: 22,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                signal,
                                style: const TextStyle(
                                  color: AppColors.dark,
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  height: 1.35,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Text(
                          destination?.fullAddress ?? 'Carregando destino…',
                          style: const TextStyle(
                            color: Color(0xFF555555),
                            fontSize: 12,
                            height: 1.4,
                          ),
                        ),
                        if (_point?.accuracy != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            'Precisão estimada: ${_point!.accuracy!.round()} m',
                            style: const TextStyle(
                              color: Color(0xFF777777),
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (_unitError != null) ...[
                          const SizedBox(height: 6),
                          Text(
                            _unitError!,
                            style: const TextStyle(
                              color: AppColors.redPrimary,
                              fontSize: 12,
                            ),
                          ),
                        ],
                        if (_error != null) ...[
                          const SizedBox(height: 10),
                          Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.redPrimary,
                              fontSize: 12,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF5F5F5),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black26,
                            blurRadius: 12,
                            offset: Offset(0, 4),
                          ),
                        ],
                      ),
                      clipBehavior: Clip.antiAlias,
                      child: FlutterMap(
                        mapController: _map,
                        options: MapOptions(
                          initialCenter:
                              point ?? dest ?? const LatLng(-14.2, -51.9),
                          initialZoom: point == null && dest == null ? 4 : 16,
                          onPositionChanged: (_, gesture) {
                            if (gesture && _follow) {
                              setState(() => _follow = false);
                            }
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
                              if (_unit != null &&
                                  _unitError == null &&
                                  _unit!.latitude != null &&
                                  _unit!.longitude != null)
                                Marker(
                                  point: LatLng(
                                    _unit!.latitude!,
                                    _unit!.longitude!,
                                  ),
                                  width: 44,
                                  height: 44,
                                  child: Tooltip(
                                    message: _unit!.name,
                                    child: Container(
                                      decoration: BoxDecoration(
                                        color: Colors.white,
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color: AppColors.redPrimary,
                                          width: 2,
                                        ),
                                        boxShadow: const [
                                          BoxShadow(
                                            color: Colors.black26,
                                            blurRadius: 4,
                                          ),
                                        ],
                                      ),
                                      child: const Icon(
                                        Icons.storefront_rounded,
                                        color: AppColors.redPrimary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                ),
                              if (dest != null)
                                Marker(
                                  point: dest,
                                  width: 44,
                                  height: 44,
                                  child: const Tooltip(
                                    message: 'Destino',
                                    child: Icon(
                                      Icons.home,
                                      color: AppColors.redPrimary,
                                      size: 36,
                                    ),
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
                  ),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: PrimaryButton(
                      label: 'Seguir entregador',
                      icon: Icons.my_location_rounded,
                      onPressed: point == null
                          ? null
                          : () {
                              setState(() => _follow = true);
                              _map.move(point, 16);
                            },
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

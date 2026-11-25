import 'pickup_order_page.dart';
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
import '../../widgets/buttons_widget.dart';

class OrderTrackingScreen extends StatefulWidget {
  const OrderTrackingScreen({
    super.key,
    required this.orderId,
    this.tileProvider,
  });
  final int orderId;
  final TileProvider? tileProvider;
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
  bool get _pickup => _order?.deliveryType == 'PICKUP';
  UnitModel? _unit;
  bool _loadingUnit = false;
  String? _unitError;
  String? _error;
  bool _busy = false;
  bool _generatingCode = false;
  Future<void> _regenerateCode() async {
    if (_generatingCode || _order?.canShowCustomerCode != true) return;
    setState(() => _generatingCode = true);
    try {
      await context.read<DeliveryRepository>().regenerateCode(
        widget.orderId,
        pickup: false,
      );
      if (!mounted) return;
      await _refresh();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = 'Não foi possível gerar o código. Tente novamente.',
        );
      }
    } finally {
      if (mounted) setState(() => _generatingCode = false);
    }
  }

  bool _follow = true;
  bool _mapReady = false;
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
        point.orderId != widget.orderId ||
        !_validCoordinates(point.latitude, point.longitude) ||
        (_point != null && !point.recordedAt.isAfter(_point!.recordedAt))) {
      return;
    }
    final firstFix = _point == null;
    setState(() {
      _point = point;
      _pointReceivedAt = DateTime.now();
      _error = null;
    });
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _centerOnCourier(resetZoom: firstFix),
    );
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
      if (firstLoad || courierChanged) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _frameLocations());
      }
      if (_unit?.id != order.unitId && !_loadingUnit) {
        unawaited(_loadUnit(order.unitId));
      }
      if (_ended) {
        setState(() => _point = null);
        _timer?.cancel();
        return;
      }
      if (_pickup) return;
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
        _unitError = valid || _pickup
            ? null
            : 'Localização da unidade indisponível.';
      });
      if (valid && _follow && !_pickup) {
        WidgetsBinding.instance.addPostFrameCallback((_) => _frameLocations());
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
    if (_pickup) {
      return PickupOrderPage(
        order: _order!,
        unit: _unit,
        error: _error ?? _unitError,
        generatingCode: _generatingCode,
        onRegenerate: _regenerateCode,
        onRefresh: _refresh,
      );
    }
    final dest = _destinationPoint;
    final point = _point == null
        ? null
        : LatLng(_point!.latitude, _point!.longitude);
    final age = _point == null
        ? null
        : DateTime.now()
              .difference(_point!.recordedAt)
              .inSeconds
              .clamp(0, 999999);
    final fresh = !_ended && age != null && age <= 30;
    final signal = _ended
        ? 'Entrega encerrada'
        : _order == null
        ? 'Carregando entrega…'
        : age == null
        ? 'Aguardando localização do entregador'
        : fresh
        ? 'Localização atualizada'
        : 'Última posição há ${age < 60 ? '$age s' : '${age ~/ 60} min'}';
    final canFollow = point != null && !_ended;
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.dark,
      child: Scaffold(
        backgroundColor: const Color(0xFFF2F2F2),
        body: Stack(
          fit: StackFit.expand,
          children: [
            if (_order == null)
              Center(
                child: _error == null
                    ? const CircularProgressIndicator(
                        color: AppColors.redPrimary,
                      )
                    : const Icon(
                        Icons.wifi_off_rounded,
                        size: 48,
                        color: Colors.grey,
                      ),
              )
            else
              FlutterMap(
                mapController: _map,
                options: MapOptions(
                  initialCenter:
                      point ?? dest ?? _unitPoint ?? const LatLng(-14.2, -51.9),
                  initialZoom:
                      point == null && dest == null && _unitPoint == null
                      ? 4
                      : 16,
                  onMapReady: () {
                    _mapReady = true;
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (_point != null) {
                        _centerOnCourier();
                      } else {
                        _frameLocations();
                      }
                    });
                  },
                  onPositionChanged: (_, gesture) {
                    if (gesture && _follow) setState(() => _follow = false);
                  },
                ),
                children: [
                  TileLayer(
                    tileProvider: widget.tileProvider,
                    urlTemplate: const String.fromEnvironment(
                      'MAP_TILE_URL',
                      defaultValue:
                          'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                    ),
                    userAgentPackageName: 'com.meatshop.mobile',
                  ),
                  if (point != null &&
                      _point?.accuracy != null &&
                      _point!.accuracy!.isFinite &&
                      _point!.accuracy! >= 0)
                    CircleLayer(
                      circles: [
                        CircleMarker(
                          point: point,
                          radius: _point!.accuracy!,
                          useRadiusInMeter: true,
                          color: Colors.blue.withValues(alpha: .12),
                        ),
                      ],
                    ),
                  MarkerLayer(
                    markers: [
                      if (_unitPoint != null)
                        _marker(
                          _unitPoint!,
                          Icons.storefront_rounded,
                          AppColors.dark,
                          _unit!.name,
                        ),
                      if (dest != null)
                        _marker(
                          dest,
                          Icons.home_rounded,
                          AppColors.redPrimary,
                          'Destino',
                        ),
                      if (point != null)
                        _marker(
                          point,
                          Icons.delivery_dining_rounded,
                          const Color(0xFF2563EB),
                          'Entregador',
                        ),
                    ],
                  ),
                  Padding(
                    padding: EdgeInsets.only(
                      left: 12,
                      bottom:
                          MediaQuery.paddingOf(context).bottom +
                          MediaQuery.textScalerOf(
                            context,
                          ).scale(100).clamp(100.0, 200.0).toDouble() +
                          64 +
                          (_error != null || _unitError != null ? 72 : 0),
                    ),
                    child: const Align(
                      alignment: Alignment.bottomLeft,
                      child: DecoratedBox(
                        decoration: BoxDecoration(color: Colors.white70),
                        child: Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 3,
                          ),
                          child: Text(
                            '© OpenStreetMap contributors',
                            maxLines: 2,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              fontSize: 10,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    Material(
                      color: Colors.white,
                      elevation: 3,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.fromLTRB(4, 8, 14, 8),
                        child: Row(
                          children: [
                            IconButton(
                              tooltip: 'Voltar aos pedidos',
                              onPressed: () => Navigator.maybePop(context),
                              icon: const Icon(Icons.arrow_back_rounded),
                              color: AppColors.dark,
                            ),
                            const SizedBox(width: 4),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'Entrega #${widget.orderId}',
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.w800,
                                      color: AppColors.dark,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 5),
                                        child: Icon(
                                          Icons.circle,
                                          size: 7,
                                          color: fresh
                                              ? const Color(0xFF237A45)
                                              : Colors.grey,
                                        ),
                                      ),
                                      const SizedBox(width: 6),
                                      Expanded(
                                        child: Text(
                                          signal,
                                          maxLines: 2,
                                          overflow: TextOverflow.ellipsis,
                                          style: const TextStyle(
                                            fontSize: 12,
                                            height: 1.35,
                                            color: Color(0xFF666666),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const Spacer(),
                    Material(
                      color: Colors.white,
                      elevation: 4,
                      shadowColor: Colors.black26,
                      borderRadius: BorderRadius.circular(20),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            if (_error != null || _unitError != null)
                              Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  _error ?? _unitError!,
                                  maxLines: 3,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    height: 1.35,
                                    color: AppColors.redPrimary,
                                  ),
                                ),
                              ),
                            Wrap(
                              alignment: WrapAlignment.center,
                              spacing: 16,
                              runSpacing: 6,
                              children: [
                                _legend(
                                  Icons.storefront_rounded,
                                  AppColors.dark,
                                  'Açougue',
                                ),
                                _legend(
                                  Icons.home_rounded,
                                  AppColors.redPrimary,
                                  'Destino',
                                ),
                                _legend(
                                  Icons.delivery_dining_rounded,
                                  const Color(0xFF2563EB),
                                  'Entregador',
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: Semantics(
                                toggled: _follow && canFollow,
                                child: FilledButton.icon(
                                  onPressed: !canFollow
                                      ? null
                                      : () {
                                          setState(() => _follow = true);
                                          _centerOnCourier(resetZoom: true);
                                        },
                                  icon: Icon(
                                    _follow && canFollow
                                        ? Icons.gps_fixed_rounded
                                        : Icons.my_location_rounded,
                                    size: 20,
                                  ),
                                  label: Text(
                                    _follow && canFollow
                                        ? 'Seguindo entregador'
                                        : 'Seguir entregador',
                                    textAlign: TextAlign.center,
                                  ),
                                  style: FilledButton.styleFrom(
                                    backgroundColor: AppColors.redPrimary,
                                    foregroundColor: Colors.white,
                                    disabledBackgroundColor: const Color(
                                      0xFFF0F0F0,
                                    ),
                                    disabledForegroundColor: const Color(
                                      0xFF777777,
                                    ),
                                    minimumSize: const Size(0, 48),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  static bool _validCoordinates(num? latitude, num? longitude) =>
      latitude != null &&
      longitude != null &&
      latitude.isFinite &&
      longitude.isFinite &&
      latitude.abs() <= 90 &&
      longitude.abs() <= 180;

  LatLng? get _destinationPoint {
    final destination = _order?.destination;
    return _validCoordinates(destination?.lat, destination?.lng)
        ? LatLng(destination!.lat!, destination.lng!)
        : null;
  }

  LatLng? get _unitPoint =>
      _unitError == null && _validCoordinates(_unit?.latitude, _unit?.longitude)
      ? LatLng(_unit!.latitude!, _unit!.longitude!)
      : null;

  void _centerOnCourier({bool resetZoom = false}) {
    if (!mounted ||
        !_mapReady ||
        !_follow ||
        _pickup ||
        _point == null ||
        _ended) {
      return;
    }
    _map.move(
      LatLng(_point!.latitude, _point!.longitude),
      resetZoom ? 16 : _map.camera.zoom,
    );
  }

  void _frameLocations() {
    if (!mounted || !_mapReady || !_follow || _pickup || _point != null) return;
    final points = <LatLng>[?_unitPoint, ?_destinationPoint];
    if (points.isEmpty) return;
    _map.fitCamera(
      CameraFit.bounds(
        bounds: LatLngBounds.fromPoints(points),
        padding: EdgeInsets.fromLTRB(
          32,
          MediaQuery.sizeOf(context).height * .18,
          32,
          MediaQuery.sizeOf(context).height * .24,
        ),
        maxZoom: 16,
      ),
    );
  }

  Marker _marker(LatLng point, IconData icon, Color color, String label) =>
      Marker(
        point: point,
        width: 46,
        height: 46,
        child: Tooltip(
          message: label,
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              border: Border.all(color: color, width: 2),
              boxShadow: const [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 6,
                  offset: Offset(0, 2),
                ),
              ],
            ),
            child: Icon(icon, color: color, size: 27),
          ),
        ),
      );

  Widget _legend(IconData icon, Color color, String label) => Row(
    mainAxisSize: MainAxisSize.min,
    children: [
      Icon(icon, color: color, size: 16),
      const SizedBox(width: 5),
      Text(
        label,
        style: const TextStyle(fontSize: 11, color: Color(0xFF555555)),
      ),
    ],
  );
}

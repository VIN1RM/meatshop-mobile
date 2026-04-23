import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:latlong2/latlong.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';
import 'package:provider/provider.dart';

class ActiveDeliveryScreen extends StatelessWidget {
  const ActiveDeliveryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DeliveryProvider>(
      builder: (context, provider, _) {
        final order = provider.activeOrder;
        if (order == null) return const SizedBox.shrink();

        return SafeArea(
          child: Column(
            children: [
              _ActiveDeliveryHeader(orderId: order.id),
              Expanded(
                child: Stack(
                  children: [
                    _DeliveryMap(
                      destinationAddress: order.address.fullAddress,
                      destLat: order.destLat,
                      destLng: order.destLng,
                    ),
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: _ActiveOrderCard(
                        order: order,
                        isLoading: provider.isLoading,
                        onConfirm: () => _onConfirmDelivery(context, provider),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _onConfirmDelivery(
    BuildContext context,
    DeliveryProvider provider,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF2C2C2C),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          'Confirmar entrega?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: const Text(
          'Confirme apenas após entregar o pedido ao cliente.',
          style: TextStyle(color: Colors.white54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: Colors.white38),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirmar'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      await provider.confirmDelivery();
    }
  }
}

class _ActiveDeliveryHeader extends StatelessWidget {
  const _ActiveDeliveryHeader({required this.orderId});
  final int orderId;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      color: const Color(0xFF2C2C2C),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: const BoxDecoration(
              color: Color(0xFF27AE60),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'Entrega em andamento',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          Text(
            '#$orderId',
            style: const TextStyle(color: Colors.white38, fontSize: 14),
          ),
        ],
      ),
    );
  }
}

class _DeliveryMap extends StatefulWidget {
  const _DeliveryMap({
    required this.destinationAddress,
    this.destLat,
    this.destLng,
  });
  final String destinationAddress;
  final double? destLat;
  final double? destLng;

  @override
  State<_DeliveryMap> createState() => _DeliveryMapState();
}

class _DeliveryMapState extends State<_DeliveryMap> {
  final MapController _mapController = MapController();

  LatLng? _currentPosition;
  LatLng? _destination;
  List<LatLng> _routePoints = [];
  StreamSubscription<Position>? _positionStream;

  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  @override
  void dispose() {
    _positionStream?.cancel();
    _mapController.dispose();
    super.dispose();
  }

  Future<void> _initialize() async {
    try {
      await _requestPermission();
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      final current = LatLng(position.latitude, position.longitude);

      final LatLng? dest;
      if (widget.destLat != null && widget.destLng != null) {
        dest = LatLng(widget.destLat!, widget.destLng!);
      } else {
        dest = await _geocodeAddress(widget.destinationAddress);
      }
      if (!mounted) return;
      setState(() {
        _currentPosition = current;
        _destination = dest;
        _isLoading = false;
      });

      if (dest != null) {
        await _fetchRoute(current, dest);
      }

      _positionStream =
          Geolocator.getPositionStream(
            locationSettings: const LocationSettings(
              accuracy: LocationAccuracy.high,
              distanceFilter: 10,
            ),
          ).listen((pos) {
            if (!mounted) return;
            setState(
              () => _currentPosition = LatLng(pos.latitude, pos.longitude),
            );
            _mapController.move(_currentPosition!, _mapController.camera.zoom);
          });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
        _errorMessage = 'Erro ao carregar mapa: $e';
      });
    }
  }

  Future<void> _requestPermission() async {
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.deniedForever) {
      throw Exception('Permissão de localização negada permanentemente.');
    }
  }

  Future<LatLng?> _geocodeAddress(String address) async {
    final encoded = Uri.encodeComponent(address);
    final url = Uri.parse(
      'https://nominatim.openstreetmap.org/search'
      '?q=$encoded&format=json&limit=1&countrycodes=br',
    );

    debugPrint('🔍 Geocodificando: $address');

    final response = await http.get(
      url,
      headers: {'User-Agent': 'meatshop_mobile/1.0'},
    );

    debugPrint('📍 Status: ${response.statusCode}');
    debugPrint('📍 Body: ${response.body}');

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as List;
      if (data.isNotEmpty) {
        final lat = double.parse(data[0]['lat'] as String);
        final lon = double.parse(data[0]['lon'] as String);
        debugPrint('✅ Destino encontrado: $lat, $lon');
        return LatLng(lat, lon);
      }
      debugPrint('❌ Nenhum resultado para o endereço');
    }
    return null;
  }

  Future<void> _fetchRoute(LatLng origin, LatLng destination) async {
    debugPrint('🛣️ Buscando rota...');
    final url = Uri.parse(
      'https://router.project-osrm.org/route/v1/driving/'
      '${origin.longitude},${origin.latitude};'
      '${destination.longitude},${destination.latitude}'
      '?overview=full&geometries=geojson',
    );

    try {
      final response = await http.get(url);
      debugPrint('🛣️ Rota status: ${response.statusCode}');
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final coords = data['routes'][0]['geometry']['coordinates'] as List;
        debugPrint('✅ Rota com ${coords.length} pontos');
        if (!mounted) return;
        setState(() {
          _routePoints = coords
              .map(
                (c) =>
                    LatLng((c[1] as num).toDouble(), (c[0] as num).toDouble()),
              )
              .toList();
        });
      }
    } catch (e) {
      debugPrint('❌ Erro na rota: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(color: Color(0xFFC0392B)),
            SizedBox(height: 12),
            Text(
              'Carregando mapa...',
              style: TextStyle(color: Colors.white54, fontSize: 13),
            ),
          ],
        ),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Text(
          _errorMessage!,
          style: const TextStyle(color: Colors.white54),
        ),
      );
    }

    final current = _currentPosition!;
    final dest = _destination;

    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(initialCenter: current, initialZoom: 14),
      children: [
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.meatshop.mobile',
        ),

        if (_routePoints.isNotEmpty)
          PolylineLayer(
            polylines: [
              Polyline(
                points: _routePoints,
                strokeWidth: 5,
                color: const Color(0xFFC0392B),
              ),
            ],
          ),

        MarkerLayer(
          markers: [
            Marker(
              point: current,
              width: 44,
              height: 44,
              child: Container(
                decoration: BoxDecoration(
                  color: const Color(0xFF2980B9),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.3),
                      blurRadius: 6,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.delivery_dining,
                  color: Colors.white,
                  size: 22,
                ),
              ),
            ),

            if (dest != null)
              Marker(
                point: dest,
                width: 44,
                height: 56,
                child: Column(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B),
                        shape: BoxShape.circle,
                        border: Border.all(color: Colors.white, width: 2),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: const Icon(
                        Icons.home,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),

                    Container(
                      width: 2,
                      height: 10,
                      color: const Color(0xFFC0392B),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ],
    );
  }
}

class _ActiveOrderCard extends StatelessWidget {
  const _ActiveOrderCard({
    required this.order,
    required this.isLoading,
    required this.onConfirm,
  });

  final DeliveryOrder order;
  final bool isLoading;
  final VoidCallback onConfirm;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 10),
            width: 36,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white12,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
            child: Row(
              children: [
                Text(
                  order.clientName,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => Navigator.pushNamed(context, AppRoutes.chat),
                  icon: const Icon(
                    Icons.chat_bubble_outline,
                    color: Colors.white38,
                    size: 20,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.white.withValues(alpha: 0.06),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.location_on,
                  color: Color(0xFFC0392B),
                  size: 18,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    order.address.fullAddress,
                    style: const TextStyle(color: Colors.white70, fontSize: 14),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: PrimaryButton(
              label: 'Confirmar entrega',
              isLoading: isLoading,
              onPressed: onConfirm,
            ),
          ),
        ],
      ),
    );
  }
}

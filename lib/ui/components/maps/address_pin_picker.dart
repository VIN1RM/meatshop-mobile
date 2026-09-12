import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';

/// The point is returned only after explicit confirmation; map center is never
/// silently treated as the user's address.
class AddressPinPicker extends StatefulWidget {
  const AddressPinPicker({super.key, this.initial});
  final LatLng? initial;

  static Future<LatLng?> show(BuildContext context, {LatLng? initial}) =>
      Navigator.of(context).push<LatLng>(
        MaterialPageRoute(
          builder: (_) => AddressPinPicker(initial: initial),
          fullscreenDialog: true,
        ),
      );

  @override
  State<AddressPinPicker> createState() => _AddressPinPickerState();
}

class _AddressPinPickerState extends State<AddressPinPicker> {
  final _map = MapController();
  LatLng? _point;
  String? _message;
  bool _locating = false;

  @override
  void initState() {
    super.initState();
    _point = widget.initial;
  }

  Future<void> _locate() async {
    setState(() {
      _locating = true;
      _message = null;
    });
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw Exception(
          'Ative a localização do aparelho ou escolha o ponto no mapa.',
        );
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw Exception(
          'Sem permissão. Você pode escolher o ponto manualmente.',
        );
      }
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 15),
        ),
      );
      if (!mounted) return;
      final point = LatLng(position.latitude, position.longitude);
      _map.move(point, 18);
      setState(() {
        _point = point;
        _message =
            'Precisão do GPS: ${position.accuracy.round()} m. Ajuste o pino na entrada correta.';
      });
    } catch (error) {
      if (mounted) {
        setState(
          () => _message = error.toString().replaceFirst('Exception: ', ''),
        );
      }
    } finally {
      if (mounted) setState(() => _locating = false);
    }
  }

  @override
  void dispose() {
    _map.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Marcar endereço no mapa')),
    body: Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'O CEP indica uma região aproximada. Toque no mapa para marcar a entrada da casa ou do prédio.',
          ),
        ),
        if (_message != null)
          Padding(padding: const EdgeInsets.all(12), child: Text(_message!)),
        Expanded(
          child: FlutterMap(
            mapController: _map,
            options: MapOptions(
              initialCenter: _point ?? const LatLng(-14.2, -51.9),
              initialZoom: _point == null ? 4 : 17,
              onTap: (_, point) => setState(() => _point = point),
            ),
            children: [
              TileLayer(
                urlTemplate: const String.fromEnvironment(
                  'MAP_TILE_URL',
                  defaultValue:
                      'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                userAgentPackageName: 'com.meatshop.mobile',
                errorTileCallback: (_, _, _) {
                  if (mounted && _message == null) {
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      if (mounted) {
                        setState(
                          () => _message =
                              'Não foi possível carregar parte do mapa. Verifique a conexão.',
                        );
                      }
                    });
                  }
                },
              ),
              if (_point != null)
                MarkerLayer(
                  markers: [
                    Marker(
                      point: _point!,
                      width: 48,
                      height: 48,
                      child: const Icon(
                        Icons.location_pin,
                        color: Colors.red,
                        size: 48,
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
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                IconButton(
                  onPressed: _locating ? null : _locate,
                  tooltip: 'Usar minha localização',
                  icon: _locating
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(),
                        )
                      : const Icon(Icons.my_location),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton(
                    onPressed: _point == null
                        ? null
                        : () => Navigator.pop(context, _point),
                    child: const Text('Confirmar este ponto'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    ),
  );
}

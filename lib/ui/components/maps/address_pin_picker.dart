import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

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
  static const _red = Color(0xFFC0392B);
  static const _background = Color(0xFF3A3A3A);
  static const _surface = Color(0xFFF5F5F5);

  final _map = MapController();
  LatLng? _point;
  String? _message;
  bool _messageIsError = false;
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
      _messageIsError = false;
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
        _messageIsError = false;
        _message =
            'Precisão do GPS: ${position.accuracy.round()} m. Ajuste o pino na entrada correta.';
      });
    } catch (error) {
      if (mounted) {
        setState(() {
          _messageIsError = true;
          _message = error.toString().replaceFirst('Exception: ', '');
        });
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
    backgroundColor: _background,
    body: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: SizedBox(
            height: 130,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) =>
                  Container(color: const Color(0xFF1A1A1A)),
            ),
          ),
        ),
        SafeArea(
          child: Column(
            children: [
              const AppHeader(showBack: true),
              const Padding(
                padding: EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'MARCAR ENDEREÇO NO MAPA',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.5,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Toque no mapa para posicionar o pino exatamente na entrada do endereço.',
                      style: TextStyle(
                        color: Color(0xFFCCCCCC),
                        fontSize: 13,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: _surface,
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
                      initialCenter: _point ?? const LatLng(-14.2, -51.9),
                      initialZoom: _point == null ? 4 : 17,
                      onTap: (_, point) => setState(() {
                        _point = point;
                        _messageIsError = false;
                        _message =
                            'Ponto selecionado. Confira se o pino está na entrada correta.';
                      }),
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
                                setState(() {
                                  _messageIsError = true;
                                  _message =
                                      'Não foi possível carregar parte do mapa. Verifique a conexão.';
                                });
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
                              width: 52,
                              height: 52,
                              child: const Icon(
                                Icons.location_pin,
                                color: _red,
                                size: 52,
                                shadows: [
                                  Shadow(color: Colors.black38, blurRadius: 6),
                                ],
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
              if (_message != null)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _messageIsError
                        ? const Color(0xFF4A2525)
                        : const Color(0xFF294237),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _messageIsError
                          ? Colors.redAccent
                          : const Color(0xFF55B987),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _messageIsError
                            ? Icons.error_outline_rounded
                            : Icons.check_circle_outline_rounded,
                        color: _messageIsError
                            ? Colors.redAccent
                            : const Color(0xFF75D7A5),
                        size: 20,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _message!,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              SafeArea(
                top: false,
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                  child: Column(
                    children: [
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: OutlinedButton.icon(
                          onPressed: _locating ? null : _locate,
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.white,
                            disabledForegroundColor: Colors.white,
                            side: const BorderSide(color: Colors.white70),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(14),
                            ),
                          ),
                          icon: _locating
                              ? const SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.my_location_rounded, size: 20),
                          label: Text(
                            _locating
                                ? 'Obtendo localização...'
                                : 'Usar minha localização',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 10),
                      PrimaryButton(
                        label: 'Confirmar este ponto',
                        icon: Icons.check_rounded,
                        onPressed: _point == null
                            ? null
                            : () => Navigator.pop(context, _point),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

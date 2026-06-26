import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/delivery_person_info_model.dart';
import 'package:meatshop_mobile/services/delivery_person_info_service.dart';
import 'dart:convert';
import 'package:meatshop_mobile/ui/screens/account/profile_photo_viewer_screen.dart';
import 'package:shimmer/shimmer.dart';

class DeliveryPersonCard extends StatefulWidget {
  const DeliveryPersonCard({super.key, required this.deliveryPersonId});

  final String deliveryPersonId;

  @override
  State<DeliveryPersonCard> createState() => _DeliveryPersonCardState();
}

class _DeliveryPersonCardState extends State<DeliveryPersonCard> {
  static const Color _cardBg = Color(0xFFF0F0F0);
  static const Color _dark = Color(0xFF1A1A1A);
  static const Color _red = Color(0xFFBE2C1B);

  final DeliveryPersonInfoService _service = DeliveryPersonInfoService();
  late final Future<DeliveryPersonInfoModel?> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.fetchInfo(widget.deliveryPersonId);
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DeliveryPersonInfoModel?>(
      future: _future,
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return _skeleton();
        }
        final info = snap.data;
        if (info == null) return const SizedBox.shrink();
        return _buildCard(info);
      },
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return value
        .split(' ')
        .map(
          (w) => w.isEmpty
              ? w
              : '${w[0].toUpperCase()}${w.substring(1).toLowerCase()}',
        )
        .join(' ');
  }

  Widget _buildCard(DeliveryPersonInfoModel info) {
    return Container(
      margin: const EdgeInsets.only(top: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: _red.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.delivery_dining_rounded, color: _red, size: 14),
              const SizedBox(width: 6),
              const Text(
                'SEU ENTREGADOR',
                style: TextStyle(
                  color: Color(0xFF888888),
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          GestureDetector(
            onTap: info.photoUrl.isNotEmpty
                ? () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          ProfilePhotoViewerScreen(photoUrl: info.photoUrl),
                    ),
                  )
                : null,
            child: Row(
              children: [
                _Avatar(photoUrl: info.photoUrl, name: info.name),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _capitalize(info.name),
                        style: const TextStyle(
                          color: _dark,
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (info.vehicleModel.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          '${_vehicleTypeLabel(info.vehicleType)} · ${info.vehicleModel}',
                          style: const TextStyle(
                            color: Color(0xFF666666),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                if (info.vehiclePlate.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: _dark,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      info.vehiclePlate.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          if (info.vehiclePhotoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ProfilePhotoViewerScreen(
                    photoUrl: info.vehiclePhotoUrls.first,
                  ),
                ),
              ),
              child: SizedBox(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: _VehiclePhoto(url: info.vehiclePhotoUrls.first),
                ),
              ),
            ),
          ],

          if (info.vehicleColor.isNotEmpty) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.circle_outlined,
                  size: 12,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 4),
                Text(
                  'Cor: ${info.vehicleColor}',
                  style: const TextStyle(
                    color: Color(0xFF888888),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _skeleton() {
    return Shimmer.fromColors(
      baseColor: const Color(0xFFE0E0E0),
      highlightColor: const Color(0xFFF5F5F5),
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(height: 14, width: 120, color: Colors.white),
                  const SizedBox(height: 6),
                  Container(height: 12, width: 80, color: Colors.white),
                ],
              ),
            ),
            Container(
              width: 70,
              height: 28,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _vehicleTypeLabel(String type) {
    switch (type.toUpperCase()) {
      case 'MOTORCYCLE':
        return 'Moto';
      case 'BIKE':
        return 'Bicicleta';
      case 'CAR':
        return 'Carro';
      case 'SCOOTER':
        return 'Scooter';
      default:
        return type;
    }
  }
}

class _Avatar extends StatelessWidget {
  const _Avatar({required this.photoUrl, required this.name});
  final String photoUrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    const Color red = Color(0xFFBE2C1B);
    final initials = name.trim().split(' ').map((w) => w[0]).take(2).join();

    return Container(
      width: 48,
      height: 48,
      decoration: const BoxDecoration(shape: BoxShape.circle),
      child: ClipOval(
        child: photoUrl.isNotEmpty
            ? _buildPhoto(initials, red)
            : _fallback(initials, red),
      ),
    );
  }

  Widget _buildPhoto(String initials, Color red) {
    if (photoUrl.startsWith('data:image')) {
      try {
        final bytes = base64Decode(photoUrl.split(',').last);
        return Image.memory(bytes, fit: BoxFit.cover);
      } catch (_) {
        return _fallback(initials, red);
      }
    }
    return Image.network(
      photoUrl,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _fallback(initials, red),
    );
  }

  Widget _fallback(String initials, Color red) => Container(
    color: red.withValues(alpha: 0.12),
    child: Center(
      child: Text(
        initials.toUpperCase(),
        style: const TextStyle(
          color: Color(0xFFBE2C1B),
          fontSize: 16,
          fontWeight: FontWeight.w800,
        ),
      ),
    ),
  );
}

class _VehiclePhoto extends StatelessWidget {
  const _VehiclePhoto({required this.url});
  final String url;

  @override
  Widget build(BuildContext context) {
    if (url.startsWith('data:image')) {
      final base64Str = url.split(',').last;
      try {
        final bytes = base64Decode(base64Str);
        return Image.memory(
          bytes,
          width: double.infinity,
          height: 160,
          fit: BoxFit.cover,
        );
      } catch (_) {
        return _placeholder();
      }
    }
    return Image.network(
      url,
      width: double.infinity,
      height: 160,
      fit: BoxFit.cover,
      errorBuilder: (_, __, ___) => _placeholder(),
    );
  }

  Widget _placeholder() => Container(
    width: double.infinity,
    height: 160,
    color: const Color(0xFFDDDDDD),
    child: const Icon(Icons.directions_car_outlined, color: Color(0xFFAAAAAA)),
  );
}

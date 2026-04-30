import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';
import 'package:meatshop_mobile/ui/components/sheets/vehicle_edit_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';

import 'package:provider/provider.dart';

class VehicleSettingsScreen extends StatelessWidget {
  const VehicleSettingsScreen({super.key});

  static const Color _red = Color(0xFFC0392B);

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();

    return Material(
      color: const Color(0xFF1A1A1A),
      child: Stack(
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
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 8),
                        _pageTitle(),
                        const SizedBox(height: 20),
                        _buildVehicleCard(context, provider),
                        const SizedBox(height: 24),
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

  Widget _pageTitle() {
    return const Text(
      'CONFIGURAÇÕES DO VEÍCULO',
      style: TextStyle(
        color: _red,
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, DeliveryProvider provider) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: _red.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _iconForVehicle(provider.vehicle),
                  color: const Color.fromARGB(255, 228, 139, 139),
                  size: 24,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      provider.vehicle.isNotEmpty
                          ? provider.vehicle
                          : 'Nenhum veículo cadastrado',
                      style: const TextStyle(
                        color: Colors.white,

                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Veículo principal',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Colors.white12),
          const SizedBox(height: 16),

          _infoRow(
            'Tipo:',
            provider.vehicle.isNotEmpty ? provider.vehicle : '—',
          ),
          const SizedBox(height: 8),
          _infoRow('Modelo:', '—'),
          const SizedBox(height: 8),
          _infoRow('Placa:', '—'),
          const SizedBox(height: 8),
          _infoRow('Cor:', '—'),
          const SizedBox(height: 8),
          _infoRow('Ano:', '—'),

          const SizedBox(height: 18),

          GestureDetector(
            onTap: () => showModalBottomSheet(
              context: context,
              isScrollControlled: true,
              backgroundColor: Colors.transparent,
              builder: (_) => const VehicleEditModal(),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: const [
                Icon(Icons.edit_outlined, color: _red, size: 14),
                SizedBox(width: 4),
                Text(
                  'Editar veículo',
                  style: TextStyle(
                    color: _red,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Colors.white54),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }

  IconData _iconForVehicle(String type) {
    switch (type.toLowerCase()) {
      case 'moto':
      case 'motorcycle':
        return Icons.two_wheeler_outlined;
      case 'carro':
      case 'car':
        return Icons.directions_car_outlined;
      case 'bicicleta':
      case 'bike':
        return Icons.pedal_bike_outlined;
      case 'van':
        return Icons.airport_shuttle_outlined;
      case 'caminhonete':
        return Icons.local_shipping_outlined;
      default:
        return Icons.directions_car_outlined;
    }
  }
}

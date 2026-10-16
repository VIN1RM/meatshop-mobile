import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:meatshop_mobile/providers/delivery/vehicle_provider.dart';
import 'package:meatshop_mobile/ui/components/sheets/vehicle_edit_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:provider/provider.dart';
import 'dart:convert';

class VehicleSettingsScreen extends StatefulWidget {
  const VehicleSettingsScreen({super.key});

  @override
  State<VehicleSettingsScreen> createState() => _VehicleSettingsScreenState();
}

class _VehicleSettingsScreenState extends State<VehicleSettingsScreen> {
  static const Color _red = Color(0xFFC0392B);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = FirebaseAuth.instance.currentUser?.uid;
      if (uid != null) {
        context.read<VehicleProvider>().loadVehicle(uid);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<VehicleProvider>();

    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
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
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const AppHeader(showBack: true),
                Expanded(
                  child: provider.isLoading
                      ? const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC0392B),
                            strokeWidth: 2.5,
                          ),
                        )
                      : SingleChildScrollView(
                          physics: const BouncingScrollPhysics(),
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(height: 8),
                              _pageTitle(),
                              const SizedBox(height: 20),
                              if (provider.error != null) ...[
                                Text(
                                  provider.error!,
                                  style: const TextStyle(color: Colors.white),
                                ),
                                TextButton(
                                  onPressed: () => provider.loadVehicle(
                                    FirebaseAuth.instance.currentUser?.uid ??
                                        '',
                                  ),
                                  child: const Text('Tentar novamente'),
                                ),
                              ],
                              if (provider.vehicles.isEmpty &&
                                  provider.error == null)
                                const Text(
                                  'Nenhum veículo cadastrado.',
                                  style: TextStyle(color: Colors.white38),
                                )
                              else
                                ...provider.vehicles.map(
                                  (v) => _buildVehicleCard(context, v),
                                ),
                              const SizedBox(height: 24),
                              if (provider.error == null)
                                OutlinedButton.icon(
                                  onPressed: () {
                                    provider.prepareNewVehicle();
                                    showModalBottomSheet(
                                      context: context,
                                      isScrollControlled: true,
                                      backgroundColor: Colors.transparent,
                                      builder: (_) => const VehicleEditModal(
                                        vehicleType: 'MOTORCYCLE',
                                        initialData: {},
                                      ),
                                    );
                                  },
                                  icon: const Icon(
                                    Icons.add,
                                    color: Colors.white,
                                  ),
                                  label: const Text(
                                    'Adicionar veículo',
                                    style: TextStyle(color: Colors.white),
                                  ),
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

  Widget _pageTitle() {
    return const Text(
      'CONFIGURAÇÕES DO VEÍCULO',
      style: TextStyle(
        color: Color.fromARGB(255, 255, 255, 255),
        fontSize: 20,
        fontWeight: FontWeight.w900,
        letterSpacing: 1.2,
      ),
    );
  }

  Widget _buildVehicleCard(BuildContext context, Map<String, dynamic> vehicle) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
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
                  color: _red.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: ClipOval(
                  child: () {
                    final photos = List<String>.from(
                      vehicle['photo_urls'] ?? [],
                    );
                    if (photos.isNotEmpty) {
                      final url = photos.first;
                      if (url.startsWith('data:image')) {
                        return Image.memory(
                          base64Decode(url.split(',').last),
                          width: 48,
                          height: 48,
                          fit: BoxFit.cover,
                        );
                      }
                      return Image.network(
                        url,
                        width: 48,
                        height: 48,
                        fit: BoxFit.cover,
                      );
                    }
                    return Icon(
                      _iconForVehicle(vehicle['type'] ?? ''),
                      color: const Color(0xFFC0392B),
                      size: 24,
                    );
                  }(),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      vehicle['type']?.isNotEmpty == true
                          ? vehicle['type']!
                          : 'Nenhum veículo cadastrado',
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),

                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    const Text(
                      'Veículo principal',
                      style: TextStyle(color: Color(0xFF888888), fontSize: 12),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),
          const SizedBox(height: 16),

          _infoRow('Tipo:', vehicle['type'] ?? '—'),

          const SizedBox(height: 18),

          GestureDetector(
            onTap: () async {
              context.read<VehicleProvider>().selectVehicle(vehicle);
              await showModalBottomSheet(
                context: context,
                isScrollControlled: true,
                backgroundColor: Colors.transparent,
                builder: (_) => VehicleEditModal(
                  vehicleType: vehicle['type'] ?? 'MOTORCYCLE',
                ),
              );
              if (context.mounted) {
                final uid = FirebaseAuth.instance.currentUser?.uid;
                if (uid != null) {
                  context.read<VehicleProvider>().loadVehicle(uid);
                }
              }
            },
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
          const SizedBox(height: 12),
          Row(
            children: [
              if (vehicle['is_active'] != true)
                TextButton.icon(
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final id = (vehicle['id'] as num?)?.toInt();
                    if (uid != null && id != null) {
                      try {
                        await context.read<VehicleProvider>().activateVehicle(
                          uid,
                          id,
                        );
                      } catch (_) {
                        if (context.mounted) {
                          CustomSnackBar.error(
                            'Não foi possível atualizar o veículo. Tente novamente.',
                            context: context,
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.check_circle_outline),
                  label: const Text('Tornar principal'),
                ),
              const Spacer(),
              if (vehicle['is_active'] != true)
                TextButton.icon(
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red.shade700,
                  ),
                  onPressed: () async {
                    final uid = FirebaseAuth.instance.currentUser?.uid;
                    final id = (vehicle['id'] as num?)?.toInt();
                    if (uid != null && id != null) {
                      try {
                        await context.read<VehicleProvider>().deleteVehicle(
                          uid,
                          id,
                        );
                      } catch (_) {
                        if (context.mounted) {
                          CustomSnackBar.error(
                            'Não foi possível atualizar o veículo. Tente novamente.',
                            context: context,
                          );
                        }
                      }
                    }
                  },
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Excluir'),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return RichText(
      text: TextSpan(
        style: const TextStyle(fontSize: 13, color: Color(0xFF555555)),
        children: [
          TextSpan(
            text: '$label ',
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
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

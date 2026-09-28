import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import '../../../providers/unit/unit_provider.dart';
import 'address_pin_picker.dart';

class UnitLocationSelector extends StatelessWidget {
  const UnitLocationSelector({super.key});

  Future<void> _choose(BuildContext context, UnitProvider units) async {
    final choice = await showModalBottomSheet<String>(
      context: context,
      isScrollControlled: true,
      builder: (sheet) => SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Onde buscar açougues?',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
              ),
              ListTile(
                leading: const Icon(Icons.my_location),
                title: const Text('Usar minha localização'),
                subtitle: const Text(
                  'Consultar o GPS uma vez para encontrar açougues próximos. Seu endereço de entrega não será alterado.',
                ),
                onTap: () => Navigator.pop(sheet, 'device'),
              ),
              ListTile(
                leading: const Icon(Icons.map_outlined),
                title: const Text('Escolher no mapa'),
                subtitle: const Text(
                  'Alternativa manual, sem precisar de permissão de GPS.',
                ),
                onTap: () => Navigator.pop(sheet, 'manual'),
              ),
              if (units.hasSavedLocation)
                ListTile(
                  leading: const Icon(Icons.home_outlined),
                  title: const Text('Usar endereço padrão'),
                  onTap: () => Navigator.pop(sheet, 'saved'),
                ),
              ListTile(
                leading: const Icon(Icons.storefront_outlined),
                title: const Text('Ver todos os açougues'),
                onTap: () => Navigator.pop(sheet, 'all'),
              ),
            ],
          ),
        ),
      ),
    );
    if (!context.mounted) return;
    switch (choice) {
      case 'device':
        await units.useCurrentLocation();
      case 'manual':
        final point = await AddressPinPicker.show(
          context,
          initial: units.hasDeliveryLocation
              ? LatLng(units.latitude!, units.longitude!)
              : null,
        );
        if (point != null && context.mounted) {
          await units.useManualLocation(point.latitude, point.longitude);
        }
      case 'saved':
        await units.useSavedAddress();
      case 'all':
        await units.showAllUnits();
    }
  }

  @override
  Widget build(BuildContext context) => Consumer<UnitProvider>(
    builder: (context, units, _) => Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextButton.icon(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => _choose(context, units),
            icon: const Icon(Icons.place_outlined, size: 20),
            label: Text(
              units.locating ? 'Obtendo localização…' : units.locationLabel,
            ),
          ),
          if (units.hasDeliveryLocation)
            const Text(
              'Busca até 25 km, respeitando a área de entrega de cada açougue.',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
          if (units.locationError != null)
            Text(
              units.locationError!,
              style: const TextStyle(color: Colors.amber),
            ),
          if (units.error != null)
            TextButton(
              onPressed: () => units.loadUnits(),
              child: const Text(
                'Não foi possível carregar os açougues. Tentar novamente',
              ),
            ),
        ],
      ),
    ),
  );
}

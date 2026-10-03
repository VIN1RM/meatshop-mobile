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
      useSafeArea: true,
      backgroundColor: Colors.transparent,
      builder: (sheet) => _LocationChoiceSheet(units: units),
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

class _LocationChoiceSheet extends StatelessWidget {
  const _LocationChoiceSheet({required this.units});

  static const _red = Color(0xFFC0392B);
  static const _background = Color(0xFFF5F5F5);
  final UnitProvider units;

  @override
  Widget build(BuildContext context) {
    final maxHeight = MediaQuery.sizeOf(context).height * 0.88;
    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: maxHeight),
      child: Container(
        decoration: const BoxDecoration(
          color: _background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(
          20,
          12,
          20,
          20 + MediaQuery.paddingOf(context).bottom,
        ),
        child: SingleChildScrollView(
          physics: const ClampingScrollPhysics(),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFDDDDDD),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Container(
                    width: 42,
                    height: 42,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF4DFDC),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.location_searching_rounded,
                      color: _red,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Onde buscar açougues?',
                          style: TextStyle(
                            color: Color(0xFF1A1A1A),
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 3),
                        Text(
                          'Escolha a região usada para ordenar e filtrar os resultados.',
                          style: TextStyle(
                            color: Color(0xFF777777),
                            fontSize: 12,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(
                      Icons.close_rounded,
                      color: Color(0xFFAAAAAA),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              _LocationOption(
                icon: Icons.my_location_rounded,
                title: 'Usar minha localização',
                description:
                    'Consulta o GPS uma vez. Seu endereço de entrega não será alterado.',
                selected: units.locationMode == UnitLocationMode.device,
                onTap: () => Navigator.pop(context, 'device'),
              ),
              const SizedBox(height: 10),
              _LocationOption(
                icon: Icons.map_outlined,
                title: 'Escolher no mapa',
                description:
                    'Marque uma região manualmente, sem liberar o GPS.',
                selected: units.locationMode == UnitLocationMode.manual,
                onTap: () => Navigator.pop(context, 'manual'),
              ),
              if (units.hasSavedLocation) ...[
                const SizedBox(height: 10),
                _LocationOption(
                  icon: Icons.home_outlined,
                  title: 'Usar endereço padrão',
                  description: 'Busca perto do seu endereço de entrega salvo.',
                  selected: units.locationMode == UnitLocationMode.savedAddress,
                  onTap: () => Navigator.pop(context, 'saved'),
                ),
              ],
              const SizedBox(height: 10),
              _LocationOption(
                icon: Icons.storefront_outlined,
                title: 'Ver todos os açougues',
                description: 'Remove o filtro de proximidade da busca.',
                selected:
                    units.locationMode == UnitLocationMode.all ||
                    (!units.hasDeliveryLocation && !units.hasSavedLocation),
                onTap: () => Navigator.pop(context, 'all'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LocationOption extends StatelessWidget {
  const _LocationOption({
    required this.icon,
    required this.title,
    required this.description,
    required this.selected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String description;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Material(
    color: selected ? const Color(0xFFFBEDEB) : const Color(0xFFEAEAEA),
    borderRadius: BorderRadius.circular(14),
    child: InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 160),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? const Color(0xFFC0392B) : const Color(0xFFD2D2D2),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: selected
                    ? const Color(0xFFC0392B)
                    : const Color(0xFFDCDCDC),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: selected ? Colors.white : const Color(0xFFC0392B),
                size: 21,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(
                      color: Color(0xFF666666),
                      fontSize: 11.5,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(
              selected
                  ? Icons.check_circle_rounded
                  : Icons.chevron_right_rounded,
              color: selected
                  ? const Color(0xFFC0392B)
                  : const Color(0xFFAAAAAA),
              size: 22,
            ),
          ],
        ),
      ),
    ),
  );
}

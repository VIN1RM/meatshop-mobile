import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/enums/vehicle_type.dart';

class VehicleTypeSelector extends StatelessWidget {
  const VehicleTypeSelector({
    super.key,
    required this.selectedValue,
    required this.onSelected,
  });

  final String? selectedValue;
  final ValueChanged<String> onSelected;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final horizontal =
          constraints.maxWidth >= 300 &&
          MediaQuery.textScalerOf(context).scale(14) <= 18;
      final options = VehicleType.values
          .map((type) => _option(type, horizontal))
          .toList();
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Escolha uma opção para adicionar os dados do veículo.',
            style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
          ),
          const SizedBox(height: 12),
          if (horizontal)
            IntrinsicHeight(
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  for (var index = 0; index < options.length; index++) ...[
                    if (index > 0) const SizedBox(width: 10),
                    Expanded(child: options[index]),
                  ],
                ],
              ),
            )
          else
            for (var index = 0; index < options.length; index++) ...[
              if (index > 0) const SizedBox(height: 10),
              options[index],
            ],
        ],
      );
    },
  );

  Widget _option(VehicleType type, bool horizontal) {
    final selected = selectedValue == type.apiValue;
    final icon = switch (type) {
      VehicleType.motorcycle => Icons.two_wheeler,
      VehicleType.car => Icons.directions_car,
      VehicleType.bike => Icons.directions_bike,
    };
    final label = Text(
      type.label,
      textAlign: horizontal ? TextAlign.center : TextAlign.start,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
    );
    return Semantics(
      button: true,
      selected: selected,
      child: Material(
        color: selected ? const Color(0xFF79332D) : const Color(0xFF525252),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: selected ? const Color(0xFFFF8A80) : Colors.white24,
            width: selected ? 2 : 1,
          ),
        ),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => onSelected(type.apiValue),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
            child: horizontal
                ? Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(icon, color: Colors.white, size: 28),
                      const SizedBox(height: 10),
                      label,
                      const SizedBox(height: 8),
                      Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 18,
                        color: selected
                            ? const Color(0xFFFFB4AB)
                            : Colors.white54,
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Icon(icon, color: Colors.white, size: 28),
                      const SizedBox(width: 14),
                      Expanded(child: label),
                      const SizedBox(width: 10),
                      Icon(
                        selected
                            ? Icons.check_circle
                            : Icons.radio_button_unchecked,
                        size: 22,
                        color: selected
                            ? const Color(0xFFFFB4AB)
                            : Colors.white54,
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

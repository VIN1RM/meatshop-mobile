import 'location_sharing_consent.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../../providers/delivery/delivery_provider.dart';

class LocationSharingControls extends StatelessWidget {
  const LocationSharingControls({super.key});
  @override
  Widget build(BuildContext context) {
    final provider = context.watch<DeliveryProvider>();
    final sharing = provider.locationSharing;
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFF383838),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color:
                        (sharing.sharing
                                ? const Color(0xFF66BB6A)
                                : const Color(0xFFC0392B))
                            .withValues(alpha: 0.14),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    sharing.sharing
                        ? Icons.location_on_outlined
                        : Icons.location_off_outlined,
                    color: sharing.sharing
                        ? const Color(0xFF81C784)
                        : const Color(0xFFEF9A9A),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    sharing.sharing
                        ? 'Localização compartilhada'
                        : 'Localização pausada',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              sharing.message ??
                  (sharing.sharing
                      ? sharing.lastSent == null
                            ? 'Aguardando o primeiro sinal de GPS.'
                            : 'Cliente e unidade podem acompanhar sua posição durante esta entrega.'
                      : 'Ative para permitir que o cliente acompanhe sua entrega.'),
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFFC0392B),
                foregroundColor: Colors.white,
                disabledBackgroundColor: const Color(0xFF555555),
                disabledForegroundColor: Colors.white54,
                minimumSize: const Size(double.infinity, 46),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              icon: Icon(sharing.sharing ? Icons.pause : Icons.my_location),
              label: Text(
                sharing.starting
                    ? 'Ativando…'
                    : sharing.sharing
                    ? 'Pausar compartilhamento'
                    : 'Compartilhar localização',
              ),
              onPressed: sharing.starting
                  ? null
                  : () async {
                      if (sharing.sharing) {
                        await sharing.stop();
                        return;
                      }
                      await requestLocationSharing(context, provider);
                    },
            ),
            if (sharing.message != null && !kIsWeb)
              TextButton(
                style: TextButton.styleFrom(foregroundColor: Colors.white70),
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Abrir permissões do aparelho'),
              ),
          ],
        ),
      ),
    );
  }
}

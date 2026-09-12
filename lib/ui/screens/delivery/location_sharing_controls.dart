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
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              sharing.sharing
                  ? 'Localização compartilhada'
                  : 'Localização pausada',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              sharing.message ??
                  (sharing.sharing
                      ? sharing.lastSent == null
                            ? 'Aguardando o primeiro sinal de GPS.'
                            : 'Cliente e unidade podem acompanhar sua posição durante esta entrega.'
                      : 'Ative para permitir que o cliente acompanhe sua entrega.'),
            ),
            const SizedBox(height: 8),
            FilledButton.icon(
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
                onPressed: () => Geolocator.openAppSettings(),
                child: const Text('Abrir permissões do aparelho'),
              ),
          ],
        ),
      ),
    );
  }
}

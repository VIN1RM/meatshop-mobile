import 'package:flutter/material.dart';
import '../../../providers/delivery/delivery_provider.dart';

Future<void> requestLocationSharing(
  BuildContext context,
  DeliveryProvider provider,
) async {
  try {
    final policy = await provider.repository.trackingPolicy();
    final days = policy['retention_days'];
    if (days is! num || days <= 0 || policy['version'] != '2026-09-11') {
      throw StateError(
        'Atualize o aplicativo para consultar a política atual.',
      );
    }
    if (!context.mounted) return;
    final consent = await showDialog<bool>(
      context: context,
      builder: (dialog) => AlertDialog(
        scrollable: true,
        title: const Text('Compartilhar durante esta entrega?'),
        content: Text(
          'O cliente e a equipe autorizada da unidade poderão acompanhar sua posição durante esta entrega, inclusive com a tela bloqueada. '
          'Você pode pausar a qualquer momento nesta tela. O envio termina ao encerrar a entrega. '
          'O prazo de retenção das posições é de ${days.toInt()} dias, com limpeza diária após esse prazo. '
          'Pausar com conexão remove as posições desta entrega. Sem conexão, o envio para imediatamente e a última posição pode aparecer como desatualizada até a sincronização. '
          'O sistema do aparelho pode interromper o GPS, especialmente se o aplicativo for encerrado à força.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialog, false),
            child: const Text('Agora não'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(dialog, true),
            child: const Text('Permitir'),
          ),
        ],
      ),
    );
    if (consent != true || !context.mounted) return;
    final started = await provider.startLocationSharing(consent: true);
    if (!started && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            provider.locationSharing.message ??
                'Fique disponível e verifique as permissões para iniciar.',
          ),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Não foi possível consultar as condições de compartilhamento. Verifique a conexão e tente novamente.',
          ),
        ),
      );
    }
  }
}

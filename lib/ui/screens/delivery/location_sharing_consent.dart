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
      builder: (_) => LocationSharingConsentDialog(retentionDays: days.toInt()),
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

class LocationSharingConsentDialog extends StatelessWidget {
  const LocationSharingConsentDialog({super.key, required this.retentionDays});

  final int retentionDays;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: const Color(0xFF333333),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 16),
      contentPadding: const EdgeInsets.symmetric(horizontal: 24),
      actionsPadding: const EdgeInsets.all(24),
      scrollable: true,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFC0392B).withValues(alpha: 0.16),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: Color(0xFFEF9A9A),
              size: 26,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'Compartilhar durante esta entrega?',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.w800,
              height: 1.25,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: 360,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const _ConsentParagraph(
              'O cliente e a equipe autorizada da unidade poderão acompanhar sua posição durante esta entrega, inclusive com a tela bloqueada.',
            ),
            const _ConsentParagraph(
              'Você pode pausar a qualquer momento nesta tela. O envio termina ao encerrar a entrega.',
            ),
            _ConsentParagraph(
              'O prazo de retenção das posições é de $retentionDays dias, com limpeza diária após esse prazo.',
            ),
            const _ConsentParagraph(
              'Pausar com conexão remove as posições desta entrega. Sem conexão, o envio para imediatamente e a última posição pode aparecer como desatualizada até a sincronização.',
            ),
            const _ConsentParagraph(
              'O sistema do aparelho pode interromper o GPS, especialmente se o aplicativo for encerrado à força.',
            ),
          ],
        ),
      ),
      actions: [
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            onPressed: () => Navigator.pop(context, true),
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              minimumSize: const Size(0, 48),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Permitir compartilhamento',
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.w700),
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: TextButton(
            onPressed: () => Navigator.pop(context, false),
            style: TextButton.styleFrom(
              foregroundColor: Colors.white70,
              minimumSize: const Size(0, 44),
            ),
            child: const Text('Agora não'),
          ),
        ),
      ],
    );
  }
}

class _ConsentParagraph extends StatelessWidget {
  const _ConsentParagraph(this.text);
  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 14),
    child: Text(
      text,
      style: const TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
    ),
  );
}

import 'package:flutter/material.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

enum IntroductionProfile { client, delivery }

/// Contextual help without dialogs or permission requests.
class ProfileQuickGuide extends StatefulWidget {
  const ProfileQuickGuide({super.key, required this.profile});
  final IntroductionProfile profile;

  @override
  State<ProfileQuickGuide> createState() => _ProfileQuickGuideState();
}

class _ProfileQuickGuideState extends State<ProfileQuickGuide> {
  final _service = OnboardingService();
  bool _visible = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final show = await _service.shouldShowGuide(widget.profile.name);
      if (mounted) setState(() => _visible = show);
    } catch (_) {
      // Help remains optional when local preferences are unavailable.
    }
  }

  Future<void> _dismiss() async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      await _service.completeGuide(widget.profile.name);
      if (mounted) setState(() => _visible = false);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Não foi possível salvar. Tente novamente.'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_visible) return const SizedBox.shrink();
    final delivery = widget.profile == IntroductionProfile.delivery;
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Semantics(
            header: true,
            child: Text(
              delivery ? 'Suas primeiras entregas' : 'Seu primeiro pedido',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            delivery
                ? 'Complete os dados do veículo e ative sua disponibilidade para receber ofertas. Ao aceitar uma entrega, confira as instruções e o código de retirada no açougue. O compartilhamento de localização é solicitado durante a entrega e pode ser pausado.'
                : 'Escolha um açougue e monte seu carrinho. No fechamento, selecione entrega ou retirada e consulte os horários disponíveis. Acompanhe o pedido em Pedidos e apresente o código somente no recebimento ou na retirada.',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          TextButton(
            onPressed: _saving ? null : _dismiss,
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFFFFB4AA),
            ),
            child: Text(_saving ? 'Salvando…' : 'Entendi'),
          ),
        ],
      ),
    );
  }
}

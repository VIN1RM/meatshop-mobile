import 'package:flutter/material.dart';
import '../../../models/order_model.dart';
import '../../../models/unit_model.dart';
import '../../widgets/app_header.dart';
import '../../widgets/app_surface.dart';
import '../../widgets/buttons_widget.dart';

class PickupOrderPage extends StatelessWidget {
  const PickupOrderPage({
    super.key,
    required this.order,
    this.unit,
    this.error,
    required this.generatingCode,
    required this.onRegenerate,
    required this.onRefresh,
  });
  final OrderModel order;
  final UnitModel? unit;
  final String? error;
  final bool generatingCode;
  final VoidCallback onRegenerate;
  final Future<void> Function() onRefresh;

  bool get _ended => const {'DELIVERED', 'CANCELLED'}.contains(order.status);
  String get _status => switch (order.status) {
    'PENDING' => 'Aguardando confirmação',
    'CONFIRMED' => 'Pedido confirmado',
    'PREPARING' => 'Seu pedido está em preparo',
    'READY' => 'Pronto para retirada',
    'DELIVERED' => 'Retirado',
    'CANCELLED' => 'Pedido cancelado',
    _ => 'Acompanhe seu pedido',
  };
  int get _step => switch (order.status) {
    'PENDING' => -1,
    'CONFIRMED' => 0,
    'PREPARING' => 1,
    'READY' => 2,
    'DELIVERED' => 3,
    _ => -1,
  };

  @override
  Widget build(BuildContext context) => Theme(
    data: appDarkSurfaceTheme(context),
    child: Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 130,
            child: Image.asset(
              'assets/images/background.png',
              fit: BoxFit.cover,
              errorBuilder: (_, _, _) => const SizedBox.shrink(),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const AppHeader(showBack: true),
                Expanded(
                  child: RefreshIndicator(
                    color: AppColors.redPrimary,
                    onRefresh: onRefresh,
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
                      children: [
                        const Text(
                          'Retirada no balcão',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 23,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Pedido #${order.id} • Sem taxa de entrega',
                          style: const TextStyle(
                            color: Colors.white60,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      color: AppColors.redPrimary.withValues(
                                        alpha: .15,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      _ended
                                          ? Icons.check_circle_outline
                                          : Icons.storefront_outlined,
                                      color: const Color(0xFFFFA99F),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'STATUS DO PEDIDO',
                                          style: TextStyle(
                                            color: Colors.white54,
                                            fontSize: 10,
                                            letterSpacing: 1,
                                          ),
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          _status,
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              if (!_ended) ...[
                                const Padding(
                                  padding: EdgeInsets.symmetric(vertical: 18),
                                  child: Divider(
                                    color: Colors.white10,
                                    height: 1,
                                  ),
                                ),
                                _stage(
                                  0,
                                  'Confirmação',
                                  'O açougue recebe e confirma sua compra.',
                                ),
                                _stage(
                                  1,
                                  'Preparo',
                                  'A equipe separa seus produtos com cuidado.',
                                ),
                                _stage(
                                  2,
                                  'Pronto para retirar',
                                  'Vá até a unidade e apresente seu código.',
                                ),
                              ],
                            ],
                          ),
                        ),
                        const SizedBox(height: 14),
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Row(
                                children: [
                                  Icon(
                                    Icons.place_outlined,
                                    color: Color(0xFFCE8178),
                                    size: 20,
                                  ),
                                  SizedBox(width: 8),
                                  Text(
                                    'Local de retirada',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                unit?.name ?? order.unitName,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                unit?.formattedAddress ??
                                    'Carregando endereço da unidade…',
                                style: const TextStyle(
                                  color: Colors.white60,
                                  fontSize: 13,
                                  height: 1.6,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (order.canShowCustomerCode) ...[
                          const SizedBox(height: 14),
                          _card(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                const Text(
                                  'Código de retirada',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white70,
                                    fontSize: 13,
                                  ),
                                ),
                                const SizedBox(height: 16),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 18,
                                    horizontal: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFF303030),
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(color: Colors.white10),
                                  ),
                                  child: SelectableText(
                                    order.deliveryCode ??
                                        'Ainda não disponível',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: order.deliveryCode == null
                                          ? 14
                                          : 32,
                                      letterSpacing: order.deliveryCode == null
                                          ? 0
                                          : 7,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 14),
                                const Text(
                                  'Mostre este código à equipe do açougue somente ao receber sua compra.',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color: Colors.white60,
                                    fontSize: 12,
                                    height: 1.6,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                TextButton.icon(
                                  onPressed: generatingCode
                                      ? null
                                      : onRegenerate,
                                  style: TextButton.styleFrom(
                                    foregroundColor: const Color(0xFFFFA99F),
                                  ),
                                  icon: const Icon(
                                    Icons.refresh_rounded,
                                    size: 17,
                                  ),
                                  label: Text(
                                    generatingCode
                                        ? 'Gerando…'
                                        : order.deliveryCode == null
                                        ? 'Gerar código de retirada'
                                        : 'Gerar novo código',
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                        if (!_ended && order.status != 'READY') ...[
                          const SizedBox(height: 14),
                          _card(
                            child: const Text(
                              'Seu código de retirada ficará disponível quando o pedido estiver pronto. Aguarde a confirmação antes de ir ao açougue.',
                              style: TextStyle(
                                color: Colors.white70,
                                height: 1.5,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 14),
                        _card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Pagamento',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                order.paymentMethodLabel,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                order.paymentStatusLabel,
                                style: const TextStyle(color: Colors.white70),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Total: ${order.formattedTotal}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                        ),
                        if (error != null) ...[
                          const SizedBox(height: 16),
                          Text(
                            error!,
                            style: const TextStyle(
                              color: Color(0xFFFFA99F),
                              height: 1.5,
                            ),
                          ),
                        ],
                        const SizedBox(height: 24),
                        PrimaryButton(
                          label: 'Atualizar pedido',
                          icon: Icons.refresh_rounded,
                          onPressed: onRefresh,
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
    ),
  );

  Widget _card({required Widget child}) => Container(
    padding: const EdgeInsets.all(18),
    decoration: BoxDecoration(
      color: const Color(0xFF383838),
      borderRadius: BorderRadius.circular(18),
      border: Border.all(color: Colors.white.withValues(alpha: .05)),
    ),
    child: child,
  );

  Widget _stage(int index, String title, String description) {
    final reached = _step >= index;
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            reached ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            color: reached ? const Color(0xFFE78176) : Colors.white24,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: reached ? Colors.white : Colors.white60,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  description,
                  style: const TextStyle(
                    color: Colors.white38,
                    fontSize: 12,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

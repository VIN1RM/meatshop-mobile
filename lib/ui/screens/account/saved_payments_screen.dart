import 'package:flutter/material.dart';
import '../../widgets/app_header.dart';

class SavedPaymentsScreen extends StatelessWidget {
  const SavedPaymentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2E2E2E),
    body: SafeArea(
      child: Column(
        children: [
          const AppHeader(showBack: true),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Text(
                  'FORMAS DE PAGAMENTO',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: const Color(0xFFF5F5F5),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.lock_outline,
                        color: Color(0xFFC0392B),
                        size: 36,
                      ),
                      SizedBox(height: 16),
                      Text(
                        'Pagamento seguro',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 20,
                        ),
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Os meios disponíveis aparecem no checkout de cada açougue. Você pode pagar online pelo Mercado Pago ou escolher uma opção na entrega.',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Seus cartões são informados e gerenciados no ambiente seguro do Mercado Pago. O MeatShop não armazena número de cartão ou CVV.',
                      ),
                      SizedBox(height: 12),
                      Text(
                        'Dinheiro e maquininha ficam a pagar até o recebimento ser registrado pelo açougue.',
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );
}

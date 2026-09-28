import 'package:flutter/material.dart';

class SavedPaymentsScreen extends StatelessWidget {
  const SavedPaymentsScreen({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Formas de pagamento')),
    body: const Padding(
      padding: EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.lock_outline, size: 40),
          SizedBox(height: 16),
          Text(
            'Cartões no checkout seguro',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            'Você informa seu cartão e escolhe as opções disponíveis diretamente no Mercado Pago ao pagar. Cartões da sua conta Mercado Pago são gerenciados lá. O Meatshop não pede número do cartão ou CVV.',
          ),
          SizedBox(height: 20),
          Text(
            'Também é possível escolher Pix, dinheiro ou cartão na entrega, conforme a disponibilidade do pedido.',
          ),
        ],
      ),
    ),
  );
}

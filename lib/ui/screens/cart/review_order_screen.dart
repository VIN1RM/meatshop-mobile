import 'package:flutter/material.dart';

class _ReviewItem {
  final String nome;
  final String imagemAsset;
  final int quantidade;
  final String unidade;

  const _ReviewItem({
    required this.nome,
    required this.imagemAsset,
    required this.quantidade,
    this.unidade = 'KG',
  });
}

class _ReviewGroup {
  final String acougueNome;
  final String logoAsset;
  final List<_ReviewItem> itens;
  final bool entregaGratis;
  final double taxaEntrega;
  final double subtotal;

  const _ReviewGroup({
    required this.acougueNome,
    required this.logoAsset,
    required this.itens,
    required this.subtotal,
    this.entregaGratis = false,
    this.taxaEntrega = 5.50,
  });
}

class ReviewOrderScreen extends StatefulWidget {
  const ReviewOrderScreen({super.key});

  @override
  State<ReviewOrderScreen> createState() => _ReviewOrderScreenState();
}

class _ReviewOrderScreenState extends State<ReviewOrderScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _surface = Color(0xFF3A3A3A);

  int _paymentIndex = 0;

  final String _endereco =
      'Avenida Rodovanio Rodovalho, Nº 17, Casa cinza\nBairro Eldorado - Anápolis, Goiás';

  final List<_ReviewGroup> _grupos = const [
    _ReviewGroup(
      acougueNome: 'Master Carnes',
      logoAsset: 'assets/images/logo_master.png',
      entregaGratis: true,
      taxaEntrega: 0,
      subtotal: 185.98,
      itens: [
        _ReviewItem(
          nome: 'Picanha angus',
          imagemAsset: 'assets/images/picanha.png',
          quantidade: 1,
        ),
        _ReviewItem(
          nome: 'Lombo suíno',
          imagemAsset: 'assets/images/lombo.png',
          quantidade: 1,
        ),
      ],
    ),
    _ReviewGroup(
      acougueNome: 'Frigorífico Goiás',
      logoAsset: 'assets/images/logo_frigorifico.png',
      entregaGratis: false,
      taxaEntrega: 5.50,
      subtotal: 78.98,
      itens: [
        _ReviewItem(
          nome: 'Filé de Tilápia',
          imagemAsset: 'assets/images/peixe.png',
          quantidade: 1,
        ),
      ],
    ),
  ];

  final List<_PaymentOption> _paymentOptions = const [
    _PaymentOption(Icons.pix, 'Pix'),
    _PaymentOption(Icons.credit_card, 'Crédito'),
    _PaymentOption(Icons.credit_card_outlined, 'Débito'),
    _PaymentOption(Icons.money, 'Dinheiro'),
  ];

  double get _total =>
      _grupos.fold(0, (s, g) => s + g.subtotal + g.taxaEntrega);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF2E2E2E),
      body: Stack(
        children: [
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SizedBox(
              height: 130,
              child: Image.asset(
                'assets/images/background.png',
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) =>
                    Container(color: const Color(0xFF1A1A1A)),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                _buildHeader(context),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 20),
                        _pageTitle(),
                        const SizedBox(height: 16),
                        _buildEndereco(),
                        const SizedBox(height: 20),

                        ..._grupos.map(_buildGrupo),

                        _buildTotal(),
                        const SizedBox(height: 24),

                        _buildPaymentSection(),
                        const SizedBox(height: 24),

                        _buildConfirmarButton(),
                        const SizedBox(height: 32),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: const BoxDecoration(
              color: _white,
              shape: BoxShape.circle,
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/images/logo1.png',
                fit: BoxFit.contain,
                errorBuilder: (_, __, ___) => const Icon(
                  Icons.storefront_outlined,
                  color: _red,
                  size: 22,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          const Text(
            'MeatShop',
            style: TextStyle(
              color: _white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              border: Border.all(color: _white, width: 1.5),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.help_outline, color: _white, size: 20),
          ),
        ],
      ),
    );
  }

  Widget _pageTitle() {
    return const Padding(
      padding: EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        'REVISE SEU PEDIDO',
        style: TextStyle(
          color: _white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.0,
        ),
      ),
    );
  }

  Widget _buildEndereco() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Endereço de entrega',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 15,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _endereco,
            style: const TextStyle(
              color: Color(0xFF555555),
              fontSize: 13,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 8),
          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {},
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(Icons.edit_outlined, color: _red, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Editar',
                    style: TextStyle(
                      color: _red,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGrupo(_ReviewGroup grupo) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        children: [
          ...grupo.itens.map((item) => _buildItemRow(item)),
          const Divider(height: 1, color: Color(0xFFE0E0E0)),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 6),
            child: Row(
              children: [
                const Icon(
                  Icons.delivery_dining,
                  color: Color(0xFF4CAF50),
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    grupo.entregaGratis ? 'Entrega Grátis' : 'Entrega',
                    style: TextStyle(
                      color: grupo.entregaGratis
                          ? const Color(0xFF4CAF50)
                          : const Color(0xFF555555),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Text(
                  grupo.entregaGratis ? 'R\$0,00' : _fmt(grupo.taxaEntrega),
                  style: const TextStyle(
                    color: Color(0xFF555555),
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(14, 0, 14, 14),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: const BoxDecoration(shape: BoxShape.circle),
                  child: ClipOval(
                    child: Image.asset(
                      grupo.logoAsset,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => Container(
                        color: const Color(0xFF555555),
                        child: const Icon(
                          Icons.storefront_outlined,
                          color: Colors.white54,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    grupo.acougueNome,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                Text(
                  _fmt(grupo.subtotal),
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildItemRow(_ReviewItem item) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: Image.asset(
              item.imagemAsset,
              width: 52,
              height: 52,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFE0E0E0),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(
                  Icons.image_outlined,
                  color: Colors.black26,
                  size: 26,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              item.nome,
              style: const TextStyle(
                color: Color(0xFF1A1A1A),
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '${item.quantidade} ${item.unidade}',
            style: const TextStyle(
              color: _red,
              fontSize: 14,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotal() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total',
            style: TextStyle(
              color: _white,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            _fmt(_total),
            style: const TextStyle(
              color: _white,
              fontSize: 20,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            'Forma de pagamento',
            style: TextStyle(
              color: _red,
              fontSize: 20,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.5,
            ),
          ),
        ),
        const SizedBox(height: 14),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List.generate(_paymentOptions.length, (i) {
              final opt = _paymentOptions[i];
              final selected = _paymentIndex == i;
              return GestureDetector(
                onTap: () => setState(() => _paymentIndex = i),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: (MediaQuery.of(context).size.width - 56) / 4,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  decoration: BoxDecoration(
                    color: selected ? _red : const Color(0xFF3A3A3A),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: selected ? _red : const Color(0xFF555555),
                      width: 1.5,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        opt.icon,
                        color: selected ? _white : Colors.white54,
                        size: 22,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        opt.label,
                        style: TextStyle(
                          color: selected ? _white : Colors.white54,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmarButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: ElevatedButton(
        onPressed: () {},
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          foregroundColor: _white,
          minimumSize: const Size(double.infinity, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          elevation: 0,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'Confirmar pedido',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(width: 8),
            Text(
              '· ${_fmt(_total)}',
              style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w500),
            ),
          ],
        ),
      ),
    );
  }

  String _fmt(double valor) {
    final s = valor.toStringAsFixed(2).replaceAll('.', ',');
    final parts = s.split(',');
    final inteiro = parts[0].replaceAllMapped(
      RegExp(r'(\d)(?=(\d{3})+(?!\d))'),
      (m) => '${m[1]}.',
    );
    return 'R\$$inteiro,${parts[1]}';
  }
}

class _PaymentOption {
  final IconData icon;
  final String label;
  const _PaymentOption(this.icon, this.label);
}

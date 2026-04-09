import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class _OrderItem {
  final String quantidade;
  final String nome;
  const _OrderItem(this.quantidade, this.nome);
}

enum _OrderStatus { emAndamento, finalizado }

class _Order {
  final String acougueNome;
  final String logoAsset;
  final String total;
  final List<_OrderItem> itens;
  final _OrderStatus status;

  const _Order({
    required this.acougueNome,
    required this.logoAsset,
    required this.total,
    required this.itens,
    required this.status,
  });
}

class OrdersScreen extends StatelessWidget {
  const OrdersScreen({super.key});

  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;

  static final List<_Order> _orders = [
    _Order(
      acougueNome: 'Master Carnes',
      logoAsset: 'assets/images/logo_master.png',
      total: 'R\$185,98',
      status: _OrderStatus.emAndamento,
      itens: const [
        _OrderItem('1 KG', 'Lombo suíno'),
        _OrderItem('1 KG', 'Picanha Angus'),
      ],
    ),
    _Order(
      acougueNome: 'Frigorífico Goiás',
      logoAsset: 'assets/images/logo_frigorifico.png',
      total: 'R\$78,98',
      status: _OrderStatus.emAndamento,
      itens: const [_OrderItem('1 KG', 'Filé de Tilápia')],
    ),

    _Order(
      acougueNome: 'Master Carnes',
      logoAsset: 'assets/images/logo_master.png',
      total: 'R\$178,75',
      status: _OrderStatus.finalizado,
      itens: const [
        _OrderItem('2,5 KG', 'Pintado'),
        _OrderItem('4 KG', 'Linguiça Toscana Sadia'),
        _OrderItem('2 KG', 'Coxa de Frango'),
      ],
    ),
    _Order(
      acougueNome: 'Mendes',
      logoAsset: 'assets/images/logo_mendes.png',
      total: 'R\$237,45',
      status: _OrderStatus.finalizado,
      itens: const [
        _OrderItem('1,5 KG', 'Filé Mignon'),
        _OrderItem('1 KG', 'Salmão'),
      ],
    ),
    _Order(
      acougueNome: 'Mendes',
      logoAsset: 'assets/images/logo_mendes.png',
      total: 'R\$306,97',
      status: _OrderStatus.finalizado,
      itens: const [
        _OrderItem('2 KG', 'Prime Rib'),
        _OrderItem('0,8 KG', 'Maminha Steak'),
      ],
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final emAndamento = _orders
        .where((o) => o.status == _OrderStatus.emAndamento)
        .toList();
    final finalizados = _orders
        .where((o) => o.status == _OrderStatus.finalizado)
        .toList();

    return Stack(
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
              _buildHeader(),

              Expanded(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _pageTitle(),
                      const SizedBox(height: 16),

                      _groupTitle('Em andamento'),
                      const SizedBox(height: 10),
                      _buildGroup(context, emAndamento, isActive: true),

                      const SizedBox(height: 24),

                      _groupTitle('Finalizados'),
                      const SizedBox(height: 10),
                      _buildGroup(context, finalizados, isActive: false),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildHeader() {
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
        'PEDIDOS',
        style: TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _groupTitle(String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        label,
        style: const TextStyle(
          color: _white,
          fontSize: 16,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }

  Widget _buildGroup(
    BuildContext context,
    List<_Order> orders, {
    required bool isActive,
  }) {
    if (orders.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFF5F5F5),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: List.generate(orders.length, (i) {
          final isLast = i == orders.length - 1;
          return Column(
            children: [
              _buildOrderCard(context, orders[i], isActive: isActive),
              if (!isLast)
                const Divider(
                  height: 1,
                  thickness: 1,
                  color: Color(0xFFE0E0E0),
                ),
            ],
          );
        }),
      ),
    );
  }

  Widget _buildOrderCard(
    BuildContext context,
    _Order order, {
    required bool isActive,
  }) {
    const int maxVisible = 2;
    final visibleItems = order.itens.take(maxVisible).toList();
    final hasMore = order.itens.length > maxVisible;

    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: const BoxDecoration(shape: BoxShape.circle),
                child: ClipOval(
                  child: Image.asset(
                    order.logoAsset,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: const Color(0xFF555555),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: Colors.white54,
                        size: 18,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),

              Expanded(
                child: Text(
                  order.acougueNome,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              Text(
                order.total,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),

          const SizedBox(height: 10),

          ...visibleItems.map(
            (item) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(
                children: [
                  SizedBox(
                    width: 52,
                    child: Text(
                      item.quantidade,
                      style: const TextStyle(
                        color: Color(0xFF555555),
                        fontSize: 13,
                      ),
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.nome,
                      style: const TextStyle(
                        color: Color(0xFF1A1A1A),
                        fontSize: 13,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 6),

          Align(
            alignment: Alignment.centerRight,
            child: GestureDetector(
              onTap: () {
                Navigator.pushNamed(context, AppRoutes.deliveries);
              },
              child: Text(
                isActive ? 'Acompanhar Entrega' : (hasMore ? 'Ver mais' : ''),
                style: TextStyle(
                  color: _red,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  decoration: isActive
                      ? TextDecoration.underline
                      : TextDecoration.none,
                  decorationColor: _red,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

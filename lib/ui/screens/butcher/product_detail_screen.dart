import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/butcher_product_model.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _headerBg = Color(0xFF3A3A3A);
  static const Color _pageBg = Color(0xFFEFEFEF);
  static const Color _white = Colors.white;
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGray = Color(0xFF555555);

  int _qty = 2;

  static const List<ButcherProduct> _suggestions = [
    ButcherProduct(
      nome: 'Picanha angus',
      preco: 'R\$75,00',
      unidade: '/kg',
      imageAsset: 'assets/images/picanha.png',
    ),
    ButcherProduct(
      nome: 'Costela bovina',
      preco: 'R\$31,49',
      unidade: '/kg',
      imageAsset: 'assets/images/costela.png',
    ),
    ButcherProduct(
      nome: 'Coxa de frango',
      preco: 'R\$9,99',
      unidade: '/kg',
      imageAsset: 'assets/images/frango.png',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final product =
        ModalRoute.of(context)?.settings.arguments as ButcherProduct? ??
        const ButcherProduct(
          nome: 'Lombo Suíno',
          preco: 'R\$17,99',
          unidade: '/kg',
          imageAsset: 'assets/images/lombo.png',
          descricao:
              'Explore a excelência gastronômica com nosso Lombo Suíno '
              'Premium, uma escolha irresistível para os amantes da boa '
              'comida! Cada peça é cuidadosamente selecionada para garantir '
              'a máxima qualidade, suculência e sabor inigualável em cada '
              'mordida.',
        );

    return Scaffold(
      backgroundColor: _pageBg,
      body: Column(
        children: [
          _buildHeader(context),
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(product),
                  _buildProductInfo(product),
                  const SizedBox(height: 20),
                  _buildQuantitySection(product),
                  const SizedBox(height: 24),
                  _buildSectionTitle('Compre também'),
                  const SizedBox(height: 12),
                  _buildSuggestions(),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: _buildBottomBar(),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      color: _headerBg,
      child: SafeArea(
        bottom: false,
        child: Column(
          children: [
            Padding(
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
                    child: const Icon(
                      Icons.help_outline,
                      color: _white,
                      size: 20,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(left: 16, right: 16, bottom: 14),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      color: _white,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Container(
                      height: 42,
                      decoration: BoxDecoration(
                        color: _white,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Row(
                        children: [
                          SizedBox(width: 10),
                          Icon(
                            Icons.search,
                            color: Color(0xFF9E9E9E),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Procure por produto ou corte',
                              style: TextStyle(
                                color: Color(0xFF9E9E9E),
                                fontSize: 14,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
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
  }

  Widget _buildHeroBanner(ButcherProduct product) {
    return SizedBox(
      width: double.infinity,
      height: 220,
      child: Image.asset(
        product.imageAsset,
        fit: BoxFit.cover,
        errorBuilder: (_, __, ___) => Container(
          color: const Color(0xFF2A2A2A),
          child: const Center(
            child: Icon(Icons.image_outlined, color: Colors.white24, size: 60),
          ),
        ),
      ),
    );
  }

  Widget _buildProductInfo(ButcherProduct product) {
    final String desc = product.descricao.isEmpty
        ? 'Produto selecionado com qualidade premium para garantir o melhor '
              'sabor e suculência na sua mesa.'
        : product.descricao;

    return Container(
      color: _white,
      padding: const EdgeInsets.fromLTRB(16, 18, 16, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  product.nome,
                  style: const TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: _textDark,
                  ),
                ),
              ),
              RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: product.preco,
                      style: const TextStyle(
                        color: _red,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: product.unidade,
                      style: const TextStyle(
                        color: _red,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              desc,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 13,
                color: _textGray,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuantitySection(ButcherProduct product) {
    return Container(
      color: _white,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          const Text(
            'Quantidade:',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const Spacer(),

          _buildQtyButton(
            icon: Icons.remove,
            onTap: () {
              if (_qty > 1) setState(() => _qty--);
            },
          ),
          const SizedBox(width: 18),
          Text(
            '$_qty',
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: _textDark,
            ),
          ),
          const SizedBox(width: 6),
          const Text(
            'KG',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _textGray,
            ),
          ),
          const SizedBox(width: 18),

          _buildQtyButton(icon: Icons.add, onTap: () => setState(() => _qty++)),
        ],
      ),
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: _red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _white, size: 22),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: _red,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildSuggestions() {
    return SizedBox(
      height: 160,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _suggestions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, i) => _buildSuggestionCard(_suggestions[i]),
      ),
    );
  }

  Widget _buildSuggestionCard(ButcherProduct product) {
    return GestureDetector(
      onTap: () {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const ProductDetailScreen(),
            settings: RouteSettings(arguments: product),
          ),
        );
      },
      child: SizedBox(
        width: 110,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 110,
                height: 100,
                child: Image.asset(
                  product.imageAsset,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: const Color(0xFFCCCCCC),
                    child: const Icon(
                      Icons.image_outlined,
                      color: Color(0xFF9E9E9E),
                      size: 32,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 6),
            Text(
              product.nome,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
                color: _textDark,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: product.preco,
                    style: const TextStyle(
                      color: _red,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  TextSpan(
                    text: product.unidade,
                    style: const TextStyle(
                      color: _red,
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
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

  Widget _buildBottomBar() {
    return Container(
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(Icons.home_outlined, 'Início'),
              _buildNavItem(Icons.shopping_cart_outlined, 'Carrinho'),
              _buildNavItem(Icons.receipt_long_outlined, 'Pedidos'),
              _buildNavItem(Icons.person_outline, 'Minha conta'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: _textGray, size: 24),
        const SizedBox(height: 2),
        Text(label, style: const TextStyle(fontSize: 11, color: _textGray)),
      ],
    );
  }
}

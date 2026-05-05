import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/models/butcher_product_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _pageBg = Color(0xFFEFEFEF);
  static const Color _white = Colors.white;
  static const Color _textDark = Color(0xFF1A1A1A);
  static const Color _textGray = Color(0xFF555555);

  bool _isGrams = true;
  final TextEditingController _qtyController = TextEditingController(
    text: '300',
  );

  static const List<int> _chipsG = [100, 200, 300, 500, 750];
  static const List<double> _chipsKg = [0.5, 1.0, 1.5, 2.0, 3.0];

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
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

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
          Expanded(
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildHeroBanner(product),
                  _buildProductInfo(product),
                  const SizedBox(height: 8),
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Quantidade',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _textDark,
            ),
          ),
          const SizedBox(height: 12),

          _buildUnitTabs(),
          const SizedBox(height: 16),

          _buildQtyInput(),
          const SizedBox(height: 12),

          _buildQtyChips(),
          const SizedBox(height: 14),

          _buildTotalBox(product),
        ],
      ),
    );
  }

  Widget _buildUnitTabs() {
    return Row(
      children: [
        _buildUnitTab(
          label: 'Gramas (g)',
          selected: _isGrams,
          onTap: () {
            setState(() {
              _isGrams = true;
              _qtyController.text = '300';
            });
          },
        ),
        const SizedBox(width: 8),
        _buildUnitTab(
          label: 'Quilos (kg)',
          selected: !_isGrams,
          onTap: () {
            setState(() {
              _isGrams = false;
              _qtyController.text = '0.5';
            });
          },
        ),
      ],
    );
  }

  Widget _buildUnitTab({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: selected ? _red : _white,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selected ? _red : const Color(0xFFDDDDDD),
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w600,
              color: selected ? _white : _textGray,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildQtyInput() {
    return Row(
      children: [
        _buildQtyButton(
          icon: Icons.remove,
          onTap: () {
            final current = double.tryParse(_qtyController.text) ?? 0;
            final step = _isGrams ? 50.0 : 0.5;
            final min = _isGrams ? 50.0 : 0.5;
            final next = current - step;
            if (next >= min) {
              setState(() {
                _qtyController.text = _isGrams
                    ? next.toInt().toString()
                    : next.toStringAsFixed(1);
              });
            }
          },
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFFF5F5F5),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFFDDDDDD)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: const TextInputType.numberWithOptions(
                      decimal: true,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9.]')),
                    ],
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                      color: _textDark,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.symmetric(vertical: 14),
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(right: 10),
                  child: Text(
                    _isGrams ? 'g' : 'kg',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: _textGray,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildQtyButton(
          icon: Icons.add,
          onTap: () {
            final current = double.tryParse(_qtyController.text) ?? 0;
            final step = _isGrams ? 50.0 : 0.5;
            final next = current + step;
            setState(() {
              _qtyController.text = _isGrams
                  ? next.toInt().toString()
                  : next.toStringAsFixed(1);
            });
          },
        ),
      ],
    );
  }

  Widget _buildQtyButton({
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: _red,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: _white, size: 22),
      ),
    );
  }

  Widget _buildQtyChips() {
    final currentVal = double.tryParse(_qtyController.text) ?? 0;

    if (_isGrams) {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _chipsG.map((g) {
          final selected = currentVal == g.toDouble();
          return _buildChip(
            label: '${g}g',
            selected: selected,
            onTap: () => setState(() => _qtyController.text = g.toString()),
          );
        }).toList(),
      );
    } else {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _chipsKg.map((kg) {
          final selected = currentVal == kg;
          return _buildChip(
            label: '${kg}kg',
            selected: selected,
            onTap: () =>
                setState(() => _qtyController.text = kg.toStringAsFixed(1)),
          );
        }).toList(),
      );
    }
  }

  Widget _buildChip({
    required String label,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? const Color(0xFFFFF0EE) : _white,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? _red : const Color(0xFFDDDDDD)),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
            color: selected ? _red : _textGray,
          ),
        ),
      ),
    );
  }

  Widget _buildTotalBox(ButcherProduct product) {
    final total = _calcTotal(product);
    final qty = _qtyController.text.isEmpty ? '0' : _qtyController.text;
    final unit = _isGrams ? 'g' : 'kg';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: _red.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Total estimado',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  color: _textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                '$qty$unit × ${product.preco}/kg',
                style: const TextStyle(fontSize: 11, color: _textGray),
              ),
            ],
          ),
          Text(
            total,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: _red,
            ),
          ),
        ],
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
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.productDetail,
          arguments: product,
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

  String _calcTotal(ButcherProduct product) {
    final raw = product.preco
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.');
    final pricePerKg = double.tryParse(raw) ?? 0.0;
    final inputVal = double.tryParse(_qtyController.text) ?? 0.0;

    final qtyKg = _isGrams ? inputVal / 1000.0 : inputVal;
    final total = pricePerKg * qtyKg;

    return 'R\$${total.toStringAsFixed(2).replaceAll('.', ',')}';
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/ui/components/sheets/cart_bag_sheet.dart';
import 'package:meatshop_mobile/ui/widgets/loading_widget.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/models/review_model.dart';
import 'package:meatshop_mobile/services/review_service.dart';
import 'package:meatshop_mobile/ui/widgets/review_card.dart';
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
  final TextEditingController _qtyController = TextEditingController(text: '');

  static const List<int> _chipsG = [100, 200, 300, 500, 750];
  static const List<double> _chipsKg = [0.5, 1.0, 1.5, 2.0, 3.0];

  bool _isEditingCart = false;
  bool _loaded = false;
  final ReviewService _reviewService = ReviewService();
  List<ReviewModel> _reviews = [];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        final item = args['cartItem'] as CartItemModel?;
        if (item != null) {
          setState(() {
            _isEditingCart = true;
            final isKg = item.unitOfMeasure.toLowerCase() == 'kg';
            _isGrams = !isKg;
            _qtyController.text = isKg
                ? item.quantity.toStringAsFixed(1)
                : (item.quantity * 1000).toInt().toString();
          });
        }
      }
      setState(() => _loaded = true);
      final productArgs = ModalRoute.of(context)?.settings.arguments;
      final ProductModel? prod;
      if (productArgs is Map<String, dynamic>) {
        prod = productArgs['product'] as ProductModel?;
      } else {
        prod = productArgs as ProductModel?;
      }
      if (prod != null) {
        final reviews = await _reviewService
            .watchProductReviews(prod.id, limit: 3)
            .first;
        if (mounted) setState(() => _reviews = reviews);
      }
    });
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  Future<void> _addToCart(BuildContext context, ProductModel product) async {
    final inputVal = double.tryParse(_qtyController.text) ?? 0;
    if (inputVal <= 0) return;

    final qtyInUom = _isGrams ? inputVal / 1000.0 : inputVal;
    final uid = context.read<AuthProvider>().currentUser?.uid;
    if (uid == null) return;

    final cart = context.read<CartProvider>();

    if (_isEditingCart) {
      await cart.updateQuantity(product.id, qtyInUom);
    } else {
      final item = CartItemModel(
        productId: product.id,
        productName: product.name,
        productImageUrl: product.imageUrl,
        unitId: product.unitId,
        unitName: product.unitName,
        unitOfMeasure: product.unitOfMeasure,
        unitPrice: product.price,
        quantity: qtyInUom,
      );
      await cart.addItem(item);
    }

    if (!context.mounted) return;
    CustomSnackBar.success(
      _isEditingCart
          ? '${product.name} - Carrinho atualizado'
          : '${product.name} - Adicionado ao carrinho',
      context: context,
      duration: const Duration(seconds: 2),
    );

    if (_isEditingCart && context.mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final args = ModalRoute.of(context)?.settings.arguments;
    final ProductModel? product;

    if (args is Map<String, dynamic>) {
      product = args['product'] as ProductModel?;
    } else {
      product = args as ProductModel?;
    }

    if (product == null) {
      if (!_loaded) {
        return const Scaffold(
          backgroundColor: Color(0xFFEFEFEF),
          body: Center(child: MeatShopLoader()),
        );
      }
      return Scaffold(
        backgroundColor: _pageBg,
        appBar: AppBar(backgroundColor: _red),
        body: const Center(child: Text('Produto não encontrado.')),
      );
    }

    return Scaffold(
      backgroundColor: _pageBg,
      body: Stack(
        children: [
          Column(
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
                      _buildReviewsSection(context, product),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
              _buildAddToCartBar(context, product),
            ],
          ),
          Consumer<CartProvider>(
            builder: (_, cart, __) {
              if (cart.items.isEmpty) return const SizedBox.shrink();
              return Positioned(
                top: MediaQuery.of(context).padding.top + 8,
                right: 12,
                child: GestureDetector(
                  onTap: () => CartBagSheet.show(context),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    decoration: BoxDecoration(
                      color: _red,
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 6,
                          offset: const Offset(0, 3),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.shopping_bag_outlined,
                          color: Colors.white,
                          size: 16,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          '${cart.items.length} ${cart.items.length == 1 ? 'item' : 'itens'}',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildHeroBanner(ProductModel product) {
    return Stack(
      children: [
        SizedBox(
          width: double.infinity,
          height: 240,
          child: product.imageUrl.isNotEmpty
              ? Image.network(
                  product.imageUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, _) => _heroBannerFallback(),
                )
              : _heroBannerFallback(),
        ),

        Positioned(
          top: MediaQuery.of(context).padding.top + 8,
          left: 12,
          child: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.black45,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: Colors.white,
                size: 18,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _heroBannerFallback() {
    return Container(
      color: const Color(0xFF2A2A2A),
      child: const Center(
        child: Icon(Icons.image_outlined, color: Colors.white24, size: 60),
      ),
    );
  }

  Widget _buildProductInfo(ProductModel product) {
    final desc = product.description.isNotEmpty
        ? product.description
        : 'Produto selecionado com qualidade premium para garantir o melhor sabor e suculência na sua mesa.';

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
                  product.name,
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
                      text: product.precoFormatado,
                      style: const TextStyle(
                        color: _red,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    TextSpan(
                      text: '/${product.unitOfMeasure}',
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

          if (product.unitName.isNotEmpty) ...[
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(
                  Icons.store_outlined,
                  size: 14,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 4),
                Text(
                  'Unidade: ${product.unitName}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ],
          if (product.brand.isNotEmpty) ...[
            const SizedBox(height: 2),
            Row(
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 14,
                  color: Color(0xFF888888),
                ),
                const SizedBox(width: 4),
                Text(
                  'Marca: ${product.brand}',
                  style: const TextStyle(
                    fontSize: 13,
                    color: Color(0xFF888888),
                  ),
                ),
              ],
            ),
          ],
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

  Widget _buildQuantitySection(ProductModel product) {
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
          onTap: () => setState(() {
            _isGrams = true;
            _qtyController.text = '300';
          }),
        ),
        const SizedBox(width: 8),
        _buildUnitTab(
          label: 'Quilos (kg)',
          selected: !_isGrams,
          onTap: () => setState(() {
            _isGrams = false;
            _qtyController.text = '0.5';
          }),
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
            setState(() {
              _qtyController.text = _isGrams
                  ? (current + step).toInt().toString()
                  : (current + step).toStringAsFixed(1);
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
          return _buildChip(
            label: '${g}g',
            selected: currentVal == g.toDouble(),
            onTap: () => setState(() => _qtyController.text = g.toString()),
          );
        }).toList(),
      );
    } else {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _chipsKg.map((kg) {
          return _buildChip(
            label: '${kg}kg',
            selected: currentVal == kg,
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

  Widget _buildTotalBox(ProductModel product) {
    final inputVal = double.tryParse(_qtyController.text) ?? 0;
    final qtyKg = _isGrams ? inputVal / 1000.0 : inputVal;
    final total = product.price * qtyKg;
    final totalFormatado =
        'R\$${total.toStringAsFixed(2).replaceAll('.', ',')}';
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
                '$qty$unit × ${product.precoFormatado}/${product.unitOfMeasure}',
                style: const TextStyle(fontSize: 11, color: _textGray),
              ),
            ],
          ),
          Text(
            totalFormatado,
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

  Widget _buildReviewsSection(BuildContext context, ProductModel product) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          child: Divider(color: Color(0x40BE2C1B), thickness: 0.8, height: 1),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Expanded(
                child: Text(
                  'Avaliações do Produto',
                  style: TextStyle(
                    color: _red,
                    fontSize: 18,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              if (_reviews.length >= 3)
                GestureDetector(
                  onTap: () => Navigator.pushNamed(
                    context,
                    AppRoutes.productReviews,
                    arguments: product.id,
                  ),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: _red.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: _red.withOpacity(0.4),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Text(
                          'Ver todas',
                          style: TextStyle(
                            color: _red,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                          ),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward_ios, size: 11, color: _red),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (_reviews.isEmpty)
          _buildEmptyProductReviews()
        else ...[
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: _reviews.length > 3 ? 3 : _reviews.length,
            itemBuilder: (_, i) => ReviewCard(review: _reviews[i]),
          ),
          if (_reviews.length < 3) _buildFewReviewsCta(),
        ],
      ],
    );
  }

  Widget _buildEmptyProductReviews() {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _red.withOpacity(0.15), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              color: _red.withOpacity(0.08),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.star_outline_rounded,
              color: _red,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Nenhuma avaliação ainda',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Color(0xFF1A1A1A),
            ),
          ),
          const SizedBox(height: 6),
          const Text(
            'Seja o primeiro a avaliar este produto\napós seu pedido!',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: Color(0xFF888888),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFewReviewsCta() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 4, 16, 0),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
      decoration: BoxDecoration(
        color: _red.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withOpacity(0.15), width: 1),
      ),
      child: Row(
        children: const [
          Icon(Icons.edit_outlined, color: _red, size: 18),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Gostou? Deixe sua avaliação após o pedido!',
              style: TextStyle(
                fontSize: 13,
                color: _red,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAddToCartBar(BuildContext context, ProductModel product) {
    final inputVal = double.tryParse(_qtyController.text) ?? 0;
    final qtyKg = _isGrams ? inputVal / 1000.0 : inputVal;
    final total = product.price * qtyKg;
    final isValid = inputVal > 0;

    return Container(
      padding: EdgeInsets.only(
        left: 16,
        right: 16,
        top: 12,
        bottom: MediaQuery.of(context).padding.bottom + 12,
      ),
      decoration: BoxDecoration(
        color: _white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 52,
        child: ElevatedButton(
          onPressed: isValid ? () => _addToCart(context, product) : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: _red,
            disabledBackgroundColor: _red.withOpacity(0.4),
            foregroundColor: _white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.shopping_cart_outlined, size: 20),
              const SizedBox(width: 8),
              Text(
                _isEditingCart ? 'Salvar alterações' : 'Adicionar no Carrinho',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 8),
              Text(
                '· R\$${total.toStringAsFixed(2).replaceAll('.', ',')}',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

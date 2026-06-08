import 'package:flutter/material.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:provider/provider.dart';

class CartBagSheet extends StatelessWidget {
  const CartBagSheet({super.key});

  static const Color _red = Color(0xFFC0392B);
static const Color _bg = Color(0xFFF5F5F5);


  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      useRootNavigator: true,
      builder: (_) => const CartBagSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CartProvider>();
    final screenH = MediaQuery.of(context).size.height;
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return ConstrainedBox(
      constraints: BoxConstraints(maxHeight: screenH * 0.75),
      child: Container(
        decoration: const BoxDecoration(
          color: _bg,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20 + bottomInset),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildHandle(),
            _buildHeader(provider),
            const SizedBox(height: 4),
            if (provider.items.isEmpty)
              _buildEmpty()
            else
              Flexible(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  child: Column(
                    children: [
                      ...provider.itemsByUnit.entries.map(
                        (e) => _buildUnitGroup(context, provider, e.key, e.value),
                      ),
                      const SizedBox(height: 16),
                      _buildTotal(provider.total),
                      const SizedBox(height: 16),
                      _buildGoToCartButton(context),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildHandle() {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12, bottom: 20),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFDDDDDD),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  Widget _buildHeader(CartProvider provider) {
    return Row(
      children: [
        const Icon(Icons.shopping_bag_outlined, color: _red, size: 22),
        const SizedBox(width: 8),
        const Text(
          'Minha sacola',
          style: TextStyle(
            color: Color(0xFF1A1A1A),
            fontSize: 18,
            fontWeight: FontWeight.w800,
          ),
        ),
        const Spacer(),
        if (provider.items.isNotEmpty)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: _red.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.items.length} ${provider.items.length == 1 ? 'item' : 'itens'}',
              style: const TextStyle(
                color: _red,
                fontSize: 12,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEmpty() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: const [
          Icon(Icons.shopping_bag_outlined, color: Color(0xFFCCCCCC), size: 52),
          SizedBox(height: 12),
          Text(
            'Sua sacola está vazia',
            style: TextStyle(color: Color(0xFF888888), fontSize: 14),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitGroup(
    BuildContext context,
    CartProvider provider,
    String unitId,
    List<CartItemModel> itens,
  ) {
    final unitName = itens.first.unitName.isNotEmpty ? itens.first.unitName : 'Açougue';

    return Container(
      margin: const EdgeInsets.only(top: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 8),
            child: Row(
              children: [
                const Icon(Icons.storefront_outlined, color: Color(0xFF888888), size: 16),
                const SizedBox(width: 6),
                Text(
                  unitName,
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: Color(0xFFEEEEEE)),
          ...itens.map((item) => _buildItem(context, provider, item)),
        ],
      ),
    );
  }

  Widget _buildItem(BuildContext context, CartProvider provider, CartItemModel item) {
    return GestureDetector(
      onTap: () {
        Navigator.pop(context);
        Navigator.pushNamed(
          context,
          AppRoutes.productDetail,
          arguments: {
            'product': ProductModel(
              id: item.productId,
              name: item.productName,
              description: '',
              price: item.unitPrice,
              unitOfMeasure: item.unitOfMeasure,
              active: true,
              brand: '',
              imageUrl: item.productImageUrl,
              unitId: item.unitId,
              unitName: item.unitName,
              categoryId: '',
              stockQuantity: 999,
            ),
            'cartItem': item,
          },
        );
      },
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: SizedBox(
                width: 48,
                height: 48,
                child: item.productImageUrl.isNotEmpty
                    ? Image.network(
                        item.productImageUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _imageFallback(),
                      )
                    : _imageFallback(),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    item.productName,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${item.quantity % 1 == 0 ? item.quantity.toInt() : item.quantity.toStringAsFixed(1)} ${item.unitOfMeasure.toUpperCase()}',
                    style: const TextStyle(color: Color(0xFF888888), fontSize: 12),
                  ),
                ],
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  item.subtotalFormatado,
                  style: const TextStyle(
                    color: _red,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    _MiniQtyButton(
                      icon: Icons.remove,
                      onTap: () => provider.updateQuantity(
                        item.productId,
                        item.quantity - (item.unitOfMeasure == 'kg' ? 0.5 : 50),
                      ),
                    ),
                    const SizedBox(width: 6),
                    _MiniQtyButton(
                      icon: Icons.add,
                      onTap: () => provider.updateQuantity(
                        item.productId,
                        item.quantity + (item.unitOfMeasure == 'kg' ? 0.5 : 50),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTotal(double total) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: _red.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _red.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const Text(
            'Total estimado',
            style: TextStyle(
              color: Color(0xFF1A1A1A),
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
          Text(
            'R\$${total.toStringAsFixed(2).replaceAll('.', ',')}',
            style: const TextStyle(
              color: _red,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGoToCartButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: ElevatedButton.icon(
        onPressed: () {
          Navigator.pop(context);
          Navigator.pushNamed(context, AppRoutes.cart);
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: _red,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        ),
        icon: const Icon(Icons.shopping_cart_outlined, color: Colors.white, size: 20),
        label: const Text(
          'Ver carrinho completo',
          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }

  Widget _imageFallback() => Container(
    color: const Color(0xFFE0E0E0),
    child: const Icon(Icons.image_outlined, color: Color(0xFFBDBDBD), size: 24),
  );
}

class _MiniQtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _MiniQtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 24,
        height: 24,
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 14),
      ),
    );
  }
}
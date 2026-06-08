import 'package:flutter/material.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';
import 'package:meatshop_mobile/models/cart_item_model.dart';
import 'package:meatshop_mobile/providers/cart_provider.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/ui/screens/cart/address_schedule_screen.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:meatshop_mobile/models/product_model.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/ui/widgets/swipe_to_delete.dart';
import 'package:meatshop_mobile/ui/widgets/swipe_tooltip.dart';
import 'package:meatshop_mobile/ui/dialogs/custom_dialog.dart';

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  static const Color _red = Color(0xFFC0392B);
  static const Color _surface = Color(0xFFF5F5F5);

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final uid = context.read<AuthProvider>().currentUser?.uid;
      if (uid != null) {
        context.read<CartProvider>().loadCart();
      }
    });
  }

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
                const AppHeader(),
                Expanded(
                  child: Consumer<CartProvider>(
                    builder: (_, provider, __) {
                      if (provider.isLoading) {
                        return const Center(
                          child: CircularProgressIndicator(
                            color: Color(0xFFC0392B),
                          ),
                        );
                      }

                      if (provider.error != null) {
                        return Center(
                          child: Text(
                            provider.error!,
                            style: const TextStyle(color: Colors.white54),
                          ),
                        );
                      }

                      if (provider.items.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.shopping_cart_outlined,
                                color: Colors.white24,
                                size: 64,
                              ),
                              SizedBox(height: 12),
                              Text(
                                'Seu carrinho está vazio',
                                style: TextStyle(
                                  color: Colors.white38,
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(height: 20),
                            _sectionTitle('CARRINHO'),
                            const SizedBox(height: 16),
                            ...provider.itemsByUnit.entries.map(
                              (e) =>
                                  _buildUnitSection(provider, e.key, e.value),
                            ),
                            const SizedBox(height: 24),
                            _buildFinalizarButton(provider),
                            const SizedBox(height: 24),
                          ],
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Text(
        title,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 22,
          fontWeight: FontWeight.w900,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildUnitSection(
    CartProvider provider,
    String unitId,
    List<CartItemModel> itens,
  ) {
    final unitName = itens.first.unitName.isNotEmpty
        ? itens.first.unitName
        : 'Açougue';
    final subtotal = itens.fold<double>(0, (s, i) => s + i.subtotal);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 14, 14, 10),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: const Color(0xFFE0E0E0),
                    border: Border.all(color: _red, width: 1.5),
                  ),
                  child: const Icon(
                    Icons.storefront_outlined,
                    color: Color(0xFF888888),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    unitName,
                    style: const TextStyle(
                      color: Color(0xFF1A1A1A),
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!provider.isUnitOpen(unitId))
            Container(
              margin: const EdgeInsets.fromLTRB(14, 0, 14, 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: const Color(0xFFC0392B).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time, color: Color(0xFFC0392B), size: 14),
                  SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      'Este açougue está fechado no momento. Você pode adicionar itens, mas o pedido só poderá ser finalizado quando estiver aberto.',
                      style: TextStyle(color: Color(0xFFC0392B), fontSize: 11),
                    ),
                  ),
                ],
              ),
            ),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          ...itens.asMap().entries.map((entry) {
            final isLast = entry.key == itens.length - 1;
            return Column(
              children: [
                _buildCartItem(provider, entry.value),
                if (!isLast)
                  const Divider(
                    color: Color.fromARGB(255, 190, 190, 190),
                    height: 1,
                    indent: 14,
                    endIndent: 14,
                  ),
              ],
            );
          }),
          const Divider(color: Color(0xFFE0E0E0), height: 1),
          Padding(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Subtotal',
                  style: TextStyle(color: Color(0xFF555555), fontSize: 14),
                ),
                Text(
                  'R\$${subtotal.toStringAsFixed(2).replaceAll('.', ',')}',
                  style: const TextStyle(
                    color: Color(0xFF1A1A1A),
                    fontSize: 16,
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

  Widget _buildCartItem(CartProvider provider, CartItemModel item) {
    return SwipeTooltip(
      child: SwipeToDelete(
        onSwipe: () =>
            CustomDialog.showRemoveCartItem(
              context: context,
              productName: item.productName,
            ).then((confirmed) {
              if (confirmed) {
                provider.removeItem(item.productId);
                CustomSnackBar.success(
                  'Produto removido do carrinho.',
                  context: context,
                  duration: const Duration(seconds: 5),
                );
              }
              return confirmed;
            }),
        child: GestureDetector(
          onTap: () => Navigator.pushNamed(
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
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 14, 4),
            child: Column(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: SizedBox(
                        width: 54,
                        height: 54,
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
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: item.precoFormatado,
                                  style: const TextStyle(
                                    color: _red,
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                TextSpan(
                                  text: '/${item.unitOfMeasure}',
                                  style: const TextStyle(
                                    color: Color(0xFF888888),
                                    fontSize: 11,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    const SizedBox(width: 66),
                    _QtyButton(
                      icon: Icons.remove,
                      onTap: () async {
                        final novaQty = item.quantity - 0.5;
                        if (novaQty <= 0) {
                          final confirmed =
                              await CustomDialog.showRemoveCartItem(
                                context: context,
                                productName: item.productName,
                              );
                          if (confirmed) {
                            provider.removeItem(item.productId);
                            CustomSnackBar.success(
                              'Produto removido do carrinho.',
                              context: context,
                              duration: const Duration(seconds: 5),
                            );
                          }
                        } else {
                          provider.updateQuantity(item.productId, novaQty);
                        }
                      },
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      child: Text(
                        item.quantity % 1 == 0
                            ? item.quantity.toInt().toString()
                            : item.quantity.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Color(0xFF1A1A1A),
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    Text(
                      item.unitOfMeasure.toUpperCase(),
                      style: const TextStyle(
                        color: Color(0xFF888888),
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 8),
                    _QtyButton(
                      icon: Icons.add,
                      onTap: () => provider.updateQuantity(
                        item.productId,
                        item.quantity + 0.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFinalizarButton(CartProvider provider) {
    final hasClosedUnit = provider.itemsByUnit.keys.any(
      (unitId) => !provider.isUnitOpen(unitId),
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        children: [
          if (hasClosedUnit)
            Container(
              margin: const EdgeInsets.only(bottom: 10),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFFDECEC),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: const Color(0xFFC0392B).withOpacity(0.3),
                ),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.store_outlined,
                    color: Color(0xFFC0392B),
                    size: 16,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Um ou mais açougues estão fechados. Aguarde o horário de funcionamento para finalizar.',
                      style: TextStyle(
                        color: Color(0xFFC0392B),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ElevatedButton(
            onPressed: hasClosedUnit
                ? null
                : () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          AddressScheduleScreen(total: provider.total),
                    ),
                  ),
            style: ElevatedButton.styleFrom(
              backgroundColor: hasClosedUnit
                  ? const Color(0xFFBDBDBD)
                  : const Color(0xFFC0392B),
              foregroundColor: Colors.white,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  hasClosedUnit ? 'Açougue fechado' : 'Confirmar Itens',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                if (!hasClosedUnit) ...[
                  const SizedBox(width: 8),
                  Text(
                    '· R\$${provider.total.toStringAsFixed(2).replaceAll('.', ',')}',
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _imageFallback() {
    return Container(
      color: const Color(0xFFE0E0E0),
      child: const Icon(
        Icons.image_outlined,
        color: Color(0xFFBDBDBD),
        size: 28,
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          color: const Color(0xFFC0392B),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Icon(icon, color: Colors.white, size: 18),
      ),
    );
  }
}

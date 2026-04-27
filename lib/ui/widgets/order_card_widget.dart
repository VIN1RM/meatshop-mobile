import 'package:flutter/material.dart';
import 'package:meatshop_mobile/providers/delivery/delivery_provider.dart';

class OrderCardWidget extends StatelessWidget {
  const OrderCardWidget({
    super.key,
    required this.order,
    required this.isLoading,
    required this.onAccept,
    required this.onReject,
  });

  final DeliveryOrder order;
  final bool isLoading;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF2C2C2C),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: const Color(0xFFC0392B).withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.receipt_long_outlined,
                    color: Color(0xFFC0392B),
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Pedido #${order.id}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        order.clientName,
                        style: const TextStyle(
                          color: Colors.white54,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  'R\$ ${order.total.toStringAsFixed(2)}',
                  style: const TextStyle(
                    color: Color(0xFF2ECC71),
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),

          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 14, 16, 6),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFFC0392B).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.storefront_outlined,
                        color: Color(0xFFC0392B),
                        size: 15,
                      ),
                    ),
                    Container(width: 2, height: 28, color: Colors.white12),
                    Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.location_on_outlined,
                        color: Color(0xFF27AE60),
                        size: 15,
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order.unitName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${order.unitAddress.street}, ${order.unitAddress.number} · ${order.unitAddress.neighborhood}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                      const SizedBox(height: 20),

                      Text(
                        order.clientName,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        '${order.address.street}, ${order.address.number} · ${order.address.neighborhood}',
                        style: const TextStyle(
                          color: Colors.white38,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(
                  Icons.fastfood_outlined,
                  color: Colors.white24,
                  size: 15,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    order.items,
                    style: const TextStyle(color: Colors.white38, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          Divider(color: Colors.white.withValues(alpha: 0.06), height: 1),

          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onReject,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFC0392B),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFFC0392B,
                        ).withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: const Text(
                        'Recusar',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  flex: 2,
                  child: SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : onAccept,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF27AE60),
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: const Color(
                          0xFF27AE60,
                        ).withValues(alpha: 0.6),
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(14),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 22,
                              height: 22,
                              child: CircularProgressIndicator(
                                strokeWidth: 2.5,
                                color: Colors.white,
                              ),
                            )
                          : const Text(
                              'Aceitar entrega',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 0.5,
                              ),
                            ),
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
}

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/models/product_review_model.dart';
import 'package:meatshop_mobile/providers/product_review_provider.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';

class WriteProductReviewScreenArgs {
  final OrderModel order;
  final List<OrderItemModel> items;

  const WriteProductReviewScreenArgs({
    required this.order,
    required this.items,
  });
}

class WriteProductReviewScreen extends StatefulWidget {
  const WriteProductReviewScreen({super.key});

  @override
  State<WriteProductReviewScreen> createState() =>
      _WriteProductReviewScreenState();
}

class _WriteProductReviewScreenState extends State<WriteProductReviewScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _surface = Color(0xFF2A2A2A);
  static const Color _bg = Color.fromARGB(255, 58, 58, 58);

  late WriteProductReviewScreenArgs _args;
  bool _argsLoaded = false;

  final Map<String, int> _ratings = {};
  final Map<String, TextEditingController> _commentCtrls = {};

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is WriteProductReviewScreenArgs) {
        _args = args;
        for (final item in args.items) {
          _ratings[item.productName] = 0;
          _commentCtrls[item.productName] =
              TextEditingController();
        }
        _argsLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    for (final ctrl in _commentCtrls.values) {
      ctrl.dispose();
    }
    super.dispose();
  }

  Future<void> _submit() async {
    final provider = context.read<ProductReviewProvider>();

    final reviews = <ProductReviewModel>[];
    for (int i = 0; i < _args.items.length; i++) {
      final item = _args.items[i];
      final rating = _ratings[item.productName] ?? 0;

      if (rating == 0) {
        CustomSnackBar.error(
          'Avalie todos os produtos para continuar',
          context: context,
        );
        return;
      }

      reviews.add(
        ProductReviewModel(
          id: '',
          orderId: _args.order.id,
          clientId: _args.order.clientId,
          productId: 'product_${item.productName}',
          productName: item.productName,
          productImageUrl: item.productImageUrl,
          unitId: _args.order.unitId,
          rating: rating,
          comment: _commentCtrls[item.productName]?.text ?? '',
          createdAt: DateTime.now(),
        ),
      );
    }

    final ok = await provider.submitMultiple(reviews);

    if (!mounted) return;

    if (ok) {
      CustomSnackBar.success('Avaliações enviadas!', context: context);
      Navigator.pop(context, true);
    } else {
      CustomSnackBar.error(
        provider.error ?? 'Erro ao enviar',
        context: context,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_argsLoaded) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(
          child: CircularProgressIndicator(color: _red),
        ),
      );
    }

    return Scaffold(
      backgroundColor: _bg,
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
                errorBuilder: (_, _, _) => Container(color: _bg),
              ),
            ),
          ),
          SafeArea(
            child: Column(
              children: [
                const AppHeader(),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'AVALIE OS PRODUTOS',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Sua opinião ajuda outros clientes',
                          style: TextStyle(
                            color: Color(0xFFB8B8B8),
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(height: 24),
                        ..._args.items.map(
                          (item) => _ProductReviewCard(
                            item: item,
                            rating: _ratings[item.productName] ?? 0,
                            comment:
                                _commentCtrls[item.productName]?.text ?? '',
                            onRatingChanged: (rating) => setState(
                              () =>
                                  _ratings[item.productName] = rating,
                            ),
                            onCommentChanged: (text) => setState(() =>
                                _commentCtrls[item.productName]?.text = text),
                            red: _red,
                            surface: _surface,
                          ),
                        ),
                        const SizedBox(height: 24),
                        Consumer<ProductReviewProvider>(
                          builder: (_, provider, _) => SizedBox(
                            width: double.infinity,
                            height: 52,
                            child: ElevatedButton(
                              onPressed:
                                  provider.isLoading ? null : _submit,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: _red,
                                disabledBackgroundColor:
                                    _red.withOpacity(0.5),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(14),
                                ),
                              ),
                              child: provider.isLoading
                                  ? const SizedBox(
                                      width: 22,
                                      height: 22,
                                      child:
                                          CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Text(
                                      'Enviar avaliações',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w700,
                                      ),
                                    ),
                            ),
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
    );
  }
}

class _ProductReviewCard extends StatelessWidget {
  const _ProductReviewCard({
    required this.item,
    required this.rating,
    required this.comment,
    required this.onRatingChanged,
    required this.onCommentChanged,
    required this.red,
    required this.surface,
  });

  final dynamic item;
  final int rating;
  final String comment;
  final ValueChanged<int> onRatingChanged;
  final ValueChanged<String> onCommentChanged;
  final Color red;
  final Color surface;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.25),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: SizedBox(
                  width: 56,
                  height: 56,
                  child: item.productImageUrl.isNotEmpty
                      ? Image.network(
                          item.productImageUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFF3A3A3A),
                            child: const Icon(
                              Icons.image_outlined,
                              color: Color(0xFF7A7A7A),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFF3A3A3A),
                          child: const Icon(
                            Icons.image_outlined,
                            color: Color(0xFF7A7A7A),
                          ),
                        ),
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
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      item.quantityLabel,
                      style: const TextStyle(
                        color: Color(0xFFB8B8B8),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Center(
            child: _StarSelector(
              value: rating,
              onChanged: onRatingChanged,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: onCommentChanged,
            maxLines: 2,
            maxLength: 150,
            style: const TextStyle(fontSize: 13, color: Colors.white),
            decoration: InputDecoration(
              hintText: 'Comentário (opcional)...',
              hintStyle: const TextStyle(
                color: Color(0xFF7A7A7A),
                fontSize: 13,
              ),
              counterStyle: const TextStyle(color: Color(0xFF7A7A7A)),
              filled: true,
              fillColor: const Color(0xFF3A3A3A),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(10),
                borderSide: BorderSide.none,
              ),
              contentPadding: const EdgeInsets.all(12),
            ),
          ),
        ],
      ),
    );
  }
}

class _StarSelector extends StatelessWidget {
  const _StarSelector({
    required this.value,
    required this.onChanged,
  });

  final int value;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: filled
                  ? const Color(0xFFFFB800)
                  : const Color(0xFF525252),
              size: 32,
            ),
          ),
        );
      }),
    );
  }
}
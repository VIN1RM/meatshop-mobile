import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:meatshop_mobile/models/order_model.dart';
import 'package:meatshop_mobile/providers/review_provider.dart';
import 'package:meatshop_mobile/ui/widgets/app_header.dart';
import 'package:meatshop_mobile/core/utils/custom_snackbar.dart';

class ReviewArgs {
  final OrderModel order;
  final String deliveryPersonId;
  final String unitImageUrl;
  final String deliveryPersonPhotoUrl;

  const ReviewArgs({
    required this.order,
    this.deliveryPersonId = '',
    this.unitImageUrl = '',
    this.deliveryPersonPhotoUrl = '',
  });
}

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  static const Color _red = Color(0xFFBE2C1B);
  static const Color _surface = Color(0xFF2A2A2A);
  static const Color _bg = Color.fromARGB(255, 58, 58, 58);

  late ReviewArgs _args;

  int _unitRating = 0;
  final TextEditingController _unitCommentCtrl = TextEditingController();

  int _deliveryRating = 0;
  final TextEditingController _deliveryCommentCtrl = TextEditingController();

  int _step = 0;

  bool _argsLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_argsLoaded) {
      final args = ModalRoute.of(context)?.settings.arguments;
      if (args is ReviewArgs) {
        _args = args;
        _argsLoaded = true;
      }
    }
  }

  @override
  void dispose() {
    _unitCommentCtrl.dispose();
    _deliveryCommentCtrl.dispose();
    super.dispose();
  }

  bool get _hasDelivery => _args.deliveryPersonId.isNotEmpty;

  void _nextStep() {
    if (_step == 0) {
      if (_unitRating == 0) {
        CustomSnackBar.show(
          SnackBarType.error,
          'Selecione uma nota para o açougue.',
        );
        return;
      }
      if (!_hasDelivery) {
        _submit();
        return;
      }
      setState(() => _step = 1);
      return;
    }

    if (_step == 1) {
      if (_deliveryRating == 0) {
        CustomSnackBar.show(
          SnackBarType.error,
          'Selecione uma nota para o entregador.',
        );
        return;
      }
      _submit();
    }
  }

  Future<void> _submit() async {
    final provider = context.read<ReviewProvider>();
    final ok = await provider.submit(
      orderId: _args.order.id,
      unitId: _args.order.unitId,
      unitRating: _unitRating,
      unitComment: _unitCommentCtrl.text,
      deliveryPersonId: _hasDelivery ? _args.deliveryPersonId : null,
      deliveryRating: _hasDelivery ? _deliveryRating : null,
      deliveryComment: _hasDelivery ? _deliveryCommentCtrl.text : null,
    );

    if (!mounted) return;

    if (ok) {
      setState(() => _step = 2);
    } else {
      CustomSnackBar.show(
        SnackBarType.error,
        provider.error ?? 'Erro ao enviar avaliação.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!_argsLoaded) {
      return Scaffold(
        backgroundColor: _bg,
        body: const Center(
          child: CircularProgressIndicator(color: Color(0xFFBE2C1B)),
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
                  child: _step == 2
                      ? _SuccessView(onDone: () => Navigator.of(context).pop())
                      : _FormView(
                          step: _step,
                          order: _args.order,
                          hasDelivery: _hasDelivery,
                          unitRating: _unitRating,
                          unitCommentCtrl: _unitCommentCtrl,
                          deliveryRating: _deliveryRating,
                          deliveryCommentCtrl: _deliveryCommentCtrl,
                          onUnitRating: (v) => setState(() => _unitRating = v),
                          onDeliveryRating: (v) =>
                              setState(() => _deliveryRating = v),
                          onNext: _nextStep,
                          red: _red,
                          surface: _surface,
                          unitImageUrl: _args.unitImageUrl,
                          deliveryPersonPhotoUrl: _args.deliveryPersonPhotoUrl,
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

class _FormView extends StatelessWidget {
  const _FormView({
    required this.step,
    required this.order,
    required this.hasDelivery,
    required this.unitRating,
    required this.unitCommentCtrl,
    required this.deliveryRating,
    required this.deliveryCommentCtrl,
    required this.onUnitRating,
    required this.onDeliveryRating,
    required this.onNext,
    required this.red,
    required this.surface,
    required this.unitImageUrl,
    required this.deliveryPersonPhotoUrl,
  });

  final int step;
  final OrderModel order;
  final bool hasDelivery;
  final int unitRating;
  final TextEditingController unitCommentCtrl;
  final int deliveryRating;
  final TextEditingController deliveryCommentCtrl;
  final ValueChanged<int> onUnitRating;
  final ValueChanged<int> onDeliveryRating;
  final VoidCallback onNext;
  final Color red;
  final Color surface;
  final String unitImageUrl;
  final String deliveryPersonPhotoUrl;

  @override
  Widget build(BuildContext context) {
    final isDeliveryStep = step == 1;
    final totalSteps = hasDelivery ? 2 : 1;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(16, 24, 16, 32),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'AVALIAÇÃO',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 20),

          if (hasDelivery) ...[
            _StepIndicator(current: step, total: totalSteps, red: red),
            const SizedBox(height: 20),
          ],

          Container(
            decoration: BoxDecoration(
              color: surface,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.25),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _AvatarWidget(
                      imageUrl: isDeliveryStep
                          ? deliveryPersonPhotoUrl
                          : unitImageUrl,
                      fallbackIcon: isDeliveryStep
                          ? Icons.delivery_dining_rounded
                          : Icons.storefront_rounded,
                      red: red,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            isDeliveryStep
                                ? 'Como foi o entregador?'
                                : 'Como foi o açougue?',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            isDeliveryStep
                                ? 'Avalie o serviço de entrega'
                                : order.unitName,
                            style: const TextStyle(
                              fontSize: 13,
                              color: Color(0xFFB8B8B8),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                Center(
                  child: _StarSelector(
                    value: isDeliveryStep ? deliveryRating : unitRating,
                    onChanged: isDeliveryStep ? onDeliveryRating : onUnitRating,
                    size: 40,
                  ),
                ),

                const SizedBox(height: 8),

                Center(
                  child: Text(
                    _ratingLabel(isDeliveryStep ? deliveryRating : unitRating),
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: red,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                TextField(
                  controller: isDeliveryStep
                      ? deliveryCommentCtrl
                      : unitCommentCtrl,
                  maxLines: 3,
                  maxLength: 200,
                  style: const TextStyle(fontSize: 14, color: Colors.white),
                  decoration: InputDecoration(
                    hintText: 'Deixe um comentário (opcional)...',
                    hintStyle: const TextStyle(
                      color: Color(0xFF7A7A7A),
                      fontSize: 14,
                    ),
                    counterStyle: const TextStyle(color: Color(0xFF7A7A7A)),
                    filled: true,
                    fillColor: const Color(0xFF3A3A3A),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                    contentPadding: const EdgeInsets.all(14),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Consumer<ReviewProvider>(
            builder: (_, provider, _) {
              final isLast = !hasDelivery || step == 1;
              return SizedBox(
                width: double.infinity,
                height: 52,
                child: ElevatedButton(
                  onPressed: provider.isLoading ? null : onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: red,
                    disabledBackgroundColor: red.withValues(alpha: 0.5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: provider.isLoading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : Text(
                          isLast ? 'Enviar avaliação' : 'Próximo',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                ),
              );
            },
          ),

          if (hasDelivery && step == 0) ...[
            const SizedBox(height: 12),
            Center(
              child: TextButton(
                onPressed: () {
                  if (unitRating == 0) {
                    onNext();
                    return;
                  }
                  onNext();
                },
                child: const Text(
                  'Avaliar apenas o açougue',
                  style: TextStyle(
                    color: Color(0xFF7A7A7A),
                    fontSize: 13,
                    decoration: TextDecoration.underline,
                    decorationColor: Color(0xFF7A7A7A),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  String _ratingLabel(int rating) {
    switch (rating) {
      case 1:
        return 'Muito ruim';
      case 2:
        return 'Ruim';
      case 3:
        return 'Regular';
      case 4:
        return 'Bom';
      case 5:
        return 'Excelente!';
      default:
        return 'Toque para avaliar';
    }
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({required this.onDone});
  final VoidCallback onDone;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: const Color(0xFF27AE60).withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle_rounded,
                color: Color(0xFF27AE60),
                size: 48,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Avaliação enviada!',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Obrigado pelo feedback.\nEle ajuda outros clientes e melhora o serviço.',
              textAlign: TextAlign.center,
              style: TextStyle(color: Color(0xFFB8B8B8), fontSize: 14),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onDone,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFBE2C1B),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: const Text(
                  'Voltar aos pedidos',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _StarSelector extends StatelessWidget {
  const _StarSelector({
    required this.value,
    required this.onChanged,
    this.size = 36,
  });

  final int value;
  final ValueChanged<int> onChanged;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (i) {
        final filled = i < value;
        return GestureDetector(
          onTap: () => onChanged(i + 1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Icon(
              filled ? Icons.star_rounded : Icons.star_border_rounded,
              color: filled ? const Color(0xFFFFB800) : const Color(0xFF525252),
              size: size,
            ),
          ),
        );
      }),
    );
  }
}

class _StepIndicator extends StatelessWidget {
  const _StepIndicator({
    required this.current,
    required this.total,
    required this.red,
  });

  final int current;
  final int total;
  final Color red;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total * 2 - 1, (i) {
        if (i.isOdd) {
          return Expanded(
            child: Container(
              height: 2,
              color: i ~/ 2 < current ? red : const Color(0xFF3A3A3A),
            ),
          );
        }
        final idx = i ~/ 2;
        final done = idx < current;
        final active = idx == current;
        return Container(
          width: 28,
          height: 28,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: done || active ? red : const Color(0xFF3A3A3A),
          ),
          child: Center(
            child: done
                ? const Icon(Icons.check, color: Colors.white, size: 14)
                : Text(
                    '${idx + 1}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
          ),
        );
      }),
    );
  }
}

class _AvatarWidget extends StatelessWidget {
  const _AvatarWidget({
    required this.imageUrl,
    required this.fallbackIcon,
    required this.red,
  });

  final String imageUrl;
  final IconData fallbackIcon;
  final Color red;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      decoration: const BoxDecoration(
        color: Color(0xFF3A3A3A),
        shape: BoxShape.circle,
      ),
      child: ClipOval(
        child: imageUrl.isNotEmpty
            ? Image.network(
                imageUrl,
                fit: BoxFit.cover,
                errorBuilder: (_, _, _) =>
                    Icon(fallbackIcon, color: red, size: 22),
              )
            : Icon(fallbackIcon, color: red, size: 22),
      ),
    );
  }
}

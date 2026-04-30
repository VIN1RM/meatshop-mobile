import 'dart:math';
import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class OrderProcessingScreen extends StatefulWidget {
  const OrderProcessingScreen({super.key});

  @override
  State<OrderProcessingScreen> createState() => _OrderProcessingScreenState();
}

class _OrderProcessingScreenState extends State<OrderProcessingScreen>
    with TickerProviderStateMixin {
  static const Color _red = Color(0xFFC0392B);
  static const Color _white = Colors.white;
  static const Color _bg = Color(0xFFF5F2EF);
  static const Color _surface = Color(0xFFEAE6E1);

  late AnimationController _progressController;
  late AnimationController _pulseController;
  late AnimationController _successController;
  late AnimationController _particleController;

  late Animation<double> _progressAnim;
  late Animation<double> _pulseAnim;
  late Animation<double> _successScaleAnim;
  late Animation<double> _successOpacityAnim;
  late Animation<double> _particleAnim;

  bool _isSuccess = false;
  int _stepIndex = 0;

  final List<_ProcessStep> _steps = const [
    _ProcessStep(
      icon: Icons.receipt_long_outlined,
      label: 'Registrando pedido...',
    ),
    _ProcessStep(
      icon: Icons.storefront_outlined,
      label: 'Notificando o açougue...',
    ),
    _ProcessStep(
      icon: Icons.payment_outlined,
      label: 'Processando pagamento...',
    ),
    _ProcessStep(icon: Icons.check_circle_outline, label: 'Pedido confirmado!'),
  ];

  @override
  void initState() {
    super.initState();

    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 5000),
    );
    _progressAnim = CurvedAnimation(
      parent: _progressController,
      curve: Curves.easeInOut,
    );

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _successController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _successScaleAnim = Tween<double>(begin: 0.4, end: 1.0).animate(
      CurvedAnimation(parent: _successController, curve: Curves.elasticOut),
    );
    _successOpacityAnim = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _successController,
        curve: const Interval(0.0, 0.4, curve: Curves.easeIn),
      ),
    );

    _particleController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    _particleAnim = CurvedAnimation(
      parent: _particleController,
      curve: Curves.easeOut,
    );

    _startFlow();
  }

  Future<void> _startFlow() async {
    _progressController.forward();

    for (int i = 0; i < _steps.length - 1; i++) {
      await Future.delayed(
        Duration(milliseconds: (5000 / (_steps.length - 1)).round()),
      );
      if (!mounted) return;
      setState(() => _stepIndex = i + 1);
    }

    await Future.delayed(const Duration(milliseconds: 200));
    if (!mounted) return;

    setState(() => _isSuccess = true);
    _pulseController.stop();
    _successController.forward();
    _particleController.forward();

    await Future.delayed(const Duration(milliseconds: 2800));
    if (!mounted) return;

    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.deliveries,
      (route) => route.settings.name == AppRoutes.shell,
    );
  }

  @override
  void dispose() {
    _progressController.dispose();
    _pulseController.dispose();
    _successController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: const Alignment(0, -0.3),
                  radius: 1.2,
                  colors: [_red.withOpacity(0.06), const Color(0xFFF5F2EF)],
                ),
              ),
            ),
          ),

          if (_isSuccess)
            AnimatedBuilder(
              animation: _particleAnim,
              builder: (_, __) => _buildParticles(context),
            ),

          SafeArea(
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 500),
              child: _isSuccess ? _buildSuccess() : _buildLoading(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoading() {
    return Center(
      key: const ValueKey('loading'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ScaleTransition(
              scale: _pulseAnim,
              child: Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _surface,
                  border: Border.all(color: _red.withOpacity(0.4), width: 2),
                  boxShadow: [
                    BoxShadow(
                      color: _red.withOpacity(0.15),
                      blurRadius: 30,
                      spreadRadius: 4,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.shopping_bag_outlined,
                  color: _red,
                  size: 44,
                ),
              ),
            ),

            const SizedBox(height: 40),

            AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Text(
                _steps[_stepIndex].label,
                key: ValueKey(_stepIndex),
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.2,
                ),
              ),
            ),

            const SizedBox(height: 8),

            const Text(
              'Isso pode levar alguns instantes',
              style: TextStyle(color: Color(0xFF888888), fontSize: 13),
            ),

            const SizedBox(height: 40),

            AnimatedBuilder(
              animation: _progressAnim,
              builder: (_, __) {
                return Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(100),
                      child: SizedBox(
                        height: 6,
                        child: LinearProgressIndicator(
                          value: _progressAnim.value,
                          backgroundColor: _surface,
                          valueColor: const AlwaysStoppedAnimation<Color>(_red),
                        ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Align(
                      alignment: Alignment.centerRight,
                      child: Text(
                        '${(_progressAnim.value * 100).toInt()}%',
                        style: const TextStyle(
                          color: Color(0xFF999999),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),

            const SizedBox(height: 48),

            _buildStepIndicators(),
          ],
        ),
      ),
    );
  }

  Widget _buildStepIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(_steps.length, (i) {
        final done = i < _stepIndex;
        final active = i == _stepIndex;
        return Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: done
                    ? _red
                    : active
                    ? _surface
                    : const Color(0xFFDDD9D4),
                border: Border.all(
                  color: done
                      ? _red
                      : active
                      ? _red.withOpacity(0.5)
                      : const Color(0xFFCCC8C2),
                  width: 1.5,
                ),
              ),
              child: Center(
                child: done
                    ? const Icon(Icons.check, color: _white, size: 16)
                    : Icon(
                        _steps[i].icon,
                        color: active ? _red : const Color(0xFFBBB7B1),

                        size: 16,
                      ),
              ),
            ),
            if (i < _steps.length - 1)
              AnimatedContainer(
                duration: const Duration(milliseconds: 500),
                width: 24,
                height: 2,
                margin: const EdgeInsets.symmetric(horizontal: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(2),
                  color: done ? _red : const Color(0xFFCCC8C2),
                ),
              ),
          ],
        );
      }),
    );
  }

  Widget _buildSuccess() {
    return Center(
      key: const ValueKey('success'),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedBuilder(
              animation: _successController,
              builder: (_, __) => Opacity(
                opacity: _successOpacityAnim.value,
                child: Transform.scale(
                  scale: _successScaleAnim.value,
                  child: Container(
                    width: 110,
                    height: 110,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _red.withOpacity(0.12),
                      border: Border.all(color: _red, width: 2.5),
                      boxShadow: [
                        BoxShadow(
                          color: _red.withOpacity(0.3),
                          blurRadius: 40,
                          spreadRadius: 8,
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      color: Color.fromARGB(255, 255, 255, 255),
                      size: 56,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            FadeTransition(
              opacity: _successOpacityAnim,
              child: const Text(
                'Pedido realizado!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF1A1A1A),
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 12),

            FadeTransition(
              opacity: _successOpacityAnim,
              child: const Text(
                'Seu pedido foi confirmado e\nestá sendo preparado.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Color(0xFF777777),
                  fontSize: 14,
                  height: 1.6,
                ),
              ),
            ),

            const SizedBox(height: 48),

            FadeTransition(
              opacity: _successOpacityAnim,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Color(0xFFCCCCCC),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Abrindo acompanhamento...',
                    style: TextStyle(color: Color(0xFFAAAAAA), fontSize: 13),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildParticles(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final rng = Random(42);
    const count = 18;

    return Stack(
      children: List.generate(count, (i) {
        final x = rng.nextDouble() * size.width;
        final startY = size.height * 0.35 + rng.nextDouble() * 60;
        final endY = startY - (80 + rng.nextDouble() * 200);
        final particleSize = 4.0 + rng.nextDouble() * 6;
        final delay = rng.nextDouble() * 0.4;

        final colors = [
          _red,
          const Color(0xFFFF6B6B),
          _white,
          const Color(0xFFFFB800),
        ];
        final color = colors[i % colors.length];

        final t = (_particleAnim.value - delay).clamp(0.0, 1.0);
        final opacity = t < 0.7 ? t / 0.7 : (1.0 - t) / 0.3;
        final currentY = startY + (endY - startY) * t;
        final currentX = x + sin(i * 1.3 + t * 3) * 20;

        return Positioned(
          left: currentX - particleSize / 2,
          top: currentY - particleSize / 2,
          child: Opacity(
            opacity: opacity.clamp(0.0, 1.0),
            child: Container(
              width: particleSize,
              height: particleSize,
              decoration: BoxDecoration(
                color: color,
                shape: i % 2 == 0 ? BoxShape.circle : BoxShape.rectangle,
                borderRadius: i % 2 != 0 ? BorderRadius.circular(2) : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _ProcessStep {
  final IconData icon;
  final String label;
  const _ProcessStep({required this.icon, required this.label});
}

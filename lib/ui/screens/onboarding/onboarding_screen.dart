import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';
import 'package:meatshop_mobile/services/onboarding_service.dart';
import 'package:meatshop_mobile/ui/widgets/app_surface.dart';
import 'package:meatshop_mobile/ui/widgets/buttons_widget.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({
    super.key,
    this.review = false,
    this.service = const OnboardingService(),
  });

  final OnboardingService service;

  /// Review never changes the authenticated navigation stack.
  final bool review;

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _page = 0;
  bool _saving = false;
  bool _moving = false;
  bool _completed = false;

  static const _slides = [
    (
      title: 'Bem-vindo ao MeatShop',
      description:
          'Uma plataforma para pedir nos açougues da sua região e realizar entregas. Conheça as possibilidades e escolha como participar.',
      icon: Icons.storefront_outlined,
      detail: 'Para clientes e entregadores',
    ),
    (
      title: 'Seu pedido, do seu jeito',
      description:
          'Explore produtos, promoções e avaliações. Monte seu carrinho e escolha entrega ou retirada no açougue, conforme as opções e os horários disponíveis.',
      icon: Icons.shopping_bag_outlined,
      detail: 'Entrega ou retirada',
    ),
    (
      title: 'Também é para quem entrega',
      description:
          'Complete seu cadastro e os dados do veículo. Controle sua disponibilidade, acompanhe entregas e organize seus ganhos e despesas.',
      icon: Icons.delivery_dining_outlined,
      detail: 'Cliente, entregador ou ambos',
    ),
    (
      title: 'Vamos começar?',
      description:
          'Acompanhe as etapas do pedido e, quando disponível, a localização do entregador. Crie sua conta ou entre para continuar.',
      icon: Icons.task_alt_outlined,
      detail: 'Você controla suas permissões',
    ),
  ];

  Future<void> _finish([String? destination]) async {
    if (_saving) return;
    setState(() => _saving = true);
    try {
      if (!widget.review) await widget.service.completeIntroduction();
      if (!mounted) return;
      setState(() => _completed = true);
      final navigator = Navigator.of(context);
      if (widget.review && navigator.canPop()) {
        navigator.pop();
        return;
      }
      navigator.pushNamedAndRemoveUntil(AppRoutes.welcome, (_) => false);
      if (!widget.review && destination != null) {
        navigator.pushNamed(destination);
      }
    } catch (_) {
      if (!mounted) return;
      setState(() => _saving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Não foi possível salvar. Tente novamente.'),
        ),
      );
    }
  }

  Future<void> _goTo(int page) async {
    if (_saving || _moving) return;
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.jumpToPage(page);
      return;
    }
    _moving = true;
    try {
      await _controller.animateToPage(
        page,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    } finally {
      _moving = false;
    }
  }

  void _back() {
    if (_saving) return;
    if (widget.review || _page == 0) {
      _finish();
    } else {
      _goTo(_page - 1);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final last = _page == _slides.length - 1;
    final reducedMotion = MediaQuery.disableAnimationsOf(context);
    return PopScope(
      canPop: _completed,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) _back();
      },
      child: Theme(
        data: appDarkSurfaceTheme(context),
        child: Scaffold(
          backgroundColor: AppColors.darkSurface,
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 560),
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
                      child: Row(
                        children: [
                          IconButton(
                            tooltip: widget.review
                                ? 'Fechar apresentação'
                                : 'Voltar',
                            onPressed: _saving ? null : _back,
                            icon: Icon(
                              widget.review ? Icons.close : Icons.arrow_back,
                            ),
                          ),
                          const Expanded(
                            child: Text(
                              'MEATSHOP',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                letterSpacing: 2,
                              ),
                            ),
                          ),
                          TextButton(
                            onPressed: _saving ? null : () => _finish(),
                            child: Text(
                              widget.review ? 'Fechar' : 'Pular',
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: PageView.builder(
                        controller: _controller,
                        itemCount: _slides.length,
                        onPageChanged: (page) => setState(() => _page = page),
                        itemBuilder: (context, index) {
                          final slide = _slides[index];
                          return LayoutBuilder(
                            builder: (context, constraints) =>
                                SingleChildScrollView(
                                  padding: const EdgeInsets.all(24),
                                  child: ConstrainedBox(
                                    constraints: BoxConstraints(
                                      minHeight: (constraints.maxHeight - 48)
                                          .clamp(0, double.infinity),
                                    ),
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        ExcludeSemantics(
                                          child: Container(
                                            padding: const EdgeInsets.all(28),
                                            decoration: BoxDecoration(
                                              color: AppColors.redPrimary
                                                  .withValues(alpha: 0.18),
                                              borderRadius:
                                                  BorderRadius.circular(32),
                                              border: Border.all(
                                                color: AppColors.redPrimary
                                                    .withValues(alpha: 0.5),
                                              ),
                                            ),
                                            child: Icon(
                                              slide.icon,
                                              size: 72,
                                              color: const Color(0xFFFFB4AA),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 24),
                                        Text(
                                          slide.detail,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFFFFB4AA),
                                            fontSize: 14,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                        const SizedBox(height: 12),
                                        Semantics(
                                          header: true,
                                          child: Text(
                                            slide.title,
                                            textAlign: TextAlign.center,
                                            style: const TextStyle(
                                              fontSize: 28,
                                              fontWeight: FontWeight.w800,
                                              height: 1.2,
                                            ),
                                          ),
                                        ),
                                        const SizedBox(height: 16),
                                        Text(
                                          slide.description,
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Colors.white70,
                                            fontSize: 16,
                                            height: 1.5,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                          );
                        },
                      ),
                    ),
                    Semantics(
                      liveRegion: true,
                      label: 'Etapa ${_page + 1} de ${_slides.length}',
                      child: ExcludeSemantics(
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            _slides.length,
                            (index) => AnimatedContainer(
                              duration: reducedMotion
                                  ? Duration.zero
                                  : const Duration(milliseconds: 200),
                              width: index == _page ? 24 : 8,
                              height: 8,
                              margin: const EdgeInsets.symmetric(horizontal: 4),
                              decoration: BoxDecoration(
                                color: index == _page
                                    ? const Color(0xFFFFB4AA)
                                    : Colors.white30,
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    ConstrainedBox(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.sizeOf(context).height * 0.42,
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.fromLTRB(24, 20, 24, 16),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            PrimaryButton(
                              label: last
                                  ? (widget.review ? 'CONCLUIR' : 'CRIAR CONTA')
                                  : 'PRÓXIMO',
                              isLoading: _saving,
                              onPressed: _saving
                                  ? null
                                  : () {
                                      if (last) {
                                        _finish(
                                          widget.review
                                              ? null
                                              : AppRoutes.selectRegister,
                                        );
                                      } else {
                                        _goTo(_page + 1);
                                      }
                                    },
                            ),
                            if (last && !widget.review) ...[
                              const SizedBox(height: 8),
                              TextButton(
                                onPressed: _saving
                                    ? null
                                    : () => _finish(AppRoutes.login),
                                child: const Text(
                                  'Já tenho conta',
                                  style: TextStyle(color: Colors.white),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

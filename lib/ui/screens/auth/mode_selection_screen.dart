import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meatshop_mobile/core/enums/app_profile.dart';
import 'package:meatshop_mobile/providers/auth/auth_provider.dart';
import 'package:provider/provider.dart';

class ModeSelectionPage extends StatefulWidget {
  const ModeSelectionPage({super.key});

  @override
  State<ModeSelectionPage> createState() => _ModeSelectionPageState();
}

class _ModeSelectionPageState extends State<ModeSelectionPage>
    with TickerProviderStateMixin {
  AppProfile? _tapped;
  bool _isLoading = false;

  late final AnimationController _clientZoom;
  late final AnimationController _deliveryZoom;
  late final AnimationController _fadeIn;

  @override
  void initState() {
    super.initState();

    _fadeIn = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    )..forward();

    _clientZoom = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _deliveryZoom = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
  }

  @override
  void dispose() {
    _fadeIn.dispose();
    _clientZoom.dispose();
    _deliveryZoom.dispose();
    super.dispose();
  }

  Future<void> _onTap(AppProfile profile) async {
    if (_isLoading) return;

    HapticFeedback.mediumImpact();
    setState(() {
      _tapped = profile;
      _isLoading = true;
    });

    if (profile == AppProfile.client) {
      _clientZoom.forward();
    } else {
      _deliveryZoom.forward();
    }

    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    context.read<AuthProvider>().selectActiveProfile(
      context: context,
      profile: profile,
    );
  }

  @override
  Widget build(BuildContext context) {
    final sh = MediaQuery.of(context).size.height;
    final sw = MediaQuery.of(context).size.width;
    final halfH = sh / 2;

    return Scaffold(
      backgroundColor: Colors.black,
      body: FadeTransition(
        opacity: CurvedAnimation(parent: _fadeIn, curve: Curves.easeOut),
        child: Stack(
          children: [
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              height: halfH,
              child: _HalfPanel(
                profile: AppProfile.client,
                imagePath: 'assets/images/cliente_bg.png',
                label: 'PARA\nVOCÊ',
                zoomController: _clientZoom,
                dimmed: _tapped == AppProfile.delivery,
                onTap: () => _onTap(AppProfile.client),
              ),
            ),

            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              height: halfH,
              child: _HalfPanel(
                profile: AppProfile.delivery,
                imagePath: 'assets/images/entregador_bg.png',
                label: 'PARA\nENTREGAR',
                zoomController: _deliveryZoom,
                dimmed: _tapped == AppProfile.client,
                onTap: () => _onTap(AppProfile.delivery),
              ),
            ),

            Positioned(
              top: halfH - 52,
              left: 0,
              right: 0,
              height: 104,
              child: _CenterDivider(isLoading: _isLoading, tapped: _tapped),
            ),

            if (_isLoading)
              Positioned(
                bottom: _tapped == AppProfile.client ? halfH - 80 : 40,
                left: 0,
                right: 0,
                child: Center(
                  child: _LoadingDots(
                    color: _tapped == AppProfile.client
                        ? Colors.white
                        : Colors.white,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _HalfPanel extends StatelessWidget {
  const _HalfPanel({
    required this.profile,
    required this.imagePath,
    required this.label,
    required this.zoomController,
    required this.dimmed,
    required this.onTap,
  });

  final AppProfile profile;
  final String imagePath;
  final String label;
  final AnimationController zoomController;
  final bool dimmed;
  final VoidCallback onTap;

  bool get _isClient => profile == AppProfile.client;

  @override
  Widget build(BuildContext context) {
    final zoomAnim = Tween<double>(
      begin: 1.0,
      end: 1.18,
    ).animate(CurvedAnimation(parent: zoomController, curve: Curves.easeInOut));

    final dimAnim = Tween<double>(
      begin: 1.0,
      end: 0.35,
    ).animate(CurvedAnimation(parent: zoomController, curve: Curves.easeOut));

    return GestureDetector(
      onTap: onTap,
      child: AnimatedOpacity(
        opacity: dimmed ? 0.35 : 1.0,
        duration: const Duration(milliseconds: 400),
        child: ClipRect(
          child: AnimatedBuilder(
            animation: zoomController,
            builder: (context, child) {
              return Transform.scale(
                scale: zoomAnim.value,
                alignment: _isClient
                    ? Alignment.bottomCenter
                    : Alignment.topCenter,
                child: child,
              );
            },
            child: Stack(
              fit: StackFit.expand,
              children: [
                Image.asset(
                  imagePath,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    color: _isClient
                        ? const Color(0xFF2C2C2C)
                        : const Color(0xFF1A1A1A),
                    child: Icon(
                      _isClient
                          ? Icons.person_outline
                          : Icons.delivery_dining_outlined,
                      color: Colors.white24,
                      size: 80,
                    ),
                  ),
                ),

                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: _isClient
                          ? Alignment.topCenter
                          : Alignment.bottomCenter,
                      end: _isClient
                          ? Alignment.bottomCenter
                          : Alignment.topCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.55),
                      ],
                      stops: const [0.3, 1.0],
                    ),
                  ),
                ),

                Positioned(
                  left: 28,
                  bottom: _isClient ? 36 : null,
                  top: _isClient ? null : 36,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 4,
                        height: 52,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC0392B),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        label,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          height: 1.15,
                          letterSpacing: 0.5,
                          shadows: [
                            Shadow(
                              color: Colors.black54,
                              blurRadius: 8,
                              offset: Offset(0, 2),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _CenterDivider extends StatelessWidget {
  const _CenterDivider({required this.isLoading, required this.tapped});

  final bool isLoading;
  final AppProfile? tapped;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 28),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFF424242).withOpacity(0.92),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.08), width: 1),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.4),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: isLoading
                ? const SizedBox.shrink()
                : const Column(
                    key: ValueKey('text'),
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'Como quer entrar hoje?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 0.3,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Toque em uma das opções',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white54, fontSize: 11),
                      ),
                    ],
                  ),
          ),
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  const _LoadingDots({required this.color});
  final Color color;

  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            final delay = i / 3;
            final t = ((_ctrl.value - delay) % 1.0).clamp(0.0, 1.0);
            final scale = 0.6 + 0.8 * (t < 0.5 ? t * 2 : (1 - t) * 2);
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Transform.scale(
                scale: scale,
                child: Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: widget.color,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}

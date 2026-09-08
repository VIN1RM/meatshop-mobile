import 'dart:async';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:meatshop_mobile/routes/app_routes.dart';

class AccountBlockedPage extends StatefulWidget {
  const AccountBlockedPage({super.key});

  @override
  State<AccountBlockedPage> createState() => _AccountBlockedPageState();
}

class _AccountBlockedPageState extends State<AccountBlockedPage> {
  late DateTime _blockedUntil;
  Timer? _timer;

  Duration _remaining = Duration.zero;
  bool _isExpired = false;
  bool _initialized = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    if (_initialized) return;
    _initialized = true;

    final args = ModalRoute.of(context)?.settings.arguments;

    if (args is DateTime) {
      _blockedUntil = args;
    } else {
      _blockedUntil = DateTime.now();
    }

    _updateRemaining();
    _startTimer();
  }

  void _startTimer() {
    _timer?.cancel();

    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _updateRemaining();
    });
  }

  void _updateRemaining() {
    final remaining = _blockedUntil.difference(DateTime.now());

    if (!mounted) return;

    setState(() {
      if (remaining.isNegative || remaining == Duration.zero) {
        _remaining = Duration.zero;
        _isExpired = true;
        _timer?.cancel();
      } else {
        _remaining = remaining;
        _isExpired = false;
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String get _formattedCountdown {
    final minutes = _remaining.inMinutes
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    final seconds = _remaining.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');

    return '$minutes:$seconds';
  }

  void _goToLogin() {
    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil(AppRoutes.login, (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return Scaffold(
      backgroundColor: _BlockedColors.grey400,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
            colors: [
              _BlockedColors.grey400,
              _BlockedColors.grey400,
              _BlockedColors.red900,
            ],
            stops: [0.0, 0.58, 1.0],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned(
                top: -120,
                right: -90,
                child: _BlurredCircle(
                  size: 240,
                  color: _BlockedColors.red700.withAlpha(70),
                ),
              ),
              Positioned(
                bottom: -130,
                left: -100,
                child: _BlurredCircle(
                  size: 280,
                  color: _BlockedColors.red900.withAlpha(80),
                ),
              ),
              LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: constraints.maxWidth < 360 ? 18 : 24,
                      vertical: 24,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight - 48,
                          maxWidth: 420,
                        ),
                        child: Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const _AppLogo(),
                              SizedBox(
                                height: (size.height * 0.03).clamp(18.0, 28.0),
                              ),
                              _BlockedCard(
                                countdown: _formattedCountdown,
                                isExpired: _isExpired,
                                onReturnToLogin: _goToLogin,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _BlockedCard extends StatelessWidget {
  const _BlockedCard({
    required this.countdown,
    required this.isExpired,
    required this.onReturnToLogin,
  });

  final String countdown;
  final bool isExpired;
  final VoidCallback onReturnToLogin;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(24, 28, 24, 24),
      decoration: BoxDecoration(
        color: _BlockedColors.grey300.withAlpha(245),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: _BlockedColors.white.withAlpha(18), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(90),
            blurRadius: 32,
            offset: const Offset(0, 18),
          ),
        ],
      ),
      child: Column(
        children: [
          const _BlockedIcon(),
          const SizedBox(height: 24),
          const _BlockedTitle(),
          const SizedBox(height: 12),
          const _BlockedDescription(),
          const SizedBox(height: 28),
          if (!isExpired) _CountdownDisplay(countdown: countdown),
          if (isExpired) _ReturnToLoginContent(onPressed: onReturnToLogin),
          const SizedBox(height: 24),
          const _SecurityInfoBox(),
        ],
      ),
    );
  }
}

class _AppLogo extends StatelessWidget {
  const _AppLogo();

  @override
  Widget build(BuildContext context) {
    return Image.asset(
      'assets/images/logo.png',
      width: 150,
      height: 150,
      fit: BoxFit.contain,
      errorBuilder: (_, _, _) {
        return Container(
          width: 104,
          height: 104,
          decoration: const BoxDecoration(
            color: _BlockedColors.redSurface,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.storefront_outlined,
            color: _BlockedColors.red700,
            size: 48,
          ),
        );
      },
    );
  }
}

class _BlockedIcon extends StatelessWidget {
  const _BlockedIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 82,
      height: 82,
      decoration: BoxDecoration(
        color: _BlockedColors.redSurface,
        shape: BoxShape.circle,
        border: Border.all(
          color: _BlockedColors.red500.withAlpha(90),
          width: 1.5,
        ),
      ),
      child: const Icon(
        Icons.lock_clock_outlined,
        color: _BlockedColors.red700,
        size: 40,
      ),
    );
  }
}

class _BlockedTitle extends StatelessWidget {
  const _BlockedTitle();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Conta temporariamente bloqueada',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _BlockedColors.white,
        fontSize: 22,
        fontWeight: FontWeight.w800,
        height: 1.2,
      ),
    );
  }
}

class _BlockedDescription extends StatelessWidget {
  const _BlockedDescription();

  @override
  Widget build(BuildContext context) {
    return const Text(
      'Detectamos muitas tentativas de login inválidas. '
      'Por segurança, aguarde o tempo abaixo para tentar novamente.',
      textAlign: TextAlign.center,
      style: TextStyle(
        color: _BlockedColors.grey100,
        fontSize: 14,
        height: 1.5,
        fontWeight: FontWeight.w400,
      ),
    );
  }
}

class _CountdownDisplay extends StatelessWidget {
  const _CountdownDisplay({required this.countdown});

  final String countdown;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const Text(
          'Tempo restante',
          style: TextStyle(
            color: _BlockedColors.grey100,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 18),
          decoration: BoxDecoration(
            color: _BlockedColors.grey400,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color.fromARGB(255, 255, 255, 255),
              width: 1.4,
            ),
          ),
          child: Text(
            countdown,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: _BlockedColors.white,
              fontSize: 42,
              fontWeight: FontWeight.w900,
              letterSpacing: 5,
              fontFeatures: [FontFeature.tabularFigures()],
            ),
          ),
        ),
      ],
    );
  }
}

class _ReturnToLoginContent extends StatelessWidget {
  const _ReturnToLoginContent({required this.onPressed});

  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: const Color(0xFFDCFCE7),
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                color: Color(0xFF16A34A),
                size: 20,
              ),
              SizedBox(width: 8),
              Flexible(
                child: Text(
                  'O bloqueio foi encerrado.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Color(0xFF166534),
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: onPressed,
            style: ElevatedButton.styleFrom(
              backgroundColor: _BlockedColors.red700,
              foregroundColor: _BlockedColors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: const Text(
              'VOLTAR AO LOGIN',
              style: TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 15,
                letterSpacing: 0.4,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SecurityInfoBox extends StatelessWidget {
  const _SecurityInfoBox();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: _BlockedColors.grey400.withAlpha(170),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _BlockedColors.white.withAlpha(16)),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.shield_outlined,
            color: Color.fromARGB(255, 255, 255, 255),
            size: 20,
          ),
          SizedBox(width: 10),
          Expanded(
            child: Text(
              'Essa proteção ajuda a evitar acessos indevidos à sua conta.',
              style: TextStyle(
                color: _BlockedColors.grey100,
                fontSize: 12.5,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _BlurredCircle extends StatelessWidget {
  const _BlurredCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(sigmaX: 50, sigmaY: 50),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
    );
  }
}

class _BlockedColors {
  const _BlockedColors._();

  static const Color white = Color(0xFFFFFFFF);
  static const Color grey100 = Color(0xFFB8B8B8);
  static const Color grey300 = Color(0xFF525252);
  static const Color grey400 = Color(0xFF2A2A2A);

  static const Color red900 = Color(0xFF932215);
  static const Color red700 = Color(0xFFBE2C1B);
  static const Color red500 = Color(0xFFE1402D);
  static const Color redSurface = Color(0xFFFDECEA);
}

import 'package:flutter/material.dart';
import 'app_header.dart';
import 'app_surface.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({
    super.key,
    required this.title,
    required this.description,
    required this.body,
    this.action,
    this.dark = false,
    this.surfaceColor = const Color(0xFFF5F5F5),
  });
  final String title;
  final String description;
  final Widget body;
  final Widget? action;
  final bool dark;
  final Color surfaceColor;

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: const Color(0xFF2E2E2E),
    bottomNavigationBar: action == null ? null : _action(context),
    body: Stack(
      children: [
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          height: 130,
          child: Image.asset(
            'assets/images/background.png',
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => const SizedBox.shrink(),
          ),
        ),
        SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const AppHeader(showBack: true),
              Expanded(child: _content()),
            ],
          ),
        ),
      ],
    ),
  );

  Widget _action(BuildContext context) => SafeArea(
    top: false,
    child: Padding(
      padding: EdgeInsets.fromLTRB(
        16,
        12,
        16,
        16 + MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 688),
          child: action!,
        ),
      ),
    ),
  );

  Widget _content() => LayoutBuilder(
    builder: (context, constraints) => Align(
      alignment: Alignment.topCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (constraints.maxHeight > 280) _heading(),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Theme(
                    data: dark
                        ? appDarkSurfaceTheme(context)
                        : appSurfaceTheme(context),
                    child: ColoredBox(color: surfaceColor, child: body),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    ),
  );

  Widget _heading() => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 22,
            fontWeight: FontWeight.w900,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          style: const TextStyle(
            color: Colors.white70,
            fontSize: 13,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}

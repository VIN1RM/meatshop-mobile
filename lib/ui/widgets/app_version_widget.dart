import 'package:flutter/material.dart';
import 'package:meatshop_mobile/services/version_service.dart';

class AppVersionText extends StatelessWidget {
  final TextStyle? style;

  const AppVersionText({super.key, this.style});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<String>(
      future: VersionService().getAppVersion(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox.shrink();

        return Text(
          'Versão: ${snapshot.data!}',
          textAlign: TextAlign.center,
          style:
              style ??
              const TextStyle(
                fontSize: 12,
                color: Colors.white,
                fontWeight: FontWeight.w400,
              ),
        );
      },
    );
  }
}

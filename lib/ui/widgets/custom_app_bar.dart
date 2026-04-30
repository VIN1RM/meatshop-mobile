import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/widgets/curved_app_bar.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;
  final Widget? flexibleSpace;
  final bool showCurve;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.leading,
    this.flexibleSpace,
    this.showCurve = true,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 20);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppBar(title: Text(title), actions: actions, leading: leading),
        if (showCurve) const AppBarCurved(),
      ],
    );
  }
}

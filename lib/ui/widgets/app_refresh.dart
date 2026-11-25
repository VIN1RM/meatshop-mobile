import 'package:flutter/material.dart';
import '../../core/utils/custom_snackbar.dart';

/// Keeps refresh feedback consistent, including empty and error states.
class AppRefresh extends StatefulWidget {
  const AppRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.scrollable = true,
    this.error,
  });
  final Future<void> Function() onRefresh;
  final Widget child;
  final bool scrollable;
  final String? Function()? error;
  @override
  State<AppRefresh> createState() => _AppRefreshState();
}

class _AppRefreshState extends State<AppRefresh> {
  Future<void>? _pending;
  Future<void> _refresh() =>
      _pending ??= _run().whenComplete(() => _pending = null);
  Future<void> _run() async {
    try {
      await widget.onRefresh();
      if (!mounted) return;
      final error = widget.error?.call();
      if (error != null) _showError(error);
    } catch (_) {
      if (mounted) {
        _showError('Não foi possível atualizar. Tente novamente.');
      }
    }
  }

  void _showError(String message) => CustomSnackBar.show(
    SnackBarType.error,
    message,
    context: context,
    action: SnackBarAction(label: 'Tentar novamente', onPressed: _refresh),
  );
  @override
  Widget build(BuildContext context) => RefreshIndicator(
    color: const Color(0xFFC0392B),
    backgroundColor: const Color(0xFFF5F5F5),
    strokeWidth: 2.5,
    onRefresh: _refresh,
    child: widget.scrollable
        ? widget.child
        : CustomScrollView(
            physics: const BouncingScrollPhysics(
              parent: AlwaysScrollableScrollPhysics(),
            ),
            slivers: [
              SliverFillRemaining(hasScrollBody: false, child: widget.child),
            ],
          ),
  );
}

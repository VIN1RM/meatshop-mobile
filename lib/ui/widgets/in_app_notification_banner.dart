import 'dart:async';

import 'package:flutter/material.dart';
import 'package:meatshop_mobile/ui/colors/app_colors.dart';

class InAppNotificationBanner {
  static OverlayEntry? _currentEntry;
  static Timer? _timer;

  static void show({
    required BuildContext context,
    required String title,
    required String message,
    required String type,
    VoidCallback? onTap,
    Duration duration = const Duration(seconds: 4),
  }) {
    _timer?.cancel();
    _currentEntry?.remove();
    _currentEntry = null;

    final overlay =
        Overlay.maybeOf(context, rootOverlay: true) ??
        Navigator.maybeOf(context, rootNavigator: true)?.overlay;

    if (overlay == null) {
      debugPrint('[InAppNotificationBanner] Nenhum Overlay encontrado.');
      return;
    }

    late OverlayEntry entry;

    entry = OverlayEntry(
      builder: (_) {
        return _InAppNotificationBannerWidget(
          title: title,
          message: message,
          type: type,
          onTap: () {
            _dismiss();
            onTap?.call();
          },
          onClose: _dismiss,
        );
      },
    );

    _currentEntry = entry;
    overlay.insert(entry);

    _timer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _timer?.cancel();
    _timer = null;

    _currentEntry?.remove();
    _currentEntry = null;
  }
}

class _InAppNotificationBannerWidget extends StatefulWidget {
  final String title;
  final String message;
  final String type;
  final VoidCallback? onTap;
  final VoidCallback onClose;

  const _InAppNotificationBannerWidget({
    required this.title,
    required this.message,
    required this.type,
    required this.onTap,
    required this.onClose,
  });

  @override
  State<_InAppNotificationBannerWidget> createState() =>
      _InAppNotificationBannerWidgetState();
}

class _InAppNotificationBannerWidgetState
    extends State<_InAppNotificationBannerWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 280),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _typeColor {
    switch (widget.type.toUpperCase()) {
      case 'ORDER':
        return AppColors.red500;
      case 'DELIVERY':
        return AppColors.red700;
      case 'PROMOTION':
        return AppColors.red300;
      case 'SYSTEM':
      default:
        return AppColors.red900;
    }
  }

  IconData get _typeIcon {
    switch (widget.type.toUpperCase()) {
      case 'ORDER':
        return Icons.shopping_bag_outlined;
      case 'DELIVERY':
        return Icons.delivery_dining_outlined;
      case 'PROMOTION':
        return Icons.local_offer_outlined;
      case 'SYSTEM':
      default:
        return Icons.notifications_outlined;
    }
  }

  String get _typeLabel {
    switch (widget.type.toUpperCase()) {
      case 'ORDER':
        return 'Pedido';
      case 'DELIVERY':
        return 'Entrega';
      case 'PROMOTION':
        return 'Promoção';
      case 'SYSTEM':
      default:
        return 'Notificação';
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPadding = MediaQuery.of(context).padding.top;

    return Positioned(
      top: topPadding + 12,
      left: 16,
      right: 16,
      child: SafeArea(
        bottom: false,
        child: SlideTransition(
          position: _slideAnimation,
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Material(
              color: Colors.transparent,
              child: GestureDetector(
                onTap: widget.onTap,
                child: Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(18),
                    border: Border.all(
                      color: _typeColor.withValues(alpha: 0.18),
                      width: 1,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.16),
                        blurRadius: 22,
                        offset: const Offset(0, 8),
                      ),
                    ],
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppColors.redSurface,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Icon(_typeIcon, color: _typeColor, size: 24),
                      ),

                      const SizedBox(width: 12),

                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 3,
                              ),
                              decoration: BoxDecoration(
                                color: _typeColor.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                _typeLabel,
                                style: TextStyle(
                                  color: _typeColor,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),

                            const SizedBox(height: 6),

                            Text(
                              widget.title.isEmpty ? 'MeatShop' : widget.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.grey400,
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                              ),
                            ),

                            const SizedBox(height: 3),

                            Text(
                              widget.message,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: AppColors.grey300,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                height: 1.25,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 8),

                      GestureDetector(
                        onTap: widget.onClose,
                        child: Container(
                          width: 28,
                          height: 28,
                          decoration: BoxDecoration(
                            color: AppColors.grey100.withValues(alpha: 0.18),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.close,
                            color: AppColors.grey300,
                            size: 17,
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
      ),
    );
  }
}

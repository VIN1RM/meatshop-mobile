import 'package:flutter/material.dart';
import '../../services/notification_service.dart';
import 'package:provider/provider.dart';
import '../../core/utils/payment_return_intent.dart';
import '../../providers/auth/auth_provider.dart';
import '../screens/fallback/order_processing_screen.dart';
import '../screens/orders/orders_screen.dart';

class PaymentReturnListener extends StatefulWidget {
  const PaymentReturnListener({
    super.key,
    required this.child,
    required this.navigatorKey,
  });
  final Widget child;
  final GlobalKey<NavigatorState> navigatorKey;
  @override
  State<PaymentReturnListener> createState() => _PaymentReturnListenerState();
}

class _PaymentReturnListenerState extends State<PaymentReturnListener> {
  AuthProvider? _auth;
  bool _scheduled = false;
  @override
  void initState() {
    super.initState();
    PaymentReturnIntent.instance.addListener(_resume);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final auth = context.read<AuthProvider>();
    if (auth != _auth) {
      _auth?.removeListener(_resume);
      _auth = auth;
      auth.addListener(_resume);
    }
    _resume();
  }

  void _resume() {
    if (_auth?.isAuthenticated == true && _auth?.activeProfile != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) NotificationService.instance.resumePending();
      });
    }
    if (_scheduled ||
        !PaymentReturnIntent.instance.pending ||
        !(_auth?.isAuthenticated ?? false)) {
      return;
    }
    _scheduled = true;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _scheduled = false;
      if (!mounted || !(_auth?.isAuthenticated ?? false)) return;
      final navigator = widget.navigatorKey.currentState;
      if (navigator == null) return;
      final orders = PaymentReturnIntent.instance.take();
      if (orders == null) return;
      navigator.push(
        MaterialPageRoute(
          builder: (_) => orders.isEmpty
              ? const Scaffold(body: OrdersScreen())
              : OrderProcessingScreen(orderIds: orders),
        ),
      );
    });
  }

  @override
  void dispose() {
    _auth?.removeListener(_resume);
    PaymentReturnIntent.instance.removeListener(_resume);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}

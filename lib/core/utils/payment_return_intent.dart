import 'package:flutter/foundation.dart';

final class PaymentReturnIntent extends ChangeNotifier {
  static final instance = PaymentReturnIntent();
  List<String>? _orders;
  bool get pending => _orders != null;
  static bool accepts(Uri uri) =>
      (uri.scheme == 'meatshop' && uri.host == 'payments') ||
      (uri.scheme.isEmpty && uri.path == '/payments');
  void remember(Uri uri) {
    if (!accepts(uri)) return;
    final id = uri.queryParameters['order_id'];
    _orders = id != null && RegExp(r'^[1-9][0-9]{0,11}$').hasMatch(id)
        ? [id]
        : [];
    notifyListeners();
  }

  List<String>? take() {
    final result = _orders;
    _orders = null;
    return result;
  }
}

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/models/payment_model.dart';
import 'package:meatshop_mobile/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentService? service})
    : _service = service ?? PaymentService();

  final PaymentService _service;

  List<PaymentMethodModel> _cards = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PaymentMethodModel>>? _sub;

  List<PaymentMethodModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void init() {
    _isLoading = true;
    _error = null;
    notifyListeners();

    _sub = _service.watchCards().listen(
      (list) {
        _cards = list;
        _isLoading = false;
        _error = null;
        notifyListeners();
      },
      onError: (e) {
        _isLoading = false;
        _error = 'Erro ao carregar cartões: $e';
        notifyListeners();
      },
    );
  }

  void clear() {
    _sub?.cancel();
    _cards = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }

  Future<void> addCard(PaymentMethodModel card) async {
    _setLoading(true);
    try {
      await _service.addCard(card);
    } catch (e) {
      _error = 'Erro ao adicionar cartão: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setDefault(String cardId) async {
    _setLoading(true);
    try {
      await _service.setDefault(cardId);
    } catch (e) {
      _error = 'Erro ao definir padrão: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeCard(String cardId) async {
    _setLoading(true);
    try {
      await _service.removeCard(cardId);
    } catch (e) {
      _error = 'Erro ao remover cartão: $e';
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool v) {
    _isLoading = v;
    notifyListeners();
  }
}

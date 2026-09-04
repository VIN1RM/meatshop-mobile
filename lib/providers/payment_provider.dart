import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/data/repositories/payment_repository.dart';
import 'package:meatshop_mobile/models/payment_model.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({required PaymentRepository repository})
    : _repository = repository;

  final PaymentRepository _repository;

  List<PaymentMethodModel> _cards = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PaymentMethodModel>>? _sub;

  List<PaymentMethodModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get requiresTokenizedCard => true;

  void init() {
    _sub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();
    unawaited(_load(_repository));
  }

  Future<void> _load(PaymentRepository repository) async {
    try {
      _cards = await repository.list();
    } catch (error) {
      _error = 'Erro ao carregar cartões: $error';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addTokenizedCard(String token, {required bool isDefault}) async {
    _setLoading(true);
    try {
      await _repository.saveTokenizedCard(token, isDefault: isDefault);
      _cards = await _repository.list();
    } catch (error) {
      _error = 'Erro ao adicionar cartão: $error';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCard(PaymentMethodModel card) async {
    _error = 'Cadastre o cartão no checkout seguro do Mercado Pago.';
    notifyListeners();
  }

  Future<void> setDefault(String cardId) async {
    _setLoading(true);
    try {
      await _repository.setDefault(cardId);
      _cards = await _repository.list();
    } catch (error) {
      _error = 'Erro ao definir padrão: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeCard(String cardId) async {
    _setLoading(true);
    try {
      await _repository.remove(cardId);
      _cards = await _repository.list();
    } catch (error) {
      _error = 'Erro ao remover cartão: $error';
    } finally {
      _setLoading(false);
    }
  }

  void clear() {
    _sub?.cancel();
    _cards = [];
    _isLoading = false;
    _error = null;
    notifyListeners();
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  @override
  void dispose() {
    _sub?.cancel();
    super.dispose();
  }
}

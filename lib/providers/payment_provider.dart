import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:meatshop_mobile/data/repositories/payment_repository.dart';
import 'package:meatshop_mobile/models/payment_model.dart';
import 'package:meatshop_mobile/services/payment_service.dart';

class PaymentProvider extends ChangeNotifier {
  PaymentProvider({PaymentRepository? repository, PaymentService? service})
    : _repository = repository,
      _service = service ?? (repository == null ? PaymentService() : null);

  final PaymentRepository? _repository;
  final PaymentService? _service;

  List<PaymentMethodModel> _cards = [];
  bool _isLoading = false;
  String? _error;
  StreamSubscription<List<PaymentMethodModel>>? _sub;

  List<PaymentMethodModel> get cards => _cards;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get requiresTokenizedCard => _repository != null;

  void init() {
    _sub?.cancel();
    _isLoading = true;
    _error = null;
    notifyListeners();
    final repository = _repository;
    if (repository != null) {
      unawaited(_load(repository));
      return;
    }
    _sub = _service!.watchCards().listen(
      (list) {
        _cards = list;
        _isLoading = false;
        notifyListeners();
      },
      onError: (Object error) {
        _isLoading = false;
        _error = 'Erro ao carregar cartões: $error';
        notifyListeners();
      },
    );
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
    final repository = _repository;
    if (repository == null) {
      throw StateError('Tokenização disponível somente com o backend.');
    }
    _setLoading(true);
    try {
      await repository.saveTokenizedCard(token, isDefault: isDefault);
      _cards = await repository.list();
    } catch (error) {
      _error = 'Erro ao adicionar cartão: $error';
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> addCard(PaymentMethodModel card) async {
    if (_repository != null) {
      _error = 'Cadastre o cartão no checkout seguro do Mercado Pago.';
      notifyListeners();
      return;
    }
    _setLoading(true);
    try {
      await _service!.addCard(card);
    } catch (error) {
      _error = 'Erro ao adicionar cartão: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> setDefault(String cardId) async {
    _setLoading(true);
    try {
      final repository = _repository;
      if (repository != null) {
        await repository.setDefault(cardId);
        _cards = await repository.list();
      } else {
        await _service!.setDefault(cardId);
      }
    } catch (error) {
      _error = 'Erro ao definir padrão: $error';
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeCard(String cardId) async {
    _setLoading(true);
    try {
      final repository = _repository;
      if (repository != null) {
        await repository.remove(cardId);
        _cards = await repository.list();
      } else {
        await _service!.removeCard(cardId);
      }
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

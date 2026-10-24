import '../../models/delivery_expense_model.dart';

abstract interface class DeliveryExpenseRepository {
  Future<DeliveryExpensePage> list({
    required String from,
    required String to,
    int page = 1,
  });
  Future<void> save({
    int? id,
    required String category,
    required String description,
    required double amount,
    required String date,
  });
  Future<void> remove(int id);
}

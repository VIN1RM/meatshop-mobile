import '../../data/repositories/delivery_expense_repository.dart';
import '../../models/delivery_expense_model.dart';
import '../http/api_client.dart';

class HttpDeliveryExpenseRepository implements DeliveryExpenseRepository {
  HttpDeliveryExpenseRepository(this.client);
  final ApiClient client;
  @override
  Future<DeliveryExpensePage> list({
    required String from,
    required String to,
    int page = 1,
  }) => client.get(
    '/delivery/expenses',
    query: {'from': from, 'to': to, 'page': page, 'limit': 30},
    decode: (json) {
      final value = json as Map;
      return DeliveryExpensePage(
        items: (value['data'] as List)
            .map(
              (row) => DeliveryExpenseModel.fromJson(
                Map<String, dynamic>.from(row as Map),
              ),
            )
            .toList(),
        total: (value['total'] as num).toInt(),
        totalAmount: double.parse('${value['total_amount']}'),
      );
    },
  );
  @override
  Future<void> save({
    int? id,
    required String category,
    required String description,
    required double amount,
    required String date,
  }) {
    final body = {
      'category': category,
      'description': description.trim(),
      'amount': amount,
      'incurred_on': date,
    };
    return id == null
        ? client.post('/delivery/expenses', body: body, decode: (_) {})
        : client.patch('/delivery/expenses/$id', body: body, decode: (_) {});
  }

  @override
  Future<void> remove(int id) =>
      client.delete('/delivery/expenses/$id', decode: (_) {});
}

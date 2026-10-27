class DeliveryExpenseModel {
  const DeliveryExpenseModel({
    required this.id,
    required this.category,
    required this.description,
    required this.amount,
    required this.date,
  });
  factory DeliveryExpenseModel.fromJson(Map<String, dynamic> json) =>
      DeliveryExpenseModel(
        id: (json['id'] as num).toInt(),
        category: json['category'] as String,
        description: json['description'] as String,
        amount: double.parse('${json['amount']}'),
        date: DateTime.parse('${json['incurred_on']}'),
      );
  final int id;
  final String category;
  final String description;
  final double amount;
  final DateTime date;
}

class DeliveryExpensePage {
  const DeliveryExpensePage({
    required this.items,
    required this.total,
    required this.totalAmount,
  });
  final List<DeliveryExpenseModel> items;
  final int total;
  final double totalAmount;
}

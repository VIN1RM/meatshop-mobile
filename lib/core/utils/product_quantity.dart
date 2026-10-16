final class ProductQuantity {
  static String unit(String value) => value.trim().toUpperCase();
  static bool isWeight(String value) => {'KG', 'G'}.contains(unit(value));
  static double step(String value) => switch (unit(value)) {
    'KG' => 0.05,
    'G' => 50,
    _ => 1,
  };
  static double parse(String value) =>
      double.tryParse(value.replaceAll(',', '.')) ?? 0;
  static double inUnit(
    double amount,
    String unitOfMeasure, {
    required bool grams,
  }) => switch (unit(unitOfMeasure)) {
    'KG' => grams ? amount / 1000 : amount,
    'G' => grams ? amount : amount * 1000,
    _ => amount,
  };
  static bool valid(double amount, String unitOfMeasure) =>
      amount.isFinite &&
      amount > 0 &&
      (isWeight(unitOfMeasure) || amount == amount.truncateToDouble());
}

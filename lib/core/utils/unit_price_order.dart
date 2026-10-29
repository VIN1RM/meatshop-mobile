import '../../models/unit_model.dart';

int compareUnitPrice(UnitModel a, UnitModel b, {bool descending = false}) {
  final first = a.averagePricePerKg;
  final second = b.averagePricePerKg;
  if (first == null && second != null) return 1;
  if (first != null && second == null) return -1;
  final comparison = first == null || second == null
      ? 0
      : first.compareTo(second);
  if (comparison != 0) return descending ? -comparison : comparison;
  final name = a.name.compareTo(b.name);
  return name != 0 ? name : a.id.compareTo(b.id);
}

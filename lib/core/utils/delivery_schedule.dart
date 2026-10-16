import '../../models/business_hours_model.dart';

final class DeliverySchedule {
  static List<String> available(
    DateTime date,
    List<List<BusinessHoursModel>> units,
  ) {
    if (units.isEmpty) return [];
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    final weekday = days[date.weekday - 1];
    final hours = units
        .map(
          (values) => values
              .where((h) => h.weekday.toLowerCase() == weekday && h.isOpen)
              .toList(),
        )
        .toList();
    if (hours.any((values) => values.isEmpty)) return [];
    int minutes(String time) {
      final parts = time.split(':');
      return (int.tryParse(parts.first) ?? 0) * 60 +
          (int.tryParse(parts.elementAtOrNull(1) ?? '') ?? 0);
    }

    return [
      for (var value = 0; value < 24 * 60; value += 30)
        if (hours.every(
          (options) => options.any((h) {
            final open = minutes(h.openingTime), close = minutes(h.closingTime);
            return close > open
                ? value >= open && value + 30 <= close
                : value >= open || value + 30 <= close;
          }),
        ))
          '${(value ~/ 60).toString().padLeft(2, '0')}:${(value % 60).toString().padLeft(2, '0')}',
    ];
  }
}

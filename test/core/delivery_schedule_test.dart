import 'package:flutter_test/flutter_test.dart';
import 'package:meatshop_mobile/core/utils/delivery_schedule.dart';
import 'package:meatshop_mobile/core/utils/business_clock.dart';
import 'package:meatshop_mobile/models/business_hours_model.dart';

void main() {
  const early = BusinessHoursModel(
    weekday: 'monday',
    openingTime: '08:00',
    closingTime: '12:00',
    isOpen: true,
  );
  const late = BusinessHoursModel(
    weekday: 'monday',
    openingTime: '10:00',
    closingTime: '18:00',
    isOpen: true,
  );
  test('only offers times when all selected units are open', () {
    expect(
      DeliverySchedule.available(DateTime(2026, 10, 19), [
        [early],
        [late],
      ]),
      ['10:00', '10:30', '11:00', '11:30'],
    );
    expect(
      DeliverySchedule.available(DateTime(2026, 10, 20), [
        [early],
        [late],
      ]),
      isEmpty,
    );
  });
  test('does not invent hours for an unconfigured unit', () {
    expect(
      DeliverySchedule.available(DateTime(2026, 10, 19), [
        [early],
        [],
      ]),
      isEmpty,
    );
  });
  test(
    'schedules and groups dates in Sao Paulo regardless of device timezone',
    () {
      expect(BusinessClock.local(DateTime.utc(2026, 10, 19, 2)).day, 18);
      expect(
        BusinessClock.scheduled(DateTime(2026, 10, 19), 10, 30).toUtc(),
        DateTime.utc(2026, 10, 19, 13, 30),
      );
    },
  );
}

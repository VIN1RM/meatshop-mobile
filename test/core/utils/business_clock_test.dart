import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:meatshop_mobile/core/utils/business_clock.dart';

void main() {
  setUpAll(() => initializeDateFormatting('pt_BR'));

  test('UTC and explicit offsets display the same Brasilia time', () {
    final utc = DateTime.parse('2026-11-25T00:22:00Z');
    final offset = DateTime.parse('2026-11-24T21:22:00-03:00');
    expect(BusinessClock.format(utc, 'dd/MM/yyyy HH:mm'), '24/11/2026 21:22');
    expect(BusinessClock.format(offset, 'HH:mm'), '21:22');
    expect(BusinessClock.local(utc).isAtSameMomentAs(utc), isTrue);
  });

  test('message grouping uses Brasilia midnight, including year changes', () {
    final before = DateTime.parse('2027-01-01T02:59:00Z');
    final after = DateTime.parse('2027-01-01T03:00:00Z');
    expect(BusinessClock.sameDay(before, after), isFalse);
    expect(BusinessClock.daysBetween(before, after), 1);
    expect(BusinessClock.format(before, 'dd/MM/yyyy'), '31/12/2026');
    expect(BusinessClock.format(after, 'HH:mm'), '00:00');
  });

  test('UTC midnight does not split a Brasilia conversation day', () {
    expect(
      BusinessClock.sameDay(
        DateTime.parse('2026-11-24T23:59:00Z'),
        DateTime.parse('2026-11-25T00:01:00Z'),
      ),
      isTrue,
    );
  });

  test('scheduling preserves the selected Brasilia hour on the API', () {
    final date = BusinessClock.scheduled(DateTime(2026, 11, 24), 21, 22);
    expect(date.toUtc().toIso8601String(), '2026-11-25T00:22:00.000Z');
  });
}

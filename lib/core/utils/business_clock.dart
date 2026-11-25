import 'package:intl/intl.dart';
import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

final class BusinessClock {
  static final tz.Location _location = _initialize();
  static tz.Location _initialize() {
    data.initializeTimeZones();
    return tz.getLocation('America/Sao_Paulo');
  }

  static DateTime local(DateTime value) => tz.TZDateTime.from(value, _location);

  static String format(DateTime value, String pattern) =>
      DateFormat(pattern, 'pt_BR').format(local(value));

  static DateTime calendarDay(DateTime value) {
    final date = local(value);
    return DateTime.utc(date.year, date.month, date.day);
  }

  static bool sameDay(DateTime a, DateTime b) =>
      calendarDay(a) == calendarDay(b);

  static int daysBetween(DateTime from, DateTime to) =>
      calendarDay(to).difference(calendarDay(from)).inDays;

  static DateTime now() => local(DateTime.now());
  static DateTime scheduled(DateTime date, int hour, int minute) =>
      tz.TZDateTime(_location, date.year, date.month, date.day, hour, minute);
}

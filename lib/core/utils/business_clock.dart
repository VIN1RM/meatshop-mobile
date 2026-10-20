import 'package:timezone/data/latest.dart' as data;
import 'package:timezone/timezone.dart' as tz;

final class BusinessClock {
  static final tz.Location _location = _initialize();
  static tz.Location _initialize() {
    data.initializeTimeZones();
    return tz.getLocation('America/Sao_Paulo');
  }

  static DateTime local(DateTime value) => tz.TZDateTime.from(value, _location);
  static DateTime now() => local(DateTime.now());
  static DateTime scheduled(DateTime date, int hour, int minute) =>
      tz.TZDateTime(_location, date.year, date.month, date.day, hour, minute);
}

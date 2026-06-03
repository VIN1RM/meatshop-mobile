class BusinessHoursModel {
  final String weekday;
  final String openingTime;
  final String closingTime;
  final bool isOpen;

  const BusinessHoursModel({
    required this.weekday,
    required this.openingTime,
    required this.closingTime,
    required this.isOpen,
  });

  factory BusinessHoursModel.fromMap(Map<String, dynamic> map) {
    return BusinessHoursModel(
      weekday: map['weekday'] as String? ?? '',
      openingTime: map['opening_time'] as String? ?? '00:00',
      closingTime: map['closing_time'] as String? ?? '00:00',
      isOpen: map['is_open'] as bool? ?? false,
    );
  }

  bool get isOpenNow {
    if (!isOpen) return false;
    final now = DateTime.now();
    final open = _parseTime(openingTime, now);
    final close = _parseTime(closingTime, now);
    return now.isAfter(open) && now.isBefore(close);
  }

  DateTime _parseTime(String time, DateTime ref) {
    final parts = time.split(':');
    return DateTime(
      ref.year,
      ref.month,
      ref.day,
      int.tryParse(parts[0]) ?? 0,
      int.tryParse(parts[1]) ?? 0,
    );
  }

  static String todayWeekday() {
    const days = [
      'monday',
      'tuesday',
      'wednesday',
      'thursday',
      'friday',
      'saturday',
      'sunday',
    ];
    return days[DateTime.now().weekday - 1];
  }
}

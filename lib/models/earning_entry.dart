class EarningEntry {
  final String label;
  final double amount;
  final String time;
  final bool isNew;

  const EarningEntry({
    required this.label,
    required this.amount,
    required this.time,
    this.isNew = false,
  });
}

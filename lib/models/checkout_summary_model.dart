class CheckoutSummaryModel {
  final String addressId;
  final bool isScheduled;
  final DateTime? scheduledDate;
  final String? scheduledTime;
  final String paymentMethod;
  final String? savedCardId;
  final String? cardBrand;

  const CheckoutSummaryModel({
    required this.addressId,
    required this.isScheduled,
    this.scheduledDate,
    this.scheduledTime,
    required this.paymentMethod,
    this.savedCardId,
    this.cardBrand,
  });
}
